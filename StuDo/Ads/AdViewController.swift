//
//  AdViewController.swift
//  StuDo
//
//  Created by Andrew on 5/28/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class AdViewController: CardViewController {
    
    // MARK: Data & Logic
    
    var showedAd: Ad?
    
    var isBeingTransitioned = false
    var isEditingAllowed = false
    var isEditingEnabled = false
    
    
    // MARK: Visible properties
    
    var nameLabel = UITextField()
    var descriptionLabel = UITextView()
    var editButton = UIButton()
    var deleteButton = UIButton()
    
    let client = APIClient()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        client.delegate = self
        
        if showedAd?.userId == PersistentStore.shared.user.id {
            isEditingAllowed = true
        }
        
        
        
        // Layout
        
        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16).isActive = true
        nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        if isEditingAllowed {
            contentView.addSubview(editButton)
            editButton.translatesAutoresizingMaskIntoConstraints = false
            editButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10).isActive = true
            editButton.centerYAnchor.constraint(equalTo:
                nameLabel.centerYAnchor).isActive = true
            
            contentView.addSubview(deleteButton)
            deleteButton.translatesAutoresizingMaskIntoConstraints = false
            deleteButton.trailingAnchor.constraint(equalTo: editButton.leadingAnchor, constant: -12).isActive = true
            deleteButton.centerYAnchor.constraint(equalTo:
                editButton.centerYAnchor).isActive = true
            
            editButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
            deleteButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
            
            
            nameLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -12).isActive = true
        } else {
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10).isActive = true
        }
        
        contentView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: -2).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6).isActive = true
        
        // Look customization
        
        nameLabel.font = .systemFont(ofSize: 22, weight: .medium)
        descriptionLabel.isScrollEnabled = false
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 12
        let attributedText = NSAttributedString(string: showedAd?.shortDescription ?? "",
                                                attributes: [
                                                    .paragraphStyle:style,
                                                    .font: UIFont.systemFont(ofSize: 16, weight: .light)
                                                ])
        descriptionLabel.attributedText = attributedText
        
        nameLabel.isUserInteractionEnabled = false
        descriptionLabel.isUserInteractionEnabled = false
        
        
        nameLabel.text = showedAd?.name
        
        editButton.setTitleColor(editButton.tintColor, for: .normal)
        editButton.setTitleColor(.white, for: .highlighted)
        editButton.setTitleColor(.white, for: .selected)
        
        editButton.clipsToBounds = true
        
        editButton.setTitle("Edit", for: .normal)
        editButton.setTitle("Done", for: .selected)
        editButton.layer.cornerRadius = 6
        editButton.layer.borderWidth = 1.5
        editButton.layer.borderColor = editButton.tintColor.cgColor
        
        
        
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.setTitleColor(UIColor(red: 1, green: 0, blue: 0, alpha: 0.5), for: .highlighted)
        
        deleteButton.clipsToBounds = true
        
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.layer.cornerRadius = 6
        deleteButton.layer.borderWidth = 1.5
        deleteButton.layer.borderColor = UIColor.red.cgColor
        
        if isEditingAllowed {
            editButton.isHidden = false
            editButton.addTarget(self, action: #selector(enableEditButtonPressed(_:)), for: .touchUpInside)
            
            deleteButton.addTarget(self, action: #selector(deleteButtonPressed(_:)), for: .touchUpInside)
            
            nameLabel.placeholder = "Name for your advertisement"
        } else {
            editButton.isHidden = true
        }
    }
    
    @objc func enableEditButtonPressed(_ button: UIButton) {
        
        if isEditingEnabled {
            if let ad = showedAd {
                
                // TODO: Change the date to actual data
                let adToEdit = Ad(id: ad.id, name: nameLabel.text!, fullDescription: "full Description", shortDescription: descriptionLabel.text!, beginTime: Date(), endTime: Date(timeInterval: 50000, since: Date()), userId: PersistentStore.shared.user.id!, user: nil, organizationId: nil, organization: nil)
                client.replaceAd(with: adToEdit)

            }
        }
        
        isEditingEnabled = !isEditingEnabled
        
        nameLabel.isUserInteractionEnabled = isEditingEnabled
        descriptionLabel.isUserInteractionEnabled = isEditingEnabled
        editButton.isSelected = isEditingEnabled

        if isEditingEnabled {
            editButton.backgroundColor = editButton.tintColor
            nameLabel.becomeFirstResponder()
        } else {
            editButton.backgroundColor = nil
        }
    }
    
    @objc func deleteButtonPressed(_ button: UIButton) {
        
        client.delete(ad: showedAd!)
    }

}




extension AdViewController: APIClientDelegate {
    func apiClient(_ client: APIClient, didUpdateAd: Ad) {
        print("updated successfully!")
    }
    
    func apiClient(_ client: APIClient, didDeleteAd: Ad) {
        print("deleted successfully!")
        dismiss(animated: true, completion: nil)
    }
    
    func apiClient(_ client: APIClient, didFailRequest request: APIRequest, withError error: Error) {
        print(error)
    }
    
    
}
