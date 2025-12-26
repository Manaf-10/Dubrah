//
//  EditProfileViewController.swift
//  Dubrah
//
//  Created by user282253 on 12/26/25.
//

import UIKit

class EditProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == SkillsCollectionView{
            return Skills.count
        }else if collectionView == interestsCollectionView{
            return Interests.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == SkillsCollectionView{
            let cell = SkillsCollectionView.dequeueReusableCell(withReuseIdentifier: "Skillscell", for: indexPath) as! skillsCollectionViewCell
            cell.Skillslbl.text = Skills[indexPath.row]
            cell.backgroundColor = .blue
            cell.Skillslbl.textColor = .white
            cell.layer.cornerRadius = 12
            return cell
        }else if collectionView == interestsCollectionView{
            let cell = interestsCollectionView.dequeueReusableCell(withReuseIdentifier: "Interestscell", for: indexPath) as! InterestsCollectionViewCell
            cell.Interestslbl.text = Interests[indexPath.row]
            cell.backgroundColor = .blue
            cell.Interestslbl.textColor = .white
            cell.layer.cornerRadius = 12
            return cell
        }
        return UICollectionViewCell()
    }
    

    @IBOutlet weak var interestsCollectionView: UICollectionView!
    @IBOutlet weak var SkillsCollectionView: UICollectionView!
    let Skills = ["Design", "Production", "Photography"]
    let Interests = ["Design", "Photography", "Tutoring"]
    override func viewDidLoad() {
        super.viewDidLoad()
        SkillsCollectionView.delegate = self
        SkillsCollectionView.dataSource = self
        interestsCollectionView.delegate = self
        interestsCollectionView.dataSource = self

      
    }
}
