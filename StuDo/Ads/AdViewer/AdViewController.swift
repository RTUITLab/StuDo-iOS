//
//  AdViewController2.swift
//  StuDo
//
//  Created by Andrew on 2/9/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import MarkdownKit

private let bodyCellId = "bodyCellId"
private let editableBodyCellId = "editableBodyCellId"
private let commentCellId = "commentCellId"
private let commentInputCellId = "commentInputCellId"

class AdViewController: UIViewController {
    
    // MARK: Visible elements
    
    private let tableView: UITableView
    
    private var headerView: AdControllerHeaderView!
    private var commentInputTextView: UITextView!
    private var commentPlaceholderLabel: UILabel!
    private var commentPublishButton: UIButton!
    
    // MARK: - State properties
    // This properties allow the controller to switch between two states
    // One allows to view the ad, the other allows to edit or publish
    
    private var currentAd: Ad!
    private var currentAdComments: [Comment] = []
    private var currentAdPeople: [User] = []
    
    private let client = APIClient()
    
    enum AdViewControllerSection {
        case body
        case editableBody
        case people
        case comments
        case commentInput
        case preferences
    }
    
    private let viewStateSections: [AdViewControllerSection] = [
        .body, .people, .comments, .commentInput
    ]
    
    private let editStateSections: [AdViewControllerSection] = [
        .editableBody, .preferences
    ]
    
    var currentSections: [AdViewControllerSection] {
        switch currentState {
        case .editing, .publishing:
            return editStateSections
        case .viewing, .previewing, .commenting:
            return viewStateSections
        }
    }
    
    private func getSectionIndex(for section: AdViewControllerSection) -> IndexSet? {
        for (i, sec) in currentSections.enumerated() {
            if sec == section {
                return IndexSet(integer: i)
            }
        }
        return nil
    }
    
    enum AdViewControllerState {
        case previewing
        case viewing
        case commenting
        case editing
        case publishing
    }
    
    var currentState: AdViewControllerState
    
    
    // MARK: - ViewController Lifecycle
    
    init(ad: Ad?) {
        if ad == nil {
            currentState = .publishing
        } else {
            currentAd = ad
            currentState = .previewing
            client.getAd(withId: currentAd.id) // get full data of the ad
        }
        
        tableView = UITableView(frame: .zero, style: .plain)
        super.init(nibName: nil, bundle: nil)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        client.delegate = self
        presentationController?.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Initial Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Order is important
        setHeaderView()
        setTableView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        
    }
        
    private func setTableView() {
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // TODO: Remove
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CELL")
        
        tableView.register(UINib(nibName: String(describing: AdBodyCell.self), bundle: nil), forCellReuseIdentifier: bodyCellId)
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: commentCellId)
        tableView.register(CommentInputTableViewCell.self, forCellReuseIdentifier: commentInputCellId)
        
        tableView.backgroundColor = .secondarySystemBackground
        tableView.tableFooterView = UIView()
        
    }
    
    private func setHeaderView() {
        headerView = AdControllerHeaderView(frame: .zero)
        view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        headerView.layer.shadowColor = UIColor(red:0.447, green:0.447, blue:0.443, alpha:0.4).cgColor
        headerView.layer.shadowRadius = 5
        headerView.backgroundColor = .red
        
    }
        
    // MARK: - Model-related methods
    
    private func set(ad: Ad) {
        currentAd = ad
        headerView.titleText = ad.name
        if ad.comments != currentAdComments {
            currentAdComments = ad.comments ?? []
            if let commentsSectionIndex = getSectionIndex(for: .comments) {
                tableView.reloadSections(commentsSectionIndex, with: .fade)
            }
        }
        
        if currentState == .previewing {
            currentState = .viewing
            if let bodySectionIndex = getSectionIndex(for: .body) {
                tableView.reloadSections(bodySectionIndex, with: .fade)
            }
        }
    }
    
    private func checkCanPublishComment(_ comment: String) -> Bool {
        return comment.count > 0
    }
    
    private func commentInputUpdated(with comment: String) {
        
        commentPublishButton.animateVisibility(shouldHide: !checkCanPublishComment(comment))
        
        if !commentInputTextView.text.isEmpty {
            commentPlaceholderLabel.isHidden = true
        } else {
            commentPlaceholderLabel.isHidden = false
        }
        
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
    
    // MARK: Actions & Observers
    
    @objc func keyboardWillShow(_ notification:Notification) {

        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.cgRectValue.height, right: 0)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    

}

// MARK: - Table view data source

extension AdViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return currentSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentSections[section] {
        case .body, .editableBody, .preferences, .commentInput:
            return 1
        case .comments:
            return currentAdComments.count
        case .people:
            return currentAdPeople.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var returnCell: UITableViewCell!
        switch currentSections[indexPath.section] {
        case .comments:
            let comment = currentAdComments[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: commentCellId, for: indexPath) as! CommentTableViewCell
            cell.bodyTextView.text = comment.text
            cell.nameLabel.text = comment.author

            // TODO: This code should be put in a separate file and refactored
            // NOTE: The cell class is subclass of UserTableViewCell
            let formatter = DateFormatter()
            formatter.locale = Localizer.currentLocale
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            cell.dateLabel.text = formatter.string(from: comment.commentTime)
            
            let nameParts = comment.author.components(separatedBy: " ")
            if nameParts.count == 1 {
                cell.initialsLabel.text = String(nameParts.first!.suffix(1))
            } else if nameParts.count == 2 {
                let name = nameParts.last!
                let surname = nameParts.first!
                cell.initialsLabel.text = String(name.prefix(1)) + surname.prefix(1)
                
                cell.nameLabel.text = "\(name) \(surname)"
            }
            
            cell.isAvatarHighlighted = (comment.authorId == PersistentStore.shared.user.id)
            
            cell.selectionStyle = .none
            
            returnCell = cell as UITableViewCell
        case .commentInput:
            let cell = tableView.dequeueReusableCell(withIdentifier: commentInputCellId, for: indexPath) as! CommentInputTableViewCell
            
            commentPlaceholderLabel = cell.placeholderLabel
            cell.placeholderLabel.text = Localizer.string(for: .adEditorCommentPlaceholder)
            cell.placeholderLabel.isHidden = false
            
            commentInputTextView = cell.textViewInput
            commentInputTextView.delegate = self
                        
            cell.selectionStyle = .none
            
            commentPublishButton = cell.publishButton
//            commentPublishButton.addTarget(self, action: #selector(publishCommentButtonTapped(_ :)), for: .touchUpInside)

            returnCell = cell as UITableViewCell
        case .body:
            let cell = tableView.dequeueReusableCell(withIdentifier: bodyCellId, for: indexPath) as! AdBodyCell
            cell.titleLabel.text = currentAd.name
            cell.dateLabel.text = currentAd.dateRange
            cell.selectionStyle = .none
            
            // TODO: Stash this formatting code in a separate class
            var description: String!
            if currentState == .previewing {
                description = currentAd.shortDescription
            } else {
                description = currentAd.description
            }
            
            var markdownParser: MarkdownParser!
            if #available(iOS 13.0, *) {
                markdownParser = MarkdownParser(font: UIFont.preferredFont(for: .body, weight: .light), color: .label)
            } else {
                markdownParser = MarkdownParser(font: UIFont.preferredFont(for: .body, weight: .light))
            }
            markdownParser.enabledElements = .all
            markdownParser.bold.font = UIFont.preferredFont(for: .body, weight: .medium)
            markdownParser.italic.font = UIFont.preferredFont(for: .body, weight: .light).italic()
            markdownParser.header.font = UIFont.preferredFont(for: .title3, weight: .medium)
            markdownParser.quote.font = UIFont.preferredFont(for: .body, weight: .light).italic()
            markdownParser.quote.color = .lightGray
            markdownParser.link.color = .globalTintColor
            
            let attrDescription = NSMutableAttributedString(string: description)
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 6
            attrDescription.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: attrDescription.length))
            
            cell.bodyTextView.attributedText = markdownParser.parse(attrDescription)
            
            
            returnCell = cell as UITableViewCell
        case .editableBody: fallthrough
        case .people: fallthrough
        case .preferences:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
            return cell
        }
        
        if #available(iOS 13, *) {
            returnCell.contentView.backgroundColor = .secondarySystemBackground
        }
        
        return returnCell
    }
    
}

// MARK: UITableViewDelegate

extension AdViewController: UITableViewDelegate {
    
}

// MARK: TextViewDelegate

extension AdViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView === commentInputTextView {
            commentInputUpdated(with: textView.text)
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView === commentInputTextView {
            currentState = .commenting
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView === commentInputTextView {
            currentState = .viewing
        }
        return true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === tableView {
            headerView.toggleState(showTitle: scrollView.contentOffset.y > 0)
        }
    }
    
}

// MARK: UIPresentationCo

extension AdViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        switch currentState {
        case .editing, .publishing:
            return false
        default:
            return true
        }
    }
}

// MARK: APIClientDelegate

extension AdViewController: APIClientDelegate {
    func apiClient(_ client: APIClient, didRecieveAd ad: Ad) {
        set(ad: ad)
    }
}


