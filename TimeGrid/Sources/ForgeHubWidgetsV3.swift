//
//  ForgeHubWidgetsV3.swift
//  时光格 - 世界级互动风格组件 V3
//
//  路由器：将所有13个互动风格组件路由到 MasterForgeWidgets_Complete.swift
//  完整实现请查看 MasterForgeWidgets_Complete.swift
//

import SwiftUI

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🎯 路由器
// MARK: - ═══════════════════════════════════════════════════════════

struct ForgeHubRouterV3: View {
    let style: TodayHubStyle
    let onTrigger: () -> Void
    
    var body: some View {
        // 所有组件实现都在 MasterForgeWidgets_Complete.swift 中
        switch style {
        case .simple:
            MasterSimpleWidget(onTrigger: onTrigger)
        case .leicaCamera:
            MasterLeicaWidget(onTrigger: onTrigger)
        case .jewelryBox:
            MasterJewelryBoxWidget(onTrigger: onTrigger)
        case .polaroidCamera:
            MasterPolaroidWidget(onTrigger: onTrigger)
        case .waxEnvelope:
            MasterWaxEnvelopeWidget(onTrigger: onTrigger)
        case .waxStamp:
            MasterWaxStampWidget(onTrigger: onTrigger)
        case .vault:
            MasterVaultWidget(onTrigger: onTrigger)
        case .typewriter:
            MasterTypewriterWidget(onTrigger: onTrigger)
        case .safari:
            MasterSafariWidget(onTrigger: onTrigger)
        case .aurora:
            MasterAuroraWidget(onTrigger: onTrigger)
        case .astrolabe:
            MasterAstrolabeWidget(onTrigger: onTrigger)
        case .omikuji:
            MasterOmikujiWidget(onTrigger: onTrigger)
        case .hourglass:
            MasterHourglassWidget(onTrigger: onTrigger)
        }
    }
}
