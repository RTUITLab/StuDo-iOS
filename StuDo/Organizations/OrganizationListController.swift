//
//  OrganizationListController.swift
//  StuDo
//
//  Created by Andrew on 9/2/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

fileprivate let organizationCellId = "organizationCellId"

class OrganizationListController: UITableViewController {
    
    let client = APIClient()
    
    var organizations = [Organization]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.hideTabBar()
        
        tableView.register(TableViewCellWithSubtitle.self, forCellReuseIdentifier: organizationCellId)
        
        client.delegate = self
        
        client.getOrganizations()

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return organizations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentOrganization = organizations[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: organizationCellId, for: indexPath)
        
        cell.textLabel?.text = currentOrganization.name
        cell.detailTextLabel?.text = currentOrganization.description
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = OrganizationViewController(organization: organizations[indexPath.row])
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
}



extension OrganizationListController: APIClientDelegate {
    func apiClient(_ client: APIClient, didRecieveOrganizations organizations: [Organization]) {
        self.organizations = organizations
        tableView.reloadData()
    }
}
