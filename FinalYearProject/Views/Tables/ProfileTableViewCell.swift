//
//  ProfileTableViewCell.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 12/04/2024.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import Charts


class ProfileTableViewCell: UITableViewCell, ChartViewDelegate {
    // Create a database reference
    private let TheDatabase = Database.database().reference()
    // Set the variables
    private var BadgeOne = ""
    private var BadgeTwo = ""
    private var BadgeThree = ""
    private var BadgeFour = ""
    private var BadgeFive = ""
    // Set a BarChart
    private var BarChart = BarChartView()
    // Create a UILabel
    private let RowLabel: UILabel = {
        let RowLabel = UILabel()
        RowLabel.textColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        RowLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        return RowLabel
    }()
    // Creates a view container for the badges
    let Badges: UIStackView = {
        let BadgeStack = UIStackView()
        BadgeStack.axis = .horizontal
        BadgeStack.distribution = .fillEqually
        BadgeStack.alignment = .center
        BadgeStack.spacing = 10
        BadgeStack.translatesAutoresizingMaskIntoConstraints = false
        return BadgeStack
    }()
    // Add the subview when called
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(RowLabel)
        
        RowLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            RowLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            RowLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    // required if init doesnt exist
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func CreateGraph(){
        // Gets the userID
        guard let UserID = UserDefaults.standard.value(forKey: "UserID") as? String else{
            return
        }
        // gets a snapshot using the database reference and the path
        TheDatabase.child("EngagementInformation/\(UserID)/Info").observeSingleEvent(of: .value, with: {snapshot in
            guard var UsersContainer = snapshot.value as? [[String: Any]] else{
                print("problem")
                return
            }
            // Create a DateFormatter
            let DF = DateFormatter()
            DF.dateFormat = "MM dd, yyyy 'at' h:mm:ss a zzz"
            // Create an array of BarChartDataEntry
            var GraphData = [BarChartDataEntry]()
            // Create an array of Strings
            var DatesCollection = [String]()
            // Loop which creates the data and append it to the array
            for x in 0..<(UsersContainer.count){
                let y = UsersContainer[x]
                let Engagement = y["Engagement"] as! Double
                // Gets components of the date
                let TheDate = DF.date(from: y["Date"] as! String)
                let TheDay = Calendar.current.component(.day, from: TheDate!)
                let TheMonth = Calendar.current.component(.month, from: TheDate!)
                let TheYear = Calendar.current.component(.year, from: TheDate!)
                let DateAsDouble = Double(String(format: "%02d.%02d", TheDay, TheMonth))
                // appends to the array
                DatesCollection.append(String(TheDay) + "/" + String(TheMonth) + "/" + String(TheYear))
                
                GraphData.append(BarChartDataEntry(x: Double(x), y: Double(Engagement)))
            }
            // Customises graph
            self.BarChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: DatesCollection)
            let DataSet = BarChartDataSet(entries: GraphData, label: "Engagement")
            DataSet.colors = [UIColor.orange]
            DataSet.valueTextColor = .orange
            self.BarChart.xAxis.labelTextColor = .orange
            self.BarChart.leftAxis.labelTextColor = .orange
            self.BarChart.rightAxis.labelTextColor = .orange
            self.BarChart.legend.textColor = .orange
            self.BarChart.chartDescription.textColor = .orange
            self.BarChart.data?.setValueTextColor(.orange)
            self.BarChart.leftAxis.axisMaximum = 1
            self.BarChart.rightAxis.axisMaximum = 1
            self.BarChart.data = BarChartData(dataSet: DataSet)
            
            self.BarChart.delegate = self
            
            self.BarChart.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.size.width, height: self.contentView.frame.size.width)
            self.BarChart.center = self.contentView.center
            self.contentView.addSubview(self.BarChart)
            
        })
    }
    
    func AddBadges(){
        // Gets the UserID from the user default
        guard let UserID = UserDefaults.standard.value(forKey: "UserID") as? String else{
            return
        }
        // gets a snapshot using the database reference and the path
        TheDatabase.child("Badges/\(UserID)").observeSingleEvent(of: .value, with: {snapshot in
            guard var UsersContainer = snapshot.value as? [String: Any] else{
                print("problem")
                return
            }
            // set the values from the snapshot value to the local arrays
            self.BadgeOne = UsersContainer["BadgeOne"] as! String
            self.BadgeTwo = UsersContainer["BadgeTwo"] as! String
            self.BadgeThree = UsersContainer["BadgeThree"] as! String
            self.BadgeFour = UsersContainer["BadgeFour"] as! String
            self.BadgeFive = UsersContainer["BadgeFive"] as! String
            // Set the badge array
            self.contentView.addSubview(self.Badges)
            // Adds contraints
            NSLayoutConstraint.activate([
                self.Badges.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
                self.Badges.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
                self.Badges.topAnchor.constraint(equalTo: self.contentView.topAnchor),
                self.Badges.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            ])
            // Displays the badges if the values gotten were true
            if(self.BadgeOne == "true"){
                let Badge = UIImageView(image: UIImage(named: "Badge1"))
                Badge.contentMode = .scaleAspectFit
                Badge.frame = CGRect(x: 0, y: 0, width: 1, height: 60)
                Badge.translatesAutoresizingMaskIntoConstraints = false
                self.Badges.addArrangedSubview(Badge)
            }
            
            if(self.BadgeTwo == "true"){
                let Badge = UIImageView(image: UIImage(named: "Badge2"))
                Badge.contentMode = .scaleAspectFit
                Badge.frame = CGRect(x: 0, y: 0, width: 1, height: 60)
                Badge.translatesAutoresizingMaskIntoConstraints = false
                self.Badges.addArrangedSubview(Badge)
            }
            
            if(self.BadgeThree == "true"){
                let Badge = UIImageView(image: UIImage(named: "Badge3"))
                Badge.contentMode = .scaleAspectFit
                Badge.frame = CGRect(x: 0, y: 0, width: 1, height: 60)
                Badge.translatesAutoresizingMaskIntoConstraints = false
                self.Badges.addArrangedSubview(Badge)
            }
            
            if(self.BadgeFour == "true"){
                let Badge = UIImageView(image: UIImage(named: "Badge4"))
                Badge.contentMode = .scaleAspectFit
                Badge.frame = CGRect(x: 0, y: 0, width: 1, height: 60)
                Badge.translatesAutoresizingMaskIntoConstraints = false
                self.Badges.addArrangedSubview(Badge)
            }
            
            if(self.BadgeFive == "true"){
                let Badge = UIImageView(image: UIImage(named: "Badge5"))
                Badge.contentMode = .scaleAspectFit
                Badge.frame = CGRect(x: 0, y: 0, width: 1, height: 60)
                Badge.translatesAutoresizingMaskIntoConstraints = false
                self.Badges.addArrangedSubview(Badge)
            }
            
        })
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //  sets the label's frame
        RowLabel.frame = CGRect(x: 10, y: 15, width: contentView.frame.size.width - 20, height: (contentView.frame.size.height-20)/1.5)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        // set the text colour to white if its highlighted
        if highlighted {
            RowLabel.textColor = UIColor.white
        } else {
            RowLabel.textColor = UIColor(red: 255/255, green: 140/255, blue: 40/255, alpha: 1)
        }
    }
    // Function to be called from other classes
    public func Build(with Model: ProfileContent){
        // set it depending on which row it is
        if(Model.ContentType == "Level"){
            self.RowLabel.text = "  Level: " + Model.Level + " - Experience: " + Model.XP + "/" + Model.MaxXP
        }
        else if(Model.ContentType == "Badges"){
            self.RowLabel.text = ""
            if(Model.Cell == 1){
                self.AddBadges()
            }
            
        }
        else if(Model.ContentType == "Statistics"){
            self.RowLabel.text = ""
            if(Model.Cell == 2){
                self.CreateGraph()
            }
        }
        else{
            
        }
    }
}

