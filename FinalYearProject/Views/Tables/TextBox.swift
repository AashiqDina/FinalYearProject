//
//  TextBox.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 08/03/2024.
//

import UIKit

class TextBox: UITextView {
    // Creates and customises a UITextView
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.backgroundColor = .white
        self.autocapitalizationType = .none
        self.layer.cornerRadius = 25
        self.returnKeyType = .done
        self.autocorrectionType = .no
        self.textAlignment = .left
        self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.font = UIFont.systemFont(ofSize: 20)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("An error has occured")
    }
}
