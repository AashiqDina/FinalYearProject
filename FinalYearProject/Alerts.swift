//
//  Alerts.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 17/01/2024.
//

import UIKit

class Alerts{
}

extension Alerts{
    // creates error for logging out
    public static func ErrorLoggingOut(on ErrorViewController: UIViewController, with error:Error){
        DispatchQueue.main.async{
        let ErrorAlert = UIAlertController(title: "Logout Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
        ErrorAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler:nil))
        ErrorViewController.present(ErrorAlert, animated: true)
        }
    }
}
    
extension Alerts{
    // creates error for unknown
    public static func UnknownError(on ErrorViewController: UIViewController, with error:Error){
        DispatchQueue.main.async{
        let ErrorAlert = UIAlertController(title: "An error has occured", message: "Check your Username or Password is correct", preferredStyle: .alert)
        ErrorAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler:nil))
        ErrorViewController.present(ErrorAlert, animated: true)
        }
    }
}

