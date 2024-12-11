//
//  AboutSpecificViewController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 29/02/2024.
//

import UIKit

class AboutSpecificViewController: UIViewController {
    
    // Sets some local variables
    var TheAboutTitle = "Error - Could not find Page"
    var TheAboutText = ""
    var IsContent = false
    var ContentID = ""
    // when the page is created it takes in the title, body, a Bool and contentID
    init(with AboutTitle: String, AboutBody: String, IsTheContent: Bool, ContentsID: String){
        super.init(nibName: nil, bundle: nil)   
        TheAboutTitle = AboutTitle
        TheAboutText = AboutBody
        IsContent = IsTheContent
        ContentID = ContentsID
    }
    // below is required if init doesnt occur it stops the program and prints the message
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // sets the background to the image specified
        let AppBackgroundImg = UIImageView(frame: UIScreen.main.bounds)
        AppBackgroundImg.image = UIImage(named: "AppBackground.png")
        self.view.insertSubview(AppBackgroundImg, at: 0)
        // calls setupdefault page
        self.SetUpDefaultPage()
        // if the parameter IsContent is true then set the right bar button with the function specified
        if(IsContent){
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(AnswerQuestions))
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "bookWrite")
            self.navigationItem.rightBarButtonItem?.tintColor = .orange
        }
    }
    // the specified function from above
    @objc func AnswerQuestions() {
        // navigate to the specified page
        let ViewController = AnswerQuestionsViewController(with: self.ContentID)
        navigationController?.pushViewController(ViewController, animated: true)
    }
    
    private func SetUpDefaultPage(){
        // set the BodyText using AboutSpecificBody with the variable TheAboutText, this creates a UILabel
        let BodyText = AboutSpecificBody(title: TheAboutText, FontSize: 25)
        print(BodyText)
        // Adds it as a subview and disables auresizing
        self.view.addSubview(BodyText)
        BodyText.translatesAutoresizingMaskIntoConstraints = false
        // positions each element using the constraints
        NSLayoutConstraint.activate([
            BodyText.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            BodyText.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height - 10),
            BodyText.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            BodyText.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            BodyText.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)])
        // if the number of characters in the variable is less than 24 then it makes the text size smaller
        if(TheAboutTitle.count > 24){
            let CustomiseUserName: [NSAttributedString.Key: Any] = [
                // makes text orange
                .foregroundColor: UIColor.orange,
                .font: UIFont.boldSystemFont(ofSize: 21.0)
            ]
            // sets the customisations
            navigationController?.navigationBar.standardAppearance.titleTextAttributes = CustomiseUserName
            navigationController?.navigationBar.scrollEdgeAppearance?.titleTextAttributes = CustomiseUserName
        }
        else{
            // Customises the variable if the text is less than 24 characters
            let CustomiseUserName: [NSAttributedString.Key: Any] = [
                // makes the text orange and makes the size 25
                .foregroundColor: UIColor.orange,
                .font: UIFont.boldSystemFont(ofSize: 25.0)
            ]
            // sets the customisation
            navigationController?.navigationBar.standardAppearance.titleTextAttributes = CustomiseUserName
            navigationController?.navigationBar.scrollEdgeAppearance?.titleTextAttributes = CustomiseUserName
        }
        // set the title
        navigationItem.title = TheAboutTitle
        // customises the back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.image = UIImage(named: "back")
        self.navigationItem.backBarButtonItem?.tintColor = .orange
        
    
    }

}
