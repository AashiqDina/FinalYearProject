//
//  SetQuestionsViewController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 13/03/2024.
//

import UIKit
import JGProgressHUD
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase

class SetQuestionsViewController: UIViewController {
    // Create a refernece to the database
    private let TheDatabase = Database.database().reference()
    private var UniqueID = ""

    // // Set the title, text fields, buttons and spinner
    private let AboutView = AboutSpecificBody(title: "Set Questions", FontSize: 30)
    private let TitleField = LoginTextField(fieldType: .Question)
    private let BodyField = LoginTextField(fieldType: .Answer)
    private let TitleField2 = LoginTextField(fieldType: .Question)
    private let BodyField2 = LoginTextField(fieldType: .Answer)
    private let TitleField3 = LoginTextField(fieldType: .Question)
    private let BodyField3 = LoginTextField(fieldType: .Answer)
    private let SubmitButtom = ConfirmButton(borderRadius: 33, hasBackground: true, fontSize: 30, Title: "Submit")
    private let spinner = JGProgressHUD(style: .dark)
    
    // When the page is loaded a unique id is passed into it
    init(with UniqueID: String){
        super.init(nibName: nil, bundle: nil)
        self.UniqueID = UniqueID

    }
    // required when using init
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Call setUI
        self.SetUI()
        //adds the login button and calls function for if the button is clicked
        self.SubmitButtom.addTarget(self, action: #selector(ClickLogin), for: .touchUpInside)
    }
    
    // function for if the button is clicked
    @objc private func ClickLogin(){
        
        let AboutTitle = TitleField.text ?? ""
        let AboutBody = BodyField.text ?? ""
        let AboutTitle2 = TitleField2.text ?? ""
        let AboutBody2 = BodyField2.text ?? ""
        let AboutTitle3 = TitleField3.text ?? ""
        let AboutBody3 = BodyField3.text ?? ""
        let ClassID = UserDefaults.standard.value(forKey: "ClassID") as! String
        
        self.spinner.show(in: view)
        // Calls CreateNewSection
        self.CreateNewSection(with: AboutTitle, Body: AboutBody, Title2: AboutTitle2, Body2: AboutBody2, Title3: AboutTitle3, Body3: AboutBody3, ClassID: ClassID, completion: { [weak self] success in
                        if success{
                            // print success if completion success
                            print("Success")
                    }
                        else{
                            // print failure if completion failure
                            print("Failed")
                        }
                    })
        // dismisses the spinner in the main thread
        DispatchQueue.main.async {
            self.spinner.dismiss()
        }
        // goes two pages back
        navigationController?.popViewController(animated: true)
        navigationController?.popViewController(animated: true)
    }
    
    public func CreateNewSection(with Title: String, Body: String, Title2: String, Body2: String, Title3: String, Body3: String, ClassID: String, completion: @escaping (Bool) -> Void){
        // Get the current user's ID
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
                "UniqueID": self.UniqueID,
                "Question1": Title,
                "Answer1": Body,
                "Question2": Title2,
                "Answer2": Body2,
                "Question3": Title3,
                "Answer3": Body3,
            ]
            // Get the Questions child of the snapshot as a array of dictionaries
            if var Chats = UsersNode["Questions"] as? [[String: Any]] {
                // Append the created dictionary to the array
                Chats.append(CreateContentSection)
                // Set the new array to the child of the snapshot
                UsersNode["Questions"] = Chats
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
                UsersNode["Questions"] = [
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
        self.view.addSubview(TitleField2)
        self.view.addSubview(BodyField2)
        self.view.addSubview(TitleField3)
        self.view.addSubview(BodyField3)
        self.view.addSubview(SubmitButtom)
        AboutView.translatesAutoresizingMaskIntoConstraints = false
        TitleField.translatesAutoresizingMaskIntoConstraints = false
        BodyField.translatesAutoresizingMaskIntoConstraints = false
        TitleField2.translatesAutoresizingMaskIntoConstraints = false
        BodyField2.translatesAutoresizingMaskIntoConstraints = false
        TitleField3.translatesAutoresizingMaskIntoConstraints = false
        BodyField3.translatesAutoresizingMaskIntoConstraints = false
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
            self.BodyField.topAnchor.constraint(equalTo: TitleField.bottomAnchor, constant: 10),
            self.BodyField.heightAnchor.constraint(equalToConstant: 55),
            self.BodyField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            self.BodyField.centerXAnchor.constraint(equalTo: AboutView.centerXAnchor),
            
            self.TitleField2.topAnchor.constraint(equalTo: BodyField.bottomAnchor, constant: 25),
            self.TitleField2.centerXAnchor.constraint(equalTo: BodyField.centerXAnchor),
            self.TitleField2.heightAnchor.constraint(equalToConstant: 55),
            self.TitleField2.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            self.BodyField2.topAnchor.constraint(equalTo: TitleField2.bottomAnchor, constant: 10),
            self.BodyField2.heightAnchor.constraint(equalToConstant: 55),
            self.BodyField2.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            self.BodyField2.centerXAnchor.constraint(equalTo: TitleField2.centerXAnchor),
            
            self.TitleField3.topAnchor.constraint(equalTo: BodyField2.bottomAnchor, constant: 25),
            self.TitleField3.centerXAnchor.constraint(equalTo: BodyField2.centerXAnchor),
            self.TitleField3.heightAnchor.constraint(equalToConstant: 55),
            self.TitleField3.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            self.BodyField3.topAnchor.constraint(equalTo: TitleField3.bottomAnchor, constant: 10),
            self.BodyField3.heightAnchor.constraint(equalToConstant: 55),
            self.BodyField3.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            self.BodyField3.centerXAnchor.constraint(equalTo: TitleField3.centerXAnchor),
            
            self.SubmitButtom.topAnchor.constraint(equalTo: BodyField3.bottomAnchor, constant: 30),
            self.SubmitButtom.heightAnchor.constraint(equalToConstant: 70),
            self.SubmitButtom.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
            self.SubmitButtom.centerXAnchor.constraint(equalTo: AboutView.centerXAnchor),
        ])
    }


}
