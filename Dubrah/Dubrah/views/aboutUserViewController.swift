//
//  aboutUserViewController.swift
//  Dubrah
//
//  Created by user282253 on 12/17/25.
//

import UIKit

// String extension to calculate the width of the string based on height and font



class aboutUserViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    
    @IBOutlet weak var textSelectSkills: UITextField!
    @IBOutlet weak var textSelectYears: UITextField!
    let pickerYears = UIPickerView()
    let pickerSkills = UIPickerView()
    var arrYears = ["1 - 5 Years", "5+ Years", "10+ Years"]
    // List of skills (tags)
        var primarySkills = ["Design", "Photography", "Editing", "Illustration", "UI Design"]
    var selectedSkills: Set<Int> = []
        var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pickerYears.delegate = self
        pickerYears.dataSource = self
        pickerSkills.delegate = self
        pickerSkills.dataSource = self

              
        setupToolbar(for: textSelectYears)
        setupToolbar(for: textSelectSkills)
                
                
        textSelectYears.inputView = pickerYears
        textSelectSkills.inputView = pickerSkills
       
    }
    func setupToolbar(for textField: UITextField) {
            let toolBar = UIToolbar()
            toolBar.sizeToFit()
            let btnDone = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(closePicker))
            toolBar.setItems([btnDone], animated: true)
            textField.inputAccessoryView = toolBar
        }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pickerYears {
                    return arrYears.count // Year picker rows
                } else {
                    return primarySkills.count // Skills picker rows
                }
    }
        
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pickerYears {
                   return arrYears[row] // Year picker titles
               } else {
                   return primarySkills[row] // Skills picker titles
               }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerYears {
                   currentIndex = row
                   textSelectYears.text = arrYears[row]
               } else {
                   // Toggle selection for the skills picker (multi-selection)
                   if selectedSkills.contains(row) {
                       selectedSkills.remove(row)
                   } else {
                       selectedSkills.insert(row)
                   }
                   updateSkillsSelection()
               }
    }
    func updateSkillsSelection() {
          var selectedSkillsArray = [String]()
          for index in selectedSkills {
              selectedSkillsArray.append(primarySkills[index])
          }
          textSelectSkills.text = selectedSkillsArray.joined(separator: ", ")
      }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func closePicker(){
        textSelectYears.text = arrYears[currentIndex]
        view.endEditing(true)
    }
}
