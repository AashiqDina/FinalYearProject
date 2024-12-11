//
//  SubmissionSectionTableViewCell.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 15/03/2024.
//

import UIKit

class SubmissionSectionTableViewCell: UITableViewCell {
    // Create a UILabel
    private let AboutTitle: UILabel = {
        let AboutTitle = UILabel()
        AboutTitle.textColor = UIColor(red: 232/255, green: 116/255, blue: 0/255, alpha: 1)
        AboutTitle.font = .systemFont(ofSize: 20, weight: .semibold)
        return AboutTitle
    }()
    // Create a UILabel
    private let AboutBody: UILabel = {
        let AboutBody = UILabel()
        AboutBody.textColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        AboutBody.font = .systemFont(ofSize: 19, weight: .light)
        AboutBody.numberOfLines = 0
        return AboutBody
    }()
    // Add the subview when called
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(AboutTitle)
        contentView.addSubview(AboutBody)
    }
    // required if init doesnt exist
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Create frame with the label
        AboutTitle.frame = CGRect(x: 10, y: 6, width: contentView.frame.size.width - 20, height: (contentView.frame.size.height-20)/2)
        
        let UsersNameLabelBottom = AboutTitle.frame.origin.y + AboutTitle.frame.size.height
        // Create frame with the label
        AboutBody.frame = CGRect(x: 10, y: UsersNameLabelBottom + 8, width: contentView.frame.size.width - 20, height: (contentView.frame.size.height-20)/2)
        

        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
            super.setHighlighted(highlighted, animated: animated)
        // change text colour to white if highlighted
            if highlighted {
                AboutTitle.textColor = UIColor.white
            } else {
                AboutTitle.textColor = UIColor(red: 232/255, green: 116/255, blue: 0/255, alpha: 1)
            }
        }
    // Function to be called from other classes
    public func Build(with Model: Submissions){
        self.AboutTitle.text = Model.SectionTile
        self.AboutBody.text = Model.SectionDescription
    }

}
