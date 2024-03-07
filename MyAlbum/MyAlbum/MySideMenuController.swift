//
//  MySideMenuController.swift
//  MyAlbum
//
//  Created by Kekwy on 2023/1/10.
//

import UIKit
import SideMenu

class MySideMenuController: SideMenuNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        SideMenuPresentationStyle
        presentationStyle = .viewSlideOut
        menuWidth = 200
//        blurEffectStyle = .
//        animationOptions = .transitionCrossDissolve
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    
    func provideViewData(album: AlbumViewController, selectedRowNum: Int) {
        (self.topViewController as? MenuTableController)?.provideViewData(album: album, selectedRowNum: selectedRowNum)
    }
    
}
