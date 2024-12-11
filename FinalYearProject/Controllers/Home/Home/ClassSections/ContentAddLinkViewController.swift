//
//  ContentAddLinkViewController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 11/03/2024.
//

import UIKit
import JGProgressHUD
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase

class ContentAddLinkViewController: UIViewController {
    // Create a reference to the database
    private let TheDatabase = Database.database().reference()
    
    private var UniqueID = ""
    // Set the title, text fieldes, buttons and spinner
    private let AboutView = AboutSpecificBody(title: "Add Content", FontSize: 30)
    private let TitleField = LoginTextField(fieldType: .Title)
    private let BodyField = LoginTextField(fieldType: .Link)
    private let SubmitButtom = ConfirmButton(borderRadius: 33, hasBackground: true, fontSize: 30, Title: "Submit")
    private let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Call setUI
        self.SetUI()
        //adds the login button and calls function for if the button is clicked
        self.SubmitButtom.addTarget(self, action: #selector(ClickLogin), for: .touchUpInside)
        // Add the back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.image = UIImage(named: "back")
        self.navigationItem.backBarButtonItem?.tintColor = .orange
    }

    
    // function for if the button is clicked
    @objc private func ClickLogin(){
        // Set the text fields' text to nothing
        let AboutTitle = TitleField.text ?? ""
        let AboutBody = BodyField.text ?? ""
        // get the classID
        let ClassID = UserDefaults.standard.value(forKey: "ClassID") as! String
        // Display the spinner
        self.spinner.show(in: view)
        // Convert current Date to string
        let Date = ContentAddViewController.DateToString.string(from: Date())
        // Create unique id with the date and the class id
        self.UniqueID = "\(Date)_\(ClassID)"
        // Call CresteNewSection
        self.CreateNewSection(with: AboutTitle, Body: AboutBody, Type: "Link", ClassID: ClassID, completion: { [weak self] success in
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
        // Send user to the setQuestions page
        let ViewController = SetQuestionsViewController(with: self.UniqueID)
        navigationController?.pushViewController(ViewController, animated: true)
//        navigationController?.popViewController(animated: true)
    }
    
    public func CreateNewSection(with Title: String, Body: String, Type: String, ClassID: String, completion: @escaping (Bool) -> Void){
        // Get the current user's id
        guard let CurrentUserID = UserDefaults.standard.value(forKey: "UserID") as? String else{
            return
        }
        // use the database reference and the path and store it in the variable
        let UserIDPath = TheDatabase.child("Classes").child("\(ClassID)")
        print(UserIDPath)
        // use the reference and path to get a snapshot
        UserIDPath.observeSingleEvent(of: .value, with: { snapshot in
            // Store the snapshor as a dictionary of strings
            guard var UsersNode = snapshot.value as? [String: Any] else{
                // Otherwise return completion false and print error
                completion(false)
                print("An error has occured")
                return
            }
            // Declare a dictionary of strings as a variable
            let CreateContentSection: [String: Any] = [
                "TheType": Type,
                "Title": Title,
                "Body": Body,
                "UniqueID": self.UniqueID,
            ]
            // Get the Content child of the snapshot as a array of dictionaries
            if var Chats = UsersNode["Content"] as? [[String: Any]] {
                // Append the created dictionary ato the array
                Chats.append(CreateContentSection)
                // Set the new array to the child of the snapshot
                UsersNode["Content"] = Chats
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
                UsersNode["Content"] = [
                    CreateContentSection
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
            self.BodyField.heightAnchor.constraint(equalToConstant: 55),
            self.BodyField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            self.BodyField.centerXAnchor.constraint(equalTo: AboutView.centerXAnchor),
            self.SubmitButtom.topAnchor.constraint(equalTo: BodyField.bottomAnchor, constant: 30),
            self.SubmitButtom.heightAnchor.constraint(equalToConstant: 70),
            self.SubmitButtom.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),

            self.SubmitButtom.centerXAnchor.constraint(equalTo: AboutView.centerXAnchor),        ])
    }


}
