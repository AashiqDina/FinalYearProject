//
//  AboutSpecificBody.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 01/03/2024.
//

import UIKit

class AboutSpecificBody: UIView {
    // Create a UILabel
    private let TextLabel: UILabel = {
        let Label = UILabel()
        Label.text = "Error"
        Label.font = .systemFont(ofSize: 25, weight: .bold)
        Label.numberOfLines = 30
        Label.textAlignment = .center
        Label.textColor = .label
        Label.textColor = .white
        return Label
    }()
    // Give the string and font size when called
    init(title: String, FontSize: Int){
        super.init(frame: .zero)
        self.TextLabel.text = title
        self.TextLabel.font = .systemFont(ofSize: CGFloat(FontSize), weight: .bold)
        self.TextLabel.textColor = .orange
//        self.TextLabel.textColor = UIColor(red: 215/255, green: 110/255, blue: 37/255, alpha: 1)
        self.SetUI()
    }
    // required if init doesnt exist
    required init?(coder: NSCoder){
        fatalError("An unexpected error has occured")
    }
    
    private func SetUI(){
        // add the subview
        self.addSubview(TextLabel)

        TextLabel.translatesAutoresizingMaskIntoConstraints = false
        // set them with constraints
        NSLayoutConstraint.activate([
            self.TextLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 30),
            self.TextLabel.widthAnchor.constraint(equalToConstant: 50),
            self.TextLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.TextLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
}
