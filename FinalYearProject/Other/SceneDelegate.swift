//
//  SceneDelegate.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 16/01/2024.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import simd

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    // Set necessary variables
    var Window: UIWindow?
    var TheTimer: Timer?
    var TimeUsedFor: TimeInterval = 0
    private let TheDatabase = Database.database().reference()
    private var TheEngagement = 0.0
    var SameDayCheck = false
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // call setWindeo and authenticateUsers
        self.SetWindow(with: scene)
        self.AuthenticateUser()
        
    }
    
    func aTimer(){
        // Create timeer which increases by 1 every second
        self.TimeUsedFor += 1
    }
    
    func UpdateDatabase(completion: @escaping (Result<Bool, Error>) -> Void){
        // set the Timer
        TheTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){TheTimer in
            self.aTimer()
        }
        // Create variable which stores the user default for the amount of times the application was opened
        var TimesAppOpened = UserDefaults.standard.object(forKey: "AmountAppWasOpened")
        // if this value is nil set it to 0
        if(TimesAppOpened == nil){
            UserDefaults.standard.set(0, forKey: "AmountAppWasOpened")
            TimesAppOpened = UserDefaults.standard.object(forKey: "AmountAppWasOpened")
        }
        // increment it by one when the app is opened
        let ToInt = TimesAppOpened as! Int
        UserDefaults.standard.set(ToInt+1, forKey: "AmountAppWasOpened")
        // Get the date from the userDefault
        var LastDate = UserDefaults.standard.object(forKey: "Day")
        // if its nil
        if(LastDate == nil){
            // set it to 0 and set the clickcount to 0
            UserDefaults.standard.set(Date(), forKey: "Day")
            UserDefaults.standard.set(0, forKey: "ClickCount")
            LastDate = UserDefaults.standard.object(forKey: "Day")
        }
        // Create the variables and store the values
        let Day = Date()
        let CurrentDay = Calendar.current
        self.SameDayCheck = CurrentDay.isDate(Day, inSameDayAs: LastDate as! Date)
    
        let Clicks  = UserDefaults.standard.object(forKey: "ClickCount") as! Double
        let Time = self.TimeUsedFor
        let TimeOpened = UserDefaults.standard.object(forKey: "AmountAppWasOpened") as! Double
        // Calculate engagement with the stored variables
        let Engagement = (1.5*(Clicks))+(0.1*(Time)/60)+(0.2*(TimeOpened))
        // normalise the engagement
        let NormalisedEngagement = (Engagement)/(100.0)
        print(NormalisedEngagement)
        // get the date as a String
        
        let TheDate = UserChatController.DateToString.string(from: Date())
        // Get the userID as a UserDefault
        guard let UserID = UserDefaults.standard.object(forKey: "UserID") else{
            return
        }
        // Get the classID as a UserDefault
        guard let ClassID = UserDefaults.standard.object(forKey: "ClassID") else{
            return
        }
        // If its a different day
        if(!self.SameDayCheck){
            
            print("New day")
            // gets the date
            let TheDate = UserChatController.DateToString.string(from: Date())
            // creates a dictionary of the engagement data
            let EngagementInfo: [String: Any] = [
                "Engagement": NormalisedEngagement,
                "Date": TheDate,
            ]
            // gets snapshot using the database reference and the path
            self.TheDatabase.child("EngagementInformation").child("\(UserID as! String)").child("Info").observeSingleEvent(of: .value, with: { snapshot in
                
                if var Info = snapshot.value as? [[String: Any]]{
                    // append this information to the snapshot value
                    Info.append(EngagementInfo)
                    // set the value in the database
                    self.TheDatabase.child("EngagementInformation").child("\(UserID as! String)").child("Info").setValue(Info)
                }
                else{
                    // set teh value straight without appending
                    self.TheDatabase.child("EngagementInformation").child("\(UserID as! String)").child("Info").setValue([EngagementInfo])
                }
            })
            
            var TheEngagement = 0.0
            // get a snapshot using the database reference and teh path
            self.TheDatabase.child("Classes").child("\(ClassID as! String)").child("Statistics").observeSingleEvent(of: .value, with: { snapshot in
                if var Info = snapshot.value as? [String: Any]{
                    print("In")
                    // calculates values and set it in the database
                    let NewCount = Info["Count"] as! Double + 1.0
                    let EngagementSum = (Info["EngagementSum"] as! Double) + NormalisedEngagement
                    let NewEngagement = EngagementSum / NewCount
                    self.TheEngagement = NewEngagement
                    self.TheDatabase.child("Classes").child("\(ClassID as! String)").child("Statistics").child("Count").setValue(NewCount)
                    self.TheDatabase.child("Classes").child("\(ClassID as! String)").child("Statistics").child("EngagementAverage").setValue(NewEngagement)
                    self.TheDatabase.child("Classes").child("\(ClassID as! String)").child("Statistics").child("EngagementSum").setValue(EngagementSum)
                    self.TheDatabase.child("Classes").child("\(ClassID as! String)").child("Statistics").child("Date").setValue(TheDate)
                }
                else{
                    // calculates the values and sets it in the database
                    self.TheDatabase.child("Classes").child("\(ClassID as! String)").child("Statistics").child("Count").setValue(0)
                    self.TheDatabase.child("Classes").child("\(ClassID as! String)").child("Statistics").child("EngagementAverage").setValue(0.0)
                    self.TheDatabase.child("Classes").child("\(ClassID as! String)").child("Statistics").child("EngagementSum").setValue(0.0)
                    self.TheDatabase.child("Classes").child("\(ClassID as! String)").child("Statistics").child("Date").setValue(TheDate)
                }
                // sets the userdefaults back to the default
                UserDefaults.standard.set(0, forKey: "AmountAppWasOpened")
                UserDefaults.standard.set(0, forKey: "ClickCount")
                UserDefaults.standard.set(0.0, forKey: "TimeUsed")
                UserDefaults.standard.set(Date(), forKey: "Day")
                self.TimeUsedFor = 0
                
                completion(.success(true))
            })
            print(self.TheEngagement)
            // sets the userdefaults back to the default
            UserDefaults.standard.set(0, forKey: "AmountAppWasOpened")
            UserDefaults.standard.set(0, forKey: "ClickCount")
            UserDefaults.standard.set(0.0, forKey: "TimeUsed")
            UserDefaults.standard.set(Date(), forKey: "Day")
            self.TimeUsedFor = 0
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // calls updateDatabase
        self.UpdateDatabase(completion: { [weak self] result in
            switch result{
            case .success(let Value):
                print(Value)
                // if it was a success call UpdateClass
                self?.UpdateClass()
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func UpdateClass(){
        // Get the date as a String
        let TheDate = UserChatController.DateToString.string(from: Date())
        // Get the classID as a userdefault
        guard let ClassID = UserDefaults.standard.object(forKey: "ClassID") else{
            return
        }
        // create a dictionary with the engagement info
        let ClassEngagementInfo: [String: Any] = [
            "Engagement": self.TheEngagement,
            "Date": TheDate,
        ]
        print("YES")
        // set the variable to the userdefaults value
        var LastDate = UserDefaults.standard.object(forKey: "Day")
        // if nil set the values
        if(LastDate == nil){
            UserDefaults.standard.set(Date(), forKey: "Day")
            UserDefaults.standard.set(0, forKey: "ClickCount")
            LastDate = UserDefaults.standard.object(forKey: "Day")
        }
        // if its a different day
        if(!self.SameDayCheck){
            print("YES")
            print(self.TheEngagement)
            // set the values back to 0
            UserDefaults.standard.set(0, forKey: "ClickCount")
            // use the database reference and the path to get a snapshot
            self.TheDatabase.child("Classes").child("\(ClassID as! String)").child("Statistics").child("EnagaementGraphInfo").observeSingleEvent(of: .value, with: { snapshot in
                if var Info = snapshot.value as? [[String: Any]]{
                    print("YES")
                    //append the above to the snapshow
                    Info.append(ClassEngagementInfo)
                    // Set value in the database
                    self.TheDatabase.child("Classes").child("\(ClassID as! String)").child("Statistics").child("EnagaementGraphInfo").setValue(Info)
                }
                else{
                    print("no")
                    // set the value in the database
                    self.TheDatabase.child("Classes").child("\(ClassID as! String)").child("Statistics").child("EnagaementGraphInfo").setValue([ClassEngagementInfo])
                }
            })}
    }
    
    func sceneWillResignActive(_ scene: UIScene){
        //        TheTimer?.invalidate()
        print("Final:")
        print(self.TimeUsedFor)
        // Store the values when the app is closed
        var PreviousTime = UserDefaults.standard.object(forKey: "TimeUsed")
        if(PreviousTime == nil){
            UserDefaults.standard.set(0.0, forKey: "TimeUsed")
            PreviousTime = UserDefaults.standard.object(forKey: "TimeUsed") as! Double
        }
        UserDefaults.standard.set(self.TimeUsedFor + (PreviousTime as! Double), forKey: "TimeUsed")
    }
    
    private func SetWindow(with scene: UIScene){
        // make window scene visible
        guard let windowScene = (scene as? UIWindowScene)
        else{
            return
        }
        self.Window = UIWindow(windowScene: windowScene)
        self.Window?.makeKeyAndVisible()
    }
    
    public func AuthenticateUser(){
        if Auth.auth().currentUser == nil {
            //   goes to LoginScreen if not logged in
            let LoginView = LoginController()
            let Navigate = UINavigationController(rootViewController: LoginView)
            Navigate.modalPresentationStyle = .fullScreen
            self.Window?.rootViewController = Navigate
        }
        else if Auth.auth().currentUser != nil {
            // goes to HomeScreen if logged in
            let HomeView = NavBarController()
            let Navigate = UINavigationController(rootViewController: HomeView)
            Navigate.modalPresentationStyle = .fullScreen
            self.Window?.rootViewController = Navigate
        }
    }
}

