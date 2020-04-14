//
//  Post.swift
//  SparkNetworkAssignment
//
//  Created by Satyadip Singha on 13/04/2020.
//  Copyright © 2020 Satyadip Singha. All rights reserved.
//

import UIKit
import Firebase

class Post {
    private var image: UIImage!
    var downloadURL : String? 

    typealias CompletionHandler = (_ success:Bool) -> Void
    
    init(image: UIImage) {
        self.image = image
    }

    func saveImage(completion:@escaping (Bool) -> ()) {
        let imgData = UIImage.jpegData(self.image)

              let imageName = UUID().uuidString
              let ref = Storage.storage().reference().child("pictures/\(imageName).jpg")
              let meta = StorageMetadata()
              meta.contentType = "image/jpeg"
            ref.putData( imgData(0.5)!, metadata: meta) { (metaData, error) in
            if let e = error {
                print("==> error: \(e.localizedDescription)")
                completion(false)
            }
            else
            {
                ref.downloadURL(completion: { (url, error) in
                    if (url?.absoluteString) != nil {
                       
                        self.downloadURL =  url?.absoluteString ?? ""
                    }
                    completion(true)
                })
            }
        }
    }

}












