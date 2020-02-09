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

class AdViewController2: CardViewController {
    
    // MARK: Visible elements
    
    private let tableView: UITableView!
    private var commentInputTextView: UITextView!
    private var commentPlaceholderLabel: UILabel!
    private var commentPublishButton: UIButton!
    
    override var contentHeight: CGFloat {
        return tableView.contentSize.height
    }
    
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
        
        super.init()
        
        client.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // TODO: Remove
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CELL")
        
        tableView.register(UINib(nibName: String(describing: AdBodyCell.self), bundle: nil), forCellReuseIdentifier: bodyCellId)
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: commentCellId)
        tableView.register(CommentInputTableViewCell.self, forCellReuseIdentifier: commentInputCellId)
        
        if #available(iOS 13.0, *) {
            tableView.backgroundColor = .secondarySystemBackground
        }
        tableView.tableFooterView = UIView()
        
        setupInitialLayout()
        setupVisualElements()
    }
    
    // MARK: Layout
    
    private func setupInitialLayout() {
        contentView.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: 0).isActive = true
        tableView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        
        tableView.rowHeight = UITableView.automaticDimension

    }
    
    private func setupVisualElements() {
        tableView.separatorInset = .zero
    }

    
    private func scrollToBottom(_ additionalOffset: CGFloat = 0) {
        let visibleSize = containerView.bounds.height - visibleKeyboardHeight
        let contentHeight = self.contentHeight
        guard contentHeight > visibleSize else { return }
        if contentHeight > visibleSize {
            let bottomOffset = CGPoint(x: 0, y: contentHeight - visibleSize + additionalOffset)
            containerView.setContentOffset(bottomOffset, animated: true)
        }
    }
    
    // MARK: CardView Overrides
    
    override func didShowKeyboard() {
        if currentState == .commenting {
            self.scrollToBottom()
        }
    }
    
    override func shouldAllowDismissOnSwipe() -> Bool {
        switch currentState {
        case .commenting, .editing, .publishing:
            return false
        case .viewing, .previewing:
            return true
        }
    }
    
    // MARK: - Model-related methods
    
    
    private func set(ad: Ad) {
        currentAd = ad
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
    
    
    // MARK: Actions
    
    
    
    
    

}

// MARK: - Table view data source

extension AdViewController2: UITableViewDataSource {

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

extension AdViewController2: UITableViewDelegate {
    
}

// MARK: TextViewDelegate

extension AdViewController2: UITextViewDelegate {
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
    
}

// MARK: APIClientDelegate

extension AdViewController2: APIClientDelegate {
    func apiClient(_ client: APIClient, didRecieveAd ad: Ad) {
        set(ad: ad)
    }
}


