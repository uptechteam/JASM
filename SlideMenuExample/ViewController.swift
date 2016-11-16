//
//  ViewController.swift
//  SideMenu
//
//  Created by Евгений Матвиенко on 11/16/16.
//  Copyright © 2016 SilverDefender. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Menu", style: .plain, target: self, action: #selector(handleBarButtonPressed(_:)))
    }
    
    // MARK: - User Interaction
    
    func handleBarButtonPressed(_ barButtonItem: UIBarButtonItem) {
        sideMenuController?.toggleMenu(on: true, animated: true)
    }
    
}
