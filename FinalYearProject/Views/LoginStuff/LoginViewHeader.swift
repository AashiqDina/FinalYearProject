//
//  LoginViewHeader.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 16/01/2024.
//

import UIKit

class LoginViewHeader: UIView {
    
    // Create a UIImageView
    private let LogoImageView: UIImageView = {
        let UIImg = UIImageView()
        UIImg.image = UIImage(named: "AppLogo")
        UIImg.contentMode = .scaleAspectFit
        return UIImg
    }()
    // Create a UILabel
    private let TitleLabel: UILabel = {
        let Label = UILabel()
        Label.text = "Error"
        Label.font = .systemFont(ofSize: 65, weight: .bold)
        Label.textAlignment = .center
        Label.textColor = .label
        Label.textColor = .white
        return Label
    }()
    // Give the variables when called
    init(title: String){
        super.init(frame: .zero)
        self.TitleLabel.text = title
        self.SetUI()
    }
    // required if init doesnt exist
    required init?(coder: NSCoder){
        fatalError("An unexpected error has occured")
    }
    
    
    private func SetUI(){
        // adds subviews
        self.addSubview(LogoImageView)
        self.addSubview(TitleLabel)
        
        LogoImageView.translatesAutoresizingMaskIntoConstraints = false
        TitleLabel.translatesAutoresizingMaskIntoConstraints = false
        // sets them with constraints
        NSLayoutConstraint.activate([
            self.LogoImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            self.LogoImageView.heightAnchor.constraint(equalTo: LogoImageView.widthAnchor),
            self.LogoImageView.widthAnchor.constraint(equalToConstant: 90),
            self.LogoImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            self.TitleLabel.topAnchor.constraint(equalTo: LogoImageView.bottomAnchor, constant: 30),
            self.TitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.TitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }

}
