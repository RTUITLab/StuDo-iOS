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
    
    private let profileLabel = UILabel()
    private let profileImageHeightAndWidth: CGFloat = 60
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(profileImage)
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.widthAnchor.constraint(equalToConstant: profileImageHeightAndWidth).isActive = true
        profileImage.heightAnchor.constraint(equalTo: profileImage.widthAnchor, multiplier: 1).isActive = true
        profileImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        profileImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        profileImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        
        
        profileImage.layer.masksToBounds = false
        profileImage.layer.cornerRadius = profileImageHeightAndWidth / 2
        profileImage.clipsToBounds = true
        profileImage.contentMode = .scaleAspectFill
        
        
        contentView.addSubview(profileLabel)
        profileLabel.translatesAutoresizingMaskIntoConstraints = false
        profileLabel.centerXAnchor.constraint(equalTo: profileImage.centerXAnchor).isActive = true
        profileLabel.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor).isActive = true
        
        profileLabel.font = .systemFont(ofSize: 20, weight: .bold)
        profileLabel.textColor = .white
        profileLabel.isHidden = false
        
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
            
            
            nameField.clearButtonMode = .whileEditing
            surnameField.clearButtonMode = .whileEditing
            
            nameField.placeholder = "First name"
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




fileprivate let orangeGradient = (UIColor(red:0.988, green:0.871, blue:0.541, alpha:1.000), UIColor(red:0.953, green:0.510, blue:0.506, alpha:1.000))
fileprivate let pinkGradient = (UIColor(red:0.965, green:0.314, blue:0.627, alpha:1.000), UIColor(red:1.000, green:0.455, blue:0.475, alpha:1.000))
fileprivate let ocyanGradient = (UIColor(red:0.102, green:0.906, blue:0.855, alpha:1.000), UIColor(red:0.357, green:0.502, blue:0.914, alpha:1.000))
fileprivate let greenGradient = (UIColor(red:0.259, green:0.890, blue:0.592, alpha:1.000), UIColor(red:0.235, green:0.714, blue:0.710, alpha:1.000))





extension CurrentUserTableViewCell {
    func generateProfileImage(for user: User) {
        let gradientLayer = CAGradientLayer()
        
        let gradients = [orangeGradient, pinkGradient, ocyanGradient, greenGradient]
        
        
        var gradientIndex: Int!
        if let index = PersistentStore.shared.profilePictureGradientIndex {
            gradientIndex = index
        } else {
            gradientIndex = Int.random(in: 0..<gradients.count)
            PersistentStore.shared.profilePictureGradientIndex = gradientIndex
        }
        let gradient = gradients[gradientIndex]
        
        gradientLayer.colors = [gradient.0.cgColor, gradient.1.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        gradientLayer.frame = CGRect(x: 0, y: 0, width: profileImageHeightAndWidth, height: profileImageHeightAndWidth)
        
        profileImage.layer.addSublayer(gradientLayer)
        
        
        profileLabel.text = String(user.firstName.prefix(1)) + user.lastName.prefix(1)
        profileLabel.isHidden = false
        
    }
}
