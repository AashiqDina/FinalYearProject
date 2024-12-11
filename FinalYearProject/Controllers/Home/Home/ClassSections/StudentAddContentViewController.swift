//
//  StudentAddContentViewController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 25/03/2024.
//

import UIKit
import JGProgressHUD
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase

class StudentAddContentViewController: UIViewController, UITextViewDelegate {
    // Create a refernece to the database
    private let TheDatabase = Database.database().reference()
    // Set the title, text fields, buttons and spinner
    private let AboutView = AboutSpecificBody(title: "Add To Student Content", FontSize: 30)
    private let TitleField = LoginTextField(fieldType: .Title)
    private let BodyField = TextBox()
    private let SubmitButtom = ConfirmButton(borderRadius: 33, hasBackground: true, fontSize: 30, Title: "Submit")
    private let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Call setUI
        self.SetUI()
        //adds the login button and calls function for if the button is clicked
        self.SubmitButtom.addTarget(self, action: #selector(ClickLogin), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    // function for if the button is clicked
    @objc private func ClickLogin(){
        
        // Set the text box texts to blank
        let AboutTitle = TitleField.text ?? ""
        let AboutBody = BodyField.text ?? ""
        // Get the ClassID from the userdefaults
        let ClassID = UserDefaults.standard.value(forKey: "ClassID") as! String
        // display spinner
        self.spinner.show(in: view)
        // Call CresteNewSection
        self.CreateNewSection(with: AboutTitle, Body: AboutBody, ClassID: ClassID, completion: { [weak self] success in
            // if completion success, print success
                        if success{
                            print("Success")
                    }
                        else{
                            // If completion failure print pailed
                            print("Failed")
                        }
                    })
        // dismiss the spinner on the main thread
        DispatchQueue.main.async {
            self.spinner.dismiss()
        }
        // Send user to the previous page
        navigationController?.popViewController(animated: true)
    }
    
    public func CreateNewSection(with Title: String, Body: String, ClassID: String, completion: @escaping (Bool) -> Void){
        // Get the current user's ID
        guard let CurrentUserID = UserDefaults.standard.value(forKey: "UserID") as? String else{
            return
        }
        // use the database reference and the path and store it in the variable
        let UserIDPath = TheDatabase.child("Classes").child("\(ClassID)")
        print(UserIDPath)
        // use the reference and path to get a snapshot
        UserIDPath.observeSingleEvent(of: .value, with: { snapshot in
            // Store the snapshot as a dictionary of strings
            guard var UsersNode = snapshot.value as? [String: Any] else{
                // Otherwise return completion false and print error
                completion(false)
                print("An error has occured")
                return
            }
            // Declare a dictionary of strings as a variable
            let CreateAboutSection: [String: Any] = [
                "SectionTitle": Title,
                "SectionBody": Body
            ]
            // Get the Content child of the snapshot as a array of dictionaries
            if var Chats = UsersNode["StudentGeneratedContent"] as? [[String: Any]] {
                // Append the created dictionary to the array
                Chats.append(CreateAboutSection)
                // Set the new array to the child of the snapshot
                UsersNode["StudentGeneratedContent"] = Chats
                // set the value in the database
                UserIDPath.setValue(UsersNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else{
                        // Return completion false
                        completion(false)
                        return
                    }
                })
            }
            else{
                // Just create the array  with the dictionaries
                UsersNode["StudentGeneratedContent"] = [
                    CreateAboutSection
                ]
                // Set the value in the array
                UserIDPath.setValue(UsersNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else{
                        // return completion false
                        completion(false)
                        return
                    }
                })
            }
        })
    }
    
    
    //sets up the UI when called
    private func SetUI(){
        // Set the background
        let AppBackgroundImg = UIImageView(frame: UIScreen.main.bounds)
        AppBackgroundImg.image = UIImage(named: "AppBackground.png")
        self.view.insertSubview(AppBackgroundImg, at: 0)
        
        // adds the following subviews
        self.view.addSubview(AboutView)
        self.view.addSubview(TitleField)
        self.view.addSubview(BodyField)
        self.view.addSubview(SubmitButtom)
        AboutView.translatesAutoresizingMaskIntoConstraints = false
        TitleField.translatesAutoresizingMaskIntoConstraints = false
        BodyField.translatesAutoresizingMaskIntoConstraints = false
        SubmitButtom.translatesAutoresizingMaskIntoConstraints = false
        // positions each element using the constraints
        NSLayoutConstraint.activate([
            self.AboutView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            self.AboutView.heightAnchor.constraint(equalToConstant: 100),
            self.AboutView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.AboutView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.TitleField.topAnchor.constraint(equalTo: AboutView.bottomAnchor, constant: 0),
            self.TitleField.centerXAnchor.constraint(equalTo: AboutView.centerXAnchor),
            self.TitleField.heightAnchor.constraint(equalToConstant: 55),
            self.TitleField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            self.BodyField.topAnchor.constraint(equalTo: TitleField.bottomAnchor, constant: 20),
            self.BodyField.heightAnchor.constraint(equalToConstant: 200),
            self.BodyField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            self.BodyField.centerXAnchor.constraint(equalTo: AboutView.centerXAnchor),
            self.SubmitButtom.topAnchor.constraint(equalTo: BodyField.bottomAnchor, constant: 30),
            self.SubmitButtom.heightAnchor.constraint(equalToConstant: 70),
            self.SubmitButtom.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),

            self.SubmitButtom.centerXAnchor.constraint(equalTo: AboutView.centerXAnchor),        ])
    }
}
