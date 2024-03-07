//
//  NavigationController.swift
//  MyAlbum
//
//  Created by Kekwy on 2023/1/10.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // print(self.navigationBar.barStyle.rawValue)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 121.0/255.0, green: 131.0/255.0, blue: 108.0/255.0, alpha: 1.0)
        
        var titleTA = appearance.titleTextAttributes
        titleTA [NSAttributedString.Key.font] = UIFont(name: "PingFangSC-Medium", size: 20.0)
        titleTA [NSAttributedString.Key.foregroundColor] = UIColor.white
        appearance.titleTextAttributes = titleTA
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.isTranslucent = true
        
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
