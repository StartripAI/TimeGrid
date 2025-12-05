import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

class ImageProcessor {
    
    static let shared = ImageProcessor()
    private let context = CIContext()

    private init() {}

    // 实现热敏打印效果 (Randomized Dithering)
    func applyThermalEffect(to image: UIImage, intensity: CGFloat = 0.6) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        // 1. 灰度化
        let monoFilter = CIFilter.photoEffectMono()
        monoFilter.inputImage = ciImage
        
        guard let monoOutput = monoFilter.outputImage else { return nil }
        
        // 2. 生成随机噪点 (模拟抖动颗粒)
        let randomGenerator = CIFilter.randomGenerator()
        guard let noiseImage = randomGenerator.outputImage else { return nil }
        
        // 3. 将噪点与图像混合
        let noiseBlendFilter = CIFilter.additionCompositing()
        noiseBlendFilter.inputImage = monoOutput
        // 噪点需要裁剪到图像大小
        let croppedNoise = noiseImage.cropped(to: ciImage.extent)
        noiseBlendFilter.backgroundImage = croppedNoise

        guard let blendedOutput = noiseBlendFilter.outputImage else { return nil }

        // 4. 二值化 (Thresholding) - 根据混合后的亮度决定黑白
        let thresholdFilter = CIFilter.colorThreshold()
        thresholdFilter.inputImage = blendedOutput
        thresholdFilter.threshold = Float(intensity) // 控制黑白平衡

        guard let finalImage = thresholdFilter.outputImage else { return nil }
        // 确保输出尺寸与输入一致
        return render(ciImage: finalImage.cropped(to: ciImage.extent))
    }
    
    // 应用简单的高对比度黑白效果（备选方案）
    func applySimpleThermalEffect(to image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        // 灰度化
        let monoFilter = CIFilter.photoEffectNoir()
        monoFilter.inputImage = ciImage
        
        guard let monoOutput = monoFilter.outputImage else { return nil }
        
        // 增加对比度
        let contrastFilter = CIFilter.colorControls()
        contrastFilter.inputImage = monoOutput
        contrastFilter.contrast = 1.5
        contrastFilter.brightness = 0.1
        
        guard let finalImage = contrastFilter.outputImage else { return nil }
        return render(ciImage: finalImage.cropped(to: ciImage.extent))
    }
    
    private func render(ciImage: CIImage) -> UIImage? {
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            return UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
        }
        return nil
    }
    
    // 生成条形码 (Code 128)
    func generateBarcode(from string: String) -> UIImage? {
        guard let data = string.data(using: String.Encoding.ascii) else { return nil }
        
        let filter = CIFilter.code128BarcodeGenerator()
        filter.message = data
        filter.quietSpace = 0 // 移除左右空白
        
        if let outputImage = filter.outputImage {
            // 放大以保持清晰度
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            let scaledImage = outputImage.transformed(by: transform)
            return render(ciImage: scaledImage)
        }
        return nil
    }
    
    // 生成 QR 码
    func generateQRCode(from string: String) -> UIImage? {
        guard let data = string.data(using: .utf8) else { return nil }
        
        let filter = CIFilter.qrCodeGenerator()
        filter.message = data
        filter.correctionLevel = "M"
        
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            return render(ciImage: scaledImage)
        }
        return nil
    }
}

