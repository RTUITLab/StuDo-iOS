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
        
        
        
        
        
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        
        descriptionTextView.isUserInteractionEnabled = false
        descriptionTextView.font = .systemFont(ofSize: 17, weight: .regular)
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.layoutManager.delegate = self
        
        additionalInfoLabel.textColor = UIColor(red:0.467, green:0.467, blue:0.471, alpha:1.000)
        additionalInfoLabel.font = .systemFont(ofSize: 17, weight: .regular)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func set(ad: Ad) {
        titleLabel.text = ad.name
        descriptionTextView.text = ad.shortDescription
        
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMM d, h:mm a"
        
        additionalInfoLabel.text = formatter.string(from: ad.beginTime)
    }

}




extension AdTableViewCell: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 8
    }
}
