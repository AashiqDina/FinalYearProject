//
//  ClassStatisticsViewController.swift
//  FinalYearProject
//
//  Created by Aashiq Dina on 27/02/2024.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import Charts

class ClassStatisticsViewController: UIViewController, ChartViewDelegate {
    // Create a reference to the database
    private let TheDatabase = Database.database().reference()
    // create a BarChartView
    private var BarChart = BarChartView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // set background
        let AppBackgroundImg = UIImageView(frame: UIScreen.main.bounds)
        AppBackgroundImg.image = UIImage(named: "AppBackground.png")
        self.view.insertSubview(AppBackgroundImg, at: 0)
        // Add the title
        navigationItem.title = "Class Statistics"
        // Set back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.image = UIImage(named: "back")
        self.navigationItem.backBarButtonItem?.tintColor = .orange
        // call createGraph
        self.CreateGraph()
    }
    

    func CreateGraph(){
        // get the classID from a userDefault
        guard let ClassID = UserDefaults.standard.value(forKey: "ClassID") as? String else{
            return
        }
        // // use the reference and path to get a snapshot as a array of dictionaries
        TheDatabase.child("Classes/\(ClassID)/Statistics/EnagaementGraphInfo").observeSingleEvent(of: .value, with: {snapshot in
            guard var UsersContainer = snapshot.value as? [[String: Any]] else{
                // Otherwise return completion false and print error
                print("problem")
                return
            }
            // Sets the current date to the variable as a string
            let DF = DateFormatter()
            DF.dateFormat = "MM dd, yyyy 'at' h:mm:ss a zzz"
            
            // Declare somw variables
            var GraphData = [BarChartDataEntry]()
            var DatesCollection = [String]()
            // For the amount of data in the array loop
            for x in 0..<(UsersContainer.count){
                // Declare a few variables
                let y = UsersContainer[x]
                let Engagement = y["Engagement"] as! Double
                // Get the date as a String
                let TheDate = DF.date(from: y["Date"] as! String)
                // Get the Day and set it to the variable
                let TheDay = Calendar.current.component(.day, from: TheDate!)
                // Get the Month and set it to the variable
                let TheMonth = Calendar.current.component(.month, from: TheDate!)
                // Get the Yeat and set it to the variable
                let TheYear = Calendar.current.component(.year, from: TheDate!)
                // Get the date as a Double
                let DateAsDouble = Double(String(format: "%02d.%02d", TheDay, TheMonth))
                // Append the concatenated string to the array
                DatesCollection.append(String(TheDay) + "/" + String(TheMonth) + "/" + String(TheYear))
                // Append the data to the Graph
                GraphData.append(BarChartDataEntry(x: Double(x), y: Double(Engagement)))
            }
            // Customises the format of the labels
            self.BarChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: DatesCollection)
            let DataSet = BarChartDataSet(entries: GraphData, label: "Engagement")
            // Customises the colours of the graph
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
            // Input the data to the graph
            self.BarChart.data = BarChartData(dataSet: DataSet)
            self.BarChart.delegate = self
            // add the graph
            self.BarChart.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width)
            self.BarChart.center = self.view.center
            self.view.addSubview(self.BarChart)
            
        })
    }


}
