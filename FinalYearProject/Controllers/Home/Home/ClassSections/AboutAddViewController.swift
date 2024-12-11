//
//  AboutAddViewController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 08/03/2024.
//

import UIKit
import JGProgressHUD
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase

class AboutAddViewController: UIViewController, UITextViewDelegate{
    
    // creates a databse reference
    private let TheDatabase = Database.database().reference()
    // Creates a title UILabel for the page
    private let AboutView = AboutSpecificBody(title: "Add To About", FontSize: 30)
    // Creates text fields
    private let TitleField = LoginTextField(fieldType: .Title)
    private let BodyField = TextBox()
    //Creates a submit button
    private let SubmitButtom = ConfirmButton(borderRadius: 33, hasBackground: true, fontSize: 30, Title: "Submit")
    // creates a loading spinner
    private let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SetUI()
        //adds the login button and calls function for if the button is clicked
        self.SubmitButtom.addTarget(self, action: #selector(ClickLogin), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    // function for if the button is clicked
    @objc private func ClickLogin(){
        
        // sets the fields' text to nothing so its empty
        let AboutTitle = TitleField.text ?? ""
        let AboutBody = BodyField.text ?? ""
        // get the ClassID
        let ClassID = UserDefaults.standard.value(forKey: "ClassID") as! String
        // Display the spinner
        self.spinner.show(in: view)
        // calls the create new section function
        self.CreateNewSection(with: AboutTitle, Body: AboutBody, ClassID: ClassID, completion: { [weak self] success in
                        if success{
                            // if its successful prints Success
                            print("Success")
                    }
                        else{
                            // if its not successful print Failed
                            print("Failed")
                        }
                    })
        // disables the spinner on the main thread
        DispatchQueue.main.async {
            self.spinner.dismiss()
        }
        // returns to the previous page
        navigationController?.popViewController(animated: true)
    }
    
    public func CreateNewSection(with Title: String, Body: String, ClassID: String, completion: @escaping (Bool) -> Void){
        // gets the userID from userdefaults
        guard let CurrentUserID = UserDefaults.standard.value(forKey: "UserID") as? String else{
            return
        }
        // gets the specified path with the database reference and store it in the variable
        let UserIDPath = TheDatabase.child("Classes").child("\(ClassID)")
        print(UserIDPath)
        // gets the database refernce path snapshot
        UserIDPath.observeSingleEvent(of: .value, with: { snapshot in
            guard var UsersNode = snapshot.value as? [String: Any] else{
                // if it cant get the snapshot as a dictionary with the keys as Strings and the values as any it returns completion false and prints an error
                completion(false)
                print("An error has occured")
                return
            }
            // creates a dictionary for the title and the body
            let CreateAboutSection: [String: Any] = [
                // sets it to the Title and Body specified in the parameters
                "SectionTitle": Title,
                "SectionBody": Body
            ]
            // if it can be stored in the chat variable as an array of dictionaries it...
            if var Chats = UsersNode["About"] as? [[String: Any]] {
                // appends the above created dictionary to the recieved array above
                Chats.append(CreateAboutSection)
                // sets it to the above gotten snapshots about
                UsersNode["About"] = Chats
                // updates the value in the database
                UserIDPath.setValue(UsersNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else{
                        // if there is an error return completion false and return
                        completion(false)
                        return
                    }
                })
            }
            else{
                // if it cant get it as an array of dictionaries then it creates its own array of dictionaries using the created dictionary above
                UsersNode["About"] = [
                    CreateAboutSection
                ]
                // sets the value in the database
                UserIDPath.setValue(UsersNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else{
                        // returns completion false and return
                        completion(false)
                        return
                    }
                })
            }
        })
    }
    
    
    //sets up the UI when called
    private func SetUI(){
        // sets the background
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
        // positions each element using the constraints below
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
