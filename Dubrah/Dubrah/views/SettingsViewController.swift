//
//  SettingsViewController.swift
//  Dubrah
//
//  Created by M7md on 20/12/2025.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSettings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = settingsTable.dequeueReusableCell(withIdentifier: "settingsCell") as! SettingsTableViewCell
        let data = arrSettings[indexPath.row]
        cell.setUpCell(photo: data.photo, Settings: data.Settings)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedOption = arrSettings[indexPath.row]
        
        switch selectedOption.Settings {
        case "Edit Profile":
            performSegue(withIdentifier:"EditProfileViewController", sender: self)
        default:
            <#code#>
        }
    }
    
    
    
    @IBOutlet weak var settingsTable: UITableView!
    var arrSettings = [setting]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsTable.delegate = self
        settingsTable.dataSource = self
        
        arrSettings.append(setting.init(Settings: "Edit Profile", photo: UIImage(contentsOfFile: "person.crop.circle")!))
        arrSettings.append(setting.init(Settings: "Security Settings", photo: UIImage(contentsOfFile: "exclamationmark.shield")!))
        arrSettings.append(setting.init(Settings: "Order History", photo: UIImage(contentsOfFile: "book.closed")!))
        arrSettings.append(setting.init(Settings: "About The App", photo: UIImage(contentsOfFile: "exclamationmark")!))
        arrSettings.append(setting.init(Settings: "Terms & Codition", photo: UIImage(contentsOfFile: "newspaper")!))
        arrSettings.append(setting.init(Settings: "Privacy Policy", photo: UIImage(contentsOfFile: "lock")!))
        arrSettings.append(setting.init(Settings: "FAQ", photo: UIImage(contentsOfFile: "questionmark")!))
    }
    
    
    struct setting {
        let Settings : String
        let photo: UIImage
    }
    
}
