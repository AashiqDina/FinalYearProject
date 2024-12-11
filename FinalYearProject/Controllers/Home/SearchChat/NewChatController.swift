//
//  NewChatController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 31/01/2024.
//

import UIKit
import JGProgressHUD
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import CoreData

class NewChatController: UIViewController {
    // set a database reference
    private let TheDatabase = Database.database().reference()
    // set a dark styled loading menu
    private let Loading = JGProgressHUD(style: .dark)
    private var CheckNewArray = false
    // Create array of dictionaries
    private var UsersArrayToCheck = [[String: String]]()
    private var FetchedResults = [[String: String]]()
    public var Completion: (([String: String]) -> (Void))?
    // Set the tableView
    private let tableView: UITableView = {
        let Table = UITableView()
        Table.register(UITableViewCell.self, forCellReuseIdentifier: "TableRow")
        // Customises the table view
        Table.backgroundColor = UIColor.clear
        Table.separatorColor = .orange
        Table.isHidden = true
        return Table
    }()
    // Create a UILabel
    private let NoResults: UILabel = {
        let Text = UILabel()
        Text.text = "No Results Found..."
        // customise the text
        Text.textAlignment = .center
        Text.textColor = .orange
        Text.font = .systemFont(ofSize: 21)
        Text.isHidden = true
        return Text
    }()
    // Create a UISearchBar
    private let ToSearch: UISearchBar = {
        let ToSearch = UISearchBar()
        ToSearch.placeholder = "Type to Search for Users..."
        // Customise the search bar
        ToSearch.tintColor = .orange
        let ToChangeTextColour = ToSearch.value(forKey: "searchField") as? UITextField
        ToChangeTextColour?.textColor = .orange
        return ToSearch
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Sets the background
        let AppBackgroundImg = UIImageView(frame: UIScreen.main.bounds)
        AppBackgroundImg.image = UIImage(named: "AppBackground.png")
        self.view.insertSubview(AppBackgroundImg, at: 0)
        // Adds right bar button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(ToDismiss))
        navigationItem.rightBarButtonItem?.tintColor = .orange
        ToSearch.delegate = self
        navigationController?.navigationBar.topItem?.titleView = ToSearch
        // Adds subviews
        view.addSubview(NoResults)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        // gets ready for keyboard input
        ToSearch.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // sets the frame of the table to the view's bounds
        tableView.frame = view.bounds

    }
    // creates a function to dismiss the view controller
    @objc private func ToDismiss(){
        dismiss(animated: true, completion: nil)
    }
    
    public func GetArrayOfUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void){
        // gets array of user dictionaries with the database reference and the path
        TheDatabase.child("users").observeSingleEvent(of: .value, with: {
            snapshot in guard let result = snapshot.value as? [[String: String]]
            else{
                // if completion failure return the error
                completion(.failure(ErrorWithDatabase.UnexpectedFetchingError))
                return
            }
            // return the result with completion success
            completion(.success(result))
        })
    }
    // Creates custom error
    public enum ErrorWithDatabase: Error{
        case UnexpectedFetchingError
    }
    
}

extension NewChatController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // set the data
        guard let inputText = searchBar.text
        else {
            return
        }
        // remove any previous fetched data
        FetchedResults.removeAll()
        // display the loading view
        Loading.show(in: view)
        // Call SearchForUsers with the variable inputText
        self.SearchForUsers(Search: inputText)
    }
    
    func filter(ToGet: String){
        guard CheckNewArray else{
            return
        }
        // Disables the loading view
        self.Loading.dismiss()
        // Creates an array of dictionaries and set the to the returned value of the function
        let FinalSearchResults: [[String: String]] = self.UsersArrayToCheck.filter({
            guard let name = $0["UsersName"]?.description.lowercased()
            else {
                return false
            }
            // returns values with the same begining value as the inputs
            return name.hasPrefix(ToGet.lowercased())
        })
        // store the value in a local variable
        self.FetchedResults = FinalSearchResults
        // Call ShowResults
        showResults()
    }
    
    func SearchForUsers(Search: String){
        // If the variable is truw call the function with the paramenter
        if CheckNewArray{
            filter(ToGet: Search)
        }
        else{
            // Calls function
            GetArrayOfUsers(completion: {[weak self] result in switch result{
            case .success(let UsersArray):
                // If succesful set the variables and call the function
                self?.UsersArrayToCheck = UsersArray
                self?.CheckNewArray = true
                self?.filter(ToGet: Search)
            case .failure(_):
                // otherwise print the following
                print("Error retrieving users")
            }})
        }
    }
    
    func showResults(){
        if FetchedResults.isEmpty{
            // if empty show message and hide table
            self.NoResults.isHidden = false
            self.tableView.isHidden = true
        }
        else{
            // if its not make it visible and reload the table's data
            self.NoResults.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}

extension NewChatController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // set the number of sections for the table
        return FetchedResults.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let TableRow = tableView.dequeueReusableCell(withIdentifier: "TableRow", for: indexPath)
        // Set the text of the Table Row
        TableRow.textLabel?.text = FetchedResults[indexPath.row]["UsersName"]
        // Customise the tablerow
        TableRow.textLabel?.textColor = .orange
        TableRow.textLabel?.font = .systemFont(ofSize: 19, weight: .bold)
        let HighlightColour = UIView()
        HighlightColour.backgroundColor = UIColor.orange
        TableRow.selectedBackgroundView = HighlightColour
        TableRow.backgroundColor = UIColor.clear
        TableRow.textLabel?.highlightedTextColor = UIColor.white
        // return the table row
        return TableRow
        
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        // un-highlight the table row
        tableView.deselectRow(at: indexPath, animated: true)
        // dismiss the view
        let UserData = FetchedResults[indexPath.row]
        dismiss(animated: true, completion: { [weak self] in
            self?.Completion?(UserData)
        })
    }
}
