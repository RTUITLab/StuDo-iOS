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
    var organizationsDictionary = [String: [Organization]]()
    var organizationsSectionTitles = [String]()
    
    let searchResultsController = UITableViewController(style: .plain)
    lazy var searchController = UISearchController(searchResultsController: nil)
    
    var isSearchModeActive = false
    var filteredResults = [Organization]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.hideTabBar()
        
        tableView.register(TableViewCellWithSubtitle.self, forCellReuseIdentifier: organizationCellId)
        tableView.tableFooterView = UIView()
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(refreshOrganizationList), for: .valueChanged)
        
        client.delegate = self
        
        title = Localizer.string(for: .back)
        navigationItem.titleView = UIView()
        navigationItem.hidesSearchBarWhenScrolling = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createOrganizationButtonTapped(_:)))
        
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        if #available(iOS 10.0, *) {
            navigationItem.searchController = searchController
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        
        searchController.searchBar.placeholder = Localizer.string(for: .search)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshOrganizationList()
    }
    
    
    @objc func refreshOrganizationList() {
        refreshControl?.endRefreshing()
        client.getOrganizations()
    }
    
    
    fileprivate func setData(_ organizations: [Organization]) {
        
        self.organizations = organizations
        organizationsDictionary = [String: [Organization]]()
        organizationsSectionTitles = [String]()
        
        for object in organizations {
            let key = String(object.name.prefix(1)).uppercased()
            if var sectionValues = organizationsDictionary[key] {
                sectionValues.append(object)
                organizationsDictionary[key] = sectionValues
            } else {
                organizationsSectionTitles.append(key)
                organizationsDictionary[key] = [object]
            }
        }
        
        organizationsSectionTitles = organizationsSectionTitles.sorted(by: { $0 < $1 })
        
        for key in [String](organizationsDictionary.keys) {
            let sectionValues = organizationsDictionary[key]!
            organizationsDictionary[key] = sectionValues.sorted(by: { $0.name < $1.name })
        }
        
        tableView.reloadData()
    }
    
    fileprivate func filterResults(for searchString: String) {
        
        filteredResults = [Organization]()
        
        let searchStringNormalized = searchString.lowercased()
        for object in organizations {
            if object.name.lowercased().contains(searchStringNormalized) || object.description.lowercased().contains(searchStringNormalized) {
                filteredResults.append(object)
            }
        }
    }
    
    fileprivate func organization(for indexPath: IndexPath) -> Organization {
        if isSearchModeActive {
            return filteredResults[indexPath.row]
        }
        let currentSectionKey = organizationsSectionTitles[indexPath.section]
        let currentOrganization = organizationsDictionary[currentSectionKey]![indexPath.row]
        return currentOrganization
    }
    
    
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isSearchModeActive {
            return 1
        }
        return organizationsSectionTitles.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchModeActive {
            return filteredResults.count
        }
        let currentSectionKey = organizationsSectionTitles[section]
        return organizationsDictionary[currentSectionKey]!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentOrganization = organization(for: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: organizationCellId, for: indexPath)
        
        cell.textLabel?.text = currentOrganization.name
        cell.detailTextLabel?.text = currentOrganization.description
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = OrganizationViewController(organization: organization(for: indexPath))
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isSearchModeActive {
            return nil
        }
        return organizationsSectionTitles[section]
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if isSearchModeActive {
            return nil
        }
        return organizationsSectionTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
}



extension OrganizationListController: APIClientDelegate {
    
    func apiClient(_ client: APIClient, didRecieveOrganizations organizations: [Organization]) {
        setData(organizations)
    }
}


extension OrganizationListController {
    @objc func createOrganizationButtonTapped(_ button: UIBarButtonItem) {
        let organizationVC = OrganizationViewController(organization: nil)
        navigationController?.pushViewController(organizationVC, animated: true)
    }
}




extension OrganizationListController: UISearchControllerDelegate, UISearchResultsUpdating {
    
    func willPresentSearchController(_ searchController: UISearchController) {
        isSearchModeActive = true
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        isSearchModeActive = false
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchedText = searchController.searchBar.text, !searchedText.isEmpty {
            isSearchModeActive = true
            filterResults(for: searchController.searchBar.text!)
            tableView.reloadData()
        } else {
            isSearchModeActive = false
            tableView.reloadData()
        }
    }
}
