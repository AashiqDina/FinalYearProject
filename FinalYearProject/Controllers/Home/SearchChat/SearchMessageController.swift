//
//  SearchMessageController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 23/01/2024.
//

import UIKit
import Foundation
import JGProgressHUD

// creates a struct for the chats
struct Chats{
    let ChatID: String
    let ResponderName: String
    let ResponderID: String
    let IsTeacher: String
    let NewestMessage: NewestMessage
}
// creates a struct for the newest message
struct NewestMessage{
    let Message: String
    let Date: String
}

class SearchMessageController: UIViewController{
    
    // creates an array of chats
    private var TheChats = [Chats]()
    // creates spinner
    private let spinner = JGProgressHUD(style: .dark)
    // function for the listener in the function
    private func BeginConversationListener(){
        // gets userid from user defaults
        guard let UserID = UserDefaults.standard.value(forKey: "UserID") as? String else{
            return
        }
        // calls getChats from userchatcontroller
        UserChatController(with: UserID, ChatID: nil).GetChats(for: UserID, completion: { [weak self] result in
            switch result{
            case .success(let TheChats):
                print(TheChats)
                //if the chat is empty it prints chat is empty
                guard !TheChats.isEmpty else {
                    print("TheChats is empty")
                    return
                }
                self?.TheChats = TheChats
                DispatchQueue.main.async{
                    // reloads the tables data
                    self?.MessagesTable.reloadData()
                }
            case .failure(let error):
                print("Failed: \(error)")
            }
        })
    }
    // creates the table for the current messages, who the user is currently messaging
    private let MessagesTable: UITableView = {
        let Table = UITableView()
        Table.register(ChatTableCellView.self, forCellReuseIdentifier: "ChatTableCellView")
        Table.separatorColor = .orange
        Table.translatesAutoresizingMaskIntoConstraints = false
        return Table
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // displays spinner
        self.spinner.show(in: view)
        // sets background
        let AppBackgroundImg = UIImageView(frame: UIScreen.main.bounds)
        AppBackgroundImg.image = UIImage(named: "AppBackground.png")
        self.view.insertSubview(AppBackgroundImg, at: 0)
        // sets page title
        self.navigationItem.title = "Messages"
        // adds subview
        self.view.addSubview(MessagesTable)
        MessagesTable.delegate = self
        MessagesTable.dataSource = self
        self.getChat()
        // sets the table background colour
        self.MessagesTable.backgroundColor = UIColor.clear
        // calls the necessary functions
        self.CreateButtons()
        self.BeginConversationListener()
        // stops the spinner
        DispatchQueue.main.async {
            self.spinner.dismiss()
        }
        
        let MoveDownBy: CGFloat = 10
        MessagesTable.contentInset.top = MoveDownBy
    }
    
    
    
    // creates the buttons for search and back
    private func CreateButtons(){
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.image = UIImage(named: "back")
        self.navigationItem.backBarButtonItem?.tintColor = .orange
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(GetNewChat))
        self.navigationItem.leftBarButtonItem?.image = UIImage(named: "Search")
        self.navigationItem.leftBarButtonItem?.tintColor = .orange
    }
    // brings to newchat page
    @objc private func GetNewChat(){
        let ViewController = NewChatController()
        ViewController.Completion = { [weak self] result in
            print("\(result)")
            self?.CreateChat(result: result)
        }
        
        let NavigateTo = UINavigationController(rootViewController: ViewController)
        present(NavigateTo, animated:  true)
    }
    
    private func CreateChat(result: [String: String]) {
        // sets variables
        guard let UsersName = result["UsersName"],
              let IsTeaching = result["IsTeaching"],
              let UserID = result["UserID"]
        else{
            return
        }
        // sets user defaults for person having conversation with
        UserDefaults.standard.set(UsersName, forKey: "ResponerName")
        print("This is ", UserID)
        UserDefaults.standard.set(UserID, forKey: "ResponderUserID")
        UserDefaults.standard.set(IsTeaching, forKey: "ResponderIsTeacher")

        // changes page to userchatcontroller
        let ViewController = UserChatController(with: UserID, ChatID: nil)
        ViewController.NewChat = true
        navigationController?.pushViewController(ViewController, animated: true)
    }
    
    private func CustomiseTitle(){
        // sets the title
        self.navigationItem.title = "Messages"
        // Customises the title
        let CustomiseUserName: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.orange,
            .font: UIFont.boldSystemFont(ofSize: 25.0)
        ]
        // customises the title
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = CustomiseUserName
        navigationController?.navigationBar.scrollEdgeAppearance?.titleTextAttributes = CustomiseUserName
        navigationItem.setHidesBackButton(true, animated: true)
        
        
    }
    // Create a UILabel
    private let NoMessages: UILabel = {
        let NoMessagesText = UILabel()
        NoMessagesText.text = "Search to start messaging..."
        // Customises the UILabel
        NoMessagesText.font = .systemFont(ofSize: 19, weight: .bold)
        NoMessagesText.textAlignment = .center
        NoMessagesText.textColor = .orange
        return NoMessagesText
    }()
    
    private func getChat(){
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Calls CustomiseTitle
        self.CustomiseTitle()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Sets the MessageTable's frame to the view's bounds
        MessagesTable.frame = view.bounds
    }
}

extension SearchMessageController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // sets the number of sections
        return TheChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // each row will get the values of theClasses array and sets the variable to it
        let CurrentModel = TheChats[indexPath.row]
        let TableRow = tableView.dequeueReusableCell(withIdentifier: "ChatTableCellView", for: indexPath) as! ChatTableCellView
        
        // calls the build function to set the variables
        TableRow.Build(with: CurrentModel)
        // set the customisation aspects of the text
        TableRow.textLabel?.textColor = .orange
        TableRow.textLabel?.font = .systemFont(ofSize: 21, weight: .bold)
        //        TableRow.backgroundColor = UIColor(red: 36/255, green: 35/255, blue: 37/255, alpha: 1)
        let HighlightColour = UIView()
        // sets the customisatioon aspects of the rows
        HighlightColour.backgroundColor = UIColor.orange
        TableRow.selectedBackgroundView = HighlightColour
        TableRow.backgroundColor = UIColor.clear
        TableRow.textLabel?.highlightedTextColor = UIColor.white
        // returns the row
        return TableRow
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // deselect it so its no longer highlighted
        tableView.deselectRow(at: indexPath, animated: true)
        let CurrentModel = TheChats[indexPath.row]
        let ViewController = UserChatController(with: CurrentModel.ResponderID, ChatID: CurrentModel.ChatID)
        // sets the user defaults
        UserDefaults.standard.set(CurrentModel.ResponderName, forKey: "ResponerName")
        UserDefaults.standard.set(CurrentModel.IsTeacher, forKey: "ResponderIsTeacher")
        // pushes to another page
        navigationController?.pushViewController(ViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // sets the size of each row
        70
    }
}
