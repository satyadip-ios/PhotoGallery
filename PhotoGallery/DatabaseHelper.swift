//
//  DatabaseHelper.swift
//  SparkNetworkAssignment
//
//  Created by Satyadip Singha on 13/04/2020.
//  Copyright © 2020 Satyadip Singha. All rights reserved.
//

import UIKit
import CoreData

class DatabaseHelper {

    static let instance = DatabaseHelper()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func saveImageInCoreData(at imgData : Data, completion:@escaping (Bool)-> ()) {
        let profile = NSEntityDescription.insertNewObject(forEntityName: "Profile", into: context) as! Profile
        profile.img = imgData
        do{
            try context.save()
             completion(true)
        }catch {
            print(error.localizedDescription)
             completion(false)
        }
    }
    
    func getAllImages() -> [Profile] {
        var arrImages = [Profile]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Profile")
        do {
            arrImages = try context.fetch(fetchRequest) as! [Profile]
        } catch let error {
            print(error.localizedDescription)
        }
        return arrImages
    }
}
