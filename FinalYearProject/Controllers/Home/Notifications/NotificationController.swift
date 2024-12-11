//
//  NotificationController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 23/01/2024.
//

import UIKit
import FirebaseCore
import FirebaseDatabase

class NotificationController: UIViewController {
    // create an array of the struct about
    var AboutSectionRows = [About]()
    // create a reference to the database
    private let TheDatabase = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        // sets the background of the page
        let AppBackgroundImg = UIImageView(frame: UIScreen.main.bounds)
        AppBackgroundImg.image = UIImage(named: "AppBackground.png")
        self.view.insertSubview(AppBackgroundImg, at: 0)
        // Sets the title of the page
        self.navigationItem.title = "Notifications"
        self.CustomiseTitle()
        // sets the table
        view.addSubview(AboutSectionTable)
        AboutSectionTable.delegate = self
        AboutSectionTable.dataSource = self
        AboutSectionTable.frame = view.bounds
        self.AboutSectionTable.backgroundColor = UIColor.clear
        self.AddTable()
    }
    
    private func CustomiseTitle(){
        // sets and customises the title
        self.navigationItem.title = "Notifications"
        
        let CustomiseUserName: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.orange,
            .font: UIFont.boldSystemFont(ofSize: 25.0)
        ]
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = CustomiseUserName
        navigationController?.navigationBar.scrollEdgeAppearance?.titleTextAttributes = CustomiseUserName
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.navigationItem.backBarButtonItem?.image = UIImage(named: "back")
        self.navigationItem.backBarButtonItem?.tintColor = .orange
        
    }
    
    private func AddTable(){
        // create an array of the struct about
        AboutSectionRows = [About]()
        guard let ClassID = UserDefaults.standard.value(forKey: "ClassID") as? String else{
            return
        }
        // calls getInfo
        self.GetInfo(for: ClassID, completion: { [weak self] result in
            switch result{
            case .success(let About):
                //if the chat is empty it prints chat is empty
                guard !About.isEmpty else {
                    print("About is empty")
                    return
                }
                // sets the returned value of the function to the array
                self?.AboutSectionRows = About
                DispatchQueue.main.async{
                    // reloads the tables data
                    self?.AboutSectionTable.reloadData()
                }
            case .failure(let error):
                // print failure if completion false is returned
                print("Failed: \(error)")
            }
        })
    }
    // create the table
    private let AboutSectionTable: UITableView = {
        let Table = UITableView()
        // registers the table
        Table.register(AboutSectionTableViewCell.self, forCellReuseIdentifier: "AboutSectionTableViewCell")
        // sets the cell seperator colours to orange
        Table.separatorColor = .orange
        Table.translatesAutoresizingMaskIntoConstraints = false
        return Table
    }()
    
    public func GetInfo(for ClassID: String, completion: @escaping (Result<[About], Error>) -> Void){
        // uses a database reference and the path to get a snapshot
        let UserID = (UserDefaults.standard.value(forKey: "UserID") as? String)!
        TheDatabase.child("Notifications/\(UserID)/Notif").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                // if the snapshot couldnt be recieved as an array of dictionaries witht the key as string and the values can be anything it prints failure and returns a completion failure
                print("Here: Failed")
                completion(.failure(AnError(message: "Failed to fetch")))
                return
            }
            // store the resulted value as a dictionary
            let AChat: [About] = value.compactMap({
                dictionary in
                guard let Title = dictionary["SectionTitle"] as? String,
                      let Body = dictionary["SectionBody"] as? String
                      else {
                          return nil
                      }
                
                return About(SectionTile: Title, SectionDescription: Body)

            })
            // if everything above completes successfully it returns completion success and returns the dictionary
            completion(.success(AChat.reversed()))
        })
    }

}

extension NotificationController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // number of sections will be the returned value of the array's count
        return AboutSectionRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let TableRow = tableView.dequeueReusableCell(withIdentifier: "AboutSectionTableViewCell", for: indexPath) as? AboutSectionTableViewCell
        else{
            return UITableViewCell()
        }
        // each row will get the values of AboutSectionRows array and sets the variable to it
        let Rows = AboutSectionRows[indexPath.row]
        TableRow.Build(with: Rows)
        // customises the text
        //        TableRow.Build(with: CurrentModel)
        TableRow.textLabel?.textColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        TableRow.textLabel?.font = .systemFont(ofSize: 30, weight: .bold)
        //        TableRow.backgroundColor = UIColor(red: 36/255, green: 35/255, blue: 37/255, alpha: 1)
        let HighlightColour = UIView()
        HighlightColour.backgroundColor = UIColor.orange
        TableRow.selectedBackgroundView = HighlightColour
        TableRow.backgroundColor = UIColor.clear
        TableRow.textLabel?.highlightedTextColor = UIColor.white
        // returns the row
        return TableRow
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // un-highlights the row
        tableView.deselectRow(at: indexPath, animated: true)
        // sets the row to the variable
        let Rows = AboutSectionRows[indexPath.row]
        // pushes to another page with the Tite and the body
        let ViewController = AboutSpecificViewController(with: Rows.SectionTile, AboutBody: Rows.SectionDescription, IsTheContent: false, ContentsID: "")
        navigationController?.pushViewController(ViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // sets size of the rows
        80
    }
}

