//
//  HomeMenuController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 16/01/2024.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase
import RealmSwift
import JGProgressHUD


struct Classes{
    let ClassID: String
    let ClassName: String
}

class HomeMenuController: UIViewController {
    
    // set a database reference
    private let TheDatabase = Database.database().reference()
    // create an array of the struct classes
    private var TheClasses = [Classes]()
    // creates spinner
    private let spinner = JGProgressHUD(style: .dark)
    
    // get variables fromt the user defaults
    private var ClickCount = UserDefaults.standard.object(forKey: "ClickCount")
    private var LastClick = UserDefaults.standard.object(forKey: "LastClick")
    
    // function to check if there is a last click
    func checkLastClick(){
        // checks it here
        if(self.LastClick == nil){
            UserDefaults.standard.set(0, forKey: "ClickCount")
            UserDefaults.standard.set(Date(), forKey: "LastClick")
        }
        // sets it in the variables above
        self.ClickCount = UserDefaults.standard.object(forKey: "ClickCount") as! Int
        self.LastClick = UserDefaults.standard.object(forKey: "LastClick") as! Date
        
    }
    // increases the click count variable if its been longer than 60 seconds
    func increaseClickCount(){
        if(Date().timeIntervalSince(self.LastClick as! Date) >= 60){
            // sets the click count user default to one more
            UserDefaults.standard.set(self.ClickCount as! Int+1, forKey: "ClickCount")
            // prints out those things
            print("Click count now:")
            print(UserDefaults.standard.object(forKey: "ClickCount"))
            print("and this:")
            print(UserDefaults.standard.object(forKey: "AmountAppWasOpened"))
            UserDefaults.standard.set(Date(), forKey: "LastClick")
            // calls the above function to update local variables
            self.checkLastClick()
        }
    }

    public func BeginClassListener(){
        // gets userid from user defaults
        TheClasses = [Classes]()
        guard let UserID = UserDefaults.standard.value(forKey: "UserID") as? String else{
            return
        }
        self.GetClass(for: UserID, completion: { [weak self] result in
            switch result{
            case .success(let TheClass):
                //if the chat is empty it prints chat is empty
                guard !TheClass.isEmpty else {
                    print("No Classes is empty")
                    return
                }
                self?.TheClasses = TheClass
                DispatchQueue.main.async{
                    // reloads the tables data
                    self?.ClassesTable.reloadData()
                }
                
            case .failure(let error):
                print("Failed: \(error)")
            }
        })
        
        DispatchQueue.main.async{
            // reloads the tables data
            self.ClassesTable.reloadData()
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.spinner.show(in: view)
        self.SetupHomeUI()
        self.CustomiseTitle()
        self.checkLastClick()
        guard let UserID = UserDefaults.standard.value(forKey: "UserID") as? String else{
            return
        }
        self.BeginClassListener()
        
        
        self.view.addSubview(ClassesTable)
        ClassesTable.delegate = self
        ClassesTable.dataSource = self
        // sets the table background colour
        self.ClassesTable.backgroundColor = UIColor.clear
        
        self.GetClass(for: UserID, completion: { [weak self] result in
            switch result{
            case .success(let TheClass):
                //if the chat is empty it prints chat is empty
                guard !TheClass.isEmpty else {
                    print("No Classes is empty")
                    return
                }
                self?.TheClasses = TheClass
                DispatchQueue.main.async{
                    // reloads the tables data
                    self?.ClassesTable.reloadData()
                }
                
            case .failure(let error):
                print("Failed: \(error)")
            }
        })
        
        DispatchQueue.main.async{
            // reloads the tables data
            self.ClassesTable.reloadData()
            self.spinner.dismiss()
        }
        
        let MoveDownBy: CGFloat = 15
        ClassesTable.contentInset.top = MoveDownBy
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // call the function when the view becomes visible
        self.BeginClassListener()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // sets the table's frame to the same as the view's bounds
        ClassesTable.frame = view.bounds
    }
    
    
    // Create the table
    private let ClassesTable: UITableView = {
        let Table = UITableView()
        // register the table set the colour of the cell seperators and makes sure autoresizing doesnt occur
        Table.register(ClassesTableViewCell.self, forCellReuseIdentifier: "ClassesTableViewCell")
        Table.separatorColor = .orange
        Table.translatesAutoresizingMaskIntoConstraints = false
        return Table
    }()
    
    private func SetupHomeUI(){
        // set the background of the page
        let AppBackgroundImg = UIImageView(frame: UIScreen.main.bounds)
        AppBackgroundImg.image = UIImage(named: "AppBackground.png")
        self.view.insertSubview(AppBackgroundImg, at: 0)
        
    }
    
    private func CustomiseTitle(){
        // sets the title of the page
        self.navigationItem.title = "Classes"
        
        // sets the customisation for title
        let CustomiseUserName: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.orange,
            .font: UIFont.boldSystemFont(ofSize: 25.0)
        ]
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = CustomiseUserName
        navigationController?.navigationBar.scrollEdgeAppearance?.titleTextAttributes = CustomiseUserName
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // customises the back button
        self.navigationItem.backBarButtonItem?.image = UIImage(named: "back")
        self.navigationItem.backBarButtonItem?.tintColor = .orange
        
    }
    
    public func GetClass(for UserID: String, completion: @escaping (Result<[Classes], Error>) -> Void){
        // gets the snapshot using the database reference and the path
        TheDatabase.child("UsersClasses/\(UserID)/0").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                // if it fails, it prints it and returns completion failure
                print("Here: Failed")
                completion(.failure(AnError(message: "Failed to fetch")))
                return
            }
            // store the resulted value as a dictionary
            let AClass: [Classes] = value.compactMap({
                dictionary in guard
                    let ClassName = dictionary["ClassName"] as? String,
                    let ClassID = dictionary["ClassID"] as? String
                else{
                    return nil
                }
                return Classes(ClassID: ClassID, ClassName: ClassName)
            })
            // if everything above goes well it returns the above dictionary
            completion(.success(AClass))
        })
    }
    
}

extension HomeMenuController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // sets the number of sections
        return TheClasses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // each row will get the values of theClasses array and sets the variable to it
        let CurrentModel = TheClasses[indexPath.row]
        let TableRow = tableView.dequeueReusableCell(withIdentifier: "ClassesTableViewCell", for: indexPath) as! ClassesTableViewCell
        
        // calls the build function to set the variables
        TableRow.Build(with: CurrentModel)
        // set the customisation aspects of the text
        TableRow.textLabel?.textColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        TableRow.textLabel?.font = .systemFont(ofSize: 30, weight: .bold)
        //        TableRow.backgroundColor = UIColor(red: 36/255, green: 35/255, blue: 37/255, alpha: 1)
        let HighlightColour = UIView()
        // sets the customisatioon aspects of the rows
        HighlightColour.backgroundColor = UIColor.orange
        TableRow.selectedBackgroundView = HighlightColour
        TableRow.backgroundColor = UIColor.clear
        TableRow.textLabel?.highlightedTextColor = UIColor.white
        // returns the row
        return TableRow
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // deselect it so its no longer highlighted
        tableView.deselectRow(at: indexPath, animated: true)
        // increases the clickcount by calling the function
        self.increaseClickCount()
        let CurrentModel = TheClasses[indexPath.row]
        let ViewController = UserClassController()
        // sets the user defaults
        UserDefaults.standard.set(CurrentModel.ClassName, forKey: "ClassName")
        UserDefaults.standard.set(CurrentModel.ClassID, forKey: "ClassID")
        // pushes to another page
        navigationController?.pushViewController(ViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // sets the size of each row
        100
    }
}

extension HomeMenuController{
    public func CreateNewSection(with Title: String, Body: String, Type: String, ClassID: String, SectionName: String, completion: @escaping (Bool) -> Void){
        // gets the userdefault and stores it in the variable
        guard let CurrentUserID = UserDefaults.standard.value(forKey: "UserID") as? String else{
            return
        }
        // set the path
        let UserIDPath = TheDatabase.child("Classes").child("\(ClassID)")
        UserIDPath.observeSingleEvent(of: .value, with: { snapshot in
            guard var UsersNode = snapshot.value as? [String: Any] else{
                // returns the completion false and prints it
                completion(false)
                print("An error has occured")
                return
            }
            // sets the parameters in a dictionary
            let CreateAboutSection: [String: Any] = [
                "SectionTitle": Title,
                "SectionBody": Body
            ]
            // sets more parameters in a dictionary
            let CreateContentSection: [String: Any] = [
                "TheType": Type,
                "Title": Title,
                "Body": Body,
            ]
            // checks if the child exists and if it does appends the above dictionary then sets the value in the database
            if var Chats = UsersNode["\(SectionName)"] as? [[String: Any]] {
                Chats.append(CreateContentSection)
                UsersNode["\(SectionName)"] = Chats
                UserIDPath.setValue(UsersNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else{
                        // returns the completion false
                        completion(false)
                        return
                    }
                })
            }
            else{
                // create a dictionary of the dictionary above
                UsersNode["\(SectionName)"] = [
                    CreateContentSection
                ]
                //sets the value in the database
                UserIDPath.setValue(UsersNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                })
            }
        })
    }
}
