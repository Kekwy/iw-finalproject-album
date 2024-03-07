//
//  AlbumViewController.swift
//  MyAlbum
//
//  Created by Kekwy on 2023/1/10.
//

import UIKit

class AlbumViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    
    func updateTheme() {
        self.navigationController?.navigationBar.standardAppearance.backgroundColor = MyAlbumData.currentTheme.darkBackColor1
        self.navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = MyAlbumData.currentTheme.darkBackColor1
        self.navigationController?.navigationBar.tintColor = MyAlbumData.currentTheme.lightTextColor
        self.scrollView.backgroundColor = MyAlbumData.currentTheme.lightBackColor
        self.themeChangingButton.backgroundColor = MyAlbumData.currentTheme.themeColor
        self.themeChangingButton.tintColor = MyAlbumData.currentTheme.lightTextColor
    }
    
    
    @IBOutlet weak var themeChangingButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadView()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themeChangingButton.layer.cornerRadius = 30
        updateTheme()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - 界面跳转
    
    @IBAction func addPicture(_ sender: Any) {
        self.performSegue(withIdentifier: "album2add", sender: sender)
    }
    
    
    @IBAction func openSideMenu(_ sender: Any) {
        self.performSegue(withIdentifier: "album2menu", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "album2menu" {
            (segue.destination as! MySideMenuController).provideViewData(album: self, selectedRowNum: self.rowNum)
        } else if segue.identifier == "album2detail" {
            (segue.destination as! DetailViewController).myAlbumImage = selectedImage
        }
    }
    
    var rowNum = 0
    
    func provideViewData(title: String, rowNum: Int) {
//        print(self.navigationItem.title!)
//        print(self.navigationController!.title!)
        self.navigationItem.title = title
        self.rowNum = rowNum
        reloadView()
    }
    
    
    
    // MARK: - 数据
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var defaultHeightConstraint: NSLayoutConstraint!
    
    var bottomConstraint: NSLayoutConstraint? = nil
    
    
    func reloadView() {
        // 重置高度约束
        bottomConstraint?.isActive = false
        if defaultHeightConstraint == nil {
            defaultHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: 600.0)
        }
        defaultHeightConstraint.isActive = true
        // 删除所有子控件
        for subview in contentView.subviews {
            subview.removeFromSuperview()
        }
        
        var topView: UIView? = nil
        let imageSet = MyAlbumData.getImageSet(title: self.navigationItem.title!)
        
        let dates = imageSet.imageDates
        
        for date in dates {
            // 生成一个用于展示日期的 label
            let dateLabel = UILabel()
            // 设置 label 字号
            dateLabel.font = UIFont.systemFont(ofSize: 28.0)
            dateLabel.text = date
            dateLabel.textColor = MyAlbumData.currentTheme.darkTextColor
            // 加入视图并设置约束
            contentView.addSubview(dateLabel)
            dateLabel.translatesAutoresizingMaskIntoConstraints = false
            
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25).isActive = true
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
            
            dateLabel.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
            
            if topView != nil {
                dateLabel.topAnchor.constraint(equalTo: topView!.bottomAnchor, constant: 5.0).isActive = true
            } else {
                dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10.0).isActive = true
            }
            
            topView = dateLabel
            
            // 取出对应的图集
            let subImageSet = imageSet.imageSet[date]!

            var i = 0
            while i < subImageSet.count {
                // 生成一个 stackView 用于展示一行（5张）图片
                let stackView = AlbumStackView()
                stackView.initStackView()

                contentView.addSubview(stackView)

                // 自定义约束
                stackView.translatesAutoresizingMaskIntoConstraints = false

                stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
                stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
                stackView.topAnchor.constraint(equalTo: topView!.bottomAnchor, constant: 5.0).isActive = true
//                stackView.heightAnchor.constraint(equalToConstant: contentView.bounds.width / 5.0).isActive = true

                topView = stackView

                for j in 0 ..< 5 {
                    if i >= subImageSet.count {
                        break
                    }
                    stackView.imageViews[j].setImage(subImageSet[i])
                    // 添加手势
                    
                    let guesture = UITapGestureRecognizer(target:self,action:#selector(imageSingleTap(_:)))
                    
                    stackView.imageViews[j].addGestureRecognizer(guesture)
                    i += 1
                }

            }
            
        }
        
        // 更新高度约束
        if topView != nil {
            bottomConstraint = contentView.bottomAnchor.constraint(equalTo: topView!.bottomAnchor, constant: 20)
            defaultHeightConstraint.isActive = false
            bottomConstraint?.isActive = true
        }
    }
    
    var selectedImage: MyAlbumImage!
    
    
    
    @objc func imageSingleTap(_ tap: UITapGestureRecognizer) {
        let sender = tap.view as! AlbumImageView
        self.selectedImage = sender.albumImage
        self.performSegue(withIdentifier: "album2detail", sender: sender)
    }
    
    
    @IBAction func changeAlbumSkin(_ sender: Any) {
    }
    
}


class AlbumStackView: UIStackView {
    
    var imageViews: [AlbumImageView] = []
    
    func initStackView() {
        self.spacing = 5
        self.distribution = .fillEqually
        self.axis = .horizontal
        
        // 加入五个空的 imageView (一行显示五张图片)
        for _ in 0 ..< 5 {
            let imageView = AlbumImageView()
            imageView.initImageView()
            imageViews.append(imageView)
            // !!!!!!!!!
            self.addArrangedSubview(imageView)
            
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        }
    }
    
}

class AlbumImageView: UIImageView {
    
    var albumImage: MyAlbumImage!
    
    func initImageView() {
        contentMode = .scaleAspectFill
        clipsToBounds = true
        // 开始图像视图交互功能
        isUserInteractionEnabled = true
    }
    
    func setImage(_ image: MyAlbumImage) {
        super.image = image.image
        self.albumImage = image
    }
    
}
