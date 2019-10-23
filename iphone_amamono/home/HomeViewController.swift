//
//  HomeViewController.swift
//  iphone_amamono
//
//  Created by P1506 on 2019/10/23.
//  Copyright © 2019 archive-asia. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    let centerTabItem = UIButton.init(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupCenterTabItem(centerTabItem)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // safe place to set the frame of button manually
        setLayoutCenterTabItem(centerTabItem)
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

// MARK: Private
extension HomeViewController {
    
    func setupCenterTabItem(_ button: UIButton) {
        
        button.setTitle("||||", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.yellow, for: .highlighted)
        
        button.backgroundColor = .orange
        button.layer.cornerRadius = 32
        button.layer.borderWidth = 4
        button.layer.borderColor = UIColor.yellow.cgColor
        
        if let tabVC = self.tabBarController {
            tabVC.view.insertSubview(button, aboveSubview: tabVC.tabBar)
            
            if let items = tabVC.tabBar.items {
                let centerIndex = Int(items.count / 2)
                items[centerIndex].isEnabled = false
            }
        }
    }
    
    func setLayoutCenterTabItem(_ button: UIButton) {
        if let tabVC = self.tabBarController {
            button.frame = CGRect.init(x: tabVC.tabBar.center.x - 32, y:
                tabVC.tabBar.frame.origin.y - 32,
                                       width: 80,
                                       height: 80)
        }
    }
}
