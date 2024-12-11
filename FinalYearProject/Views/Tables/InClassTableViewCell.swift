//
//  InClassTableViewCell.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 26/02/2024.
//

import UIKit

class InClassTableViewCell: UITableViewCell {
    // Create a UILabel
    private let RowLabel: UILabel = {
        let RowLabel = UILabel()
        RowLabel.textColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        RowLabel.font = .systemFont(ofSize: 25, weight: .semibold)
        return RowLabel
    }()
    // Add the subview when called
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(RowLabel)
    }
    // required if init doesnt exist
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Create frame with the label
        RowLabel.frame = CGRect(x: 10, y: 15, width: contentView.frame.size.width - 20, height: (contentView.frame.size.height-20)/1.5)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
            super.setHighlighted(highlighted, animated: animated)
        // if highlighted set the text colour to white
            if highlighted {
                RowLabel.textColor = UIColor.white
            } else {
                RowLabel.textColor = UIColor(red: 255/255, green: 140/255, blue: 40/255, alpha: 1)
            }
        }
    // Function to be called from other classes
    public func Build(with Model: ClassContent){
        self.RowLabel.text = Model.Title
    }


}
