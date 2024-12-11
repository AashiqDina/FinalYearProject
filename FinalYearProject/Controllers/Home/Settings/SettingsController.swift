//
//  SettingsController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 23/01/2024.
//

import UIKit

struct SettingsRow{
    let Title: String
    let Function: (() -> Void)
}

struct RowSegments{
    let Title: String
    let Row: [SettingsRow]
}
// create an array of the struct RowSegments
var TheRows = [RowSegments]()
// Create public variable and set it to false
var Anonymous = false


class SettingsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // number of rows in sections will be the returned value of the array's count
        return TheRows[section].Row.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath) as? SettingsTableViewCell else{
            return UITableViewCell()
        }
        // each row will get the values of AboutSectionRows array and sets the variable to it
        let Rows = TheRows[indexPath.section].Row[indexPath.row]
        row.Build(with: Rows)
        // sets the cell's customisation aspects
        row.backgroundColor = UIColor.clear
        let RowSelectedColour = UIView()
        RowSelectedColour.backgroundColor = .orange
        row.selectedBackgroundView = RowSelectedColour
        row.textLabel?.highlightedTextColor = UIColor.clear
        return row
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // sets size of the rows
        50
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // number of sections will be the returned value of the array's count
        TheRows.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (Anonymous){
            // unhighlight row
            tableView.deselectRow(at: indexPath, animated: true)
        }
        else{
            
        }
        let ToDo = TheRows[indexPath.section].Row[indexPath.row]
        // call the function
        ToDo.Function()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // set the background
        let AppBackgroundImg = UIImageView(frame: UIScreen.main.bounds)
        AppBackgroundImg.image = UIImage(named: "AppBackground.png")
        self.view.insertSubview(AppBackgroundImg, at: 10)
        // set and customise title
        self.navigationItem.title = "Settings"
        self.CustomiseTitle()
        // Set the Table
        view.addSubview(SettingsTable)
        SettingsTable.delegate = self
        SettingsTable.dataSource = self
        SettingsTable.frame = view.bounds
        self.SettingsTable.backgroundColor = UIColor.clear
        
//        SettingsTableViewCell().IsAnonymous(Status: false)
        // Create an array of RowSegments
        TheRows = [RowSegments]()
        // Call function
        self.setSettingsRow()
    }
    
    func setSettingsRow(){
        // Get variables from user defaults
        let IsTeacher = UserDefaults.standard.value(forKey: "IsTeacher") as? String ?? "false"
        let IsTempTeacher = UserDefaults.standard.value(forKey: "TempIsTeacher") as? String ?? "false"
        var Title = "Anonymous"
        if(IsTeacher == "true" || IsTempTeacher == "true"){
            Title += " Student Enabler"
        }
        // Append a RowSegment to an array
        TheRows.append(RowSegments(Title: Title, Row: [SettingsRow(Title: Title){
            if(Anonymous){
                // Checks if anonymous and sets userDefaults
                Anonymous = false
                print("is NOT anonymous")
                UserDefaults.standard.set(UserDefaults.standard.value(forKey: "TempUsersID"), forKey: "UserID")
                UserDefaults.standard.set(UserDefaults.standard.value(forKey: "TempUsersName"), forKey: "UsersName")
                UserDefaults.standard.set(UserDefaults.standard.value(forKey: "TempIsTeacher"), forKey: "IsTeacher")
                
                UserDefaults.standard.set("false", forKey: "TempIsTeacher")
            }
            else{
                // Otherwise set anonymous to true and set the previous values back
                Anonymous = true
                UserDefaults.standard.set(UserDefaults.standard.value(forKey: "UserID"), forKey: "TempUsersID")
                UserDefaults.standard.set(UserDefaults.standard.value(forKey: "UsersName"), forKey: "TempUsersName")
                UserDefaults.standard.set(UserDefaults.standard.value(forKey: "IsTeacher"), forKey: "TempIsTeacher")
                UserDefaults.standard.set(UserDefaults.standard.value(forKey: "UserID"), forKey: "ActualUserID")
                
                UserDefaults.standard.set("000000000", forKey: "UserID")
                UserDefaults.standard.set("Anonymous", forKey: "UsersName")
                UserDefaults.standard.set(false, forKey: "IsTeacher")
                print("IS anonymous")
            }
        }]))
        
    }
     // Set the table
    private let SettingsTable: UITableView = {
        let Table = UITableView(frame: .zero, style: .grouped)
        Table.register(SettingsTableViewCell.self, forCellReuseIdentifier: "SettingsTableViewCell")
        Table.separatorColor = .orange
        Table.translatesAutoresizingMaskIntoConstraints = false
        return Table
    }()
    

    private func CustomiseTitle(){
        // Set the title
        self.navigationItem.title = "Settings"
        // Customise the Tirle
        let CustomiseUserName: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.orange,
            .font: UIFont.boldSystemFont(ofSize: 25.0)
        ]
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = CustomiseUserName
        navigationController?.navigationBar.scrollEdgeAppearance?.titleTextAttributes = CustomiseUserName
        
        // Customises back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.navigationItem.backBarButtonItem?.image = UIImage(named: "back")
        self.navigationItem.backBarButtonItem?.tintColor = .orange
        
    }

}
