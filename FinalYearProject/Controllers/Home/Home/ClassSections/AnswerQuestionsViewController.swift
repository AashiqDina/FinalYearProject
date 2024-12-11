//
//  AnswerQuestionsViewController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 14/03/2024.
//


import UIKit
import JGProgressHUD
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase

class AnswerQuestionsViewController: UIViewController {
    // Create a refernece to the database
    private let TheDatabase = Database.database().reference()
    private var UniqueID = ""
    // Sets the variables
    private var Question1 = "1"
    private var Answer1 = "1a"
    private var Question2 = "2"
    private var Answer2 = "2a"
    // Set the title, text fields, buttons and spinner
    private let AboutView = AboutSpecificBody(title: "Answer the Questions", FontSize: 30)
    private var BodyField = LoginTextField(fieldType: .Answer)
    private var BodyField2 = LoginTextField(fieldType: .Answer)
    private let SubmitButtom = ConfirmButton(borderRadius: 33, hasBackground: true, fontSize: 30, Title: "Submit")
    private let spinner = JGProgressHUD(style: .dark)
    
    // When the page is loaded the unique id is passed to it
    init(with UniqueID: String){
        super.init(nibName: nil, bundle: nil)
        self.UniqueID = UniqueID
        
    }
    // required when using it
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getQuestions(completion: @escaping (Bool) -> Void){
        // Get the class id using the userdefaults
        guard let ClassID = UserDefaults.standard.value(forKey: "ClassID") as? String else{
            return
        }
        // use the reference and path to get a snapshot
        TheDatabase.child("Classes/\(ClassID)/Questions").observeSingleEvent(of: .value, with: {snapshot in
            // Store the snapshot as a dictionary of strings
            guard var QuestionsContainer = snapshot.value as? [[String: Any]] else{
                // Otherwise return
                return
            }
            
            var i = 0
            // Create a dictionaries of Strings
            var TheQuestions: [String: Any]?
            // Loop until the unique id is equal to the one from init
            for Questions in QuestionsContainer {
                if let TheUniqueID = Questions["UniqueID"] as? String, TheUniqueID == self.UniqueID{
                    TheQuestions = Questions
                    // store in the variable and break if found
                    break
                }
                // increment by one
                i += 1
            }
            // Set two random variables
            let RandomNum = Int.random(in: 0..<3)
            var RandomNum2 = Int.random(in: 0..<3)
            print(RandomNum)
            print(RandomNum2)
            // Make sure the numbers are different
            while(RandomNum == RandomNum2){
                RandomNum2 = Int.random(in: 0..<3)
            }
            // Sets the questions and answers to the variables
            if(RandomNum == 0){
                self.Question1 = TheQuestions?["Question1"] as! String
                self.Answer1 = TheQuestions?["Answer1"] as! String
            }
            else if(RandomNum == 1){
                self.Question1 = TheQuestions?["Question1"] as! String
                self.Answer1 = TheQuestions?["Answer1"] as! String
            }
            else{
                self.Question1 = TheQuestions?["Question3"] as! String
                self.Answer1 = TheQuestions?["Answer3"] as! String
            }
            if(RandomNum2 == 0){
                self.Question2 = TheQuestions?["Question1"] as! String
                self.Answer2 = TheQuestions?["Answer1"] as! String
            }
            else if(RandomNum2 == 1){
                self.Question2 = TheQuestions?["Question2"] as! String
                self.Answer2 = TheQuestions?["Answer2"] as! String
            }
            else{
                self.Question2 = TheQuestions?["Question3"] as! String
                self.Answer2 = TheQuestions?["Answer3"] as! String
            }
            
            print(self.Question1)
            print(self.Answer1)
            print(self.Question2)
            print(self.Answer2)
            // return completion true
            completion(true)
        })
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Calls getQuestions
        self.getQuestions{ success in
            if success {
                // If it returns successful then it sets the UI and the submit button
                self.SetUI()
                self.SubmitButtom.addTarget(self, action: #selector(self.ClickLogin), for: .touchUpInside)
            } else {
                print("An error has occured")
            }
        }
        
    }
    
    // function for if the button is clicked
    @objc private func ClickLogin(){
        // set the text fields to blank
        let Answer1 = BodyField.text ?? ""
        let Answer2 = BodyField2.text ?? ""
        // get the classid from the user defaults
        let ClassID = UserDefaults.standard.value(forKey: "ClassID") as! String
        // show the spinner
        self.spinner.show(in: view)
        
        //        self.CreateNewSection(with: AboutTitle, Body: AboutBody, Title2: AboutTitle2, Body2: AboutBody2, ClassID: ClassID, completion: { [weak self] success in
        //                        if success{
        //                            print("Success")
        //                    }
        //                        else{
        //                            print("Failed")
        //                        }
        //                    })
        
        // Dismisses the spinner in the main thread
        DispatchQueue.main.async {
            self.spinner.dismiss()
        }
        // Calls verifyanswers with the answers from the text fields
        VerifyAnswers(UserAnswer1: Answer1, UserAnswer2: Answer2)
        // returns two pages back
        navigationController?.popViewController(animated: true)
        navigationController?.popViewController(animated: true)
    }
    
    public func VerifyAnswers(UserAnswer1: String, UserAnswer2: String){
        // Gets the userId from the userdefaults
        guard let UserID = UserDefaults.standard.value(forKey: "UserID") as? String else{
            return
        }
        // uses the database reference and path to get a snapshot as an array of dictionaries
        TheDatabase.child("LevelSystem/Users").observeSingleEvent(of: .value, with: {snapshot in
            guard var UsersContainer = snapshot.value as? [[String: Any]] else{
                print("problem")
                return
            }
            print("got through")
            // Sets a variable for the loop and a dictionary
            var i = 0
            var TheUsers: [String: Any]?
            
            for User in UsersContainer {
                // loops until the id matches the userid
                if let TheUniqueID = User["UserID"] as? String, TheUniqueID == UserID{
                    // Sets the variables if the userid matches and breaks
                    TheUsers = User
                    print(i)
                    break
                }
                // increments i
                i += 1
            }
            // Get these variables gotten from the variable above
            let UserLevel = Int(TheUsers?["Level"] as! String)
            let UserExp = Int(TheUsers?["Exp"] as! String)
            let UserMaxExp = Int(TheUsers?["MaxXp"] as! String)
            
            // Checks the answers  to the inputted answers by making sure they are lowercased, if this is the case it calls levelup
            if(UserAnswer1.lowercased() == self.Answer1.lowercased() && UserAnswer2.lowercased() == self.Answer2.lowercased()){
                self.LevelUp(CurrentLevel: UserLevel!, CurrentXp: UserExp!, MaxXp: UserMaxExp!, GainedXp: 50, UserID: UserID)
                print("Both Correct")
            }
            // the same thing occurs but less xp is gained if only one question is correct
            else if(UserAnswer1.lowercased() == self.Answer1.lowercased() || UserAnswer2.lowercased() == self.Answer2.lowercased()){
                self.LevelUp(CurrentLevel: UserLevel!, CurrentXp: UserExp!, MaxXp: UserMaxExp!, GainedXp: 20, UserID: UserID)
                print("One Correct")
            }
            else{
                print("Didnt answer correctly")
            }
            
        })
    }
    
    public func LevelUp(CurrentLevel: Int, CurrentXp: Int, MaxXp: Int, GainedXp: Int, UserID: String){
        // declares the variables as seen
        let NewXpValue = CurrentXp + GainedXp
        var NewLevel = CurrentLevel
        var NewCurrentXp = CurrentXp
        var NewMaxXp = MaxXp
        // if the new xp value is more than max xp then the level is increased
        if(NewXpValue >= MaxXp){
            NewLevel += 1
            NewCurrentXp = NewXpValue - MaxXp
            NewMaxXp += (100 * NewLevel)
        }
        else{
            NewCurrentXp = NewXpValue
        }
        // gets a snapshot using the database reference and the path as an array of dictionaries
        TheDatabase.child("LevelSystem/Users").observeSingleEvent(of: .value, with: {snapshot in
            guard var UsersContainer = snapshot.value as? [[String: Any]] else{
                return
            }
            // sets the variables
            var i = 0
            var TheUsers: [String: Any]?
            // loops until the uniqueid is equal to the user id
            for User in UsersContainer {
                if let TheUniqueID = User["UserID"] as? String, TheUniqueID == UserID{
                    TheUsers = User
                    break
                }
                i += 1
            }
            // sets the new variables
            TheUsers?["Level"] = String(NewLevel)
            TheUsers?["Exp"] = String(NewCurrentXp)
            TheUsers?["MaxXp"] = String(NewMaxXp)
            guard let ToUpdateChat = TheUsers else{
                return
            }
            // set the new variable to teh variable
            UsersContainer[i] = ToUpdateChat
            // set the value in the database
            self.TheDatabase.child("LevelSystem/Users").setValue(UsersContainer, withCompletionBlock: { error, _ in guard error == nil else{
                return
            }
                
            })
            
            
        })
        // gets the badges data using the data reference and the path
        TheDatabase.child("Badges/\(UserID)").observeSingleEvent(of: .value, with: {snapshot in
            guard var UsersContainer = snapshot.value as? [String: Any] else{
                return
            }
            // checks the users level and sets the values to true  if the conditions are met
            if(NewLevel >= 1){
                UsersContainer["BadgeOne"] = "true"
            }
            if(NewLevel >= 5){
                UsersContainer["BadgeTwo"] = "true"
            }
            if(NewLevel >= 10){
                UsersContainer["BadgeThree"] = "true"
            }

            // set the values in the database
            self.TheDatabase.child("Badges/\(UserID)").setValue(UsersContainer, withCompletionBlock: { error, _ in guard error == nil else{
                return
            }
                
            })
            
            
        })
        
    }
    
    //sets up the UI when called
    private func SetUI(){
        // set the background
        let AppBackgroundImg = UIImageView(frame: UIScreen.main.bounds)
        AppBackgroundImg.image = UIImage(named: "AppBackground.png")
        self.view.insertSubview(AppBackgroundImg, at: 0)
        // set the questions
        let TitleField = AboutSpecificBody(title: Question1, FontSize: 20)
        let TitleField2 = AboutSpecificBody(title: Question2, FontSize: 20)
        
        // adds the following subviews
        self.view.addSubview(AboutView)
        self.view.addSubview(TitleField)
        self.view.addSubview(BodyField)
        self.view.addSubview(TitleField2)
        self.view.addSubview(BodyField2)
        self.view.addSubview(SubmitButtom)
        AboutView.translatesAutoresizingMaskIntoConstraints = false
        TitleField.translatesAutoresizingMaskIntoConstraints = false
        BodyField.translatesAutoresizingMaskIntoConstraints = false
        TitleField2.translatesAutoresizingMaskIntoConstraints = false
        BodyField2.translatesAutoresizingMaskIntoConstraints = false
        SubmitButtom.translatesAutoresizingMaskIntoConstraints = false
        // positions each element using contraints
        NSLayoutConstraint.activate([
            self.AboutView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            self.AboutView.heightAnchor.constraint(equalToConstant: 100),
            self.AboutView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.AboutView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            TitleField.topAnchor.constraint(equalTo: AboutView.bottomAnchor, constant: 0),
            TitleField.centerXAnchor.constraint(equalTo: AboutView.centerXAnchor),
            TitleField.heightAnchor.constraint(equalToConstant: 55),
            TitleField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            self.BodyField.topAnchor.constraint(equalTo: TitleField.bottomAnchor, constant: 48),
            self.BodyField.heightAnchor.constraint(equalToConstant: 55),
            self.BodyField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            self.BodyField.centerXAnchor.constraint(equalTo: AboutView.centerXAnchor),
            
            TitleField2.topAnchor.constraint(equalTo: BodyField.bottomAnchor, constant: 25),
            TitleField2.centerXAnchor.constraint(equalTo: BodyField.centerXAnchor),
            TitleField2.heightAnchor.constraint(equalToConstant: 55),
            TitleField2.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            self.BodyField2.topAnchor.constraint(equalTo: TitleField2.bottomAnchor, constant: 48),
            self.BodyField2.heightAnchor.constraint(equalToConstant: 55),
            self.BodyField2.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            self.BodyField2.centerXAnchor.constraint(equalTo: TitleField2.centerXAnchor),
            
            self.SubmitButtom.topAnchor.constraint(equalTo: BodyField2.bottomAnchor, constant: 30),
            self.SubmitButtom.heightAnchor.constraint(equalToConstant: 70),
            self.SubmitButtom.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
            self.SubmitButtom.centerXAnchor.constraint(equalTo: AboutView.centerXAnchor),
        ])
    }
    
    
}
