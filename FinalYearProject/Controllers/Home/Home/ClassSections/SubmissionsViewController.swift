//
//  SubmissionsViewController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 27/02/2024.
//

import JGProgressHUD
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase

// Creates a submission struct
struct Submissions{
    let SectionTile: String
    let SectionDescription: String
    let UniqueID: String
}

class SubmissionsViewController: UIViewController {
    // Create an array of submissions
    var SubmissionsSectionRows = [Submissions]()
    // Create a refernece to the database
    private let TheDatabase = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // sets the background
        let AppBackgroundImg = UIImageView(frame: UIScreen.main.bounds)
        AppBackgroundImg.image = UIImage(named: "AppBackground.png")
        self.view.insertSubview(AppBackgroundImg, at: 0)
        // adds the following subviews
        view.addSubview(SubmissionsSectionTable)
        SubmissionsSectionTable.delegate = self
        SubmissionsSectionTable.dataSource = self
        SubmissionsSectionTable.frame = view.bounds
        self.SubmissionsSectionTable.backgroundColor = UIColor.clear
        // sets the title
        navigationItem.title = "Submissions"
        // sets the buttons
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.image = UIImage(named: "back")
        self.navigationItem.backBarButtonItem?.tintColor = .orange
        // Calls AddTable
        self.AddTable()
        // Gets isTeacher from the userdefault
        let IsTeacher = UserDefaults.standard.value(forKey: "IsTeacher") as? String ?? "false"
        if(IsTeacher == "true"){
            // calls the method below
            self.AddTeacherStuff()
        }

        // Do any additional setup after loading the view.
    }
    // adds a button on the top right
    private func AddTeacherStuff(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(CreateSubmissionsRow))
        self.navigationItem.rightBarButtonItem?.image = UIImage(named: "Plus")
        self.navigationItem.rightBarButtonItem?.tintColor = .orange
    }
    // Adds the function for if the button is clicked
    @objc private func CreateSubmissionsRow(){
        let ViewController = AddSubmissionrRowViewController()
        navigationController?.pushViewController(ViewController, animated: true)
    }
    
    private func AddTable(){
        // Creates an array of submissions
        SubmissionsSectionRows = [Submissions]()
        // Gets the ClassID from the userdefaults
        guard let ClassID = UserDefaults.standard.value(forKey: "ClassID") as? String else{
            return
        }
        // calls getinfo
        self.GetInfo(for: ClassID, completion: { [weak self] result in
            switch result{
            case .success(let Submissions):
                //if the chat is empty it prints chat is empty
                guard !Submissions.isEmpty else {
                    print("Submissions is empty")
                    return
                }
                // sets the values with the recieved value
                self?.SubmissionsSectionRows = Submissions
                DispatchQueue.main.async{
                    // reloads the tables data in the main queue
                    self?.SubmissionsSectionTable.reloadData()
                }
            case .failure(let error):
                // if completions failure print the following
                print("Failed: \(error)")
            }
        })
    }
    // create the table
    private let SubmissionsSectionTable: UITableView = {
        let Table = UITableView()
        // registers the table
        Table.register(SubmissionSectionTableViewCell.self, forCellReuseIdentifier: "SubmissionSectionTableViewCell")
        // sets the cell seperator colours to orange
        Table.separatorColor = .orange
        Table.translatesAutoresizingMaskIntoConstraints = false
        return Table
    }()
    
    public func GetInfo(for ClassID: String, completion: @escaping (Result<[Submissions], Error>) -> Void){
        // uses a database reference and the path to get a snapshot
        TheDatabase.child("Classes/\(ClassID)/Submissions").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                // if the snapshot couldnt be recieved as an array of dictionaries witht the key as string and the values can be anything it prints failure and returns a completion failure
                print("Here: Failed")
                completion(.failure(AnError(message: "Failed to fetch")))
                return
            }
            // store the resulted value as a dictionary
            let AChat: [Submissions] = value.compactMap({
                dictionary in
                guard let Title = dictionary["Title"] as? String,
                      let Body = dictionary["Body"] as? String,
                      let UniqueID = dictionary["UniqueID"] as? String
                      else {
                          return nil
                      }
                
                return Submissions(SectionTile: Title, SectionDescription: Body, UniqueID: UniqueID)

            })
            // if everything above completes successfully it returns completion success and returns the dictionary
            completion(.success(AChat))
        })
    }

}

extension SubmissionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // number of sections will be the returned value of the array's count
        return SubmissionsSectionRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let TableRow = tableView.dequeueReusableCell(withIdentifier: "SubmissionSectionTableViewCell", for: indexPath) as? SubmissionSectionTableViewCell
        else{
            return UITableViewCell()
        }
        // each row will get the values of AboutSectionRows array and sets the variable to it
        let Rows = SubmissionsSectionRows[indexPath.row]
        TableRow.Build(with: Rows)
        // customises the text
        //        TableRow.Build(with: CurrentModel)
        TableRow.textLabel?.textColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        TableRow.textLabel?.font = .systemFont(ofSize: 30, weight: .bold)
        //        TableRow.backgroundColor = UIColor(red: 36/255, green: 35/255, blue: 37/255, alpha: 1)
        let HighlightColour = UIView()
        // sets the cell's customisation aspects
        HighlightColour.backgroundColor = UIColor.orange
        TableRow.selectedBackgroundView = HighlightColour
        TableRow.backgroundColor = UIColor.clear
        TableRow.textLabel?.highlightedTextColor = UIColor.white
        // returns the row
        return TableRow
    }
    // when clicked
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // un-highlights the row
        tableView.deselectRow(at: indexPath, animated: true)
        // increases the click count
        let Rows = SubmissionsSectionRows[indexPath.row]
        // pushes to another page with the Tite and the body
        let ViewController = AddSubmissionsViewController(with: Rows.UniqueID, Title: Rows.SectionTile)
        navigationController?.pushViewController(ViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // sets size of the rows
        80
    }
}
