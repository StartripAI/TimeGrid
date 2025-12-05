//
//  GLMService.swift
//  时光格 V2.0 - GLM AI 服务
//
//  功能：
//  - 智能续写
//  - 情绪分析
//  - 周报/年报生成
//

import Foundation
import Combine

class GLMService: ObservableObject {
    // MARK: - Singleton
    static let shared = GLMService()
    
    // MARK: - Configuration
    private let baseURL = "https://open.bigmodel.cn/api/paas/v4"
    private var apiKey: String {
        return AppConfig.glmAPIKey
    }
    
    // MARK: - Published Properties
    @Published var isProcessing = false
    @Published var error: GLMError?
    
    // MARK: - Init
    private init() {}
    
    // MARK: - ============================================
    // MARK: - 智能续写
    // MARK: - ============================================
    
    /// 根据用户输入生成续写建议
    func generateWritingSuggestion(
        prompt: String,
        style: WritingSuggestion.SuggestionStyle = .expand,
        context: WritingContext? = nil
    ) async throws -> String {
        isProcessing = true
        defer { isProcessing = false }
        
        let systemPrompt = buildWritingSystemPrompt(style: style, context: context)
        let userPrompt = "用户已写内容：\(prompt)\n\n请继续写下去，保持自然流畅，不要重复用户已写的内容。"
        
        return try await chat(
            systemPrompt: systemPrompt,
            userMessage: userPrompt,
            maxTokens: 200
        )
    }
    
    /// 构建写作系统提示
    private func buildWritingSystemPrompt(
        style: WritingSuggestion.SuggestionStyle,
        context: WritingContext?
    ) -> String {
        var prompt = """
        你是「时光格」App的AI助手，帮助用户记录生活。
        你的任务是根据用户已写的内容，自然地续写下去。
        
        要求：
        - 保持用户的语气和风格
        - 续写内容要自然衔接，不要重复用户已写的
        - 长度适中，2-4句话即可
        - 不要使用"我觉得"、"我认为"等AI口吻
        """
        
        switch style {
        case .expand:
            prompt += "\n- 展开描述细节，让内容更丰富"
        case .emotional:
            prompt += "\n- 深化情感表达，让内容更有温度"
        case .poetic:
            prompt += "\n- 使用优美的语言，增添诗意"
        case .concise:
            prompt += "\n- 简洁总结，提炼核心"
        }
        
        if let context = context {
            prompt += "\n\n背景信息："
            if let mood = context.mood {
                prompt += "\n- 心情：\(mood.label)"
            }
            if let weather = context.weather {
                prompt += "\n- 天气：\(weather.label)"
            }
            if let date = context.date {
                let formatter = DateFormatter()
                formatter.dateFormat = "M月d日 EEEE"
                prompt += "\n- 日期：\(formatter.string(from: date))"
            }
        }
        
        return prompt
    }
    
    // MARK: - ============================================
    // MARK: - 情绪分析
    // MARK: - ============================================
    
    /// 分析单条记录的情绪
    func analyzeEmotion(content: String, mood: Mood?) async throws -> EmotionAnalysis {
        isProcessing = true
        defer { isProcessing = false }
        
        let systemPrompt = """
        你是情绪分析专家。分析用户的日记内容，返回JSON格式结果。
        
        返回格式：
        {
            "dominantEmotion": "喜悦|平静|忧伤|焦虑|愤怒|感恩|希望|怀念",
            "emotionScores": {
                "喜悦": 0.8,
                "平静": 0.5,
                ...
            },
            "keywords": ["关键词1", "关键词2", "关键词3"],
            "summary": "一句话总结这条记录的情感基调",
            "suggestions": ["温馨建议1", "温馨建议2"]
        }
        
        注意：
        - emotionScores 中每种情绪的分数在 0-1 之间
        - keywords 提取 3-5 个关键词
        - suggestions 给出 1-2 条温馨的建议（可选）
        """
        
        var userPrompt = "请分析以下内容的情绪：\n\n\(content)"
        if let mood = mood {
            userPrompt += "\n\n用户自选心情标签：\(mood.emoji) \(mood.label)"
        }
        
        let response = try await chat(
            systemPrompt: systemPrompt,
            userMessage: userPrompt,
            maxTokens: 500,
            responseFormat: .jsonObject
        )
        
        // 解析JSON响应
        return try parseEmotionAnalysis(response, recordId: UUID())
    }
    
    // MARK: - ============================================
    // MARK: - 核心 API 调用
    // MARK: - ============================================
    
    enum ResponseFormat {
        case text
        case jsonObject
    }
    
    private func chat(
        systemPrompt: String,
        userMessage: String,
        maxTokens: Int = 500,
        responseFormat: ResponseFormat = .text
    ) async throws -> String {
        guard !apiKey.isEmpty else {
            throw GLMError.unauthorized
        }
        
        let url = URL(string: "\(baseURL)/chat/completions")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body: [String: Any] = [
            "model": "glm-4-flash",  // 使用快速模型，成本低
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userMessage]
            ],
            "max_tokens": maxTokens,
            "temperature": 0.7
        ]
        
        if responseFormat == .jsonObject {
            body["response_format"] = ["type": "json_object"]
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GLMError.networkError
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorResponse = try? JSONDecoder().decode(GLMErrorResponse.self, from: data) {
                throw GLMError.apiError(errorResponse.error.message)
            }
            throw GLMError.serverError(httpResponse.statusCode)
        }
        
        let result = try JSONDecoder().decode(GLMResponse.self, from: data)
        
        guard let content = result.choices.first?.message.content else {
            throw GLMError.emptyResponse
        }
        
        return content
    }
    
    // MARK: - ============================================
    // MARK: - 解析方法
    // MARK: - ============================================
    
    private func parseEmotionAnalysis(_ json: String, recordId: UUID) throws -> EmotionAnalysis {
        guard let data = json.data(using: .utf8) else {
            throw GLMError.parseError
        }
        
        let parsed = try JSONDecoder().decode(EmotionAnalysisResponse.self, from: data)
        
        // 转换 emotionScores
        var scores: [EmotionAnalysis.EmotionType: Double] = [:]
        for (key, value) in parsed.emotionScores {
            if let type = EmotionAnalysis.EmotionType(rawValue: key) {
                scores[type] = value
            }
        }
        
        // 确定主导情绪
        let dominant = EmotionAnalysis.EmotionType(rawValue: parsed.dominantEmotion) ?? .calm
        
        return EmotionAnalysis(
            recordId: recordId,
            analyzedAt: Date(),
            dominantEmotion: dominant,
            emotionScores: scores,
            keywords: parsed.keywords,
            summary: parsed.summary,
            suggestions: parsed.suggestions
        )
    }
}

// MARK: - ============================================
// MARK: - 数据结构
// MARK: - ============================================

/// 写作上下文
struct WritingContext {
    var mood: Mood?
    var weather: Weather?
    var date: Date?
}

/// GLM API 响应
struct GLMResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
}

/// GLM 错误响应
struct GLMErrorResponse: Codable {
    let error: ErrorDetail
    
    struct ErrorDetail: Codable {
        let message: String
        let code: String?
    }
}

/// 情绪分析响应
struct EmotionAnalysisResponse: Codable {
    let dominantEmotion: String
    let emotionScores: [String: Double]
    let keywords: [String]
    let summary: String?
    let suggestions: [String]?
}

// MARK: - ============================================
// MARK: - 错误类型
// MARK: - ============================================

enum GLMError: Error, LocalizedError {
    case networkError
    case serverError(Int)
    case apiError(String)
    case parseError
    case emptyResponse
    case rateLimited
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "网络连接失败"
        case .serverError(let code):
            return "服务器错误 (\(code))"
        case .apiError(let msg):
            return msg
        case .parseError:
            return "数据解析失败"
        case .emptyResponse:
            return "AI 未返回内容"
        case .rateLimited:
            return "请求太频繁，请稍后再试"
        case .unauthorized:
            return "API 密钥无效"
        }
    }
}

