//
//  ForumSpecificViewController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 21/04/2024.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

// Creates a Forums struct
struct Forums{
    let ID: Int
    let SectionTile: String
    let SectionDescription: String
}

class ForumSpecificViewController: UIViewController {
    // Create an array of About
    var AboutSectionRows = [About]()
    // Create a database reference
    private let TheDatabase = Database.database().reference()
    // Declare variables
    var TheAboutTitle = "Error - Could not find Page"
    var TheAboutText = ""
    var TheForumResponseID = 100
    
    // when the page is created it takes in the title, body and ForumResponseID
    init(with AboutTitle: String, AboutBody: String, ForumResponseID: Int){
        super.init(nibName: nil, bundle: nil)
        TheAboutTitle = AboutTitle
        TheAboutText = AboutBody
        TheForumResponseID = ForumResponseID
    }
    // below is required if init doesnt occur it stops the program and prints the message
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the background
        let AppBackgroundImg = UIImageView(frame: UIScreen.main.bounds)
        AppBackgroundImg.image = UIImage(named: "AppBackground.png")
        self.view.insertSubview(AppBackgroundImg, at: 0)
        // set the top right button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(CreateForumPost))
        self.navigationItem.rightBarButtonItem?.image = UIImage(named: "Plus")
        self.navigationItem.rightBarButtonItem?.tintColor = .orange
        // customise the back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.image = UIImage(named: "back")
        self.navigationItem.backBarButtonItem?.tintColor = .orange
        // Add the table
        view.addSubview(AboutSectionTable)
        AboutSectionTable.delegate = self
        AboutSectionTable.dataSource = self
        AboutSectionTable.frame = view.bounds
        self.AboutSectionTable.backgroundColor = UIColor.clear
        self.AddTable()
        
    }
    
    @objc private func CreateForumPost(){
        // brings to the Forum response page
        let ViewController = ForumResponseAddViewController(with: TheForumResponseID)
        navigationController?.pushViewController(ViewController, animated: true)
    }
    
    private func AddTable(){
        // Creates an array of About
        AboutSectionRows = [About]()
        // Get ClassID from the userDefault
        guard let ClassID = UserDefaults.standard.value(forKey: "ClassID") as? String else{
            return
        }
        // Calls GetInfo
        self.GetInfo(for: ClassID, completion: { [weak self] result in
            switch result{
            case .success(let About):
                // if completion success
                // if the chat is empty it prints chat is empty
                guard !About.isEmpty else {
                    print("About is empty")
                    return
                }
                // The returned array is given to the variable
                self?.AboutSectionRows = About
                DispatchQueue.main.async{
                    // reloads the tables data using the main thread
                    self?.AboutSectionTable.reloadData()
                }
            case .failure(let error):
                // if completion failure is returned print the error
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
        TheDatabase.child("Classes/\(ClassID)/Forum/\(TheForumResponseID)/Responses").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                // if it is not able to get the snapshot as a array of dictionaries then it prints false and returns completion false and returns
                print("Here: Failed")
                completion(.failure(AnError(message: "Failed to fetch")))
                return
            }
            // store the resulted value as a dictionary (About)
            var AChat: [About] = value.compactMap({
                dictionary in
                guard let Title = dictionary["SectionTitle"] as? String,
                      let Body = dictionary["SectionBody"] as? String
                      else {
                          return nil
                      }
                
                return About(SectionTile: Title, SectionDescription: Body)

            })
            // Make the first row the question and answer by giving the variable the title and description
            let FirstSection = FinalYearProject.About(SectionTile: self.TheAboutTitle, SectionDescription: self.TheAboutText)
            print(FirstSection)
            // Append FirstSection
            AChat.append(FirstSection)
            // Reverse the array so the initial question is at the top and the responses are ordered by newest to oldest
            AChat.reverse()
            print(AChat)
            // returns the array as completion success
            completion(.success(AChat))
        })
    }

}

extension ForumSpecificViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the count of the array AboutSectionRows
        return AboutSectionRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let TableRow = tableView.dequeueReusableCell(withIdentifier: "AboutSectionTableViewCell", for: indexPath) as? AboutSectionTableViewCell
        else{
            return UITableViewCell()
        }
        // set the variable to the element of the Array
        let Rows = AboutSectionRows[indexPath.row]
        // Call build with the variable declared above
        TableRow.Build(with: Rows)
        
        //        TableRow.Build(with: CurrentModel)
        // Customise the text label
        TableRow.textLabel?.textColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        if(indexPath.row == 0){
            TableRow.textLabel?.font = .systemFont(ofSize: 40, weight: .bold)
        }
        else{
            TableRow.textLabel?.font = .systemFont(ofSize: 30, weight: .bold)
        }
        //        TableRow.backgroundColor = UIColor(red: 36/255, green: 35/255, blue: 37/255, alpha: 1)
        // Customise the cells
        let HighlightColour = UIView()
        HighlightColour.backgroundColor = UIColor.orange
        TableRow.selectedBackgroundView = HighlightColour
        TableRow.backgroundColor = UIColor.clear
        TableRow.textLabel?.highlightedTextColor = UIColor.white
        // Return the Row
        return TableRow
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Un-highlight the row
        tableView.deselectRow(at: indexPath, animated: true)
        // set the variable to the element of the Array
        let Rows = AboutSectionRows[indexPath.row]
        // Goes to About specific page with the title and the bidy
        let ViewController = AboutSpecificViewController(with: Rows.SectionTile, AboutBody: Rows.SectionDescription, IsTheContent: false, ContentsID: "")
        navigationController?.pushViewController(ViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0){
            // the first row has double the height of the other rows
            return 160
        }
        else{
            // Other rows have this height
            return 80
        }
    }
}
