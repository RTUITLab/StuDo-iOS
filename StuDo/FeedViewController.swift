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
    
    var animator = CardTransitionAnimator()
    
    
    // MARK: Visible properties

    var tableView: UITableView!
    let refreshControl = UIRefreshControl()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: view.frame, style: .plain)
        
        if PersistentStore.shared.isUsingFakeData {
            generateFakeData()
        } else {
            client.delegate = self
            client.getAdds()
        }
        
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AdTableViewCell.self, forCellReuseIdentifier: feedItemCellID)
        tableView.rowHeight = 100
        
        refreshControl.addTarget(self, action: #selector(refreshAds(_:)), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.backgroundView = refreshControl
        }
        
        navigationItem.title = "Ads"
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.prefersLargeTitles = true

    }
    
    @objc func refreshAds(_ sender: Any) {
        client.getAdds()
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
        detailVC.transitioningDelegate = self
        self.present(detailVC, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension FeedViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isPresenting = false
        return animator
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isPresenting = true
        return animator
    }
}



extension FeedViewController: APIClientDelegate {
    fileprivate func generateFakeData() {
        for fakeAd in DataMockup().getPrototypeAds(count: 4) {
            let ad = Ad(id: "", name: fakeAd.headline, description: fakeAd.description, shortDescription: fakeAd.description, beginTime: nil, endTime: nil, userId: "", user: nil, organizationId: nil, organization: nil)
            feedItems.append(ad)
        }
        tableView.reloadData()
    }
    
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        refreshControl.endRefreshing()
        generateFakeData()
    }
    
    func apiClient(_ client: APIClient, didRecieveAds ads: [Ad]) {
        feedItems = ads
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    
}
