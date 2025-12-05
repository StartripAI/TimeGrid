//
//  KeepsakeAnimation.swift
//  时光格 V4.0 - 专属入场动画系统
//
//  12种信物，12种专属入场动画
//  有记忆感、有仪式感、又不卡顿
//

import SwiftUI

// MARK: - 每种信物的专属动画类型
enum KeepsakeAnimationStyle {
    case polaroidDrop          // 拍立得从天而降 + 轻微晃动
    case filmDevelop           // 胶片底片逐渐显影
    case photoStack            // 冲洗照片堆叠滑入
    case ticketPunch           // 电影票被"打孔"撕开
    case trainPassing          // 车票像列车驶入
    case concertFlash          // 演出票灯光闪烁
    case envelopeSeal          // 火漆信封封口动画
    case postcardFly           // 明信片从远方飞来
    case journalFlip           // 日记本翻页
    case vinylSpin             // 唱片旋转出现
    case bookmarkFall          // 书签从书里滑落
    case flowerBloom           // 干花慢慢绽放
}

// MARK: - ViewModifier 统一入口
struct KeepsakeEntranceAnimation: ViewModifier {
    let style: KeepsakeAnimationStyle
    @State private var animate = false
    
    func body(content: Content) -> some View {
        content
            .opacity(animate ? 1 : 0)
            .scaleEffect(animate ? 1 : scaleStart)
            .rotationEffect(animate ? (style == .polaroidDrop ? .degrees(shakeOffset * 0.5) : .zero) : rotationStart)
            .offset(animate ? (style == .polaroidDrop ? CGSize(width: shakeOffset, height: 0) : .zero) : offsetStart)
            .blur(radius: animate ? 0 : blurStart)
            .onAppear { startAnimation() }
            .overlay(animationOverlay)
    }
    
    // 各个参数由 style 决定
    private var scaleStart: CGFloat {
        switch style {
        case .polaroidDrop, .postcardFly, .bookmarkFall: return 0.3
        case .filmDevelop, .flowerBloom: return 0.9
        default: return 0.8
        }
    }
    
    private var rotationStart: Angle {
        switch style {
        case .polaroidDrop: return .degrees(-30)
        case .bookmarkFall: return .degrees(15)
        default: return .zero
        }
    }
    
    private var offsetStart: CGSize {
        switch style {
        case .polaroidDrop, .bookmarkFall: return CGSize(width: 0, height: -300)
        case .postcardFly: return CGSize(width: -600, height: -400)
        case .trainPassing: return CGSize(width: 600, height: 0)
        case .ticketPunch: return CGSize(width: 0, height: 200)
        default: return .zero
        }
    }
    
    private var blurStart: CGFloat {
        style == .filmDevelop || style == .flowerBloom ? 12 : 0
    }
    
    private func startAnimation() {
        withAnimation(.spring(response: 0.9, dampingFraction: 0.7)) {
            animate = true
        }
        
        // 某些需要二次动画的，加延迟
        switch style {
        case .polaroidDrop:   DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { polaroidShake() }
        case .envelopeSeal:   DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { sealDrop() }
        case .vinylSpin:      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { spinRecord() }
        case .concertFlash:   flashLights()
        default: break
        }
    }
    
    // MARK: - 各信物专属二次动画
    @State private var shakeOffset: CGFloat = 0
    private func polaroidShake() {
        withAnimation(.easeInOut(duration: 0.08).repeatCount(3, autoreverses: true)) {
            shakeOffset = 4
        }
    }
    
    @State private var sealY: CGFloat = -80
    private func sealDrop() {
        withAnimation(.interpolatingSpring(stiffness: 200, damping: 12)) {
            sealY = -20
        }
    }
    
    @State private var recordRotation: Angle = .zero
    private func spinRecord() {
        withAnimation(.linear(duration: 1.8)) {
            recordRotation = .degrees(360)
        }
    }
    
    @State private var flashOpacity = 0.0
    private func flashLights() {
        withAnimation(.easeOut(duration: 0.3).repeatCount(4, autoreverses: true)) {
            flashOpacity = flashOpacity == 0.7 ? 0 : 0.7
        }
    }
    
    @ViewBuilder
    private var animationOverlay: some View {
        switch style {
        case .envelopeSeal:
            Circle()
                .fill(RadialGradient(colors: [Color.red, Color.red.opacity(0)], center: .center, startRadius: 0, endRadius: 30))
                .frame(width: 50, height: 50)
                .offset(y: sealY)
                .opacity(animate ? 1 : 0)
        case .concertFlash:
            Rectangle()
                .fill(Color.white.opacity(flashOpacity))
                .ignoresSafeArea()
        default:
            EmptyView()
        }
    }
}

// MARK: - 便捷扩展
extension View {
    func keepsakeAnimation(_ style: KeepsakeAnimationStyle) -> some View {
        self.modifier(KeepsakeEntranceAnimation(style: style))
    }
}

// MARK: - RitualStyle 到动画风格的映射
extension RitualStyle {
    var animationStyle: KeepsakeAnimationStyle {
        switch self {
        case .polaroid: return .polaroidDrop
        case .filmNegative: return .filmDevelop
        case .developedPhoto: return .photoStack
        case .movieTicket: return .ticketPunch
        case .trainTicket: return .trainPassing
        case .concertTicket: return .concertFlash
        case .envelope: return .envelopeSeal
        case .postcard: return .postcardFly
        case .journalPage: return .journalFlip
        case .vinylRecord: return .vinylSpin
        case .bookmark: return .bookmarkFall
        case .pressedFlower: return .flowerBloom
        case .monoTicket: return .ticketPunch
        case .galaInvite: return .concertFlash
        }
    }
}

