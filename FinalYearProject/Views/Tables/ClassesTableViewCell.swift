//
//  ClassesTableViewCell.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 17/02/2024.
//

import UIKit

class ClassesTableViewCell: UITableViewCell {
    // Create a UILabel
    private let ClassNameLabel: UILabel = {
        let ClassNameLabel = UILabel()
        ClassNameLabel.textColor = .red
        ClassNameLabel.font = .systemFont(ofSize: 25, weight: .semibold)
        return ClassNameLabel
    }()
    // Add the subview when called
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(ClassNameLabel)
    }
    // required if init doesnt exist
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Create frame with the label
        ClassNameLabel.frame = CGRect(x: 10, y: 6, width: contentView.frame.size.width - 20, height: (contentView.frame.size.height-20)/2)

        let UsersNameLabelBottom = ClassNameLabel.frame.origin.y + ClassNameLabel.frame.size.height
        // Label frame set to the following
        ClassNameLabel.frame = CGRect(x: 10, y: UsersNameLabelBottom - 15, width: contentView.frame.size.width - 20, height: (contentView.frame.size.height-20)/2)
        

        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
            super.setHighlighted(highlighted, animated: animated)
        // change text colour to white if highlighted
            if highlighted {
                ClassNameLabel.textColor = UIColor.white
            } else {
                ClassNameLabel.textColor = UIColor(red: 232/255, green: 116/255, blue: 0/255, alpha: 1)
            }
        }
    // Function to be called from other classes
    public func Build(with Model: Classes){
        self.ClassNameLabel.text = Model.ClassName
    }


}
