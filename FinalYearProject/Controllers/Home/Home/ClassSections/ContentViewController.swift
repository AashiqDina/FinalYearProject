//
//  ContentViewController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 27/02/2024.
//

// Ctreate a content struct
struct Content{
    let TheType: String
    let Title: String
    let Body: String
    let UniqueID: String
}

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import FirebaseStorage
import SwiftUI

class ContentViewController: UIViewController {
    // Create a database reference
    private let TheDatabase = Database.database().reference()
    // Create a firebase storage reference
    private let storage = Storage.storage()
    // Create an array of conten
    var ContentSectionRows = [Content]()
    // sets the variables for getting the clickcount and the last click date
    private var ClickCount = UserDefaults.standard.object(forKey: "ClickCount")
    private var LastClick = UserDefaults.standard.object(forKey: "LastClick")
    // checks if the lastclick exists and if it doesnt create it
    func checkLastClick(){
        if(self.LastClick == nil){
            UserDefaults.standard.set(0, forKey: "ClickCount")
            UserDefaults.standard.set(Date(), forKey: "LastClick")
        }
        self.ClickCount = UserDefaults.standard.object(forKey: "ClickCount") as! Int
        self.LastClick = UserDefaults.standard.object(forKey: "LastClick") as! Date
    }
    // increases the click count if its been more than 60 seconds, sets the new last click
    func increaseClickCount(){
        if(Date().timeIntervalSince(self.LastClick as! Date) >= 60){
            // sets the click count user default to one more
            UserDefaults.standard.set(self.ClickCount as! Int+1, forKey: "ClickCount")
            // prints out those things
            print("Click count now:")
            print(UserDefaults.standard.object(forKey: "ClickCount"))
            UserDefaults.standard.set(Date(), forKey: "LastClick")
            // calls the above function to update local variables
            self.checkLastClick()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Sets the background
        let AppBackgroundImg = UIImageView(frame: UIScreen.main.bounds)
        AppBackgroundImg.image = UIImage(named: "AppBackground.png")
        self.view.insertSubview(AppBackgroundImg, at: 0)
        // Adds the table as a subview
        view.addSubview(ContentTable)
        ContentTable.delegate = self
        ContentTable.dataSource = self
        ContentTable.frame = view.bounds
        self.ContentTable.backgroundColor = UIColor.clear
        // Sets the title
        navigationItem.title = "Content"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.image = UIImage(named: "back")
        self.navigationItem.backBarButtonItem?.tintColor = .orange
        // Calls AddTable to get information needed in the table
        self.AddTable()
        
        let IsTeacher = UserDefaults.standard.value(forKey: "IsTeacher") as? String ?? "false"
        // If the user is a teacher calls function
        if(IsTeacher == "true"){
            self.AddTeacherStuff()
        }
        
    }
    // Adds a button on the top right of hte page
    private func AddTeacherStuff(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ToAdd))
        self.navigationItem.rightBarButtonItem?.image = UIImage(named: "Plus")
        self.navigationItem.rightBarButtonItem?.tintColor = .orange
    }
    
    public func GetInfo(for ClassID: String, completion: @escaping (Result<[Content], Error>) -> Void){
        // Uses the database reference and the path to get a snapshot
        TheDatabase.child("Classes/\(ClassID)/Content").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                // if the snapshot couldnt be recieved as an array of dictionaries witht the key as string and the values can be anything it prints failure and returns a completion failure
                print("Here: Failed")
                completion(.failure(AnError(message: "Failed to fetch")))
                return
            }
            // store the resulted value as a dictionary
            let ToReturn: [Content] = value.compactMap({
                dictionary in
                guard let Title = dictionary["Title"] as? String,
                      let Body = dictionary["Body"] as? String,
                      let Type = dictionary["TheType"] as? String,
                      let ID = dictionary["UniqueID"] as? String
                      else {
                          return nil
                      }
                
                return Content(TheType: Type, Title: Title, Body: Body, UniqueID: ID)
                

            })
            // if everything above completes successfully it returns completion success and returns the dictionary
            completion(.success(ToReturn))
        })
    }
    
    private func AddTable(){
        // Creates an array of content
        ContentSectionRows = [Content]()
        // Gets the ClassID
        guard let ClassID = UserDefaults.standard.value(forKey: "ClassID") as? String else{
            return
        }
        // Calls GetInfo
        self.GetInfo(for: ClassID, completion: { [weak self] result in
            switch result{
            case .success(let About):
                //if the chat is empty it prints chat is empty
                guard !About.isEmpty else {
                    print("About is empty")
                    return
                }
                self?.ContentSectionRows = About
                DispatchQueue.main.async{
                    // reloads the tables data on the main thread
                    self?.ContentTable.reloadData()
                }
            case .failure(let error):
                print("Failed: \(error)")
            }
        })
    }
    // Create the UITableView
    private let ContentTable: UITableView = {
        let Table = UITableView()
        Table.register(ContentTableViewCell.self, forCellReuseIdentifier: "ContentTableViewCell")
        Table.separatorColor = .orange
        Table.translatesAutoresizingMaskIntoConstraints = false
        return Table
    }()
    // Create a function to show several options if the teacher clicks the top right button
    @objc private func ToAdd(){
        print("-------------------------------")
        let Confirm = UIAlertController(title: "Select Addition", message: "What would you like to add?", preferredStyle: UIAlertController.Style.alert)
        Confirm.addAction(UIAlertAction(title: "Page", style: .default, handler: { (action: UIAlertAction!) in
            let ViewController = ContentAddViewController()
            self.navigationController?.pushViewController(ViewController, animated: true)
        }))

        Confirm.addAction(UIAlertAction(title: "Link", style: .default, handler: { (action: UIAlertAction!) in
            let ViewController = ContentAddLinkViewController()
            self.navigationController?.pushViewController(ViewController, animated: true)
        }))
        
        Confirm.addAction(UIAlertAction(title: "Download", style: .default, handler: { (action: UIAlertAction!) in
            let ViewController = ContentAddDownloadViewController()
            self.navigationController?.pushViewController(ViewController, animated: true)
        }))
        Confirm.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
              print("Cancelled")
        }))
        self.present(Confirm, animated: true)
        }

}

extension ContentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // sets the number of rows in each section
        return ContentSectionRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let TableRow = tableView.dequeueReusableCell(withIdentifier: "ContentTableViewCell", for: indexPath) as? ContentTableViewCell
        else{
            return UITableViewCell()
        }
        // each row will get the values of ContentSectionRows array and sets the variable to it
        let Rows = ContentSectionRows[indexPath.row]
        TableRow.Build(with: Rows)
        
        //        TableRow.Build(with: CurrentModel)
        // Customise the rows
        TableRow.textLabel?.textColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        TableRow.textLabel?.font = .systemFont(ofSize: 30, weight: .bold)
        //        TableRow.backgroundColor = UIColor(red: 36/255, green: 35/255, blue: 37/255, alpha: 1)
        let HighlightColour = UIView()
        HighlightColour.backgroundColor = UIColor.orange
        TableRow.selectedBackgroundView = HighlightColour
        TableRow.backgroundColor = UIColor.clear
        TableRow.textLabel?.highlightedTextColor = UIColor.white
        
        return TableRow
    }
    // Row is clicked
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // un-highlight the rows
        tableView.deselectRow(at: indexPath, animated: true)
        //get the specific row
        let Rows = ContentSectionRows[indexPath.row]
        // increment the click count
        self.increaseClickCount()
        // check the row type to perform the specified actions
        if(Rows.TheType == "Page"){
            // send to the specified page
            let ViewController = AboutSpecificViewController(with: Rows.Title, AboutBody: Rows.Body, IsTheContent: true, ContentsID: Rows.UniqueID)
            navigationController?.pushViewController(ViewController, animated: true)
        }
        if(Rows.TheType == "Link"){
            // sends the user to the specified page
            if let URL = URL(string: Rows.Body) {
                UIApplication.shared.open(URL)
                guard let IsTeacher = UserDefaults.standard.value(forKey: "IsTeacher") as? String else{
                    return
                }
                let CanShow = HasQuestions(UniqueID: Rows.UniqueID, completion: { (success) -> Void in
                    if success {
                        // if user is not a teacher send them to the gamified questions page
                        if(IsTeacher == "false"){
                            let ViewController = AnswerQuestionsViewController(with: Rows.UniqueID)
                            self.navigationController?.pushViewController(ViewController, animated: true)
                        }
                    } else {
                         print("false")
                    }
                })
                }
            }
        if(Rows.TheType == "Download"){
            // Get the File name which is stored in the body in the database
            let FileName = Rows.Body
            // get the classID
            guard let ClassID = UserDefaults.standard.value(forKey: "ClassID") as? String else{
                return
            }
            // Get firebase storage reference
            let FileReference = storage.reference().child("\(ClassID)/\(FileName)")
            // gets the data usign the reference and path with a size of 1mb
            FileReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
              if let error = error {
                print(error)
              } else {
                  // Creates and appends tp a path component
                  let ToFiles = FileManager.default.temporaryDirectory
                  let WriteTo = ToFiles.appendingPathComponent("\(FileName).pdf")
                  // writes data to the specified file location
                  FileReference.write(toFile: WriteTo) { url, error in
                      if let error = error {
                         print("\(error.localizedDescription)")
                      } else {
                          self.presentActivityViewController(withUrl: url!)
                      }
                   }
              }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // specifies height of rows
        80
    }
    
    func presentActivityViewController(withUrl TheURL: URL) {
        // Gives the user several options of what to do with the file
        DispatchQueue.main.async {
          let ViewController = UIActivityViewController(activityItems: [TheURL], applicationActivities: nil)
          ViewController.popoverPresentationController?.sourceView = self.view
          self.present(ViewController, animated: true, completion: nil)
        }
    }
    
    func HasQuestions(UniqueID: String, completion: @escaping (Bool) -> Void){
        guard let ClassID = UserDefaults.standard.value(forKey: "ClassID") as? String else{
            return
        }
        // gets a snapshot using the databasse reference and the path
        TheDatabase.child("Classes/\(ClassID)/Questions").observeSingleEvent(of: .value, with: {snapshot in
            guard var QuestionsContainer = snapshot.value as? [[String: Any]] else{
                return
            }
            
            var i = 0
            // Creates a dictionary of strings
            var TheQuestions: [String: Any]?
            var QuestionContainerLength = QuestionsContainer.count
            print("Length here: ",QuestionContainerLength)
            // Finds the questions associated with the page
            for Questions in QuestionsContainer {
                if let TheUniqueID = Questions["UniqueID"] as? String, TheUniqueID == UniqueID{
                    TheQuestions = Questions
                    //sets the questions to the variable and returns completion tru
                    completion(true)
                    break
                }
                print(i)
                print(QuestionContainerLength)
                i += 1
                if(i > QuestionContainerLength){
                    // if it cant find it, it returns completion false
                    print("doesnt work")
                    completion(false)
                    break
                }
            
        }
    })
    }
}
