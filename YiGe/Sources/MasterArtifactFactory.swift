//
//  MasterArtifactFactory.swift
//  时光格 - 世界级信物工厂
//
//  整合所有世界级信物模板的统一入口
//  替换原有的 ArtifactTemplateFactory
//

import SwiftUI

// MARK: - ═══════════════════════════════════════════════════════════
// MARK: - 🏭 世界级信物工厂
// MARK: - ═══════════════════════════════════════════════════════════
struct MasterArtifactFactory {
    
    @ViewBuilder
    static func makeView(for record: DayRecord) -> some View {
        switch record.artifactStyle {
            
        // ═══════════════════════════════════════
        // 📜 皇家系列 (MasterArtifacts_Royal.swift)
        // ═══════════════════════════════════════
        case .envelope, .waxEnvelope:
            MasterRoyalDecreeView(record: record)
            
        case .vault:
            MasterClassifiedView(record: record)
            
        // ═══════════════════════════════════════
        // 💿 收藏家系列 (使用现有视图)
        // ═══════════════════════════════════════
        case .vinylRecord:
            VinylRecordV5(record: record)
            
        case .polaroid:
            StylePolaroidSX70View(record: record)
            
        case .postcard:
            StyleWesAndersonView(record: record)
            
        case .bookmark:
            BookmarkV5(record: record)
            
        // ═══════════════════════════════════════
        // ✈️ 航空系列 (MasterArtifacts_Aviation.swift)
        // ═══════════════════════════════════════
        case .boardingPass:
            MasterBoardingPassView(record: record)
            
        case .aircraftType:
            MasterAircraftTypeRatingView(record: record)
            
        case .flightLog:
            MasterFlightLogView(record: record)
            
        case .luggageTag:
            MasterLuggageTagView(record: record)
            
        // ═══════════════════════════════════════
        // 🎫 票据系列 (MasterArtifacts_Tickets.swift)
        // ═══════════════════════════════════════
        case .monoTicket:
            MasterMonoTicketView(record: record)
            
        case .galaInvite:
            MasterGalaInviteView(record: record)
            
        case .concertTicket:
            MasterConcertTicketView(record: record)
            
        // ═══════════════════════════════════════
        // 🧾 小票系列 (StyleReceiptThermalV3.swift)
        // ═══════════════════════════════════════
        case .receipt:
            StyleReceiptViewV3(record: record)
            
        case .thermal:
            StyleThermalViewV3(record: record)
            
        // ═══════════════════════════════════════
        // 🌿 自然书写系列 (MasterArtifacts_Nature.swift)
        // ═══════════════════════════════════════
        case .pressedFlower:
            MasterPressedFlowerView(record: record)
            
        case .journalPage:
            MasterJournalPageView(record: record)
            
        case .typewriter:
            MasterTypewriterManuscriptView(record: record)
            
        // ═══════════════════════════════════════
        // 🎬 影像系列 (MasterArtifacts_Film.swift)
        // ═══════════════════════════════════════
        case .developedPhoto:
            MasterDevelopedPhotoView(record: record)
            
        case .filmNegative:
            MasterFilmNegativeView(record: record)
            
        // ═══════════════════════════════════════
        // 🌍 探索者系列 (MasterArtifacts_Explorer.swift)
        // ═══════════════════════════════════════
        case .safari:
            MasterSafariJournalView(record: record)
            
        case .aurora:
            MasterAuroraView(record: record)
            
        case .astrolabe:
            MasterAstrolabeView(record: record)
            
        case .omikuji:
            MasterOmikujiView(record: record)
            
        case .hourglass:
            MasterHourglassView(record: record)
            
        // ═══════════════════════════════════════
        // 🔄 兼容旧版本 / 默认
        // ═══════════════════════════════════════
        case .simple:
            // 使用极简风格作为默认
            StyleThermalViewV3(record: record)
            
        case .waxStamp:
            MasterRoyalDecreeView(record: record)
        }
    }
}

