//
//  CurrentUserTableViewCell.swift
//  StuDo
//
//  Created by Andrew on 7/11/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class CurrentUserTableViewCell: UITableViewCell {
    
    let profileImage = UIImageView()
    let fullnameLabel = UILabel()
    let emailLabel = UILabel()
    let nameField = UITextField()
    let surnameField = UITextField()
    
    var isEditingAlailable = false
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let profileImageHeightAndWidth: CGFloat = 60
        
        contentView.addSubview(profileImage)
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.widthAnchor.constraint(equalToConstant: profileImageHeightAndWidth).isActive = true
        profileImage.heightAnchor.constraint(equalTo: profileImage.widthAnchor, multiplier: 1).isActive = true
        profileImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        profileImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        profileImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        
        
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor(red:0.965, green:0.965, blue:0.965, alpha:1.000).cgColor
        profileImage.layer.masksToBounds = false
        profileImage.layer.cornerRadius = profileImageHeightAndWidth / 2
        profileImage.clipsToBounds = true
        profileImage.contentMode = .scaleAspectFill
    }
    
    func setupCell() {
        if !isEditingAlailable {
            addSubview(fullnameLabel)
            fullnameLabel.translatesAutoresizingMaskIntoConstraints = false
            fullnameLabel.topAnchor.constraint(equalTo: profileImage.topAnchor, constant: 5).isActive = true
            fullnameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 10).isActive = true
            
            fullnameLabel.font = .systemFont(ofSize: 18, weight: .medium)
            
            addSubview(emailLabel)
            emailLabel.translatesAutoresizingMaskIntoConstraints = false
            emailLabel.topAnchor.constraint(equalTo: fullnameLabel.bottomAnchor, constant: 6).isActive = true
            emailLabel.leadingAnchor.constraint(equalTo: fullnameLabel.leadingAnchor).isActive = true
            
            emailLabel.font = .systemFont(ofSize: 14, weight: .medium)
            emailLabel.textColor = UIColor(red:0.489, green:0.494, blue:0.490, alpha:1.000)
            
        } else {
            let separator = UIView()
            separator.backgroundColor = UIColor(red:0.867, green:0.867, blue:0.867, alpha:1.000)
            
            addSubview(separator)
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
            separator.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 10).isActive = true
            separator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            
            let distanceFromSeparator: CGFloat = 8
            
            addSubview(nameField)
            nameField.translatesAutoresizingMaskIntoConstraints = false
            nameField.leadingAnchor.constraint(equalTo: separator.leadingAnchor).isActive = true
            nameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
            nameField.bottomAnchor.constraint(equalTo: separator.topAnchor, constant: -distanceFromSeparator).isActive = true
            
            
            addSubview(surnameField)
            surnameField.translatesAutoresizingMaskIntoConstraints = false
            surnameField.leadingAnchor.constraint(equalTo: separator.leadingAnchor).isActive = true
            surnameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
            surnameField.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: distanceFromSeparator).isActive = true
            
            
            
            nameField.placeholder = "First name"
            nameField.becomeFirstResponder()
            
            surnameField.placeholder = "Last name"
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
