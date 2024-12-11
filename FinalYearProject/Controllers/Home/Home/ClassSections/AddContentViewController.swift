//
//  AddContentViewController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 27/02/2024.
//

import UIKit
import JGProgressHUD

struct EditClassContent{
    let Title: String
    let Function: (() -> Void)
}

struct EditClassContentSection{
    let Title: String
    let Section: [EditClassContent]
}

var EditClassContentRows = [EditClassContentSection]()

class AddContentViewController: UIViewController {
    
    // creates spinner
    private let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // sets the background
        let AppBackgroundImg = UIImageView(frame: UIScreen.main.bounds)
        AppBackgroundImg.image = UIImage(named: "AppBackground.png")
        self.view.insertSubview(AppBackgroundImg, at: 0)
        // adds the subview
        view.addSubview(AddClassContentsTable)
        AddClassContentsTable.delegate = self
        AddClassContentsTable.dataSource = self
        AddClassContentsTable.frame = view.bounds
        self.AddClassContentsTable.backgroundColor = UIColor.clear
        // sets the title
        navigationItem.title = "Add Content"
        // sets the back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.image = UIImage(named: "back")
        self.navigationItem.backBarButtonItem?.tintColor = .orange
        // creates array of EditClassContentSection
        EditClassContentRows = [EditClassContentSection]()
        // call setRows
        self.SetRows()
        // Move the table down
        let MoveDownBy: CGFloat = 30
        AddClassContentsTable.contentInset.top = MoveDownBy
        
    }
    
    private func SetRows(){
        // appends sections to the array
        EditClassContentRows.append(EditClassContentSection(Title: "About", Section: [
            EditClassContent(Title: "About Class"){
                let ViewController = AboutViewController()
                self.navigationController?.pushViewController(ViewController, animated: true)
            }
        ]))
        EditClassContentRows.append(EditClassContentSection(Title: "Content", Section: [
            EditClassContent(Title: "Content"){
                let ViewController = ContentViewController()
                self.navigationController?.pushViewController(ViewController, animated: true)
            }
        ]))
        EditClassContentRows.append(EditClassContentSection(Title: "Submissions", Section: [
            EditClassContent(Title: "Submissions"){
                let ViewController = SubmissionsViewController()
                self.navigationController?.pushViewController(ViewController, animated: true)
            }
        ]))
        EditClassContentRows.append(EditClassContentSection(Title: "Grades", Section: [
            EditClassContent(Title: "Grades"){
                let ViewController = GradesViewController()
                self.navigationController?.pushViewController(ViewController, animated: true)
            }
        ]))
        EditClassContentRows.append(EditClassContentSection(Title: "Class Statistics", Section: [
            EditClassContent(Title: "Class Statistics"){
                let ViewController = ClassStatisticsViewController()
                self.navigationController?.pushViewController(ViewController, animated: true)
            }
        ]))
        EditClassContentRows.append(EditClassContentSection(Title: "Other", Section: [
            EditClassContent(Title: "Other"){
                let ViewController = OtherViewController()
                self.navigationController?.pushViewController(ViewController, animated: true)
            }
        ]))
        
    }
    
    private let AddClassContentsTable: UITableView = {
        let Table = UITableView()
        Table.register(EditClassesViewCell.self, forCellReuseIdentifier: "EditClassesViewCell")
        Table.separatorColor = .orange
        Table.translatesAutoresizingMaskIntoConstraints = false
        return Table
    }()
}

extension AddContentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // number of sections will be the returned value of the array's count
        return EditClassContentRows[section].Section.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let TheRows = EditClassContentRows[indexPath.row]
        guard let TableRow = tableView.dequeueReusableCell(withIdentifier: "EditClassesViewCell", for: indexPath) as? EditClassesViewCell
        else{
            return UITableViewCell()
        }
        // each row will get the values of AboutSectionRows array and sets the variable to it
        let Rows = EditClassContentRows[indexPath.section].Section[indexPath.row]
        TableRow.Build(with: Rows)
        // customises the text
        //        TableRow.Build(with: CurrentModel)
        TableRow.textLabel?.textColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        TableRow.textLabel?.font = .systemFont(ofSize: 30, weight: .bold)
        //        TableRow.backgroundColor = UIColor(red: 36/255, green: 35/255, blue: 37/255, alpha: 1)
        // sets the cell's customisation aspects
        let HighlightColour = UIView()
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
        let ToDo = EditClassContentRows[indexPath.section].Section[indexPath.row]
        // completes the function
        ToDo.Function()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // sets size of the rows
        80
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // number of sections will be the returned value of the array's count
        EditClassContentRows.count
    }
}
