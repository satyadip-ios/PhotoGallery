//
//  DisplayCell.swift
//  SparkNetworkAssignment
//
//  Created by Satyadip Singha on 13/04/2020.
//  Copyright © 2020 Satyadip Singha. All rights reserved.
//

import UIKit

class DisplayCell: UICollectionViewCell {
    


    @IBOutlet weak var imgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bindCellData(data : Profile) {
        self.imgView.image = UIImage( data: data.img!)
    }
}

