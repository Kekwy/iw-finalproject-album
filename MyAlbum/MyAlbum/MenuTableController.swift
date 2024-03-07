//
//  MenuTableView.swift
//  MyAlbum
//
//  Created by Kekwy on 2023/1/11.
//

import UIKit

class MenuTableController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var indexOfTileToShow: [Int] = []
    
    func updateTheme() {
        self.view.backgroundColor = MyAlbumData.currentTheme.darkBackColor2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTheme()
        //
        indexOfTileToShow.append(0)
        for i in 1 ..< MyAlbumData.categoryNumber {
            if !(MyAlbumData.getImageSet(index: i).isEmpty) {
                indexOfTileToShow.append(i)
            }
        }
        
        initMenuTableView()
    }
    
    func initMenuTableView() {
        self.tableView.register(MenuTableCell.self, forCellReuseIdentifier: "myCell")
        // 设置 TableView 的数据源
        self.tableView.dataSource = self
        self.tableView.delegate = self
        // 页面显示之前，刷新表格数据
        self.tableView.reloadData()
        // 判断当前主视图选中的行数
        for i in 0 ..< indexOfTileToShow.count {
            let index = indexOfTileToShow[i]
            if album!.navigationItem.title == MyAlbumData.getCategoryTitle(index: index) {
                let selectedIndex = IndexPath(row: i, section: 0)
                self.tableView.selectRow(at: selectedIndex, animated: true, scrollPosition: .none)
                break
            }
        }
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return indexOfTileToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        print("cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        
        // Configure the cell...
        let row = indexOfTileToShow[indexPath.row]
        
        let str = MyAlbumData.getCategoryTitle(index: row)
        let num = MyAlbumData.getImageSet(title: str).count
        (cell as! MenuTableCell).title = str + " (" + String(num) + ")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexOfTileToShow[indexPath.row]
        let title = MyAlbumData.getCategoryTitle(index: index)
        album?.provideViewData(title: title, rowNum: index)
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    // MARK: - 视图跳转
    var album: AlbumViewController? = nil
    
    func provideViewData(album: AlbumViewController, selectedRowNum: Int) {
        if self.album == nil {
            self.album = album
        }
    }
    
}


class MenuTableCell: UITableViewCell {

    private let titleLabel = UILabel()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: nil)
        self.backgroundColor = .clear
        // Initialization code
        // 设置圆角
        layer.cornerRadius = 10.0
        backgroundColor = .clear
        // 字体颜色设置为白色
        self.titleLabel.textColor = MyAlbumData.currentTheme.lightTextColor
        // 设置背景透明
        titleLabel.backgroundColor = .clear
        // 设置对齐方式
        titleLabel.textAlignment = .left
        // 设置字体
        titleLabel.font = UIFont(name:"PingFangSC-Regular", size: 18) ?? UIFont.systemFont(ofSize: 20)
//        // 使标签可以显示多行文字，0行表示没有行数限制
//        titleLabel.numberOfLines = 0;
        
        // 加入控件
        self.contentView.addSubview(titleLabel)
        
        // 设置约束
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 30).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -25).isActive = true
        titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12).isActive = true
    }
    
    var title: String {
        set {
            self.titleLabel.text = newValue
        }
        get {
            return self.titleLabel.text!
        }
    }
    
    // 被点击时根据选中状态改变 cell 样式
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            self.backgroundColor = .white
            self.titleLabel.textColor = MyAlbumData.currentTheme.themeColor
        } else {
            self.backgroundColor = .clear
            self.titleLabel.textColor = MyAlbumData.currentTheme.lightTextColor
        }
    }
    
    // 不显示 cell 高亮状态
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    }

}
