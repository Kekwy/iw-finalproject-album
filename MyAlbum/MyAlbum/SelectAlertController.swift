//
//  SelectAlertView.swift
//  MyAlbum
//
//  Created by Kekwy on 2023/1/12.
//

import UIKit
import Vision

class SelectAlertController: UIAlertController, UITableViewDataSource, UITableViewDelegate {

    // 针对类别名词英译汉的字典
    static let en2ScDic = [
        "apple":"苹果",
        "banana":"香蕉",
        "cake":"蛋糕",
        "candy":"糖果",
        "carrot":"胡萝卜",
        "cookie":"曲奇",
        "doughnut":"甜甜圈",
        "grape":"葡萄",
        "hot dog":"热狗",
        "ice cream":"冰激凌",
        "juice":"果汁儿",
        "muffin":"杯状小松糕",
        "orange":"橙子",
        "pineapple":"菠萝",
        "popcorn":"爆米花儿",
        "pretzel":"双圈饼干",
        "salad":"沙拉",
        "strawberry":"草莓",
        "waffle":"华夫饼",
        "watermelon":"西瓜"
    ]
    
    let tableView: UITableView = UITableView()
    
    var results: [String] = []
    
    var isSelected: [Bool] = []
    
    var image: MyAlbumImage!
    
    func provideResults(results: [String], image: MyAlbumImage) {
        
        self.image = image
        
        if !results.isEmpty {
            for result in results {
                self.results.append(SelectAlertController.en2ScDic[result]!)
            }
        }
        //
        self.results.append("不确定")
        for _ in 0 ..< results.count {
            isSelected.append(true)
        }
        isSelected.append(false)
    }
    
    override func viewDidLoad() {
        //
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        // 设置高亮颜色
        self.view.tintColor = MyAlbumData.currentTheme.themeColor
        //
        tableView.backgroundColor = .clear
        //
        tableView.dataSource = self
        tableView.delegate = self
        //
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15).isActive = true
        tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 90).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: 240.0).isActive = true
        self.view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 50).isActive = true
        
        self.tableView.register(AlertTableViewCell.self, forCellReuseIdentifier: "myCell")
        
        //
        let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
        let archiveAction = UIAlertAction(title: "保存", style: .default, handler: self.saveImage)
        addAction(cancelAction)
        addAction(archiveAction)
    }
    
    func saveImage(_: UIAlertAction) {
        MyAlbumData.getImageSet(title: "所有照片").addImage(self.image)
        for i in 0 ..< self.isSelected.count {
            if isSelected[i] {
                let str = self.results[i]
                self.image.categories.append(str)
            }
        }
        for str in self.image.categories {
            MyAlbumData.getImageSet(title: str).addImage(self.image)
        }
        MyAlbumData.saveData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
//        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        (cell as! AlertTableViewCell).initCell(text: results[indexPath.row], isSelected: isSelected[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSelected[indexPath.row] {
            isSelected[indexPath.row] = false
        } else {
            isSelected[indexPath.row] = true
        }
        tableView.deselectRow(at: indexPath, animated: true)
        // 选中“不确定”时，取消选择其他选项
        // 选中其他选项时，取消选择“不确定”
        if indexPath.row == results.count - 1 {
            clearSelected()
        } else {
            if isSelected.last! {
                isSelected[isSelected.count - 1] = false
                self.tableView.reloadData()
            }
        }
    }
    
    func clearSelected() {
        for i in 0 ..< isSelected.count - 1 {
            if isSelected[i] {
                isSelected[i] = false
            }
        }
        self.tableView.reloadData()
    }
    
}

class AlertTableViewCell: UITableViewCell {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let label = UILabel()
    let icon = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: nil)
        self.backgroundColor = .clear
        // Initialization code
        backgroundColor = .clear
        // 背景透明
        label.backgroundColor = .clear
        
        // 设置颜色和默认图标
        icon.tintColor =  MyAlbumData.currentTheme.themeColor
        icon.image = UIImage(systemName: "plus.rectangle.on.folder")
        
        // 加入控件
        self.contentView.addSubview(icon)
        self.contentView.addSubview(label)
        
        // 添加约束
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8).isActive = true
        icon.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16).isActive = true
        
        icon.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10).isActive = true
        label.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -25).isActive = true
        label.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 18).isActive = true
    }
    
    var myIsSelected: Bool = false
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            if myIsSelected {
                myIsSelected = false
                icon.image = UIImage(systemName: "plus.rectangle.on.folder")
            } else {
                myIsSelected = true
                icon.image = UIImage(systemName: "plus.rectangle.on.folder.fill")
            }
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    }
    
    func initCell(text: String, isSelected: Bool) {
        label.text = text
        myIsSelected = isSelected
        if myIsSelected {
            icon.image = UIImage(systemName: "plus.rectangle.on.folder.fill")
        } else {
            icon.image = UIImage(systemName: "plus.rectangle.on.folder")
        }
    }
    
}
