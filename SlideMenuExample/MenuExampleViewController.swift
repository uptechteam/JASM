//
//  ViewController.swift
//  SlideMenuExample
//
//  Created by Евгений Матвиенко on 11/14/16.
//  Copyright © 2016 SilverDefender. All rights reserved.
//

import UIKit
import SideMenu

class MenuExampleViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate   = self
        tableView.dataSource = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

// MARK: - UITableViewDataSource and Delegate

extension MenuExampleViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        
        cell.textLabel?.text = "Cell #\(indexPath.row)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sideMenuController?.present(viewControllerAtIndex: indexPath.row)
    }
    
}

