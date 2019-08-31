//
//  AdTableViewCell.swift
//  StuDo
//
//  Created by Andrew on 7/11/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class AdTableViewCell: UITableViewCell {
    
    let titleLabel = UILabel()
    let descriptionTextView = UITextView()
    let additionalInfoLabel = UILabel()
    
    let bottomSeparator = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        
        
        
        contentView.addSubview(descriptionTextView)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 11).isActive = true
        descriptionTextView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 0).isActive = true
        descriptionTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0).isActive = true
        
        
        contentView.addSubview(additionalInfoLabel)
        additionalInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        additionalInfoLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 0).isActive = true
        additionalInfoLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: -4).isActive = true
        additionalInfoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        
        
        
        
        contentView.addSubview(bottomSeparator)
        bottomSeparator.translatesAutoresizingMaskIntoConstraints = false
        bottomSeparator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        bottomSeparator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        bottomSeparator.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        bottomSeparator.heightAnchor.constraint(equalToConstant: 0.8).isActive = true
        
        bottomSeparator.backgroundColor = UIColor(red:0.820, green:0.820, blue:0.820, alpha:1.000)
        
        
        
        
        
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        
        descriptionTextView.isUserInteractionEnabled = false
        descriptionTextView.font = .preferredFont(forTextStyle: .body)
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.layoutManager.delegate = self
        
        additionalInfoLabel.textColor = UIColor(red:0.467, green:0.467, blue:0.471, alpha:1.000)
        additionalInfoLabel.font = .preferredFont(forTextStyle: .footnote)
        
        selectionStyle = .none
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func set(ad: Ad) {
        titleLabel.text = ad.name
        descriptionTextView.text = ad.shortDescription
        
        let formatter = DateFormatter()
        
        let currentLanguage = PersistentStore.shared.currentLanguage
        var currentLocale = Locale.current
        if currentLanguage == .English {
            currentLocale = Locale(identifier: "en")
        } else if currentLanguage == .Russian {
            currentLocale = Locale(identifier: "ru")
        }
        formatter.locale = currentLocale
        
        
        var dateFormat = "MMM d, H:mm"
        if currentLanguage == .English {
            dateFormat = "MMM d, h:mm a"
        }
        formatter.dateFormat = dateFormat
        
        
        let timeString = formatter.string(from: ad.beginTime)
        
        var creator: String!
        if let userName = ad.userName {
            creator = userName
        } else if let organizationName = ad.organizationName {
            creator = organizationName
        }
        
        let additionalLabelFontStyle: UIFont.TextStyle = .caption2
        
        let attributedString = NSMutableAttributedString(string: timeString, attributes: [
            .font: UIFont.preferredFont(forTextStyle: additionalLabelFontStyle)
            ])
        attributedString.append(NSAttributedString(string: " ‧ ", attributes: [
            NSAttributedString.Key.font: UIFont.preferredFont(for: additionalLabelFontStyle, weight: .bold)
            ]))
        attributedString.append(NSAttributedString(string: creator, attributes: [
            .font : UIFont.preferredFont(for: additionalLabelFontStyle, weight: .semibold)
            ]))
            
        additionalInfoLabel.attributedText = attributedString
    }

}




extension AdTableViewCell: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 8
    }
}
