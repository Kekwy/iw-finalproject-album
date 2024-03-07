//
//  DetailViewController.swift
//  MyAlbum
//
//  Created by Kekwy on 2023/1/13.
//

import UIKit

class DetailViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // 开始图像视图交互功能
        imageView.isUserInteractionEnabled = true
        // 创建单击手势监测对象
        let guesture = UITapGestureRecognizer(target:self,action:#selector(self.imageViewSingleTap))
        // 为视图注册手势监听对象
        imageView.addGestureRecognizer(guesture)
        // 创建一组 boundingBox
        boundingBoxViews = BoundingBoxView.setUpBoundingBoxViews(&self.imageView)
    }
    
    var boundingBoxViews: [BoundingBoxView]!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    @IBOutlet var imageView: UIImageView!
    
    var myAlbumImage: MyAlbumImage!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageView.image = myAlbumImage.image
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
//    }
    
    
    lazy var alertController: UIAlertController = {
        let alertController = UIAlertController(title: nil, message: "查看图片信息，\n显示 boundingBox，或删除图片", preferredStyle: .actionSheet)
        
        alertController.view.tintColor = MyAlbumData.currentTheme.themeColor
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "删除", style: .destructive, handler: deleteActionHandle)
        let infoAction = UIAlertAction(title: "详情", style: .default, handler: infoActionHandle)
        let showAction = UIAlertAction(title: "边框", style: .default, handler: showActionHandle)
        
        alertController.addAction(cancelAction)
        alertController.addAction(infoAction)
        alertController.addAction(showAction)
        alertController.addAction(deleteAction)
        
        return alertController
    }()
    
    
    @IBAction func showOptions(_ sender: Any) {
        let sendView = sender as! UIView
        alertController.popoverPresentationController!.sourceView = sendView
        alertController.popoverPresentationController!.sourceRect = sendView.bounds
        alertController.popoverPresentationController!.permittedArrowDirections = UIPopoverArrowDirection.any
        self.present(alertController, animated: true, completion: nil)
    }
    
    // 单击屏幕(imageView)时切换导航栏的隐藏状态
    @objc func imageViewSingleTap() {
        if self.navigationController!.isNavigationBarHidden {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        } else {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    func infoActionHandle(_ : UIAlertAction) {
        
        let message = "加入时间：\(myAlbumImage.date)\n所在分类：\(myAlbumImage.categories)"
        
        let alert = UIAlertController(title: "图片详情", message: message,preferredStyle: .alert)
        
        alert.view.tintColor = UIColor(red: 121.0 / 255.0, green: 131.0 / 255.0, blue: 108.0 / 255.0, alpha: 1.0)
        
        let action = UIAlertAction(title: "确定", style: .default, handler: nil)
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // 将照片从整个相册中删除
    func deleteActionHandle(_ : UIAlertAction) {
        // 从所有照片中删除
        let imageSet = MyAlbumData.imageSets!["所有照片"] as! MyAlbumImageSet
        imageSet.removeImage(self.myAlbumImage)
        for str in self.myAlbumImage.categories {
            let imageSet = MyAlbumData.imageSets![str] as! MyAlbumImageSet
            imageSet.removeImage(self.myAlbumImage)
        }
        MyAlbumData.saveData()
        // 代码实现 navigation 返回上一层视图
        self.navigationController?.popViewController(animated: true)
    }
    
    var isShow = false
    
    func showActionHandle(_ : UIAlertAction) {
        if !isShow {
            BoundingBoxView.show(predictions: myAlbumImage.detegateResults!, imageView: self.imageView, boundingBoxViews: self.boundingBoxViews)
            isShow = true
        } else {
            // 隐藏已绘制的 boundingBoxViews
            for box in boundingBoxViews {
                box.hide()
            }
            isShow = false
        }
    }
    
    // 横屏时重新绘制 boundingBox
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if isShow {
            BoundingBoxView.show(predictions: myAlbumImage.detegateResults!, imageView: self.imageView, boundingBoxViews: self.boundingBoxViews)
        }
    }
}
