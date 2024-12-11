//
//  LoginTextField.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 16/01/2024.
//

import UIKit

class LoginTextField: UITextField {
    // create exhastive enum
    enum LoginFieldType{
        case UserId
        case Password
        case Title
        case Link
        case Question
        case Answer
    }
    
    private let authFieldType: LoginFieldType
    // set values with init
    init(fieldType: LoginFieldType){
        self.authFieldType = fieldType
        super.init(frame: .zero)
        self.backgroundColor = .white
        self.autocapitalizationType = .none
        self.layer.cornerRadius = 25
        self.returnKeyType = .done
        self.autocorrectionType = .no
        // set texts and such dependent on the case
        switch fieldType{
        case .UserId:
            self.placeholder = "User ID"
        case .Password:
            self.textContentType = .oneTimeCode
            self.placeholder = "Password"
            self.isSecureTextEntry = true
        case .Title:
            self.placeholder = "Enter your title here..."
            self.textAlignment = .left
            
        case .Link:
            self.placeholder = "Enter your Link here..."
            self.textAlignment = .left
            self.sizeToFit()
        case .Question:
            self.placeholder = "Enter question here..."
            self.textAlignment = .left
            self.sizeToFit()
        case .Answer:
            self.placeholder = "Enter the answer here..."
            self.textAlignment = .left
            self.sizeToFit()
        }
    
        
        self.leftViewMode = .always
        self.leftView = UIView(frame:CGRect(x: 0, y:0, width: 12, height: self.frame.size.height))
    }
    // required if init doesnt exist
    required init?(coder: NSCoder){
        fatalError("An error has occured")
    }
    
    //    func hexStringToUIColor (hex:String, alpha:Float) -> UIColor {
    //        let cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    //
    //        if ((cString.count) != 6) {
    //            return UIColor.black
    //        }
    //
    //        var rgb:UInt64 = 0
    //        Scanner(string: cString).scanHexInt64(&rgb)
    //
    //        return UIColor(
    //            red: CGFloat((rgb & 0xFF0000) >> 16)/255.0,
    //            green: CGFloat((rgb & 0x00FF00) >> 8)/255.0,
    //            blue: CGFloat(rgb & 0x0000FF)/255.0,
    //            alpha: CGFloat(alpha)
    //        )
    //    }
}
