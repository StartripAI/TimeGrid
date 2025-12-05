//
//  MigrationManager.swift
//  时光格 V2.0 - 数据迁移管理
//
//  功能：
//  - 本地游客数据迁移到云端
//  - 冲突处理
//  - 迁移进度跟踪
//

import Foundation
import Combine

@MainActor
class MigrationManager: ObservableObject {
    // MARK: - Singleton
    static let shared = MigrationManager()
    
    // MARK: - Published Properties
    @Published var isMigrating = false
    @Published var progress: MigrationProgress = .idle
    @Published var error: MigrationError?
    
    // MARK: - Private Properties
    private let localDataKey = "YiGe_LocalRecords_V2"
    private let migrationCompleteKey = "YiGe_MigrationComplete"
    
    // MARK: - Init
    private init() {}
    
    // MARK: - ============================================
    // MARK: - 迁移状态
    // MARK: - ============================================
    
    enum MigrationProgress: Equatable {
        case idle
        case preparing
        case uploading(current: Int, total: Int)
        case processing
        case completed(recordCount: Int)
        case failed(String)
        
        var description: String {
            switch self {
            case .idle:
                return "等待开始"
            case .preparing:
                return "准备数据..."
            case .uploading(let current, let total):
                return "上传中 \(current)/\(total)"
            case .processing:
                return "处理中..."
            case .completed(let count):
                return "完成！已迁移\(count)条记录"
            case .failed(let msg):
                return "失败：\(msg)"
            }
        }
        
        var progressValue: Double {
            switch self {
            case .idle: return 0
            case .preparing: return 0.1
            case .uploading(let current, let total):
                return 0.1 + 0.7 * Double(current) / Double(max(1, total))
            case .processing: return 0.9
            case .completed: return 1.0
            case .failed: return 0
            }
        }
    }
    
    enum MigrationError: Error, LocalizedError {
        case noDataToMigrate
        case networkError
        case serverError(String)
        case partialFailure(succeeded: Int, failed: Int)
        
        var errorDescription: String? {
            switch self {
            case .noDataToMigrate:
                return "没有需要迁移的数据"
            case .networkError:
                return "网络连接失败，请检查网络后重试"
            case .serverError(let msg):
                return msg
            case .partialFailure(let succeeded, let failed):
                return "部分迁移成功：\(succeeded)条成功，\(failed)条失败"
            }
        }
    }
    
    // MARK: - ============================================
    // MARK: - 公开方法
    // MARK: - ============================================
    
    /// 检查是否有待迁移数据
    func hasPendingMigration() -> Bool {
        // 需要从 DataManager 获取
        let isMigrated = UserDefaults.standard.bool(forKey: migrationCompleteKey)
        let recordCount = UserDefaults.standard.integer(forKey: "YiGe_LocalRecordCount")
        return !isMigrated && recordCount > 0
    }
    
    /// 获取待迁移数据摘要
    func getPendingDataSummary(dataManager: DataManager) -> (records: Int, capsules: Int, anniversaries: Int) {
        return (
            records: dataManager.records.count,
            capsules: 0, // V4.0: 时光胶囊功能已简化/移除
            anniversaries: dataManager.anniversaries.filter { !$0.isBuiltIn }.count
        )
    }
    
    /// 执行数据迁移
    func migrateGuestData(to user: User, dataManager: DataManager? = nil) async {
        guard !isMigrating else { return }
        
        isMigrating = true
        progress = .preparing
        error = nil
        
        do {
            // 1. 收集本地数据
            let guestData: GuestData
            if let dataManager = dataManager {
                guestData = collectLocalData(from: dataManager)
            } else {
                guestData = collectLocalData()
            }
            
            guard guestData.recordCount > 0 else {
                throw MigrationError.noDataToMigrate
            }
            
            // 2. 上传数据
            let total = guestData.records.count
            var uploaded = 0
            
            for record in guestData.records {
                progress = .uploading(current: uploaded, total: total)
                
                // TODO: 调用后端API上传单条记录
                try await uploadRecord(record, userId: user.id)
                
                uploaded += 1
                
                // 小延迟，避免请求过快
                try await Task.sleep(nanoseconds: 100_000_000)
            }
            
            // 3. 上传时光胶囊
            for capsule in guestData.capsules {
                try await uploadCapsule(capsule, userId: user.id)
            }
            
            // 4. 上传纪念日
            for anniversary in guestData.anniversaries where !anniversary.isBuiltIn {
                try await uploadAnniversary(anniversary, userId: user.id)
            }
            
            // 5. 上传设置
            progress = .processing
            try await uploadSettings(guestData.settings, userId: user.id)
            
            // 6. 标记迁移完成
            UserDefaults.standard.set(true, forKey: migrationCompleteKey)
            
            progress = .completed(recordCount: total)
            
            // 发送迁移完成通知
            NotificationCenter.default.post(
                name: .dataMigrationCompleted,
                object: MigrationResult(
                    success: true,
                    recordCount: total,
                    capsuleCount: guestData.capsules.count
                )
            )
            
        } catch let migrationError as MigrationError {
            error = migrationError
            progress = .failed(migrationError.localizedDescription)
        } catch {
            self.error = .serverError(error.localizedDescription)
            progress = .failed(error.localizedDescription)
        }
        
        isMigrating = false
    }
    
    /// 重试迁移
    func retryMigration(for user: User) async {
        // 重置迁移状态
        UserDefaults.standard.set(false, forKey: migrationCompleteKey)
        await migrateGuestData(to: user)
    }
    
    // MARK: - ============================================
    // MARK: - 私有方法
    // MARK: - ============================================
    
    /// 使用 DataManager 收集本地数据
    func collectLocalData(from dataManager: DataManager) -> GuestData {
        return GuestData(
            deviceId: AuthManager.shared.getDeviceId(),
            records: dataManager.records,
            capsules: [], // V4.0: 不再收集胶囊数据
            anniversaries: dataManager.anniversaries,
            settings: dataManager.settings,
            createdAt: dataManager.records.last?.date ?? Date(),
            lastModified: Date()
        )
    }
    
    private func collectLocalData() -> GuestData {
        // 如果没有传入 DataManager，返回空数据
        return GuestData(
            deviceId: AuthManager.shared.getDeviceId(),
            records: [],
            capsules: [],
            anniversaries: [],
            settings: AppSettings.defaultSettings(),
            createdAt: Date(),
            lastModified: Date()
        )
    }
    
    private func uploadRecord(_ record: DayRecord, userId: String) async throws {
        // TODO: 实现后端API调用
        // POST /api/v1/records
        // Body: { userId, record }
        
        // 模拟网络请求
        try await Task.sleep(nanoseconds: 50_000_000)
    }
    
    private func uploadCapsule(_ capsule: TimeCapsule, userId: String) async throws {
        // TODO: 实现后端API调用
        try await Task.sleep(nanoseconds: 50_000_000)
    }
    
    private func uploadAnniversary(_ anniversary: Anniversary, userId: String) async throws {
        // TODO: 实现后端API调用
        try await Task.sleep(nanoseconds: 50_000_000)
    }
    
    private func uploadSettings(_ settings: AppSettings, userId: String) async throws {
        // TODO: 实现后端API调用
        try await Task.sleep(nanoseconds: 50_000_000)
    }
}

// MARK: - ============================================
// MARK: - 迁移结果
// MARK: - ============================================

struct MigrationResult {
    let success: Bool
    let recordCount: Int
    let capsuleCount: Int
    let errors: [Error]?
    
    init(success: Bool, recordCount: Int, capsuleCount: Int, errors: [Error]? = nil) {
        self.success = success
        self.recordCount = recordCount
        self.capsuleCount = capsuleCount
        self.errors = errors
    }
}

