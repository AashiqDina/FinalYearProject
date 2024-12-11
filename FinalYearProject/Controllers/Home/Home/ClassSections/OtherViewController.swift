//
//  ClassViewController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 27/02/2024.
//

import UIKit
import JGProgressHUD
    
var OtherContentRows = [ClassContentSection]()

class OtherViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //adds the login button and calls function for if the button is clicked
        let AppBackgroundImg = UIImageView(frame: UIScreen.main.bounds)
        AppBackgroundImg.image = UIImage(named: "AppBackground.png")
        self.view.insertSubview(AppBackgroundImg, at: 0)
        // adds the following subviews
        view.addSubview(ClassContentsTable)
        ClassContentsTable.delegate = self
        ClassContentsTable.dataSource = self
        ClassContentsTable.frame = view.bounds
        self.ClassContentsTable.backgroundColor = UIColor.clear
        // Add the title
        navigationItem.title = UserDefaults.standard.value(forKey: "ClassName") as! String
        // Set the title
        navigationItem.title = "Other"
        // Set the back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.image = UIImage(named: "back")
        self.navigationItem.backBarButtonItem?.tintColor = .orange
        
        // Create an array of classContent
        OtherContentRows = [ClassContentSection]()
        //call setRows
        self.SetRows()
        // Moves tables down
        let MoveDownBy: CGFloat = 30
        ClassContentsTable.contentInset.top = MoveDownBy
    }
    // sets tables
    
    private let ClassContentsTable: UITableView = {
        let Table = UITableView()
        Table.register(InClassTableViewCell.self, forCellReuseIdentifier: "InClassTableViewCell")
        Table.separatorColor = .orange
        Table.translatesAutoresizingMaskIntoConstraints = false
        return Table
    }()
    
    private func SetRows(){
        // appens the created variable
        OtherContentRows.append(ClassContentSection(Title: "Student Generated Content", Section: [
            ClassContent(Title: "Student Generated Content"){
                let ViewController = StudentGeneratedContentViewController()
                self.navigationController?.pushViewController(ViewController, animated: true)
            }
        ]))
    }

}
    

extension OtherViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // number of sections will be the returned value of the array's count
        return OtherContentRows[section].Section.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let TheRows = OtherContentRows[indexPath.row]
        guard let TableRow = tableView.dequeueReusableCell(withIdentifier: "InClassTableViewCell", for: indexPath) as? InClassTableViewCell
        else{
            return UITableViewCell()
        }
        // each row will get the values of AboutSectionRows array and sets the variable to it
        let Rows = OtherContentRows[indexPath.section].Section[indexPath.row]
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // un-highlights the row
        tableView.deselectRow(at: indexPath, animated: true)
        let ToDo = OtherContentRows[indexPath.section].Section[indexPath.row]
        // calls the function
        ToDo.Function()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // sets size of the rows
        80
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // number of sections will be the returned value of the array's count
        OtherContentRows.count
    }
}
