//
//  UserpersonalInfoViewController.swift
//  Dubrah
//
//  Created by user282253 on 12/25/25.
//

import UIKit

class UserpersonalInfoViewController: UIViewController {

    @IBOutlet weak var DateOfBirthtxt: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChange(datePicker:)), for: UIControl.Event.valueChanged)
        datePicker.frame.size = CGSize(width: 0, height: 300)
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        
        DateOfBirthtxt.inputView = datePicker
        DateOfBirthtxt.text = formatDate(date: Date())
        
    }
    
    @objc func dateChange(datePicker: UIDatePicker){
        DateOfBirthtxt.text = formatDate(date: datePicker.date)
    }
    func formatDate(date: Date) -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd yyyy"
        return formatter.string(from: date)
    }
    
    

}
