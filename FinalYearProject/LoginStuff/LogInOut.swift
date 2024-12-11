//
//  LogInOut.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 20/01/2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import RealmSwift

class LoginOut {
    // make the function accessible to other functions and creates references to the database to make later code easier
    public static let shared = LoginOut()
    private init() {}
    private let TheDatabase = Database.database().reference()
    private let FireStoreDatabase = Firestore.firestore()
    // create struct within the class for the needed values (struct only needed within class)
    struct UsersData {
        let UsersID: String
        let UsersName: String
        let IsTeacher: String
    }
    
    public func Login(with LoginInfo: UserLogin, completion: @escaping (Error?)->Void){
    // takes user login information and checks it with the values in the database
        Auth.auth().signIn(withEmail: LoginInfo.UserID + "@userid.com", password: LoginInfo.Password){
            result, error in if error != nil{
                // if error is not equal to nil so an error has occured
                completion(error)
                return
            }
            else{
                // checks local cache to see if we already have the values
                print("How far does it go 1")
                self.TheDatabase.child("users").observeSingleEvent(of: .value, with: {snapshot in
                    if var UserArray = snapshot.value as? [[String: String]]{
                        print("How far does it go")
                        self.FireStoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                            // if the document exists
                                if let document = document, document.exists {
                                    // gets the values of the data from the document
                                    let Name = document.data()?["UsersName"] as? String
                                    let IsTeacher = document.data()?["IsTeaching"] as? String
                                    let UserID = document.data()?["UserID"] as? String
                                    // sets userdefaults for later use in the application
                                    UserDefaults.standard.set(UserID, forKey: "UserID")
                                    // checks if its in the messager array for later use
                                    if let InArray = document.data()?["IsInArray"]
                                        as? Bool {
                                        print(InArray)
                                        // calls the following functions
                                        self.GetAndStoreUserData { UsersData in
                                            if let UsersData = UsersData {
                                                // if we get data it prints succeeds
                                                print("Successfully Got User Data")
                                                completion(nil)
                                            } else {
                                                // if we dont it prints fail
                                                print("Failed to get User Data")
                                            }
                                        }
                                }
                                    else {
                                        // if it doesnt exist it would append the following
                                        let ToAppend = [
                                            "UsersName": Name ?? "No Name",
                                            "IsTeaching": IsTeacher ?? "false",
                                            "UserID": UserID ?? "false"
                                        ]
                                        // and ensure the value exists for next time
                                        self.FireStoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).setData(["IsInArray": true], merge: true) { error in
                                            if let error = error {
                                                print(error)
                                            } else {
                                                print("Worked")
                                            }
                                        }
                                        UserArray.append(ToAppend)
                                        
                                        self.TheDatabase.child("users").setValue(UserArray, withCompletionBlock: { error, _ in guard error == nil else{
                                                return
                                            }
                                            
                                        })
                                        completion(nil)
                                    }
                                }
                            }
                        
                    }
                    else{
                        // if its not in the local cache it will check the database, sets the variables and create the user defaults
                        self.FireStoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                            let Name = document?.data()?["UsersName"] as? String
                            let IsTeacher = document?.data()?["IsTeaching"] as? String
                            let UserID = document?.data()?["UserID"] as? String
                            UserDefaults.standard.set(UserID, forKey: "UserID")
                            // sets the new data "IsInArray" for the messanger later on
                            self.FireStoreDatabase.collection("Users").document(Auth.auth().currentUser!.uid).setData(["IsInArray": true], merge: true) { error in
                                if let error = error {
                                    print(error)
                                } else {
                                    print("Worked")
                                }
                            }
                            // create and store variables in a new variable, which uses the struct created earlier
                            let UserArray: [[String: String]] = [[
                                "UsersName": Name ?? "No Name",
                                "IsTeaching": IsTeacher ?? "false",
                                "UserID": UserID ?? "false"
                                ]]
                            // calls the following functions
                            self.GetAndStoreUserData { userData in
                                if userData != nil {
                                    print("Success")
                                } else {
                                    print("Fail")
                                }
                            }
                            // sets the user to the database
                            self.TheDatabase.child("users").setValue(UserArray, withCompletionBlock: { error, _ in guard error == nil else{
                                    return
                                }
                                
                                
                                
                                
                            })
                        }
                        completion(nil)
                    }
                })
            }
        }
    }
    
    public func LogOut(completion: @escaping (Error?)->Void){
        // signs out
        do{
            try Auth.auth().signOut()
            completion(nil)
        }
        catch let error{
            completion(error)
        }
    }
    
    func GetAndStoreUserData(completion: @escaping (UsersData?) -> Void) {
        // gets document from database which has the necessary information
        let DatabaseCollection = FireStoreDatabase.collection("Users")
        DatabaseCollection.document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
                if let document = document, document.exists {
                    // returns necessary information and stores it into variables
                    if let UsersID = document["UserID"] as? String,
                       let UsersName = document["UsersName"] as? String,
                       let IsTeacher = document["IsTeacher"] as? String {
                        // cast the data into a struct which we created before and return that
                        let UsersData = UsersData(UsersID: UsersID, UsersName: UsersName, IsTeacher: IsTeacher)
                        self.SetUserDefaults(UsersData)
                        completion(UsersData)
                    } else {
                        completion(nil)
                    }
                } else {
                    // prints the that occured
                    print("Error: \(error?.localizedDescription ?? "An Unknown error has occured")")
                    completion(nil)
                }
            }
        }

        private func SetUserDefaults(_ UsersData: UsersData) {
            // Function to set user defaults
            UserDefaults.standard.set(UsersData.UsersID, forKey: "UsersID")
            UserDefaults.standard.set(UsersData.UsersName, forKey: "UsersName")
            UserDefaults.standard.set(UsersData.IsTeacher, forKey: "IsTeacher")
            UserDefaults.standard.set(false, forKey: "IsAnonymous")
            
            print("Should happen 1st")
            
        }
}
