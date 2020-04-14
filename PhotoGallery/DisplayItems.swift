
//  DisplayItems.swift
//  SparkNetworkAssignment
//
//  Created by Satyadip Singha on 13/04/2020.
//  Copyright © 2020 Satyadip Singha. All rights reserved.
//

import UIKit

class DisplayItems: UIViewController {
    
    var viewModel: GalleryViewModel!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        lblMessage.isHidden = viewModel.arrImagesInLocal.count > 0 ?  true: false
        super.viewWillAppear(true)
    }
}

extension DisplayItems: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.arrImagesInLocal.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as?  DisplayCell {
            if viewModel.arrImagesInLocal.count > indexPath.row {
                cell.bindCellData(data: viewModel.arrImagesInLocal[indexPath.row])
            }
            return cell
        }
        return UICollectionViewCell()
    }
}

