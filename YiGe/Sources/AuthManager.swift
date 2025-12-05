//
//  AuthManager.swift
//  时光格 V2.0 - 用户认证管理
//
//  功能：
//  - 延迟注册策略
//  - 多种登录方式
//  - 本地数据迁移
//

import Foundation
import SwiftUI
import AuthenticationServices
import Combine

@MainActor
class AuthManager: ObservableObject {
    // MARK: - Singleton
    static let shared = AuthManager()
    
    // MARK: - Published Properties
    @Published var authState: AuthState = .unknown
    @Published var isLoading = false
    @Published var error: AuthError?
    @Published var showLoginSheet = false
    @Published var loginTrigger: RegistrationTrigger?
    
    // MARK: - Private Properties
    private let userDefaultsKey = "YiGe_CurrentUser"
    private let guestDataKey = "YiGe_GuestData"
    private let deviceIdKey = "YiGe_DeviceId"
    private let recordCountKey = "YiGe_LocalRecordCount"
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 配置
    
    /// 触发注册的记录数阈值
    let registrationThreshold = 10
    
    // MARK: - Init
    
    private init() {
        loadAuthState()
    }
    
    // MARK: - ============================================
    // MARK: - 公开方法
    // MARK: - ============================================
    
    /// 检查是否需要注册
    func checkRegistrationRequired(for trigger: RegistrationTrigger) -> Bool {
        guard !authState.isLoggedIn else { return false }
        
        switch trigger {
        case .recordCount(let count):
            return count >= registrationThreshold
        case .capsuleCreate, .cloudSync, .aiFeature, .proUpgrade, .socialFeature:
            return true
        }
    }
    
    /// 请求注册（显示登录弹窗）
    func requestRegistration(trigger: RegistrationTrigger) {
        guard !authState.isLoggedIn else { return }
        
        loginTrigger = trigger
        showLoginSheet = true
    }
    
    /// 记录数增加时检查
    func onRecordCountChanged(_ count: Int) {
        UserDefaults.standard.set(count, forKey: recordCountKey)
        
        // 达到阈值时软提示（不强制）
        if count == registrationThreshold && !authState.isLoggedIn {
            // 可以发送通知或显示提示
            NotificationCenter.default.post(
                name: .registrationSuggested,
                object: RegistrationTrigger.recordCount(count)
            )
        }
    }
    
    /// 微信登录
    func loginWithWechat() async throws {
        isLoading = true
        defer { isLoading = false }
        
        // TODO: 接入微信 SDK
        // 1. 调用微信授权
        // 2. 获取 code
        // 3. 发送到后端换取 token 和用户信息
        
        // 模拟实现
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        let user = User(
            id: UUID().uuidString,
            nickname: "微信用户",
            createdAt: Date()
        )
        
        await completeLogin(user: user, provider: .wechat)
    }
    
    /// Apple 登录
    func loginWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let userId = credential.user
        let email = credential.email
        let fullName = credential.fullName
        
        // 发送到后端验证
        // TODO: 实现后端API调用
        
        var user = User(
            id: userId,
            createdAt: Date()
        )
        
        if let givenName = fullName?.givenName {
            user.nickname = givenName
        }
        user.email = email
        user.appleUserId = userId
        
        await completeLogin(user: user, provider: .apple)
    }
    
    /// 手机号登录
    func loginWithPhone(phone: String, code: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        // TODO: 发送到后端验证短信验证码
        
        // 模拟实现
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        var user = User(
            id: UUID().uuidString,
            createdAt: Date()
        )
        user.phone = phone
        
        await completeLogin(user: user, provider: .phone)
    }
    
    /// 发送验证码
    func sendVerificationCode(to phone: String) async throws {
        // TODO: 调用后端API发送验证码
        try await Task.sleep(nanoseconds: 500_000_000)
    }
    
    /// 登出
    func logout() {
        // 清除用户数据但保留本地记录
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        authState = .guest
    }
    
    /// 跳过登录（继续游客模式）
    func skipLogin() {
        showLoginSheet = false
        loginTrigger = nil
    }
    
    /// 获取设备ID（用于游客数据标识）
    func getDeviceId() -> String {
        if let deviceId = UserDefaults.standard.string(forKey: deviceIdKey) {
            return deviceId
        }
        
        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: deviceIdKey)
        return newId
    }
    
    // MARK: - ============================================
    // MARK: - 私有方法
    // MARK: - ============================================
    
    private func loadAuthState() {
        // 尝试加载已保存的用户
        if let userData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            authState = .authenticated(user)
        } else {
            authState = .guest
        }
    }
    
    private func completeLogin(user: User, provider: AuthProvider) async {
        // 保存用户
        if let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: userDefaultsKey)
        }
        
        // 检查是否有本地数据需要迁移
        let localRecordCount = UserDefaults.standard.integer(forKey: recordCountKey)
        
        if localRecordCount > 0 {
            authState = .migrating
            
            // 触发数据迁移（dataManager 为 nil 时会使用空数据，实际使用时需要传入）
            // TODO: 从环境或单例获取 DataManager 并传入
            await MigrationManager.shared.migrateGuestData(to: user, dataManager: nil)
        }
        
        authState = .authenticated(user)
        showLoginSheet = false
        loginTrigger = nil
        
        // 发送登录成功通知
        NotificationCenter.default.post(name: .userDidLogin, object: user)
    }
    
    private func saveUser(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
}

// MARK: - ============================================
// MARK: - 错误类型
// MARK: - ============================================

enum AuthError: Error, LocalizedError {
    case wechatNotInstalled
    case wechatAuthFailed
    case appleAuthFailed
    case invalidPhoneNumber
    case invalidVerificationCode
    case networkError
    case serverError(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .wechatNotInstalled:
            return "请先安装微信"
        case .wechatAuthFailed:
            return "微信授权失败"
        case .appleAuthFailed:
            return "Apple 登录失败"
        case .invalidPhoneNumber:
            return "请输入正确的手机号"
        case .invalidVerificationCode:
            return "验证码错误"
        case .networkError:
            return "网络连接失败"
        case .serverError(let msg):
            return msg
        case .unknown:
            return "未知错误"
        }
    }
}

// MARK: - ============================================
// MARK: - 通知名称
// MARK: - ============================================

extension Notification.Name {
    static let userDidLogin = Notification.Name("userDidLogin")
    static let userDidLogout = Notification.Name("userDidLogout")
    static let registrationSuggested = Notification.Name("registrationSuggested")
    static let dataMigrationCompleted = Notification.Name("dataMigrationCompleted")
}

