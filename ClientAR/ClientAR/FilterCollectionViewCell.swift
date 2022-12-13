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
            self.transform = CGAffineTransform(scaleX: 1.50, y: 1.50)
            self.layer.borderColor = UIColor.black.cgColor
            self.layer.borderWidth = 1.3
        }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func transformToStandard(){
        UIView.animate(withDuration: 0.2) {
            self.layer.borderWidth = 0
            self.transform = CGAffineTransform.identity
        }
    }
}
