//
//  LoginController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 16/01/2024.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
import FirebaseStorage

class LoginController: UIViewController {
    
    // creates necessary parts of the view as specified
    private let LoginView = LoginViewHeader(title: "Login")
    private let UserIdField = LoginTextField(fieldType: .UserId)
    private let PasswordField = LoginTextField(fieldType: .Password)
    private let LoginButton = ConfirmButton(borderRadius: 33, hasBackground: true, fontSize: 30, Title: "Login")
    private let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SetUI()
        //adds the login button and calls function for if the button is clicked
        self.LoginButton.addTarget(self, action: #selector(ClickLogin), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    // function for if the button is clicked
    @objc private func ClickLogin(){
        // uses a struct we previously created to get the input values
        let LoginRequest = UserLogin(
            UserID: self.UserIdField.text ?? "", Password: self.PasswordField.text ?? "")
        // displays loading spinner
        self.spinner.show(in: view)
        // calls login button with the the variable created above
        LoginOut.shared.Login(with: LoginRequest){
            error in if let error = error{
                Alerts.UnknownError(on: self, with: error)
                return
            }
            
            // calls the authenticate user function from scene delegate
            if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate{
                print("Should happen 2nd")
                sceneDelegate.AuthenticateUser()
            }
        }
        // dismisses the spinner
        DispatchQueue.main.async {
            self.spinner.dismiss()
        }
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        // hide the nav bar
        self.navigationController?.navigationBar.isHidden = true
    }
    //sets up the UI when called
    private func SetUI(){
        let AppBackgroundImg = UIImageView(frame: UIScreen.main.bounds)
        AppBackgroundImg.image = UIImage(named: "AppBackground.png")
        self.view.insertSubview(AppBackgroundImg, at: 0)
        
        // adds the following subviews
        self.view.addSubview(LoginView)
        self.view.addSubview(UserIdField)
        self.view.addSubview(PasswordField)
        self.view.addSubview(LoginButton)
        LoginView.translatesAutoresizingMaskIntoConstraints = false
        UserIdField.translatesAutoresizingMaskIntoConstraints = false
        PasswordField.translatesAutoresizingMaskIntoConstraints = false
        LoginButton.translatesAutoresizingMaskIntoConstraints = false
        // positions each element
        NSLayoutConstraint.activate([
            self.LoginView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            self.LoginView.heightAnchor.constraint(equalToConstant: 222),
            self.LoginView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.LoginView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.UserIdField.topAnchor.constraint(equalTo: LoginView.bottomAnchor, constant: 70),
            self.UserIdField.centerXAnchor.constraint(equalTo: LoginView.centerXAnchor),
            self.UserIdField.heightAnchor.constraint(equalToConstant: 55),
            self.UserIdField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            self.PasswordField.topAnchor.constraint(equalTo: UserIdField.bottomAnchor, constant: 50),
            self.PasswordField.heightAnchor.constraint(equalToConstant: 55),
            self.PasswordField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            self.PasswordField.centerXAnchor.constraint(equalTo: LoginView.centerXAnchor),
            self.LoginButton.topAnchor.constraint(equalTo: PasswordField.bottomAnchor, constant: 80),
            self.LoginButton.heightAnchor.constraint(equalToConstant: 70),
            self.LoginButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),

            self.LoginButton.centerXAnchor.constraint(equalTo: LoginView.centerXAnchor),        ])
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
