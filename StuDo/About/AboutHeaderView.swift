//
//  AboutHeaderView.swift
//  StuDo
//
//  Created by Andrew on 8/19/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class AboutHeaderView: UITableViewHeaderFooterView {
    
    let logoImage = UIImageView()
    let versionLabel = UILabel()

    func setVersion(_ version: String, _ build: String) {
        let attributedString = NSMutableAttributedString(string: Localizer.string(for: .aboutVersion), attributes: [
            .foregroundColor: UIColor.secondaryLabel,
            .font: UIFont.systemFont(ofSize: 16, weight: .regular)
            ])
        
        let versionNumberString = NSAttributedString(string: " \(version)", attributes: [
            .foregroundColor: UIColor.secondaryLabel,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ])
        
        let buildString = NSMutableAttributedString(string: " (\(build))", attributes: [
        .foregroundColor: UIColor.secondaryLabel,
        .font: UIFont.systemFont(ofSize: 16, weight: .regular)
        ])
        
        attributedString.append(versionNumberString)
        attributedString.append(buildString)
        versionLabel.attributedText = attributedString
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(logoImage)
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        logoImage.heightAnchor.constraint(equalToConstant: 180).isActive = true
//        logoImage.widthAnchor.constraint(equalTo: logoImage.heightAnchor).isActive = true
        logoImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18).isActive = true
        logoImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        logoImage.image = #imageLiteral(resourceName: "logo")
        logoImage.contentMode = .scaleAspectFit
        
        
        contentView.addSubview(versionLabel)
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        versionLabel.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 8).isActive = true
        versionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -18).isActive = true
        
        versionLabel.textAlignment = .center
        versionLabel.text = ""
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
