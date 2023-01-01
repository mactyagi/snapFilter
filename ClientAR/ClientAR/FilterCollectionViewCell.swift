//
//  FilterCollectionViewCell.swift
//  ClientAR
//
//  Created by manukant tyagi on 23/11/22.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var filterImageView: UIImageView!
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func transformToLarge(){
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.layer.borderColor = UIColor.white.cgColor
            self.layer.borderWidth = 5
        }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func transformToStandard(){
        UIView.animate(withDuration: 0.2) {
            self.layer.borderWidth = 1
            self.transform = CGAffineTransform.identity
        }
    }
}
