//
//  ParticipantsViewController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 27/02/2024.
//

import UIKit

class ParticipantsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // sets the backgrounf
        let AppBackgroundImg = UIImageView(frame: UIScreen.main.bounds)
        AppBackgroundImg.image = UIImage(named: "AppBackground.png")
        self.view.insertSubview(AppBackgroundImg, at: 0)
        // sets the title
        navigationItem.title = "Participants"
        // sets the back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.image = UIImage(named: "back")
        self.navigationItem.backBarButtonItem?.tintColor = .orange
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
