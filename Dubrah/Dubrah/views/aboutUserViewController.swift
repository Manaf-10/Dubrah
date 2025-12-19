//
//  aboutUserViewController.swift
//  Dubrah
//
//  Created by user282253 on 12/17/25.
//

import UIKit

class aboutUserViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate  {
    
 
    
    @IBOutlet weak var txtSelectSkills: UITextField!
    @IBOutlet weak var textSelectYears: UITextField!
    let pickerYears = UIPickerView()
    let pickerSkills = UIPickerView()
    var arrYears = ["1 - 5 Years", "5+ Years", "10+ Years"]
    var arrSkills = ["UI Design", "Graphics Design", "Logo Design", "Illustation"]
    var currentIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        pickerYears.delegate = self
        pickerYears.dataSource = self
        pickerSkills.delegate = self
        pickerSkills.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let btnDone = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(closePicker))
        toolBar.setItems([btnDone], animated: true)
        
        textSelectYears.inputView = pickerYears
        textSelectYears.inputAccessoryView = toolBar
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrYears.count
    }
        
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrYears[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentIndex = row
        textSelectYears.text = arrYears[row]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func closePicker(){
        textSelectYears.text = arrYears[currentIndex]
        view.endEditing(true)
    }

}
