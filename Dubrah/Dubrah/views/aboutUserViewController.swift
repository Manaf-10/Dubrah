//
//  aboutUserViewController.swift
//  Dubrah
//
//  Created by user282253 on 12/17/25.
//

import UIKit

// String extension to calculate the width of the string based on height and font
extension String {
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return boundingBox.width
    }
}


class aboutUserViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate  {
    
 
    
    @IBOutlet weak var SkillsContainerView: UIView!
    @IBOutlet weak var txtSelectSkills: UITextField!
    @IBOutlet weak var textSelectYears: UITextField!
    let pickerYears = UIPickerView()
    let pickerSkills = UIPickerView()
    var arrYears = ["1 - 5 Years", "5+ Years", "10+ Years"]
    var arrSkills = ["UI Design", "Graphics Design", "Logo Design", "Illustation"]
    var primarySkills = ["Design", "Photography", "Editing"]
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
        createTags()
     
        
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
    func createTags() {
            var xPosition: CGFloat = 10  // Starting position for the first tag
            let yPosition: CGFloat = 10  // Fixed position for the vertical axis
            let tagHeight: CGFloat = 30   // Height of each tag
            let tagPadding: CGFloat = 10  // Padding between the tags
            
            // Loop through each primary skill and create a tag for it
            for skill in primarySkills {
                let tagLabel = UILabel()
                tagLabel.text = skill
                tagLabel.backgroundColor = .blue   // You can change this to your desired color
                tagLabel.textColor = .white        // Text color for tags
                tagLabel.font = UIFont.systemFont(ofSize: 14)  // Font size for the tags
                tagLabel.layer.cornerRadius = 15   // Round the corners of the label
                tagLabel.layer.masksToBounds = true
                tagLabel.textAlignment = .center   // Align text to center
                tagLabel.translatesAutoresizingMaskIntoConstraints = false
                
                // Add the tag label to the container view
                SkillsContainerView.addSubview(tagLabel)
                
                // Calculate the width of the tag dynamically based on text
                let width = skill.width(withConstrainedHeight: tagHeight, font: tagLabel.font)
                
                // Set the frame of the tag label with calculated width and fixed height
                tagLabel.frame = CGRect(x: xPosition, y: yPosition, width: width + 20, height: tagHeight)
                
                // Update the x position for the next tag
                xPosition += tagLabel.frame.width + tagPadding
                
                // Adjust the container view width based on the added tags
                SkillsContainerView.frame.size.width = xPosition
            }
        }

    
    
    // Function to remove a tag when tapped
    @objc func removeTag(_ sender: UITapGestureRecognizer) {
        if let tagLabel = sender.view as? UILabel {
            tagLabel.removeFromSuperview()  // Remove the label from the container
        }
    }


}
