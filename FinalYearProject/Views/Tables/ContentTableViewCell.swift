//
//  ContentTableViewCell.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 04/03/2024.
//

import UIKit

class ContentTableViewCell: UITableViewCell {
    // Create a UILabel
    private let Title: UILabel = {
        let Title = UILabel()
        Title.textColor = UIColor(red: 232/255, green: 116/255, blue: 0/255, alpha: 1)
        Title.font = .systemFont(ofSize: 20, weight: .semibold)
        return Title
    }()
    // Create a UILabel
    private let Body: UILabel = {
        let Body = UILabel()
        Body.textColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        Body.font = .systemFont(ofSize: 19, weight: .light)
        Body.numberOfLines = 0
        return Body
    }()
    // Add the subview when called
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(Title)
        contentView.addSubview(Body)
    }
    // required if init doesnt exist
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Create frame with the label
        Title.frame = CGRect(x: 10, y: 6, width: contentView.frame.size.width - 20, height: (contentView.frame.size.height-20)/2)
        
        let TitleBottom = Title.frame.origin.y + Title.frame.size.height
        // Label frame set to the following
        Body.frame = CGRect(x: 10, y: TitleBottom + 8, width: contentView.frame.size.width - 20, height: (contentView.frame.size.height-20)/2)
        

        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
            super.setHighlighted(highlighted, animated: animated)
            // change text colour to white if highlighted
            if highlighted {
                Title.textColor = UIColor.white
            } else {
                Title.textColor = UIColor(red: 232/255, green: 116/255, blue: 0/255, alpha: 1)
            }
        }
    // Function to be called from other classes and the functions depends on the types
    public func Build(with Model: Content){
        if(Model.TheType == "Link"){
            self.Body.text = "Click to Access"
        }
        else if(Model.TheType == "Download"){
            self.Body.text = "Click to Download"
        }
        else{
            self.Body.text = Model.Body
        }

        self.Title.text = Model.Title
    }


}
