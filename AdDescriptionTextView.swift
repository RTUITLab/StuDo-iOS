//
//  AdDescriptionTextView.swift
//  StuDo
//
//  Created by Andrew on 9/25/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class AdDescriptionTextView: UITextView {

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        switch action {
        case #selector(copy(_:)), #selector(cut(_:)) , #selector(paste(_:)):
            return super.canPerformAction(action, withSender: sender)
        default:
            return false
        }
    }
    
    var selectedRangeAsNSRange: NSRange? {
        guard let range = selectedTextRange else { return nil }
        let location = offset(from: beginningOfDocument, to: range.start)
        let length = offset(from: range.start, to: range.end)
        return NSRange(location: location, length: length)
    }

}
