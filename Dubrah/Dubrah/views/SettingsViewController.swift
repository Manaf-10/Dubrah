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
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    @IBOutlet weak var settingsTable: UITableView!
    var arrSettings = [setting]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsTable.delegate = self
        settingsTable.dataSource = self
        
        arrSettings.append(setting.init(Settings: "Edit Profile", photo: UIImage(named: "Edit profile")!))
        arrSettings.append(setting.init(Settings: "Security Settings", photo: UIImage(named: "Security Settings")!))
        arrSettings.append(setting.init(Settings: "Order History", photo: UIImage(named: "Order History")!))
        arrSettings.append(setting.init(Settings: "About The App", photo: UIImage(named: "About The App")!))
        arrSettings.append(setting.init(Settings: "Terms & Condition", photo: UIImage(named: "Terms&Condition")!))
        arrSettings.append(setting.init(Settings: "Privacy Policy", photo: UIImage(named: "Privacy Policy")!))
        arrSettings.append(setting.init(Settings: "FAQ", photo: UIImage(named: "FAQ")!))
    }
    
    
    struct setting {
        let Settings : String
        let photo: UIImage
    }
    
}
