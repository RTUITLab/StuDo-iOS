//
//  TextViewNoPadding.swift
//  StuDo
//
//  Created by Andrew on 9/12/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

@IBDesignable
class TextViewNoPadding: UITextView {

    override func layoutSubviews() {
        super.layoutSubviews()
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
    }

}
