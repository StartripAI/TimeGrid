//
//  ArtifactOutputSpecV4.swift
//  信物输出规格系统 V4.0
//
//  核心原则：
//  1. 长条形信物的最长边必须比屏幕短
//  2. 标准信物整体缩小15%（视觉更舒适）
//  3. 长条形信物分辨率提高（更清晰）
//

import SwiftUI
import UIKit

// MARK: - 🎯 输出质量档位

enum OutputQualityV4: String, CaseIterable, Identifiable {
    case standard = "标准"      // @2x - 快速分享
    case hd = "高清"           // @3x - 相册保存（默认）
    case ultra = "超高清"      // @4x - 壁纸/打印
    
    var id: String { rawValue }
    
    var scale: CGFloat {
        switch self {
        case .standard: return 2.0
        case .hd: return 3.0
        case .ultra: return 4.0
        }
    }
}

// MARK: - 📐 信物输出规格 V4

struct ArtifactOutputSpecV4 {
    let designWidth: CGFloat   // 设计宽度 (pt)
    let designHeight: CGFloat  // 设计高度 (pt)
    let extraScale: CGFloat    // 额外分辨率倍数（长条形信物用）
    
    init(designWidth: CGFloat, designHeight: CGFloat, extraScale: CGFloat = 1.0) {
        self.designWidth = designWidth
        self.designHeight = designHeight
        self.extraScale = extraScale
    }
    
    /// 高清输出尺寸 (@3x × extraScale)
    var hdOutputSize: CGSize {
        let scale = OutputQualityV4.hd.scale * extraScale
        return CGSize(
            width: designWidth * scale,
            height: designHeight * scale
        )
    }
    
    /// 最长边像素数
    var maxDimension: CGFloat {
        max(hdOutputSize.width, hdOutputSize.height)
    }
    
    /// 是否需要缩小以适应屏幕
    var needsScaleDown: Bool {
        maxDimension > 2200 // iPhone安全显示高度
    }
    
    /// 宽高比
    var aspectRatio: CGFloat {
        designWidth / designHeight
    }
    
    /// 是否是长条形
    var isLongFormat: Bool {
        aspectRatio < 0.5 || aspectRatio > 2.0
    }
}

// MARK: - 🎨 每个信物的输出规格（V4修正版）

extension RitualStyle {
    var outputSpecV4: ArtifactOutputSpecV4 {
        switch self {
        // ══════════════════════════════════════════════════════════════
        // 📐 标准竖向信物 (缩小15%)
        // 原尺寸：300×450pt → 新尺寸：255×383pt
        // @3x输出：765×1149px ✓ 在屏幕内完整显示
        // ══════════════════════════════════════════════════════════════
        case .vault, .pressedFlower, .waxStamp, .typewriter, .journalPage,
             .postcard, .developedPhoto, .simple,
             .safari, .aurora, .astrolabe, .hourglass, .monoTicket, .galaInvite:
            return ArtifactOutputSpecV4(designWidth: 255, designHeight: 383)
        case .filmNegative: // 胶片底片 (横向长条形)
            return ArtifactOutputSpecV4(designWidth: 320, designHeight: 130)
            
        // ══════════════════════════════════════════════════════════════
        // 📐 较大竖向信物 (缩小15%)
        // 原尺寸：320×520pt → 新尺寸：272×442pt
        // @3x输出：816×1326px ✓
        // ══════════════════════════════════════════════════════════════
        case .envelope, .waxEnvelope:
            return ArtifactOutputSpecV4(designWidth: 272, designHeight: 442)
            
        // ══════════════════════════════════════════════════════════════
        // 📐 宝丽来 (缩小15%)
        // 原尺寸：300×400pt → 新尺寸：255×340pt
        // @3x输出：765×1020px ✓ 接近 Instagram 4:5
        // ══════════════════════════════════════════════════════════════
        case .polaroid:
            return ArtifactOutputSpecV4(designWidth: 255, designHeight: 340)
            
        // ══════════════════════════════════════════════════════════════
        // 📐 票据型信物 (缩小15%)
        // 原尺寸：280×450pt → 新尺寸：238×383pt
        // @3x输出：714×1149px ✓
        // ══════════════════════════════════════════════════════════════
        case .omikuji:
            return ArtifactOutputSpecV4(designWidth: 238, designHeight: 383)
            
        // ══════════════════════════════════════════════════════════════
        // 📐 书签 (窄型，缩小15%)
        // 原尺寸：200×450pt → 新尺寸：170×383pt
        // @3x输出：510×1149px ✓
        // ══════════════════════════════════════════════════════════════
        case .bookmark:
            return ArtifactOutputSpecV4(designWidth: 170, designHeight: 383)
            
        // ══════════════════════════════════════════════════════════════
        // 🔴 收据型信物 (关键修正！)
        // 问题：之前太长，超出屏幕
        // 解决：大幅缩小，同时提高分辨率补偿清晰度
        //
        // 新尺寸：200×400pt（宽高比 1:2）
        // 额外分辨率：1.5x（总计 @4.5x）
        // @4.5x输出：900×1800px ✓ 刚好在屏幕内，且非常清晰
        // ══════════════════════════════════════════════════════════════
        case .receipt:
            return ArtifactOutputSpecV4(designWidth: 200, designHeight: 400, extraScale: 1.5)
            
        // ══════════════════════════════════════════════════════════════
        // 🔴 热敏小票 (关键修正！)
        // 问题：太长太窄，在屏幕上只能看一半
        // 解决：缩短高度，提高分辨率
        //
        // 新尺寸：180×420pt（比收据更窄更长一点）
        // 额外分辨率：1.5x
        // @4.5x输出：810×1890px ✓ 在屏幕内完整显示
        // ══════════════════════════════════════════════════════════════
        case .thermal:
            return ArtifactOutputSpecV4(designWidth: 180, designHeight: 420, extraScale: 1.5)
            
        // ══════════════════════════════════════════════════════════════
        // 📐 黑胶唱片 (横向，缩小15%)
        // 原尺寸：350×300pt → 新尺寸：298×255pt
        // @3x输出：894×765px ✓
        // 横向信物在手机上会自动旋转或缩放显示
        // ══════════════════════════════════════════════════════════════
        case .vinylRecord:
            return ArtifactOutputSpecV4(designWidth: 298, designHeight: 255)
            
        // ══════════════════════════════════════════════════════════════
        // ✈️ 航空系列信物
        // ══════════════════════════════════════════════════════════════
        case .boardingPass:
            // 登机牌：横向长条形，类似收据
            return ArtifactOutputSpecV4(designWidth: 200, designHeight: 400, extraScale: 1.5)
        case .aircraftType:
            // 机型证：证书型，竖向
            return ArtifactOutputSpecV4(designWidth: 255, designHeight: 383)
        case .flightLog:
            // 航空日志：日志本型，竖向
            return ArtifactOutputSpecV4(designWidth: 255, designHeight: 383)
        case .luggageTag:
            // 行李牌：标签型，较小
            return ArtifactOutputSpecV4(designWidth: 200, designHeight: 300)
            
        // ══════════════════════════════════════════════════════════════
        // 🎫 票据系列信物
        // ══════════════════════════════════════════════════════════════
        case .concertTicket:
            // 演出门票：票据型，竖向
            return ArtifactOutputSpecV4(designWidth: 200, designHeight: 400, extraScale: 1.5)
        }
    }
    
    // MARK: - V5 输出规格（用于V5版本的信物）
    var specV5: ArtifactOutputSpecV5 {
        switch self {
        case .thermal:
            // 热敏小票：170×400pt, @4.5x → 765×1800px (V7: 增大以容纳大照片)
            return ArtifactOutputSpecV5(width: 170, height: 400, extraScale: 1.5)
        case .receipt:
            // 收据：190×450pt, @4.5x → 855×2025px (V7: 增大以容纳大照片)
            return ArtifactOutputSpecV5(width: 190, height: 450, extraScale: 1.5)
        case .bookmark:
            return ArtifactOutputSpecV5(width: 140, height: 350, extraScale: 1.0)
        case .vinylRecord:
            return ArtifactOutputSpecV5(width: 255, height: 200, extraScale: 1.0)
        case .pressedFlower:
            return ArtifactOutputSpecV5(width: 220, height: 340, extraScale: 1.0)
        case .safari:
            return ArtifactOutputSpecV5(width: 220, height: 340, extraScale: 1.0)
        case .envelope, .waxEnvelope:
            return ArtifactOutputSpecV5(width: 272, height: 442, extraScale: 1.0)
        case .polaroid:
            return ArtifactOutputSpecV5(width: 255, height: 340, extraScale: 1.0)
        case .omikuji:
            return ArtifactOutputSpecV5(width: 238, height: 383, extraScale: 1.0)
        default:
            return ArtifactOutputSpecV5(width: 255, height: 383, extraScale: 1.0)
        }
    }
}

// MARK: - V5 输出规格结构
struct ArtifactOutputSpecV5 {
    let width: CGFloat
    let height: CGFloat
    let extraScale: CGFloat // 额外分辨率倍数
    
    /// 最终输出尺寸 (px)
    var outputSize: CGSize {
        let baseScale: CGFloat = 3.0
        let finalScale = baseScale * extraScale
        return CGSize(
            width: width * finalScale,
            height: height * finalScale
        )
    }
}

