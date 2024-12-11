//
//  ProfileController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 24/01/2024.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase
import RealmSwift
import JGProgressHUD

struct ProfileContent{
    let ContentType: String
    let Level: String
    let XP: String
    let MaxXP: String
    let Badges: [Bool]
    let StatsValues: [GraphCoordinates]
    let Cell: Int
}

struct ProfileContentSection{
    let Title: String
    let Section: [ProfileContent]
}

struct GraphCoordinates{
    let x: Int
    let y: Int
}

var ProfileContentRows = [ProfileContentSection]()

class UserProfileController: UIViewController {
    
    private let TheDatabase = Database.database().reference()
    private let spinner = JGProgressHUD(style: .dark)
    private var Level = ""
    private var XP = ""
    private var maxXP = ""
    
    
    private let TitleNameLabel: UILabel = {
        let Label = UILabel()
        Label.text = "Loading..."
        Label.font = .systemFont(ofSize: 30, weight: .bold)
        Label.textColor = .white
        return Label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.GetInfo(completion: { [weak self] result in
            switch result{
            case .success(let Value):
                print(Value)
                ProfileContentRows = [ProfileContentSection]()
                self?.spinner.show(in: (self?.view)!)
                self?.SetupProfileUI()
                self?.navigationItem.title = UserDefaults.standard.value(forKey: "UsersName")! as? String
                DispatchQueue.main.async {
                    self?.spinner.dismiss()
                }
                
                self!.view.addSubview(self!.ProfileContentsTable)
                self?.ProfileContentsTable.delegate = self
                self?.ProfileContentsTable.dataSource = self
                self?.ProfileContentsTable.frame = (self?.view.bounds)!
                self?.ProfileContentsTable.backgroundColor = UIColor.clear
                
                
                let MoveDownBy: CGFloat = 30
                self?.ProfileContentsTable.contentInset.top = MoveDownBy
                
                ProfileContentRows.append(ProfileContentSection(Title: "Levels", Section: [
                    ProfileContent(ContentType: "Level", Level: self!.Level, XP: self!.XP, MaxXP: self!.maxXP, Badges: [], StatsValues: [], Cell: 0)
                ]))
                
                ProfileContentRows.append(ProfileContentSection(Title: "", Section: [
                    ProfileContent(ContentType: "Badges", Level: "", XP: "", MaxXP: "", Badges: [], StatsValues: [], Cell: 1)
                ]))
                
                ProfileContentRows.append(ProfileContentSection(Title: "", Section: [
                    ProfileContent(ContentType: "Statistics", Level: "", XP: "", MaxXP: "", Badges: [], StatsValues: [], Cell: 2)
                ]))

            case .failure(let error):
                print(error)
            }
        })
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.image = UIImage(named: "back")
        self.navigationItem.backBarButtonItem?.tintColor = .orange
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = UserDefaults.standard.value(forKey: "UsersName")! as? String
        
        DispatchQueue.main.async{
            self.ProfileContentsTable.reloadData()
        }
    }
    
    private func SetupProfileUI(){
        let AppBackgroundImg = UIImageView(frame: UIScreen.main.bounds)
        AppBackgroundImg.image = UIImage(named: "AppBackground.png")
        self.view.insertSubview(AppBackgroundImg, at: 2)
        
        let CustomiseUserName: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.orange,
            .font: UIFont.boldSystemFont(ofSize: 25.0)
        ]
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = CustomiseUserName
        navigationController?.navigationBar.scrollEdgeAppearance?.titleTextAttributes = CustomiseUserName
        
    }
    
    private let ProfileContentsTable: UITableView = {
        let Table = UITableView()
        Table.register(ProfileTableViewCell.self, forCellReuseIdentifier: "ProfileTableViewCell")
        Table.separatorColor = .orange
        Table.translatesAutoresizingMaskIntoConstraints = false
        return Table
    }()
    
    private func GetInfo(completion: @escaping (Result<Bool, Error>) -> Void){
        
        self.GetValue(TheType: "Level", completion: { [weak self] result in
            switch result{
            case .success(let Value):
                self?.Level = Value
                
                self?.GetValue(TheType: "XP", completion: { [weak self] result in
                    switch result{
                    case .success(let Value):
                        self?.XP = Value
                        
                        self?.GetValue(TheType: "MaxXp", completion: { [weak self] result in
                            switch result{
                            case .success(let Value):
                                self?.maxXP = Value
                                completion(.success(true))
                                
                            case .failure(let error):
                                print("Failed: \(error)")
                            }
                        })
                        
                    case .failure(let error):
                        print("Failed: \(error)")
                    }
                })
            case .failure(let error):
                print("Failed: \(error)")
            }
        })
    }
    
    private func SetRows(){
        
    }
    
    private func GetValue(TheType: String, completion: @escaping (Result<String, Error>) -> Void){
        var UserID = ""
        let Usersname = UserDefaults.standard.value(forKey: "UsersName")
        if(Usersname as! String == "Anonymous"){
            UserID = (UserDefaults.standard.value(forKey: "ActualUserID") as? String)!
        }
        else{
            UserID = (UserDefaults.standard.value(forKey: "UserID") as? String)!
        }
        

        TheDatabase.child("LevelSystem/Users").observeSingleEvent(of: .value, with: {snapshot in
            guard let UsersContainer = snapshot.value as? [[String: Any]] else{
                print("problem")
                return
            }
            
            var i = 0
            
            var TheUsers: [String: Any]?
            
            for User in UsersContainer {
                if let TheUniqueID = User["UserID"] as? String, TheUniqueID == UserID{
                    TheUsers = User
                    break
                }
                i += 1
            }
            
            let UserLevel = TheUsers?["Level"] as! String
            let UserExp = TheUsers?["Exp"] as! String
            let UserMaxExp = TheUsers?["MaxXp"] as! String
            
            
            let ReturnType = TheType
            
            if(ReturnType == "Level"){
                completion(.success(UserLevel))
            }
            else if(ReturnType == "XP"){
                completion(.success(UserExp))
            }
            else if(ReturnType == "MaxXp"){
                completion(.success(UserMaxExp))
            }
            else{
            }
        }
                                                                  
        )}
    
}













extension UserProfileController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProfileContentRows[section].Section.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let TheRows = ProfileContentRows[indexPath.row]
        guard let TableRow = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell", for: indexPath) as? ProfileTableViewCell
        else{
            return UITableViewCell()
        }
        
        let Rows = ProfileContentRows[indexPath.section].Section[indexPath.row]
//        print(ProfileContentRows[indexPath.section].Section[indexPath.row])
        TableRow.Build(with: Rows)
        
        //        TableRow.Build(with: CurrentModel)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let Rows = ProfileContentRows[indexPath.section].Section[indexPath.row]
        if Rows.Cell == 1{
            return 160
        }
        else if Rows.Cell == 2{
            return 460
        }
        else{
            return 80
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        ProfileContentRows.count
    }
}
