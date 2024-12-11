//
//  SettingsTableViewCell.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 12/02/2024.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    // Create a UILabel
    private let RowTitle: UILabel = {
        let RowTitle = UILabel()
        RowTitle.textColor = UIColor(red: 232/255, green: 116/255, blue: 0/255, alpha: 1)
        RowTitle.font = .systemFont(ofSize: 21, weight: .semibold)
        return RowTitle
    }()
    // Add the subview when called
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(RowTitle)
    }
    // required if init doesnt exist
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        RowTitle.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Create frame with the label
        RowTitle.frame = CGRect(x: 10, y: 15, width: contentView.frame.size.width - 20, height: (contentView.frame.size.height-20)/1.5)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
            super.setHighlighted(highlighted, animated: animated)
        // change text colour to white if highlighted
            if highlighted {
                if(!Anonymous){
                    RowTitle.textColor = UIColor(red: 39/255, green: 41/255, blue: 56/255, alpha: 1)
                }
            } else {
                if(Anonymous){
                    RowTitle.textColor = UIColor(red: 232/255, green: 116/255, blue: 0/255, alpha: 1)
                    
                }
            }
        }
    // Function to be called from other classes
    public func Build(with Model: SettingsRow){
        self.RowTitle.text = Model.Title
    }
    
//    public func IsAnonymous(with Status: Bool){
//        if(Status){
//            self.RowTitle.textColor = .white
//        }
//        else{
//            self.RowTitle.textColor = .orange
//        }
//    }
}
