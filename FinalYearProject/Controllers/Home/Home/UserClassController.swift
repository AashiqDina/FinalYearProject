//
//  UserClassController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 24/02/2024.
//

import UIKit
import JGProgressHUD
// creates a struct with a title and the function
struct ClassContent{
    let Title: String
    let Function: (() -> Void)
}
// creates a struct with a title and an array of classContents
struct ClassContentSection{
    let Title: String
    let Section: [ClassContent]
}
// creates an array of ClassContentSection
var ClassContentRows = [ClassContentSection]()

class UserClassController: UIViewController {
    
    // creates spinner
    private let spinner = JGProgressHUD(style: .dark)
    
    // creates the variables and gets it from the userdefaults
    private var ClickCount = UserDefaults.standard.object(forKey: "ClickCount")
    private var LastClick = UserDefaults.standard.object(forKey: "LastClick")
    
    // checks if the last click exists and if it doesnt sets it
    func checkLastClick(){
        if(self.LastClick == nil){
            UserDefaults.standard.set(0, forKey: "ClickCount")
            UserDefaults.standard.set(Date(), forKey: "LastClick")
        }
        // sets the values to the above variables
        self.ClickCount = UserDefaults.standard.object(forKey: "ClickCount") as! Int
        self.LastClick = UserDefaults.standard.object(forKey: "LastClick") as! Date
    }
    // increases the click count if the a row is clicked and it has been more than 1 minute since the last click
    func increaseClickCount(){
        if(Date().timeIntervalSince(self.LastClick as! Date) >= 60){
            UserDefaults.standard.set(self.ClickCount as! Int+1, forKey: "ClickCount")
            print("Click count now:")
            print(UserDefaults.standard.object(forKey: "ClickCount"))
            UserDefaults.standard.set(Date(), forKey: "LastClick")
            self.checkLastClick()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // sets the background
        let AppBackgroundImg = UIImageView(frame: UIScreen.main.bounds)
        AppBackgroundImg.image = UIImage(named: "AppBackground.png")
        self.view.insertSubview(AppBackgroundImg, at: 0)
        // sets the table
        view.addSubview(ClassContentsTable)
        ClassContentsTable.delegate = self
        ClassContentsTable.dataSource = self
        ClassContentsTable.frame = view.bounds
        // make the table rows background transparent
        self.ClassContentsTable.backgroundColor = UIColor.clear
        // sets the title
        navigationItem.title = UserDefaults.standard.value(forKey: "ClassName") as! String
        // sets the back button and its customisation
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.image = UIImage(named: "back")
        self.navigationItem.backBarButtonItem?.tintColor = .orange
        // create an array of ClassContentSections
        ClassContentRows = [ClassContentSection]()
        // calls SetRows
        self.SetRows()
        // moves the table down slightly
        let MoveDownBy: CGFloat = 30
        ClassContentsTable.contentInset.top = MoveDownBy
        
    }
    
    private func SetRows(){
        // checks is its a teacher
        let IsTeacher = UserDefaults.standard.value(forKey: "IsTeacher") as? String ?? "false"
        if(IsTeacher == "true"){
            // if the user is a teacher it appends the created rows below with the functions as seen and the titles
            ClassContentRows.append(ClassContentSection(Title: "AddContent", Section: [
                ClassContent(Title: "+ Add/Edit Content"){
                    self.increaseClickCount()
                    let ViewController = AddContentViewController()
                    self.navigationController?.pushViewController(ViewController, animated: true)
                }
            ]))
            ClassContentRows.append(ClassContentSection(Title: "Forums", Section: [
                ClassContent(Title: "Forums"){
                    self.increaseClickCount()
                    let ViewController = ForumsViewController()
                    self.navigationController?.pushViewController(ViewController, animated: true)
                }
            ]))
            ClassContentRows.append(ClassContentSection(Title: "Class Statistics", Section: [
                ClassContent(Title: "Class Statistics"){
                    self.increaseClickCount()
                    let ViewController = ClassStatisticsViewController()
                    self.navigationController?.pushViewController(ViewController, animated: true)
                }
            ]))
        }
        else{
            // if its not a teacher then it appends the created rows below with the functions as seen and the titles
            ClassContentRows.append(ClassContentSection(Title: "About", Section: [
                ClassContent(Title: "About Class"){
                    self.increaseClickCount()
                    let ViewController = AboutViewController()
                    self.navigationController?.pushViewController(ViewController, animated: true)
                }
            ]))
            ClassContentRows.append(ClassContentSection(Title: "Forums", Section: [
                ClassContent(Title: "Forums"){
                    self.increaseClickCount()
                    let ViewController = ForumsViewController()
                    self.navigationController?.pushViewController(ViewController, animated: true)
                }
            ]))
            ClassContentRows.append(ClassContentSection(Title: "Content", Section: [
                ClassContent(Title: "Content"){
                    self.increaseClickCount()
                    let ViewController = ContentViewController()
                    self.navigationController?.pushViewController(ViewController, animated: true)
                }
            ]))
            ClassContentRows.append(ClassContentSection(Title: "Submissions", Section: [
                ClassContent(Title: "Submissions"){
                    self.increaseClickCount()
                    let ViewController = SubmissionsViewController()
                    self.navigationController?.pushViewController(ViewController, animated: true)
                }
            ]))
            ClassContentRows.append(ClassContentSection(Title: "Grades", Section: [
                ClassContent(Title: "Grades"){
                    self.increaseClickCount()
                    let ViewController = GradesViewController()
                    self.navigationController?.pushViewController(ViewController, animated: true)
                }
            ]))
            ClassContentRows.append(ClassContentSection(Title: "Class Statistics", Section: [
                ClassContent(Title: "Class Statistics"){
                    self.increaseClickCount()
                    let ViewController = ClassStatisticsViewController()
                    self.navigationController?.pushViewController(ViewController, animated: true)
                }
            ]))
            ClassContentRows.append(ClassContentSection(Title: "Other", Section: [
                ClassContent(Title: "Other"){
                    self.increaseClickCount()
                    let ViewController = OtherViewController()
                    self.navigationController?.pushViewController(ViewController, animated: true)
                }
            ]))
        }
        
    }
    
    // creates the table as seen with the cells
    private let ClassContentsTable: UITableView = {
        let Table = UITableView()
        Table.register(InClassTableViewCell.self, forCellReuseIdentifier: "InClassTableViewCell")
        // make the row seperators orange
        Table.separatorColor = .orange
        Table.translatesAutoresizingMaskIntoConstraints = false
        return Table
    }()
}

extension UserClassController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // number of sections are returned by getting the count
        return ClassContentRows[section].Section.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // sets the data in the array to the variabel
        let TheRows = ClassContentRows[indexPath.row]
        guard let TableRow = tableView.dequeueReusableCell(withIdentifier: "InClassTableViewCell", for: indexPath) as? InClassTableViewCell
        else{
            return UITableViewCell()
        }
        // calls build  in the table view cell
        let Rows = ClassContentRows[indexPath.section].Section[indexPath.row]
        TableRow.Build(with: Rows)
        
        //        TableRow.Build(with: CurrentModel)
        TableRow.textLabel?.textColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        TableRow.textLabel?.font = .systemFont(ofSize: 30, weight: .bold)
        //        TableRow.backgroundColor = UIColor(red: 36/255, green: 35/255, blue: 37/255, alpha: 1)
        // customises the rows
        let HighlightColour = UIView()
        HighlightColour.backgroundColor = UIColor.orange
        TableRow.selectedBackgroundView = HighlightColour
        TableRow.backgroundColor = UIColor.clear
        TableRow.textLabel?.highlightedTextColor = UIColor.white
        // returns the rows
        return TableRow
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // un-highlights the row
        tableView.deselectRow(at: indexPath, animated: true)
        //and calls the intended functions
        let ToDo = ClassContentRows[indexPath.section].Section[indexPath.row]
        ToDo.Function()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // sets height of the rows
        80
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // sets the number of sections
        ClassContentRows.count
    }
}
