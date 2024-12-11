//
//  UserChatController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 29/01/2024.
//

import UIKit
import InputBarAccessoryView
import MessageKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import RealmSwift

// Create Stucts
struct Message: MessageType{
    var messageId: String
    public var sender: SenderType
    public var sentDate: Date
    public var kind: MessageKind
}

struct MessageSender: SenderType{
    public var senderId: String
    public var displayName: String
}

struct AnError: Error {
    let message: String
}

extension MessageKind{
    var Description: String{
        switch self{
            
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "vider"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}




class UserChatController: MessagesViewController {
    
    // Create a database reference
    private let TheDatabase = Database.database().reference()
    // Set some variables
    public var NewChat = false
    public var ResponderUserID: String = ""
    public var TheChatID: String?
    // Create a DateFormatter
    public static var DateToString: DateFormatter = {
        let ToString = DateFormatter()
        ToString.dateStyle = .medium
        ToString.timeStyle = .long
        ToString.timeZone = .current
        return ToString
    }()
    // Create an Array of messages
    private var ViewableMessages = [Message]()
    // Get the Urrent User and set it as a Message Sender Variable
    private var CurrentSender: MessageSender?{
        guard let UserID = UserDefaults.standard.value(forKey: "UserID") as? String
        else{
            return nil
        }
        return MessageSender(
            senderId: UserID,
            displayName: "Me"
        )
    }
    
    private func MessagesListener(ChatID: String){
        // Calls getMessages
        self.GetMessages(with:ChatID , completion: { [weak self] result in
            switch result{
            case .success(let Messages):
                guard !Messages.isEmpty else{
                    // If its empty it should print nothing
                    print(Messages)
                    return
                }
                print("Here")
                // Set the local variable to the returned value
                self?.ViewableMessages = Messages
                
                DispatchQueue.main.async{
                    // In the main thread the data will be reloaded
                    let CurrentContentOffset = self?.messagesCollectionView.contentOffset
                    self?.messagesCollectionView.reloadData()
                    // update the subviews
                    self?.messagesCollectionView.layoutIfNeeded()
                    // Scrolls to the bottom of the page
                    self?.messagesCollectionView.setContentOffset(CurrentContentOffset!, animated: false)
                }
                
                
            case .failure(let error):
                // If completion failure print the error
                print(error)
            }
        })
    }
    
    //       var TheCurrentSender = MessageSender(senderId: "1", displayName: "Aashiq Dina")
    //        var CurrentSender2 = MessageSender(senderId: "2", displayName: "Other Guy")
    // it is called with the UserID and the ChatID
    init(with UserID: String, ChatID: String?){
        super.init(nibName: nil, bundle: nil)
        self.ResponderUserID = UserID
        self.TheChatID = ChatID
    }
    
    // This is required if init is not set
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set the input bar and hte collectionView
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
//        self.customConfigureMessageCollectionView()
        // sets the background
        let AppBackgroundImg = UIImage(named: "AppBackground.png")
        let NewAppBackgroundImg = UIImageView(image: AppBackgroundImg)
        NewAppBackgroundImg.contentMode = .scaleAspectFill
        messagesCollectionView.backgroundView = NewAppBackgroundImg
        
        messageInputBar.delegate = self
        // Calls the messageListener
        self.MessagesListener(ChatID: self.TheChatID ?? "NoChatID")
        
        //
        //        ViewableMessages.append(Message(messageId: "1", sender: CurrentSender!, sentDate: Date(), kind: .text("Seems like it works, writing some longer text now to see if that works properly... Seems like it works, thats good")))
        //        ViewableMessages.append(Message(messageId: "2", sender: CurrentSender2, sentDate: Date(), kind: .text("Testing double Message now")))
        //        ViewableMessages.append(Message(messageId: "3", sender: CurrentSender!, sentDate: Date(), kind: .text("Looks Natural?")))
        //        ViewableMessages.append(Message(messageId: "4", sender: CurrentSender2, sentDate: Date(), kind: .text("IDK")))
        //        ViewableMessages.append(Message(messageId: "5", sender: CurrentSender!, sentDate: Date(), kind: .text("Lets see")))
        //        ViewableMessages.append(Message(messageId: "6", sender: CurrentSender2, sentDate: Date(), kind: .text("Seems like it works, writing some longer text now to see if that works properly with the second sender... Seems like it works, thats good")))
        // Sets the colour to a variable
        let BackgroundColor = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        BackgroundColor?.collectionView?.backgroundColor = UIColor(red: 36/255, green: 35/255, blue: 37/255, alpha: 1)
        // calls customisePage
        self.CustomisePage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func CustomisePage(){
        // Customises parts of the page such as the input bbar
        messageInputBar.inputTextView.backgroundColor = .white
        messageInputBar.inputTextView.layer.cornerRadius = 20
        messageInputBar.bottomStackView.backgroundColor = UIColor(red: 34/255, green: 47/255, blue: 57/255, alpha: 1)
        messageInputBar.backgroundView.backgroundColor = UIColor(red: 34/255, green: 47/255, blue: 57/255, alpha: 1)
        messageInputBar.separatorLine.backgroundColor = UIColor(red: 34/255, green: 47/255, blue: 57/255, alpha: 1)
        messageInputBar.sendButton.setTitleColor(UIColor.orange, for: .normal)
        // if the person being message is a teacher educator is concatenated to their names
        let IsResponderTeacher = UserDefaults.standard.value(forKey: "ResponderIsTeacher") as? String ?? "false"
        
        if(IsResponderTeacher == "true"){
            // set the title
            navigationItem.title = UserDefaults.standard.value(forKey: "ResponerName") as! String + " (Educator)"
            // decreases the size of the title of the name is too long and customises it
            if(navigationItem.title!.count >=  15){
                let CustomiseUserName: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.orange,
                    .font: UIFont.boldSystemFont(ofSize: 20.0)
                ]
                navigationController?.navigationBar.standardAppearance.titleTextAttributes = CustomiseUserName
                navigationController?.navigationBar.scrollEdgeAppearance?.titleTextAttributes = CustomiseUserName
                
            }
        }
        else{
            // set the title
            navigationItem.title = UserDefaults.standard.value(forKey: "ResponerName") as? String
            // decreases the size of the title of the name is too long
            if(navigationItem.title!.count >=  15){
                let CustomiseUserName: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.orange,
                    .font: UIFont.boldSystemFont(ofSize: 20.0)
                ]
                navigationController?.navigationBar.standardAppearance.titleTextAttributes = CustomiseUserName
                navigationController?.navigationBar.scrollEdgeAppearance?.titleTextAttributes = CustomiseUserName
            }
        }
        
        // remove the default pfp view messagekit provides
        if let RemovePFP = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            RemovePFP.textMessageSizeCalculator.outgoingAvatarSize = .zero
            RemovePFP.textMessageSizeCalculator.incomingAvatarSize = .zero
        }
    }
}

extension UserChatController: MessagesLayoutDelegate, MessagesDataSource, MessagesDisplayDelegate{
    func currentSender() -> SenderType {
        // Ensures the sender is the current user
        if let TheSender = CurrentSender{
            return TheSender
        }
        return MessageSender(senderId: "0", displayName: "")
    }
    // returns the message for that part of the array
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return ViewableMessages[indexPath.section]
    }
    // sets the number of sections
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return ViewableMessages.count
    }
    // sets the background colour for each user's texts
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        //checks which user
        if message.sender.senderId == self.currentSender().senderId {
            // returns the colour
            return UIColor(red: 245/255, green: 245/255, blue: 255/255, alpha: 0.1)
        } else {
            // returns the colour
            return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.07)
        }
    }
    
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        // Dequeue the custom cell for the first message
//        if indexPath.item ==  0 {
//            let cell = collectionView.dequeueReusableCell(FirstMessageCell.self, for: indexPath)
//            return cell
//        }
//
//        // Dequeue and configure other cells as usual
//        // ...
//
//        return cell
//    }
    
    // sets the text colour for each user
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        // checks the current user
        if message.sender.senderId == self.currentSender().senderId {
            // returns the colour
            return UIColor(red: 255/255, green: 123/255, blue: 0/255, alpha: 0.95)
        } else {
            // returns the colour
            return UIColor(red: 255/255, green: 123/255, blue: 0/255, alpha: 0.95)
        }
    }
    
}




extension UserChatController: InputBarAccessoryViewDelegate{
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        // if the text is empty and send is pressed do nothing and return
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let MessageSender = self.CurrentSender else{
                  print("does nothing")
                  return
              }
        // set the variables
        let MessageID = self.RandomMessageID()
        let TheMessage = Message(messageId: MessageID ?? "NoIdCouldBeGenerated", sender: MessageSender, sentDate: Date(), kind: .text(text))
        // if its a new chat
        if NewChat{
            // Call createNewChat
            CreateNewChat(with: UserDefaults.standard.value(forKey: "ResponderUserID") as! String ?? "000000000", ResponderName: UserDefaults.standard.value(forKey: "ResponerName") as? String ?? "Anonymous", IsTeacher: UserDefaults.standard.value(forKey: "ResponderIsTeacher") as? String ?? "false", Message: TheMessage, completion: { [weak self] success in if success{
                print(success)
                self?.NewChat =  false
            }
                else{
                    print("Failed")
                }
            })
            
        }
        else{
            // Get the ChatID
            guard let ChatID = TheChatID else{
                return
            }
            // Call SendMessage
            SendMessage(to: ChatID, Message: TheMessage, ResponderName: UserDefaults.standard.value(forKey: "ResponerName") as? String ?? "Anonymous", completion: {
                success in if success{
                    // if completion success print the following
                    print("message successfully sent")
                }
                else{
                    // if completion false print the following
                    print("message failed sent")
                }
            })
        }
        
    }
    
    // Function to create a randomID
    func RandomMessageID() -> String?{
        // Get the user's ID
        guard let SenderUserID = UserDefaults.standard.value(forKey: "UserID")
        else{
            return nil
        }
        // Get the data as a string
        let TheDate = UserChatController.DateToString.string(from: Date())
        // return uniqueID
        return "\(TheDate)_\(SenderUserID)_\(ResponderUserID)"
    }
    
    public func CreateNewSection(with Title: String, Body: String, ResponderID: String, completion: @escaping (Bool) -> Void){
        // Set a variable using the database reference and the path
        let UserIDPath = TheDatabase.child("Notifications").child("\(ResponderID)")
        print(UserIDPath)
        // Get a snapshot usign the above
        UserIDPath.observeSingleEvent(of: .value, with: { snapshot in
            // store it as a dictionary
            guard var UsersNode = snapshot.value as? [String: Any] else{
                // Otherwise completion false and print
                completion(false)
                print("An error has occured")
                return
            }
            // Create a dictionary variabel with the variables
            let CreateAboutSection: [String: Any] = [
                "SectionTitle": Title,
                "SectionBody": Body
            ]
            // checks if the child exists and if it does appends the above dictionary then sets the value in the database
            if var Chats = UsersNode["Notif"] as? [[String: Any]] {
                Chats.append(CreateAboutSection)
                UsersNode["Notif"] = Chats
                UserIDPath.setValue(UsersNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else{
                        // returns the completion false
                        completion(false)
                        return
                    }
                })
            }
            else{
                // create a dictionary of the dictionary above
                UsersNode["Notif"] = [
                    CreateAboutSection
                ]
                //sets the value in the database
                UserIDPath.setValue(UsersNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                })
            }
        })
    }
}





extension UserChatController{
    
    public func CreateNewChat(with RespoderUserId: String, ResponderName: String, IsTeacher: String, Message: Message, completion: @escaping (Bool) -> Void){
        // store the UserID gotten from the userdefault
        guard let CurrentUserID = UserDefaults.standard.value(forKey: "UserID") as? String else{
            return
        }
        // Use the database reference and the path then store it in a variable
        let UserIDPath = TheDatabase.child("Messages").child("\(CurrentUserID)")
        print(UserIDPath)
        // Get a snapshot using the variable above
        UserIDPath.observeSingleEvent(of: .value, with: { snapshot in
            // store this in a variable
            guard var UsersNode = snapshot.value as? [String: Any] else{
                completion(false)
                print("An error has occured")
                return
            }
            // Get the date as a string
            let MessageDateToString = UserChatController.DateToString.string(from: Message.sentDate)
            
            var TheMessage = ""
            // exhausts the message's kind
            switch Message.kind {
                
            case .text(let text):
                TheMessage = text
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            // Get the ChatID
            let ChatID = "\(Message.messageId)"
            // Create a variable as a dictionary
            let CreateChats: [String: Any] = [
                "ChatID": ChatID,
                "ResponderID": RespoderUserId,
                "ResponderName": ResponderName,
                "IsTeacher" : IsTeacher,
                "Latest_Message": [
                    "Date": MessageDateToString,
                    "Message": TheMessage
                ]
            ]
            // Get if the user is a teacher
            let UserIsTeacher = UserDefaults.standard.value(forKey: "IsTeacher") as! String
            var UserIsTeacherToUpload = "false"
            if (UserIsTeacher == "true"){
                print("Is Teacher")
                // sets the value to true
                UserIsTeacherToUpload = "true"
            }
            else{
                // sets the variable to false
                UserIsTeacherToUpload = "false"
            }
            // Create a variable as a dictionary
            let ResponderCreateChats: [String: Any] = [
                "ChatID": ChatID,
                "ResponderID": UserDefaults.standard.value(forKey: "UserID")!,
                "ResponderName": UserDefaults.standard.value(forKey: "UsersName")!,
                "IsTeacher" : UserIsTeacherToUpload,
                "Latest_Message": [
                    "Date": MessageDateToString,
                    "Message": TheMessage
                ]
            ]
            // Get the snapshot using the database reference and the path
            self.TheDatabase.child("Messages").child("\(RespoderUserId)").observeSingleEvent(of: .value, with: { snapshot in
                print("This")
                print(snapshot.value)
                print("This End")
                // If it was successful append the above declared variable
                if var Chats = snapshot.value as? [[String: Any]]{
                    Chats.append(ResponderCreateChats)
                    self.TheDatabase.child("Messages").child("\(RespoderUserId)").child("Chats").setValue([Chats])
                }
                else{
                    // set the dictionary
                    self.TheDatabase.child("Messages").child("\(RespoderUserId)").child("Chats").setValue([ResponderCreateChats])
                }
            })
            // if the variable is successfully stored then
            if var Chats = UsersNode["Chats"] as? [[String: Any]] {
                // append the above
                Chats.append(CreateChats)
                // set the new array
                UsersNode["Chats"] = Chats
                // set the value in the database
                UserIDPath.setValue(UsersNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    // Call chat created
                    self?.ChatCreated(ChatID: ChatID, ResponderName: ResponderName, Message: Message, completion: completion)
                })
            }
            else{
                // Create an array with CreateChats
                UsersNode["Chats"] = [
                    CreateChats
                ]
                // Set the value in the database
                UserIDPath.setValue(UsersNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    // Call ChatCreated
                    self?.ChatCreated(ChatID: ChatID, ResponderName: ResponderName, Message: Message, completion: completion)
                })
            }
        })
    }
    
    public func GetChats(for UserID: String, completion: @escaping (Result<[Chats], Error>) -> Void){
        // Get snapshot using the database reference and the path
        TheDatabase.child("Messages/\(UserID)/Chats").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                print("Here: Failed")
                completion(.failure(AnError(message: "Failed to fetch")))
                return
            }
            // Create an array of chats
            let AChat: [Chats] = value.compactMap({
                dictionary in
                // Set variables
                guard let ChatID = dictionary["ChatID"] as? String,
                      let ResponderID = dictionary["ResponderID"] as? String,
                      let ResponderName = dictionary["ResponderName"] as? String,
                      let IsTeacher = dictionary["IsTeacher"] as? String,
                      let LatestMessage = dictionary["Latest_Message"] as? [String: Any],
                      let Message = LatestMessage["Message"] as? String,
                      let Date = LatestMessage["Date"] as? String else {
                          return nil
                      }
                // Set variables
                let TheNewestMessage = NewestMessage(Message: Message, Date: Date)
                // and return as a Chat using the varibales set above
                return Chats(ChatID: ChatID, ResponderName: ResponderName, ResponderID: ResponderID, IsTeacher: IsTeacher, NewestMessage: TheNewestMessage)
            })
            
            completion(.success(AChat))
        })
    }
    
    public func GetMessages(with ID: String, completion: @escaping (Result<[Message], Error>) -> Void){
        // Get a snapshot using a database reference and the path
        TheDatabase.child("\(ID)/Messages").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                print("Here: Failed")
                completion(.failure(AnError(message: "Failed to fetch")))
                return
            }
            // Create a variable as a compact map with the variables set withing
            let TheMessages: [Message] = value.compactMap({
                dictionary in
                // set the variables
                guard let RespondersName = dictionary["ResponderName"] as? String,
                      let MessageID = dictionary["MessageID"] as? String,
                      let ActualMessage = dictionary["ActualMessage"] as? String,
                      let SenderID = dictionary["Sender"] as? String,
                      let Date = dictionary["Date"] as? String,
                      let Type = dictionary["Type"] as? String,
                      let TheDate = UserChatController.DateToString.date(from: Date)
                else{

                    return nil
                }
                // Create a sender with the variabls above
                let TheSender = Sender(senderId: SenderID, displayName: RespondersName)
                // Returns the message variable with the other variables
                return Message(messageId: MessageID, sender: TheSender, sentDate: TheDate, kind: .text(ActualMessage))

            })
            // on completion success return TheMessages
            completion(.success(TheMessages))
        })
    }
    
    public func SendMessage(to Chat: String, Message: Message, ResponderName: String, completion: @escaping (Bool) -> Void){
        // Get a snapshot using the database reference and the path
        self.TheDatabase.child("\(Chat)/Messages").observeSingleEvent(of: .value, with: {
            [weak self] snapshot in guard let Strong = self else{
                return
            }
            // get is as an array of dictionarie
            guard var TheCurrentMessage = snapshot.value as? [[String: Any]] else{
                completion(false)
                return
            }
            // Get the userid from the userdefaults
            guard let UserID = UserDefaults.standard.value(forKey: "UserID") as? String
            else{
                return
            }
            // sets the message variable
            var TheMessage = ""
            // set the current date to a variable as a String
                        let MessageDateToString = UserChatController.DateToString.string(from: Message.sentDate)
                        switch Message.kind {
                            
                        case .text(let text):
                            TheMessage = text
                        case .attributedText(_):
                            break
                        case .photo(_):
                            break
                        case .video(_):
                            break
                        case .location(_):
                            break
                        case .emoji(_):
                            break
                        case .audio(_):
                            break
                        case .contact(_):
                            break
                        case .linkPreview(_):
                            break
                        case .custom(_):
                            break
                        }
                        // Create a dictionary and set it to a variable
                        let ToMessage: [String: Any] = [
                            "MessageID": Message.messageId,
                            "ResponderName": ResponderName,
                            "Type": Message.kind.Description,
                            "IsTeacher": UserDefaults.standard.value(forKey: "ResponderIsTeacher") ?? "Anonymous",
                            "ActualMessage": TheMessage,
                            "Date": MessageDateToString,
                            "Sender": UserDefaults.standard.value(forKey: "UserID") ?? "Anonymous"
                        ]
                        // Append it to the array
                        TheCurrentMessage.append(ToMessage)
            // Set the value in the database
                        Strong.self.TheDatabase.child("\(Chat)/Messages").setValue(TheCurrentMessage) {error,  _ in guard error == nil else{
                            completion(false)
                            return
                        }
                            // set the value in the database
                            Strong.TheDatabase.child("Messages/\(UserID)/Chats").observeSingleEvent(of: .value, with: {snapshot in
                                guard var CurrentUsersChat = snapshot.value as? [[String: Any]] else{
                                    completion(false)
                                    return
                                }
                                // Create some variables
                                var i = 0
            
                                let NewValue: [String: Any] = ["Date": MessageDateToString, "Message": TheMessage]
            
                                var TheChat: [String: Any]?
                                // Find the correct chat with the correct id
                                for Chats in CurrentUsersChat {
                                    if let ChatID = Chats["ChatID"] as? String, ChatID == Chat{
                                        // set it to the variable and break
                                        TheChat = Chats
                                        break
                                    }
                                    // increment i
                                    i += 1
                                }
                                // set the new value ot the gotten value
                                TheChat?["Latest_Message"] = NewValue
                                guard let ToUpdateChat = TheChat else{
                                    completion(false)
                                    return
                                }
                                // set the value in the database
                                CurrentUsersChat[i] = ToUpdateChat
                                Strong.TheDatabase.child("Messages/\(UserID)/Chats").setValue(CurrentUsersChat, withCompletionBlock: { error, _ in guard error == nil else{
                                    completion(false)
                                    return
                                }
            
                                })
                                print("done1")
                            })
                            
                            
                            guard let TheResponerUserID = self?.ResponderUserID
                            else{
                                return
                            }
                            // User the responderID to get a snapshot
                            print(TheResponerUserID)
                            Strong.TheDatabase.child("Messages/\(TheResponerUserID)/Chats").observeSingleEvent(of: .value, with: {snapshot in
                                guard var CurrentUsersChat = snapshot.value as? [[String: Any]] else{
                                    completion(false)
                                    return
                                }
                                // create the neccessary variables
                                var i = 0
            
                                let NewValue: [String: Any] = ["Date": MessageDateToString, "Message": TheMessage]
            
                                var TheChat: [String: Any]?
                                // Loop until the correct chat is found
                                for Chats in CurrentUsersChat {
                                    if let ChatID = Chats["ChatID"] as? String, ChatID == Chat{
                                        // set it to the varaible
                                        TheChat = Chats
                                        break
                                    }
                                    // increment by one
                                    i += 1
                                }
                                // update the value
                                TheChat?["Latest_Message"] = NewValue
                                guard let ToUpdateChat = TheChat else{
                                    completion(false)
                                    return
                                }
                                // set the value in the database
                                CurrentUsersChat[i] = ToUpdateChat
                                Strong.TheDatabase.child("Messages/\(TheResponerUserID)/Chats").setValue(CurrentUsersChat, withCompletionBlock: { error, _ in guard error == nil else{
                                    completion(false)
                                    return
                                }
            
                                })
                            })
                            // Get the current User's name
                            let CurrentUser = UserDefaults.standard.value(forKey: "UsersName")! as? String
                            // Call CreateNewSection
                            self?.CreateNewSection(with: CurrentUser! + " has message you!", Body: TheMessage, ResponderID: TheResponerUserID, completion: { [weak self] success in
                                            if success{
                                                // If it was completion success print success
                                                print("Success")
                                        }
                                            else{
                                                // if it was completion failure print failure
                                                print("Failed")
                                            }
                                        })
                            completion(true)
                        }
                    })
                }

    
    private func ChatCreated(ChatID: String, ResponderName: String, Message: Message, completion: @escaping (Bool) -> Void){
        // Sets the variables
        var TheMessage = ""
        // Gets the current date as a String
        let MessageDateToString = UserChatController.DateToString.string(from: Message.sentDate)
        // exhauts the types
        switch Message.kind {
            
        case .text(let text):
            TheMessage = text
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        // Create a dictionary with the above variables
        let Message: [String: Any] = [
            "MessageID": Message.messageId,
            "ResponderName": ResponderName,
            "Type": Message.kind.Description,
            "IsTeacher": UserDefaults.standard.value(forKey: "ResponderIsTeacher") ?? "Anonymous",
            "ActualMessage": TheMessage,
            "Date": MessageDateToString,
            "Sender": UserDefaults.standard.value(forKey: "UserID") ?? "Anonymous"
        ]
        // Create a dictionary which contains an array of Messages
        let NewValue: [String: Any] = [
            "Messages": [
                Message]]
        // set the value in the database
        TheDatabase.child("\(ChatID)").setValue(NewValue, withCompletionBlock: {error, _ in
            guard error == nil else{
                completion(false)
                return
            }
            completion(true)
        })
    }
}
