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
        
        client.delegate = self
//        client.getAdds()
        
        tableView = UITableView(frame: view.frame, style: .plain)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: feedItemCellID)
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: feedItemCellID, for: indexPath)
        cell.textLabel?.text = feedItems[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = AdViewController()
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
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        refreshControl.endRefreshing()
    }
    
    func apiClient(_ client: APIClient, didRecieveAds ads: [Ad]) {
        feedItems = ads
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    
}
