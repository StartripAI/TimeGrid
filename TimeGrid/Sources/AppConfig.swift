//
//  AppConfig.swift
//  时光格 V2.0 - 应用配置
//

import Foundation

enum AppConfig {
    // MARK: - API Keys
    // ⚠️ 生产环境应从服务端获取或使用 Keychain
    
    static var glmAPIKey: String {
        // 从 Info.plist 读取
        Bundle.main.infoDictionary?["GLM_API_KEY"] as? String ?? ""
    }
    
    // MARK: - API Endpoints
    
    enum API {
        static let baseURL = "https://api.shiguangge.com/v1"
        
        static var auth: String { "\(baseURL)/auth" }
        static var records: String { "\(baseURL)/records" }
        static var capsules: String { "\(baseURL)/capsules" }
        static var sync: String { "\(baseURL)/sync" }
        static var users: String { "\(baseURL)/users" }
    }
    
    // MARK: - 功能开关
    
    enum Features {
        static let aiEnabled = true
        static let cloudSyncEnabled = true
        static let socialEnabled = false  // V2.0 暂不开放
        static let capsuleEnabled = true
    }
    
    // MARK: - 业务配置
    
    enum Business {
        /// 触发注册的记录数阈值
        static let registrationThreshold = 10
        
        /// 免费版最大照片数/记录
        static let freePhotoLimit = 3
        
        /// 免费版最大记录数
        static let freeRecordLimit = 100
        
        /// AI 每日免费次数
        static let freeAIQuota = 10
    }
    
    // MARK: - 第三方配置
    
    enum ThirdParty {
        // 微信开放平台
        static let wechatAppId = "wx_your_app_id"
        static let wechatAppSecret = "your_secret"  // 应该在服务端
        
        // Apple Sign In
        static let appleServicesId = "com.yourcompany.shiguangge"
    }
}

