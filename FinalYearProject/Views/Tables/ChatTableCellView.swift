//
//  ChatTableCellView.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 05/02/2024.
//

import UIKit

class ChatTableCellView: UITableViewCell {
    // Create a UILabel
    private let UsersNameLabel: UILabel = {
        let UserNameLabel = UILabel()
        UserNameLabel.textColor = UIColor(red: 232/255, green: 116/255, blue: 0/255, alpha: 1)
        UserNameLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        return UserNameLabel
    }()
    // Create a UILabel
    private let MessageLabel: UILabel = {
        let MessageLabel = UILabel()
        MessageLabel.textColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        MessageLabel.font = .systemFont(ofSize: 19, weight: .light)
        MessageLabel.numberOfLines = 0
        return MessageLabel
    }()
    // Add the subview when called
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(UsersNameLabel)
        contentView.addSubview(MessageLabel)
    }
    // required if init doesnt exist
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Create frame with the label
        UsersNameLabel.frame = CGRect(x: 10, y: 6, width: contentView.frame.size.width - 20, height: (contentView.frame.size.height-20)/2)
        
        let UsersNameLabelBottom = UsersNameLabel.frame.origin.y + UsersNameLabel.frame.size.height
        // Label frame set to the following
        MessageLabel.frame = CGRect(x: 10, y: UsersNameLabelBottom + 8, width: contentView.frame.size.width - 20, height: (contentView.frame.size.height-20)/2)
        

        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
            super.setHighlighted(highlighted, animated: animated)
        // change text colour to white if highlighted
            if highlighted {
                UsersNameLabel.textColor = UIColor.white
            } else {
                UsersNameLabel.textColor = UIColor(red: 232/255, green: 116/255, blue: 0/255, alpha: 1)
            }
        }
    // Function to be called from other classes
    public func Build(with Model: Chats){
        self.MessageLabel.text = Model.NewestMessage.Message
        self.UsersNameLabel.text = Model.ResponderName
    }

}
