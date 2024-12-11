//
//  AddSubmissionsViewController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 15/03/2024.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import FirebaseStorage
import SwiftUI
import JGProgressHUD


class AddSubmissionsViewController: UIViewController, UIDocumentPickerDelegate  {
    // Create a refernece to the database
    private let TheDatabase = Database.database().reference()
    // Create a storage reference
    var TheStorage = Storage.storage().reference()
    // Sets variables
    var DocumentName = ""
    var UniqueID = ""
    var SubmissionID = ""
    
    var TheAboutTitle = "Error - Could not find Page"
    // Set the title, text fieldes, buttons and spinner
    private let BodyField = ConfirmButton(borderRadius: 33, hasBackground: true, fontSize: 28, Title: "Upload File")
    private let SubmitButtom = ConfirmButton(borderRadius: 33, hasBackground: true, fontSize: 30, Title: "Submit")
    private let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Call setUI
        self.SetUI()
        //adds the login button and calls function for if the button is clicked
        self.SubmitButtom.addTarget(self, action: #selector(ClickLogin), for: .touchUpInside)
        self.BodyField.addTarget(self, action: #selector(UploadFiles), for: .touchUpInside)
        // Add the back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.image = UIImage(named: "back")
        self.navigationItem.backBarButtonItem?.tintColor = .orange
        print(SubmissionID)
    }
    // The page is opened with the submissionID and the title
    init(with SubmissionID: String, Title: String){
        super.init(nibName: nil, bundle: nil)
        // sets the variables to the local variables
        self.SubmissionID = SubmissionID
        self.TheAboutTitle = Title
    }
    // this is a required error
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc private func UploadFiles(){
        // allow users to select files from the system and is presented
        let ChooseDocument = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf"], in: .import)
        ChooseDocument.delegate = self
        present(ChooseDocument, animated: true, completion: {
            print("Document successfully chosen")
        })
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // Get the first element of urls and store it in teh variable
        if let File = urls.first {
            // call the function with the url
            SendFileToDatabase(fileURL: File)
            // gets the last part of the url
            DocumentName = File.lastPathComponent
        }
    }
    
    func SendFileToDatabase(fileURL: URL) {
        // gets the classID from the userdefaults
        guard let ClassID = UserDefaults.standard.value(forKey: "ClassID") as? String else{
            return
        }
        // gets the userID from the userdefaults
        guard let UserID = UserDefaults.standard.value(forKey: "UserID") as? String else{
            return
        }
        // inititialises a data object with the contents of fileURl
        let File = try! Data(contentsOf: fileURL)
        let StorageLocation = TheStorage.child("\(ClassID)").child("Submissions").child("\(SubmissionID)").child("\(UserID)").child(fileURL.lastPathComponent)
        // Upload the data using the file path
        StorageLocation.putData(File, metadata: nil) { (metadata, error) in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
            // Gets the downloadURL to check
            StorageLocation.downloadURL { (url, error) in
                    guard let DownloadLocation = url else {
                        print("Error getting download URL: \(error!.localizedDescription)")
                        return
                    }

                    print(DownloadLocation)
                }
            }
    }
    
    
    // function for if the button is clicked
    @objc private func ClickLogin(){
        // Set title field to blank and set the body to the name of the file
        let AboutBody = DocumentName
        let ClassID = UserDefaults.standard.value(forKey: "ClassID") as! String
        let UserID = UserDefaults.standard.value(forKey: "UserID") as! String
        // display the spinner
        self.spinner.show(in: view)
        // Call CreateNewSection
        self.CreateNewSection(StudentID: UserID, ClassID: ClassID, completion: { [weak self] success in
                        if success{
                            print("Success")
                    }
                        else{
                            print("Failed")
                        }
                    })
        // Disable the spinner on the main thread
        DispatchQueue.main.async {
            self.spinner.dismiss()
        }
        // return to the previous page
        navigationController?.popViewController(animated: true)
    }
    
    public func CreateNewSection(StudentID: String, ClassID: String, completion: @escaping (Bool) -> Void){
        // sets the path in the database to a variable using the database reference
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
            // Sets the current date to the variable as a string
            let Date = ContentAddViewController.DateToString.string(from: Date())
            // sets the unique id
            self.UniqueID = "\(Date)_\(ClassID)"
            // Declare a dictionary of strings as a variable
            let CreateContentSection: [String: Any] = [
                "StudentID":  StudentID,
            ]
            // Get the Content child of the snapshot as a array of dictionaries
            if var Chats = UsersNode["StudentsSubmission"] as? [[String: Any]] {
                // Append the created dictionary ato the array
                Chats.append(CreateContentSection)
                // Set the new array to the child of the snapshot
                UsersNode["StudentsSubmission"] = Chats
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
                UsersNode["StudentsSubmission"] = [
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
        
        let AboutView = AboutSpecificBody(title: self.TheAboutTitle, FontSize: 30)
        
        // adds the following subviews
        self.view.addSubview(AboutView)
        self.view.addSubview(BodyField)
        self.view.addSubview(SubmitButtom)
        AboutView.translatesAutoresizingMaskIntoConstraints = false
        BodyField.translatesAutoresizingMaskIntoConstraints = false
        SubmitButtom.translatesAutoresizingMaskIntoConstraints = false
        // positions each element using the constraints
        NSLayoutConstraint.activate([
            AboutView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            AboutView.heightAnchor.constraint(equalToConstant: 100),
            AboutView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            AboutView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.BodyField.topAnchor.constraint(equalTo: AboutView.bottomAnchor, constant: 50),
            self.BodyField.heightAnchor.constraint(equalToConstant: 100),
            self.BodyField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            self.BodyField.centerXAnchor.constraint(equalTo: AboutView.centerXAnchor),
            self.SubmitButtom.topAnchor.constraint(equalTo: BodyField.bottomAnchor, constant: 50),
            self.SubmitButtom.heightAnchor.constraint(equalToConstant: 70),
            self.SubmitButtom.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),

            self.SubmitButtom.centerXAnchor.constraint(equalTo: AboutView.centerXAnchor),        ])
    }
    
}
