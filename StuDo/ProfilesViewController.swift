//
//  ProfilesViewController.swift
//  StuDo
//
//  Created by Andrew on 5/16/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

fileprivate let personItemCellID = "feedItemCellID"

class ProfilesViewController: UIViewController {
    
    // MARK: Data & Logic
    
    var people = [Profile]()
    
    var foundPeople = [Profile]()
    
    var searchController: UISearchController!
    
    var isSearching = false {
        didSet {
            tableView.reloadData()
        }
    }
    
    
    // MARK: Visible properties
    
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        people = DataMockup().getPrototypePeople(count: 33)
        
        tableView = UITableView(frame: view.frame, style: .plain)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: personItemCellID)
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.delegate = self
        
        navigationItem.title = "People"
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
        
    }

}


extension ProfilesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return foundPeople.count
        }
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: personItemCellID, for: indexPath)
        
        var profile: Profile!
        if isSearching {
            profile = foundPeople[indexPath.row]
        } else {
            profile = people[indexPath.row]
        }
        
        cell.textLabel?.text = profile.briefDescription
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = UIViewController()
        detailVC.view.backgroundColor = .white
        detailVC.navigationItem.largeTitleDisplayMode = .never
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}



extension ProfilesViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        isSearching = true
    }

    func willDismissSearchController(_ searchController: UISearchController) {
        isSearching = false
    }
}
