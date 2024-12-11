//
//  NavBarController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 23/01/2024.
//

import UIKit

class NavBarController: UITabBarController {
    
    var Window: UIWindow?

    override func viewDidLoad() {
        super.viewDidLoad()
        // call function
        self.SetBottomNavBar()
        // set the colours of the tabBar
        self.tabBar.tintColor = .orange
        self.tabBar.barTintColor = .darkGray
        // call function
        self.SetTopNavBar()
        // Push to another viewController
        let ViewController = HomeMenuController()
        navigationController?.pushViewController(ViewController, animated: true)
    }
    
    public func SetBottomNavBar(){
        // Set the variables
        let HomeScreen = self.ToNav(and: UIImage(named: "Book"), Title: "Classes", ViewController: HomeMenuController())
        
        let Message = self.ToNav(and: UIImage(named: "Message"), Title: "Messages", ViewController: SearchMessageController())
        
        let Other = self.ToNav(and: UIImage(named: "LogoOther"), Title: "Other", ViewController: OtherStuffController())
        
        let Notify = self.ToNav(and: UIImage(named: "Notify"), Title: "Notifications", ViewController: NotificationController())
        
        let Settings = self.ToNav(and: UIImage(named: "Settings"), Title: "Settings", ViewController: SettingsController())
        
        // sets the view controlers with the variables using the function
        self.setViewControllers([HomeScreen, Message, Other, Notify, Settings], animated: true)
    }
    
    private func ToNav(and image: UIImage?, Title: String, ViewController: UIViewController) -> UINavigationController {
        let NavigateTo = UINavigationController(rootViewController: ViewController)
        // set the image
        NavigateTo.tabBarItem.image = image
        // return the newController
        return NavigateTo
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    public func SetTopNavBar(){
        // Set the top left button
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Logout"), style: .plain, target: self, action: #selector(LogOut))
        self.navigationItem.leftBarButtonItem?.tintColor = .orange
        // set the top right button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "UserIcon"), style: .plain, target: self, action: #selector(ToProfilePage))
        self.navigationItem.rightBarButtonItem?.tintColor = .orange
        // Set the back bar button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        // customise the back bar button
        self.navigationItem.backBarButtonItem?.image = UIImage(named: "back")
        self.navigationItem.backBarButtonItem?.tintColor = .orange
        
    }
    
    @objc private func LogOut(){
        print("-------------------------------")
        // Create an alert
        let Confirm = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: UIAlertController.Style.alert)
        // Add action to the alert
        Confirm.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            LoginOut.shared.LogOut {
                [weak self] error in guard let self = self
                else{
                    return
                }
                // Add the function
                if let error = error{
                    Alerts.ErrorLoggingOut(on: self, with: error)
                    return
                }
                if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate{
                    sceneDelegate.AuthenticateUser()
                }
            }
        }))
        // Add action
        Confirm.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
              print("Logout Cancelled")
        }))
        // Present a confirm button
        self.present(Confirm, animated: true)
        }

        // function to push the user to another page
        @objc private func ToProfilePage(){
            self.navigationController?.pushViewController(UserProfileController(), animated: true)
        }

    
}


