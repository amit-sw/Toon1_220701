//
//  ImageSaver.swift
//  Toon1_220701
//
//  Created by Amit Gupta on 7/4/22.
//

import SwiftUI
import Photos

class ImageSaver: NSObject {
    
    func writeToPA(image: UIImage) {
        PHPhotoLibrary.shared().performChanges {
            _ = PHAssetChangeRequest.creationRequestForAsset(from: image)

        } completionHandler: { (success, error) in
            print("PA Save finished!")
        }
    }
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("OBJC Save finished!")
    }
    
    func maskImage(image:UIImage, mask:(UIImage))->UIImage{
            
        let imageReference = image.cgImage
        let maskReference = mask.cgImage
        guard let maskReference = maskReference else {
            return image
        }

            
        let imageMask = CGImage(maskWidth: maskReference.width,
                                height: maskReference.height,
                                bitsPerComponent: maskReference.bitsPerComponent,
                                bitsPerPixel: maskReference.bitsPerPixel,
                                bytesPerRow: maskReference.bytesPerRow,
                                provider: maskReference.dataProvider!,
                                decode: nil,
                                shouldInterpolate: true)
            
        let maskedReference = imageReference!.masking(imageMask!)
            
        let maskedImage = UIImage(cgImage:maskedReference!)
            
         return maskedImage
    }
    
    /*
    func captureScreenshot(){
                let layer = UIApplication.shared.keyWindow!.layer
                let scale = UIScreen.main.scale
                // Creates UIImage of same size as view
                UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
                layer.render(in: UIGraphicsGetCurrentContext()!)
                let screenshot = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                // THIS IS TO SAVE SCREENSHOT TO PHOTOS
                UIImageWriteToSavedPhotosAlbum(screenshot!, nil, nil, nil)
      }
     */
    
}

// MARK: Merge Image
// From https://gist.github.com/A-Zak/3c38d3f83f911a25790f

extension UIImage {

    func mergeImage(with secondImage: UIImage, point: CGPoint? = nil) -> UIImage {

        let firstImage = self
        let newImageWidth = max(firstImage.size.width, secondImage.size.width)
        let newImageHeight = max(firstImage.size.height, secondImage.size.height)
        let newImageSize = CGSize(width: newImageWidth, height: newImageHeight)

        //UIGraphicsBeginImageContextWithOptions(newImageSize, false, deviceScale)
        UIGraphicsBeginImageContextWithOptions(newImageSize, false, UIScreen.main.scale)

        let firstImagePoint = CGPoint(x: round((newImageSize.width - firstImage.size.width) / 2),
                                      y: round((newImageSize.height - firstImage.size.height) / 2))

        let secondImagePoint = point ?? CGPoint(x: round((newImageSize.width - secondImage.size.width) / 2),
                                                y: round((newImageSize.height - secondImage.size.height) / 2))

        firstImage.draw(at: firstImagePoint)
        secondImage.draw(at: secondImagePoint)

        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return image ?? self
    }
}

// From HackingWithSwift
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-convert-a-swiftui-view-to-an-image

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

/*
 Example Code
 ============
 
 struct ContentView: View {
     var textView: some View {
         Text("Hello, SwiftUI")
             .padding()
             .background(.blue)
             .foregroundColor(.white)
             .clipShape(Capsule())
     }

     var body: some View {
         VStack {
             textView

             Button("Save to image") {
                 let image = textView.snapshot()

                 UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
             }
         }
     }
 }
 */

