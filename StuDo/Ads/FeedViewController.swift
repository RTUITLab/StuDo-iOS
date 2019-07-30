//
//  FeedViewController.swift
//  StuDo
//
//  Created by Andrew on 5/16/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

fileprivate let feedItemCellID = "feedItemCellID"

class FeedViewController: UIViewController {
    
    // MARK: Data & Logic
    
    var feedItems = [Ad]()
    var client = APIClient()
        
    
    // MARK: Visible properties

    var tableView: UITableView!
    let refreshControl = UIRefreshControl()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: view.frame, style: .plain)
        
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AdTableViewCell.self, forCellReuseIdentifier: feedItemCellID)
        tableView.rowHeight = 100
        
        refreshControl.addTarget(self, action: #selector(refreshAds), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.backgroundView = refreshControl
        }
        
        navigationItem.title = "Ads"
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if PersistentStore.shared.user != nil {
            refreshAds()
        }

    }
    
    @objc func refreshAds() {
        if GCIsUsingFakeData {
            feedItems = DataMockup().getPrototypeAds(count: 4)
            tableView.reloadData()
        } else {
            client.delegate = self
            client.getAdds()
        }
    }

}


extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: feedItemCellID, for: indexPath) as! AdTableViewCell
        cell.titleLabel.text = feedItems[indexPath.row].name
        cell.shortDescriptionLabel.text = feedItems[indexPath.row].shortDescription
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = AdViewController()
        detailVC.showedAd = feedItems[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        self.present(detailVC, animated: true, completion: nil)
    }
}


extension FeedViewController: APIClientDelegate {
    
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        refreshControl.endRefreshing()
    }
    
    func apiClient(_ client: APIClient, didRecieveAds ads: [Ad]) {
        feedItems = ads
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    
}
