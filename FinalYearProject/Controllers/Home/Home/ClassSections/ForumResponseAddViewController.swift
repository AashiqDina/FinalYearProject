//
//  ForumResponseAddViewController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 21/04/2024.
//

import UIKit
import JGProgressHUD
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase

class ForumResponseAddViewController: UIViewController {
    // create a reference to thre database
    private let TheDatabase = Database.database().reference()
    // initalise theForumResponseID
    var TheForumResponseID = 100
    // when the page is created it takes in the Forum's Response ID
    init(with ForumResponseID: Int){
        super.init(nibName: nil, bundle: nil)
        TheForumResponseID = ForumResponseID
    }
    // below is required if init doesnt occur it stops the program and prints the message
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // creates the variabels such as textfields, buttons and more
    private let ForumPostView = AboutSpecificBody(title: "Respond to Post", FontSize: 30)
    private let TitleField = LoginTextField(fieldType: .Title)
    private let BodyField = TextBox()
    private let SubmitButtom = ConfirmButton(borderRadius: 33, hasBackground: true, fontSize: 30, Title: "Submit")
    private let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // calls SetUI
        self.SetUI()
        //adds the login button and calls function for if the button is clicked
        self.SubmitButtom.addTarget(self, action: #selector(ClickLogin), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    // function for if the button is clicked
    @objc private func ClickLogin(){
        // sets the text field to nothing there
        let ForumPostTitle = TitleField.text ?? ""
        let ForumPostBody = BodyField.text ?? ""
        let ClassID = UserDefaults.standard.value(forKey: "ClassID") as! String
        // display the spinner
        self.spinner.show(in: view)
        // call CreateNewSection
        self.CreateNewSection(with: ForumPostTitle, Body: ForumPostBody, ClassID: ClassID, completion: { [weak self] success in
                        if success{
                            // if completion success was returned print success
                            print("Success")
                    }
                        else{
                            // if completion failure was returned print failure
                            print("Failed")
                        }
                    })
        
        DispatchQueue.main.async {
            // dismiss the spinner in the main thread
            self.spinner.dismiss()
        }
        // return to the previous page
        navigationController?.popViewController(animated: true)
    }
    
    public func CreateNewSection(with Title: String, Body: String, ClassID: String, completion: @escaping (Bool) -> Void){
        // get the UserID of the current user from the UserDefaults
        guard let CurrentUserID = UserDefaults.standard.value(forKey: "UserID") as? String else{
            return
        }
        // uses the variable with the path to get a snapshot
        let UserIDPath = TheDatabase.child("Classes").child("\(ClassID)").child("Forum").child(String(self.TheForumResponseID))
        print(UserIDPath)
        UserIDPath.observeSingleEvent(of: .value, with: { snapshot in
            guard var UsersNode = snapshot.value as? [String: Any] else{
                // if it cant get the snapshot as a dictionary then it returns completion false, prints an error and returns
                completion(false)
                print("An error has occured")
                return
            }
            print(UsersNode)
            // creates a dictionary with the parameters
            let CreateForumPostSection: [String: Any] = [
                "SectionTitle": Title,
                "SectionBody": Body
            ]
            // stores the snapshot's value for the key forums as a array of dictionaries
            if var Chats = UsersNode["Responses"] as? [[String: Any]] {
                // appends the dictionary to the array
                Chats.append(CreateForumPostSection)
                // sets it to the array of dictionaries
                UsersNode["Responses"] = Chats
                // updates the array
                UserIDPath.setValue(UsersNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else{
                        // if there is an error returns completion false and returns
                        completion(false)
                        return
                    }
                })
            }
            else{
                // if it cant get UsersNodes["Responses"] as an array of dictionaries then it creates an array of dictionaries with the dictionary created above
                UsersNode["Responses"] = [
                    CreateForumPostSection
                ]
                // update the value (technically create the value) in the database
                UserIDPath.setValue(UsersNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else{
                        // return completion false and returns
                        completion(false)
                        return
                    }
                })
            }
        })
    }
    
    
    //sets up the UI when called
    private func SetUI(){
        // set the background
        let AppBackgroundImg = UIImageView(frame: UIScreen.main.bounds)
        AppBackgroundImg.image = UIImage(named: "AppBackground.png")
        self.view.insertSubview(AppBackgroundImg, at: 0)
        
        // adds the following subviews
        self.view.addSubview(ForumPostView)
        self.view.addSubview(TitleField)
        self.view.addSubview(BodyField)
        self.view.addSubview(SubmitButtom)
        ForumPostView.translatesAutoresizingMaskIntoConstraints = false
        TitleField.translatesAutoresizingMaskIntoConstraints = false
        BodyField.translatesAutoresizingMaskIntoConstraints = false
        SubmitButtom.translatesAutoresizingMaskIntoConstraints = false
        // positions each element with constraints
        NSLayoutConstraint.activate([
            self.ForumPostView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            self.ForumPostView.heightAnchor.constraint(equalToConstant: 100),
            self.ForumPostView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.ForumPostView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.TitleField.topAnchor.constraint(equalTo: ForumPostView.bottomAnchor, constant: 0),
            self.TitleField.centerXAnchor.constraint(equalTo: ForumPostView.centerXAnchor),
            self.TitleField.heightAnchor.constraint(equalToConstant: 55),
            self.TitleField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            self.BodyField.topAnchor.constraint(equalTo: TitleField.bottomAnchor, constant: 20),
            self.BodyField.heightAnchor.constraint(equalToConstant: 200),
            self.BodyField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            self.BodyField.centerXAnchor.constraint(equalTo: ForumPostView.centerXAnchor),
            self.SubmitButtom.topAnchor.constraint(equalTo: BodyField.bottomAnchor, constant: 30),
            self.SubmitButtom.heightAnchor.constraint(equalToConstant: 70),
            self.SubmitButtom.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),

            self.SubmitButtom.centerXAnchor.constraint(equalTo: ForumPostView.centerXAnchor),        ])
    }


}
