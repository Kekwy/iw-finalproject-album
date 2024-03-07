/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import UIKit
import Vision

class BoundingBoxView {
    let shapeLayer: CAShapeLayer
    let textLayer: CATextLayer
    
    init() {
        shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.isHidden = true
        
        textLayer = CATextLayer()
        textLayer.foregroundColor = UIColor.black.cgColor
        textLayer.isHidden = true
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.fontSize = 14
        textLayer.font = UIFont(name: "Avenir", size: textLayer.fontSize)
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
    }
    
    func addToLayer(_ parent: CALayer) {
        parent.addSublayer(shapeLayer)
        parent.addSublayer(textLayer)
    }
    
    func show(frame: CGRect, label: String, color: UIColor) {
        CATransaction.setDisableActions(true)
        
        let path = UIBezierPath(rect: frame)
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.isHidden = false
        
        textLayer.string = label
        textLayer.backgroundColor = color.cgColor
        textLayer.isHidden = false
        
        let attributes = [
            NSAttributedString.Key.font: textLayer.font as Any
        ]
        
        let textRect = label.boundingRect(with: CGSize(width: 400, height: 100),
                                          options: .truncatesLastVisibleLine,
                                          attributes: attributes, context: nil)
        let textSize = CGSize(width: textRect.width + 12, height: textRect.height)
        let textOrigin = CGPoint(x: frame.origin.x - 2, y: frame.origin.y - textSize.height)
        textLayer.frame = CGRect(origin: textOrigin, size: textSize)
    }
    
    func hide() {
        shapeLayer.isHidden = true
        textLayer.isHidden = true
    }
    
    static var colors: [String: UIColor] = [:]
    
    // MARK: - 公用的静态方法
    
    // 
    static func initLabels() {
        let labels = [
            "apple",
            "banana",
            "cake",
            "candy",
            "carrot",
            "cookie",
            "doughnut",
            "grape",
            "hot dog",
            "ice cream",
            "juice",
            "muffin",
            "orange",
            "pineapple",
            "popcorn",
            "pretzel",
            "salad",
            "strawberry",
            "waffle",
            "watermelon",
        ]
        
        // Make colors for the bounding boxes. There is one color for
        // each class, 20 classes in total.
        var i = 0
        for r: CGFloat in [0.5, 0.6, 0.75, 0.8, 1.0] {
            for g: CGFloat in [0.5, 0.8] {
                for b: CGFloat in [0.5, 0.8] {
                    colors[labels[i]] = UIColor(red: r, green: g, blue: b, alpha: 1)
                    i += 1
                }
            }
        }
    }
    
    // 设置全局 boundingBoxView 的数量
    static let maxBoundingBoxViews = 10
    
    // 初始化 boundingBoxViews
    static func setUpBoundingBoxViews( _ imageView: inout UIImageView) -> [BoundingBoxView] {
        var boundingBoxViews = [BoundingBoxView]()
        for _ in 0 ..< maxBoundingBoxViews {
            boundingBoxViews.append(BoundingBoxView())
        }
        
        for box in boundingBoxViews {
            box.addToLayer(imageView.layer)
        }
        
        return boundingBoxViews
        
    }

    // 根据检测结果，绘制 boundingBox
    static func show(predictions: [VNRecognizedObjectObservation], imageView: UIImageView, boundingBoxViews: [BoundingBoxView]) {
        
        //process the results, call show function in BoundingBoxView
        let width = imageView.image!.size.width
        let height = imageView.image!.size.height
        
        var finalWidth = imageView.bounds.width
        var finalHeight = finalWidth / width * height
        var offsetX = 0.0
        var offsetY = (imageView.bounds.height - finalHeight) / 2.0
        
        if finalHeight > imageView.bounds.height {
            finalHeight = imageView.bounds.height
            finalWidth = finalHeight / height * width
            offsetY = 0.0
            offsetX = (imageView.bounds.width - finalWidth) / 2.0
        }
        
        for i in 0 ..< boundingBoxViews.count {
            if i < predictions.count {
                let prediction = predictions[i]
//                let offsetY = (imageView.bounds.height - height) / 2
                let scale = CGAffineTransform.identity.scaledBy(x: finalWidth, y: finalHeight)
                let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: offsetX, y: -finalHeight - offsetY)
                let rect = prediction.boundingBox.applying(scale).applying(transform)
                
                let bestClass = prediction.labels[0].identifier
                let confidence = prediction.labels[0].confidence
                
                let label = String(format: "%@ %.1f", bestClass, confidence * 100)
                let color = BoundingBoxView.colors[bestClass] ?? UIColor.red
                boundingBoxViews[i].show(frame: rect, label: label, color: color)
            } else {
                boundingBoxViews[i].hide()
            }
        }
    }
    
}

