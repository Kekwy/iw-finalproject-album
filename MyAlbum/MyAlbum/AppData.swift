//
//  MyImage.swift
//  MyAlbum
//
//  Created by Kekwy on 2023/1/13.
//

import UIKit
import Vision

class MyAlbumData {
    
    // 预设的主题配色方案
    static let albumThemes = [
        "苔古": AlbumTheme(UIColor(red: 190.0 / 255.0, green: 194.0 / 255.0, blue: 179.0 / 255.0, alpha: 1.0), UIColor(red: 121.0 / 255.0, green: 131.0 / 255.0, blue: 108.0 / 255.0, alpha: 1.0), UIColor(red: 157.0 / 255.0, green: 157.0 / 255.0, blue: 130.0 / 255.0, alpha: 1.0), .white, UIColor(red: 121.0 / 255.0, green: 131.0 / 255.0, blue: 108.0 / 255.0, alpha: 1.0), UIColor(red: 121.0 / 255.0, green: 131.0 / 255.0, blue: 108.0 / 255.0, alpha: 1.0)),
        "南大紫": AlbumTheme(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7), UIColor(red: 98.0/255.0, green: 6.0/255.0, blue: 95.0/255.0, alpha: 1.0), UIColor(red: 126.0/255.0, green: 82.0/255.0, blue: 127.0/255.0, alpha: 1.0), .white, .black, UIColor(red: 98.0/255.0, green: 6.0/255.0, blue: 95.0/255.0, alpha: 1.0))
    ]
    
    static var currentTheme: AlbumTheme!
    
    static let writeDiskQueue: DispatchQueue = DispatchQueue(label: "writeDisk")
    
    static let categoryNumber = 22
    
    static let categoryTitles: [String] = [
        "所有照片",
        "苹果",
        "香蕉",
        "蛋糕",
        "糖果",
        "胡萝卜",
        "曲奇",
        "甜甜圈",
        "葡萄",
        "热狗",
        "冰激凌",
        "果汁儿",
        "杯状小松糕",
        "橙子",
        "菠萝",
        "爆米花儿",
        "双圈饼干",
        "沙拉",
        "草莓",
        "华夫饼",
        "西瓜",
        "不确定"
    ]
    
    // 每个类别相册中的图片数据
    static var imageSets: NSDictionary? = nil
    
    static var appData: MyAlbumData!
    
    static func getImageSet(index: Int) -> MyAlbumImageSet {
        let str = categoryTitles[index]
        return imageSets![str]! as! MyAlbumImageSet
    }
    
    static func getImageSet(title: String) -> MyAlbumImageSet {
        return imageSets![title]! as! MyAlbumImageSet
    }
    
    static func getCategoryTitle(index: Int) -> String {
        return categoryTitles[index]
    }
    
    static var url: URL? = nil
    
    static func initAppData(url: URL?) {
        
    }
    
    //设置文件存放位置，配置文件一般比较重要，建议放在Document下，可ITunes同步
    static let savePath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)/album.data"
    
    static let themePath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)/theme.data"
    
    static var themeName: String? = "南大紫"
    
    //将字典数据存到指定位置
    static func saveData() {
        // 异步执行，避免占用主线程导致用户交互卡顿
        writeDiskQueue.async {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: imageSets!, requiringSecureCoding: true)
                do {
                    _ = try data.write(to: URL(fileURLWithPath: savePath))
                    print("写入成功")
                } catch {
                    print("data写入本地失败: \(error)")
                }
            } catch  {
                print("模型转data失败: \(error)")
            }
        }
    }
    
    static func saveTheme() {
        writeDiskQueue.async {
            do {
                let theme = try NSKeyedArchiver.archivedData(withRootObject: themeName!, requiringSecureCoding: true)
                do {
                    _ = try theme.write(to: URL(fileURLWithPath: themeName!))
                    print("写入成功")
                } catch {
                    print("data写入本地失败: \(error)")
                }
            } catch  {
                print("模型转data失败: \(error)")
            }
        }
    }
    
    static func changeTheme(_ name: String) {
        themeName = name
        currentTheme = albumThemes[name]
        saveTheme()
    }
    
    static func readData() {
        do {
            let data = try Data.init(contentsOf: URL(fileURLWithPath: savePath))
            // 当用户首次登陆, 直接从沙盒获取数据, 就会为nil  所以这里需要使用as?
            imageSets = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? NSDictionary
        } catch {
            print("获取data数据失败: \(error)")
            // 第一次启动 APP，初始化数据
            imageSets = [
                "所有照片":MyAlbumImageSet(),
                "苹果":MyAlbumImageSet(),
                "香蕉":MyAlbumImageSet(),
                "蛋糕":MyAlbumImageSet(),
                "糖果":MyAlbumImageSet(),
                "胡萝卜":MyAlbumImageSet(),
                "曲奇":MyAlbumImageSet(),
                "甜甜圈":MyAlbumImageSet(),
                "葡萄":MyAlbumImageSet(),
                "热狗":MyAlbumImageSet(),
                "冰激凌":MyAlbumImageSet(),
                "果汁儿":MyAlbumImageSet(),
                "杯状小松糕":MyAlbumImageSet(),
                "橙子":MyAlbumImageSet(),
                "菠萝":MyAlbumImageSet(),
                "爆米花儿":MyAlbumImageSet(),
                "双圈饼干":MyAlbumImageSet(),
                "沙拉":MyAlbumImageSet(),
                "草莓":MyAlbumImageSet(),
                "华夫饼":MyAlbumImageSet(),
                "西瓜":MyAlbumImageSet(),
                "不确定":MyAlbumImageSet()
            ]
        }
        do {
            let data = try Data.init(contentsOf: URL(fileURLWithPath: themePath))
            themeName = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? String
        } catch {
            print("获取data数据失败: \(error)")
            themeName = "南大紫"
        }
        currentTheme = albumThemes[themeName!]
    }
    
}

class MyAlbumImageSet: NSObject, NSSecureCoding {
    
    static var supportsSecureCoding: Bool = true
    
    override init() {
        
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(imageDates, forKey: "imageDates")
        coder.encode(imageSet, forKey: "imageSet")
    }
    
    required init?(coder: NSCoder) {
        imageDates = coder.decodeObject(forKey: "imageDates") as! [String]
        imageSet = coder.decodeObject(forKey: "imageSet") as! [String : [MyAlbumImage]]
    }
    
    
    var imageDates = [String]()
    var imageSet = [String : [MyAlbumImage]]()
    
    var count: Int {
        get {
            var num = 0
            for str in imageDates {
                num += imageSet[str]!.count
            }
            return num
        }
    }
    
    var isEmpty: Bool {
        get {
            for i in imageSet {
                if i.value.count > 0 {
                    return false
                }
            }
            return true
        }
    }
    
    func addImage(_ image: MyAlbumImage) {
        let date = image.date
        if imageDates.contains(date) {
            imageSet[date]!.append(image)
        } else {
            imageDates.append(date)
            imageSet[date] = [image]
        }
    }
    
    
    // 将指定的照片从对应的图集中删除
    func removeImage(_ image: MyAlbumImage) {
        var pos = imageSet[image.date]!.firstIndex(of: image)
        imageSet[image.date]!.remove(at: pos!)
        if imageSet[image.date]!.count == 0 {
            imageSet.removeValue(forKey: image.date)
            pos = imageDates.firstIndex(of: image.date)
            imageDates.remove(at: pos!)
        }
    }
    
}

class MyAlbumImage: NSObject, NSSecureCoding {
    
    static var supportsSecureCoding: Bool = true
    
    
    func encode(with coder: NSCoder) {
        coder.encode(image, forKey: "image")
        coder.encode(detegateResults, forKey: "detegateResults")
        coder.encode(date, forKey: "date")
        coder.encode(categories, forKey: "categories")
    }
    
    required init?(coder: NSCoder) {
        image = coder.decodeObject(forKey: "image") as! UIImage
        detegateResults = coder.decodeObject(forKey: "detegateResults") as? [VNRecognizedObjectObservation]
        date = coder.decodeObject(forKey: "date") as! String
        categories = coder.decodeObject(forKey: "categories") as! [String]
    }
    
    
    let image: UIImage
    let detegateResults: [VNRecognizedObjectObservation]?
    let date: String
    var categories: [String]
    
    init(image: UIImage, detegateResults: [VNRecognizedObjectObservation], date: String, categories: [String]) {
        self.image = image
        self.detegateResults = detegateResults
        self.date = date
        self.categories = categories
    }
    
}

// 一组主题配色方案
class AlbumTheme {
    
    let lightBackColor: UIColor!
    let darkBackColor1: UIColor!
    let darkBackColor2: UIColor!
    let lightTextColor: UIColor!
    let darkTextColor: UIColor!
    let themeColor: UIColor!
    
    init(_ lightBackColor: UIColor!, _ darkBackColor1: UIColor!, _ darkBackColor2: UIColor!, _ lightTextColor: UIColor!, _ darkTextColor: UIColor!, _ themeColor: UIColor!) {
        self.lightBackColor = lightBackColor
        self.darkBackColor1 = darkBackColor1
        self.darkBackColor2 = darkBackColor2
        self.lightTextColor = lightTextColor
        self.darkTextColor = darkTextColor
        self.themeColor = themeColor
    }
}
