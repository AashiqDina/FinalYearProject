//
//  OtherStuffController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 23/01/2024.
//

import UIKit

class OtherStuffController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // set the background
        let AppBackgroundImg = UIImageView(frame: UIScreen.main.bounds)
        AppBackgroundImg.image = UIImage(named: "AppBackground.png")
        self.view.insertSubview(AppBackgroundImg, at: 0)
        self.CustomiseTitle()
        
    }
    

    private func CustomiseTitle(){
        // Set the title
        self.navigationItem.title = "Other"
        // Customise the title
        let CustomiseUserName: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.orange,
            .font: UIFont.boldSystemFont(ofSize: 25.0)
        ]
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = CustomiseUserName
        navigationController?.navigationBar.scrollEdgeAppearance?.titleTextAttributes = CustomiseUserName
        
    }

}
