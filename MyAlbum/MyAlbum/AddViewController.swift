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

import UIKit
import CoreML
import Vision

class AddViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var photoLibraryButton: UIButton!
    @IBOutlet var resultsView: UIView!
    @IBOutlet var resultsLabel: UILabel!
    @IBOutlet var resultsConstraint: NSLayoutConstraint!
    
    var firstTime = true
    
    //TODO: define a VNCoreMLRequest
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        resultsView.alpha = 0
        resultsLabel.text = "choose or take a photo"
        
        // 开始图像视图交互功能
        imageView.isUserInteractionEnabled = true
        // 创建单击手势监测对象
        let guesture = UITapGestureRecognizer(target:self,action:#selector(self.imageViewSingleTap))
        // 为视图注册手势监听对象
        imageView.addGestureRecognizer(guesture)
        // 创建一组 boundingBox
        boundingBoxViews = BoundingBoxView.setUpBoundingBoxViews(&self.imageView)
    }
    
    // 绑定的事件处理方法
    @objc func imageViewSingleTap() {
        if self.navigationController!.isNavigationBarHidden {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        } else {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Show the "choose or take a photo" hint when the app is opened.
        if firstTime {
            showResultsView(delay: 0.5)
            firstTime = false
        }
        // 隐藏导航栏
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    
    var boundingBoxViews: [BoundingBoxView]!
    
    
    func hideBoundingBoxViews() {
        for box in boundingBoxViews {
            box.hide()
        }
    }
    
    @IBAction func takePicture() {
        presentPhotoPicker(sourceType: .camera)
    }
    
    @IBAction func choosePhoto() {
        presentPhotoPicker(sourceType: .photoLibrary)
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
        hideResultsView()
    }
    
    func showResultsView(delay: TimeInterval = 0.1) {
        resultsConstraint.constant = 100
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5,
                       delay: delay,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.6,
                       options: .beginFromCurrentState,
                       animations: {
            self.resultsView.alpha = 1
            self.resultsConstraint.constant = -10
            self.view.layoutIfNeeded()
        },
                       completion: nil)
    }
    
    func hideResultsView() {
        UIView.animate(withDuration: 0.3) {
            self.resultsView.alpha = 0
        }
    }
    
    
    // MARK: - 图像识别
    lazy var visionModel: VNCoreMLModel = {
        do {
            //        let coreMLWrapper = SnackLocalizationModel()
            let coreMLWrapper = SnackDetector()
            let visionModel = try VNCoreMLModel(for: coreMLWrapper.model)
            
            if #available(iOS 13.0, *) {
                visionModel.inputImageFeatureName = "image"
                visionModel.featureProvider = try MLDictionaryFeatureProvider(dictionary: [
                    "iouThreshold": MLFeatureValue(double: 0.15),
                    "confidenceThreshold": MLFeatureValue(double: 0.25),
                ])
            }
            return visionModel
        } catch {
            fatalError("Failed to create VNCoreMLModel: \(error)")
        }
    }()
    
    lazy var visionRequest: VNCoreMLRequest = {
        let request = VNCoreMLRequest(model: visionModel, completionHandler: {
            [weak self] request, error in
            self?.processObservations(for: request, error: error)
        })
        
        // NOTE: If you choose another crop/scale option, then you must also
        // change how the BoundingBoxView objects get scaled when they are drawn.
        // Currently they assume the full input image is used.
        request.imageCropAndScaleOption = .scaleFill
        return request
    }()
    
    func classify(image: UIImage) {
        
        guard let ciImage = CIImage(image: image) else {
            print("Unable to create CIImage")
            return
        }
        
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                 try handler.perform([self.visionRequest])
            } catch {
                print("Failed to perform classification: \(error)")
            }
        }
    }
    
    
    func processObservations(for request: VNRequest, error: Error?) {
        // call show function
        DispatchQueue.main.async {
            if let results = request.results as? [VNRecognizedObjectObservation] {
                // 保存本次判断结果
                self.preResults = results
                BoundingBoxView.show(predictions: results, imageView: self.imageView, boundingBoxViews: self.boundingBoxViews)
            } else {
                self.preResults = []
                BoundingBoxView.show(predictions: [], imageView: self.imageView, boundingBoxViews: self.boundingBoxViews)
            }
            self.showSelectAlert()
        }
    }
    
    var preResults: [VNRecognizedObjectObservation] = []
    
    func showSelectAlert() {
        let alert = SelectAlertController(title: "添加照片", message: "根据目标检测结果，选择以下需要加入的相册。", preferredStyle: .alert)
        var results: [String] = []
        // 提取检测出的种类，过滤重复的类别
        for res in preResults {
            if !results.contains(res.labels[0].identifier) {
                results.append(res.labels[0].identifier)
            }
        }
        // 按首字母排序
        results.sort()
        //
        let date = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy 年 MM 月 dd 日"
        let strNowTime = timeFormatter.string(from: date) as String
        
        let albumImage = MyAlbumImage(image: self.imageView.image!, detegateResults: preResults, date: strNowTime, categories: [])
        alert.provideResults(results: results, image: albumImage)
        self.present(alert, animated: true)
    }
    
    // 横屏时重新绘制 boundingBox
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        // bugfix - 1.16: 没有选择照片时，横屏不做操作
        // 否则由于 imageView.image 为 nil，导致 APP crash
        if self.imageView.image == nil {
            return
        }
        BoundingBoxView.show(predictions: preResults, imageView: self.imageView, boundingBoxViews: self.boundingBoxViews)
    }
    
}
//TODO: define a function like func processObservations(for request: VNRequest, error: Error?)  to process the results from the classification model

extension AddViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        let image = info[.originalImage] as! UIImage
        imageView.image = image
        // 隐藏上一次检测结果的 boundingBox
        hideBoundingBoxViews()
        // 隐藏导航栏
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        classify(image: image)
    }
    
    
    
}
