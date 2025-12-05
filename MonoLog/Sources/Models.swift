import Foundation
import SwiftData
import UIKit

@Model
final class ReceiptEntry {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var content: String
    
    // 存储原始图片数据
    @Attribute(.externalStorage) var originalImageData: Data?
    
    // 存储最终渲染的小票图片（用于快速显示和分享）
    @Attribute(.externalStorage) var renderedReceiptData: Data?
    
    // 小票元数据（程序化生成）
    var transactionID: String
    var barcodeString: String
    var footerMessage: String

    init(timestamp: Date = Date(), content: String, imageData: Data?) {
        self.id = UUID()
        self.timestamp = timestamp
        self.content = content
        self.originalImageData = imageData
        self.renderedReceiptData = nil
        
        // 生成随机元数据，强化仪式感和唯一性
        self.transactionID = "TXN-\(UUID().uuidString.prefix(8).uppercased())"
        // 生成一个随机的12位条形码数字
        self.barcodeString = "\(Int64.random(in: 100000000000...999999999999))"
        self.footerMessage = [
            "THANK YOU FOR YOUR TIME",
            "请保留此时间凭证",
            "时间一经售出，概不退换",
            "HAVE A NICE DAY",
            "此刻值得被记住",
            "时光珍贵，妥善保管"
        ].randomElement()!
    }
    
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: timestamp)
    }
    
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: timestamp)
    }
}

