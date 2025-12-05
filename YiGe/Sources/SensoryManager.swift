import SwiftUI
import CoreHaptics
import AVFoundation
import AudioToolbox

// MARK: - 声音资源清单 (需添加到 Xcode Assets/Resources)
/*
 请准备以下音频文件 (m4a/mp3) 并拖入项目：
 1. sfx_shutter_mechanical.m4a (徕卡快门)
 2. sfx_shutter_digital.m4a (拍立得快门)
 3. sfx_stamp_thud.m4a (火漆盖章沉闷声)
 4. sfx_magic_sparkle.m4a (显影/魔法音效)
 5. sfx_paper_slide.m4a (纸张滑动)
 6. sfx_gear_tick.m4a (转盘齿轮声)
 7. sfx_tab_switch.m4a (Tab切换清脆声)
 8. sfx_success_chime.m4a (铸造完成)
 9. sfx_wind_up.m4a (机械卷片)
 10. sfx_photo_eject.m4a (照片弹出)
 11. sfx_box_open.m4a (盒子打开)
 */

class SensoryManager: NSObject, ObservableObject {
    static let shared = SensoryManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
    private override init() {
        super.init()
        // 可以在这里预加载常用音效
        prepareSound("sfx_tab_switch")
        prepareSound("sfx_gear_tick")
    }
    
    // MARK: - 🎛️ 统一感官触发 (Public API)
    
    /// 触发 UI 交互反馈 (轻量级)
    func playUIFeedback(_ type: UIFeedbackType) {
        // 1. 触觉
        triggerHaptic(type.haptic)
        
        // 2. 听觉
        playSound(type.soundFile, fallbackID: type.systemSoundID)
    }
    
    /// 触发 仪式感反馈 (重量级，根据风格变化)
    func playRitualFeedback(for style: RitualStyle, phase: RitualPhase) {
        // 1. 触觉 (根据阶段)
        let hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle
        switch phase {
        case .prepare: hapticStyle = .light
        case .capture: hapticStyle = .rigid // 机械感
        case .mintingStart: hapticStyle = .medium
        case .mintingComplete: hapticStyle = .heavy
        }
        triggerHaptic(.impact(hapticStyle))
        
        // 2. 听觉 (根据风格 + 阶段)
        let soundFile = getSoundFile(for: style, phase: phase)
        let systemFallback = getSystemFallback(for: style, phase: phase)
        
        playSound(soundFile, fallbackID: systemFallback)
    }
    
    // MARK: - 🔊 Audio Engine
    
    private func playSound(_ filename: String?, fallbackID: SystemSoundID? = nil) {
        // 尝试播放自定义文件
        if let filename = filename,
           let url = Bundle.main.url(forResource: filename, withExtension: "m4a") ?? Bundle.main.url(forResource: filename, withExtension: "mp3") {
            
            do {
                // 如果已有播放器则复用（处理快速点击），或者创建新的
                // 注意：为了简单起见，这里每次都创建新player或者重置，生产环境可用对象池
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = 1.0 // 可以根据类型调整音量
                player.prepareToPlay()
                player.play()
                // 缓存引用以防被释放 (简单缓存)
                audioPlayers[filename] = player 
            } catch {
                print("⚠️ Audio Playback Error: \(error)")
                playSystemSound(fallbackID)
            }
        } else {
            // 文件不存在，回退到系统音效
            playSystemSound(fallbackID)
        }
    }
    
    private func prepareSound(_ filename: String) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "m4a") else { return }
        let _ = try? AVAudioPlayer(contentsOf: url)
    }
    
    private func playSystemSound(_ id: SystemSoundID?) {
        guard let id = id else { return }
        AudioServicesPlaySystemSound(id)
    }
    
    // MARK: - 👋 Haptic Engine
    
    private func triggerHaptic(_ type: FeedbackType) {
        switch type {
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        case .impact(let style):
            UIImpactFeedbackGenerator(style: style).impactOccurred()
        case .notification(let type):
            UINotificationFeedbackGenerator().notificationOccurred(type)
        case .shutter:
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 1.0)
        }
    }
    
    // MARK: - Enums & Helpers
    
    enum FeedbackType {
        case selection
        case impact(UIImpactFeedbackGenerator.FeedbackStyle)
        case notification(UINotificationFeedbackGenerator.FeedbackType)
        case shutter
    }
    
    enum UIFeedbackType {
        case tabSwitch
        case scrollTick
        case buttonTap
        case success
        case warning
        case error
        
        var haptic: FeedbackType {
            switch self {
            case .tabSwitch: return .selection
            case .scrollTick: return .selection
            case .buttonTap: return .impact(.medium)
            case .success: return .notification(.success)
            case .warning: return .notification(.warning)
            case .error: return .notification(.error)
            }
        }
        
        var soundFile: String? {
            switch self {
            case .tabSwitch: return "sfx_tab_switch"
            case .scrollTick: return "sfx_gear_tick"
            case .buttonTap: return nil
            case .success: return "sfx_success_chime"
            case .warning: return nil
            case .error: return nil
            }
        }
        
        var systemSoundID: SystemSoundID? {
            switch self {
            case .tabSwitch: return 1104 // Tock
            case .scrollTick: return 1103 // Tink
            case .buttonTap: return 1105 // Tock
            case .success: return 1054 // Success
            case .warning: return 1053 // System handheld
            case .error: return 1053
            }
        }
    }
    
    enum RitualPhase {
        case prepare        // 准备/切换风格
        case capture        // 拍照/按下快门
        case mintingStart   // 开始铸造
        case mintingComplete// 完成
    }
    
    // 核心：根据风格定义声音图谱
    private func getSoundFile(for style: RitualStyle, phase: RitualPhase) -> String? {
        switch style.category {
        case .photography: // 影像类 (机械音)
            switch phase {
            case .capture: return style == .polaroid ? "sfx_shutter_digital" : "sfx_shutter_mechanical"
            case .mintingStart: return "sfx_wind_up" // 卷片声
            case .mintingComplete: return "sfx_photo_eject" // 出片声
            default: return nil
            }
            
        case .tickets, .letters: // 纸质类 (物理摩擦/盖章)
            switch phase {
            case .capture: return "sfx_paper_slide"
            case .mintingStart: return "sfx_paper_crunch"
            case .mintingComplete: return "sfx_stamp_thud" // 盖章重击
            default: return nil
            }
            
        case .collection: // 收藏类 (魔法/清脆)
            switch phase {
            case .capture: return "sfx_shimmer"
            case .mintingStart: return "sfx_box_open"
            case .mintingComplete: return "sfx_magic_sparkle"
            default: return nil
            }
        }
    }
    
    private func getSystemFallback(for style: RitualStyle, phase: RitualPhase) -> SystemSoundID {
        switch phase {
        case .prepare: return 1103 // Tink
        case .capture: return 1108 // Camera Shutter
        case .mintingStart: return 1104 // Tock
        case .mintingComplete: return 1054 // Success (or 1057 for simple ping)
        }
    }
}
