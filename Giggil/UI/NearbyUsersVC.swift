//
//  NearbyUsersVC.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 12/30/19.
//  Copyright © 2019 Fitchmun. All rights reserved.
//

import Foundation
import UIKit

class NearbyUsersVC: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "DarkBlue")!
        
        tableView.register(
            NearbyUserCell.self,
            forCellReuseIdentifier: NearbyUserCell.identifier)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else { return }

        
        tableView.dataSource = appDelegate.profileCollector
        
        appDelegate.profileCollector?.add(reload)
        

    }
    
    func reload(message: GiggilMessage) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        nil
    }
    
}
