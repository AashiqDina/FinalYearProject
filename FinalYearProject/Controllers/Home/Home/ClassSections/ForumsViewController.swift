//
//  ForumsViewController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 27/02/2024.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ForumsViewController: UIViewController {
    // create an array of About
    var AboutSectionRows = [About]()
    // create a database reference and store it in a variable
    private let TheDatabase = Database.database().reference()
    // create an array that stores the clickcount and the date of the lastclick
    private var ClickCount = UserDefaults.standard.object(forKey: "ClickCount")
    private var LastClick = UserDefaults.standard.object(forKey: "LastClick")
    // function that checks if the last click exists
    func checkLastClick(){
        if(self.LastClick == nil){
            // if it doesnt exist then set it as the user defaults
            UserDefaults.standard.set(0, forKey: "ClickCount")
            UserDefaults.standard.set(Date(), forKey: "LastClick")
        }
        // sets the local variables to the newly assigned userdefaults
        self.ClickCount = UserDefaults.standard.object(forKey: "ClickCount") as! Int
        self.LastClick = UserDefaults.standard.object(forKey: "LastClick") as! Date
    }
    // function that increases the clickcount
    func increaseClickCount(){
        // if its been more than one minute then it...
        if(Date().timeIntervalSince(self.LastClick as! Date) >= 60){
            // sets the new userdefault to one more
            UserDefaults.standard.set(self.ClickCount as! Int+1, forKey: "ClickCount")
            print("Click count now:")
            print(UserDefaults.standard.object(forKey: "ClickCount"))
            // sets the current date to the user default
            UserDefaults.standard.set(Date(), forKey: "LastClick")
            // calls check last click to set it to the local variables
            self.checkLastClick()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // sets the background
        let AppBackgroundImg = UIImageView(frame: UIScreen.main.bounds)
        AppBackgroundImg.image = UIImage(named: "AppBackground.png")
        self.view.insertSubview(AppBackgroundImg, at: 0)
        // sets the title
        navigationItem.title = "Forums"
        // customises the back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.image = UIImage(named: "back")
        self.navigationItem.backBarButtonItem?.tintColor = .orange
        // adds the add button to the top right
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(CreateForumPost))
        self.navigationItem.rightBarButtonItem?.image = UIImage(named: "Plus")
        self.navigationItem.rightBarButtonItem?.tintColor = .orange
        // calls addtable
        self.AddTable()
        // adds the table
        view.addSubview(AboutSectionTable)
        AboutSectionTable.delegate = self
        AboutSectionTable.dataSource = self
        AboutSectionTable.frame = view.bounds
        // makes the cells background clear
        self.AboutSectionTable.backgroundColor = UIColor.clear
    }
    // function that brings the user to another page
    @objc private func CreateForumPost(){
        let ViewController = ForumAddViewController()
        navigationController?.pushViewController(ViewController, animated: true)
    }
    
    private func AddTable(){
        // empties the AboutSectionRows array
        AboutSectionRows = [About]()
        // Gets the ClassID from the userDefault
        guard let ClassID = UserDefaults.standard.value(forKey: "ClassID") as? String else{
            return
        }
        // calls GetInfo
        self.GetInfo(for: ClassID, completion: { [weak self] result in
            switch result{
            case .success(let About):
                //if the chat is empty it prints chat is empty
                guard !About.isEmpty else {
                    print("About is empty")
                    return
                }
                self?.AboutSectionRows = About
                DispatchQueue.main.async{
                    // reloads the tables data in the main thread
                    self?.AboutSectionTable.reloadData()
                }
            case .failure(let error):
                // if it returns failure it prints below
                print("Failed: \(error)")
            }
        })
    }
    // Creates the table
    private let AboutSectionTable: UITableView = {
        let Table = UITableView()
        Table.register(AboutSectionTableViewCell.self, forCellReuseIdentifier: "AboutSectionTableViewCell")
        Table.separatorColor = .orange
        Table.translatesAutoresizingMaskIntoConstraints = false
        return Table
    }()
    
    public func GetInfo(for ClassID: String, completion: @escaping (Result<[About], Error>) -> Void){
        //  Uses the database reference and the path ot get a snapshot
        TheDatabase.child("Classes/\(ClassID)/Forum").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                // if it is not able to get the snapshot as a array of dictionaries then it prints false and returns completion false and returns
                print("Here: Failed")
                completion(.failure(AnError(message: "Failed to fetch")))
                return
            }
            // store the resulted value as a dictionary (About)
            let AChat: [About] = value.compactMap({
                dictionary in
                guard let Title = dictionary["SectionTitle"] as? String,
                      let Body = dictionary["SectionBody"] as? String
                      else {
                          return nil
                      }
                
                return About(SectionTile: Title, SectionDescription: Body)

            })
            // on completion success return the dictionary
            completion(.success(AChat))
        })
    }

}

extension ForumsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // the number of sections is is the count of the aboutsectionrows array
        return AboutSectionRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let TableRow = tableView.dequeueReusableCell(withIdentifier: "AboutSectionTableViewCell", for: indexPath) as? AboutSectionTableViewCell
        else{
            return UITableViewCell()
        }
        // Gets the specific element of the array
        let Rows = AboutSectionRows[indexPath.row]
        // Calls build with the above variable
        TableRow.Build(with: Rows)
        
        // customise the UILabel form TableRow
        TableRow.textLabel?.textColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        TableRow.textLabel?.font = .systemFont(ofSize: 30, weight: .bold)
        //        TableRow.backgroundColor = UIColor(red: 36/255, green: 35/255, blue: 37/255, alpha: 1)
        let HighlightColour = UIView()
        HighlightColour.backgroundColor = UIColor.orange
        TableRow.selectedBackgroundView = HighlightColour
        TableRow.backgroundColor = UIColor.clear
        TableRow.textLabel?.highlightedTextColor = UIColor.white
        // return the tableRow
        return TableRow
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Un-highlights the row
        tableView.deselectRow(at: indexPath, animated: true)
        // calls increaseClickCount
        self.increaseClickCount()
        // Gets the specific element of the array and uses it as parameters for the page it will get taken into
        let Rows = AboutSectionRows[indexPath.row]
        let ViewController = ForumSpecificViewController(with: Rows.SectionTile, AboutBody: Rows.SectionDescription, ForumResponseID: indexPath.row)
        navigationController?.pushViewController(ViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // sets the size of the row
        80
    }
}
