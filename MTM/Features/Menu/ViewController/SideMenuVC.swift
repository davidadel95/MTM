//
//  SideMenuVC.swift
//  MTM
//
//  Created by David Adel on 03/02/2021.
//

import UIKit
import SideMenuSwift

class SideMenuVC: UIViewController {
    
    
    // MARK: - Outlets
    @IBOutlet var filterTableView: UITableView!
    // MARK: - Variables
    let menuItems = ["Home", "Account", "Settings"]
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        
    }
    
    func setupTableView(){
        filterTableView.delegate = self
        filterTableView.dataSource = self
        
        filterTableView.separatorStyle = .none
        filterTableView.registerCellNib(cellClass: MenuTVC.self)
    }


}
extension SideMenuVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTVC") as! MenuTVC
        
        cell.selectionStyle = .none
        cell.menuLbl.text = self.menuItems[indexPath.row]
        
        return cell
    }
    
    
}

extension SideMenuVC: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}
