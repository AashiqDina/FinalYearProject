//
//  ConfirmButton.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 16/01/2024.
//

import UIKit

class ConfirmButton: UIButton {
    // needs the border radius and background when called
    init(borderRadius: CGFloat, hasBackground: Bool = false, fontSize: CGFloat, Title: String){
        super.init(frame: .zero)
        // set the title
        self.setTitle(Title, for: .normal)
        if(fontSize < 29){
            self.backgroundColor = hasBackground ? .systemGray4 : .clear
        }
        else{
            self.backgroundColor = hasBackground ? .systemOrange : .clear
        }
        // set customisation fot the button
        self.layer.masksToBounds = true
        self.layer.cornerRadius = borderRadius
        self.titleLabel?.font = .systemFont(ofSize: fontSize, weight: .bold)
        let titleColor: UIColor = hasBackground ? .white : .systemOrange
        self.setTitleColor(titleColor, for: .normal)
        if(fontSize < 29){
            let titleColor: UIColor = hasBackground ? .orange : .systemOrange
            self.setTitleColor(titleColor, for: .normal)
        }
    }
    // required if init doesnt exist
    required init?(coder:NSCoder){
        fatalError("An error has occured")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
