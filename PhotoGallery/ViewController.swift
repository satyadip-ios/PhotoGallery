//
//  ViewController.swift
//  SparkNetworkAssignment
//
//  Created by Satyadip Singha on 13/04/2020.
//  Copyright © 2020 Satyadip Singha. All rights reserved.
//

import UIKit
import Firebase
import CropViewController

class ViewController: UIViewController,CropViewControllerDelegate {

    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var lblUploadStatus: UILabel!
    
    var tapGesture = UITapGestureRecognizer()
    var takenImage: UIImage!
    var isNetworkAvailable : Bool = false
    let reachability = Reachability()!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     imgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectImageView)))
        
        imgView.isUserInteractionEnabled = true
        imgView.isUserInteractionEnabled = true
        
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                self.isNetworkAvailable = true
            } else {
                self.isNetworkAvailable = true
            }
        }
        reachability.whenUnreachable = { _ in
            self.isNetworkAvailable = false
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
          try reachability.startNotifier()
        }catch{
          print("could not start reachability notifier")
        }
    }

    @objc func reachabilityChanged(note: Notification) {

      let reachability = note.object as! Reachability

      switch reachability.connection {
      case .wifi, .cellular:
        self.isNetworkAvailable = true
      case .none:
        self.isNetworkAvailable = false
      }
        if isNetworkAvailable {
            self.lblUploadStatus.text = takenImage != nil ? "Tap image to upload" : ""
        } else {
            self.lblUploadStatus.text = takenImage != nil ? "Network is not available" : ""
        }
    }
    
    @objc func handleSelectImageView() {
        guard self.takenImage != nil else {
            return
        }
        uploadImage()
    }
    

    func uploadImage() {
        if isNetworkAvailable {
            lblUploadStatus.text = "Uploading image ..."
            if let image = self.imgView.image {
                let newPost = Post(image: image)
                    newPost.saveImage { (uploadedStatus) in
                        if uploadedStatus {
                            self.lblUploadStatus.text = "Uploaded Successfully, Download in progress!"
                            if let url = newPost.downloadURL {
                                self.saveImageinDB(downloadedPath: url)
                            }
                        } else {
                            self.lblUploadStatus.text = "Error in upload"
                        }
                        
                    }
                } else {
                    lblUploadStatus.text = "Nework is not available"
                }
            }
    }
    
    
    func saveImageinDB(downloadedPath : String?) {
        if let url = URL(string: downloadedPath ?? "") {
                              self.downloadImage(from:url , success: { (imageData) in
                                  print(imageData)
                                DispatchQueue.main.async{
                                   
                                    DatabaseHelper.instance.saveImageInCoreData(at: imageData) { (isImageSaved) in
                                        if isImageSaved {
                                            self.lblUploadStatus.text = "Image Saved!!!"
                                        }
                                    }
                                }

                              }, failure: { (failureReason) in
                                  print(failureReason)
                              })
                          }
    }
    
    func presentCropViewController(image : UIImage) {
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = self
        if #available(iOS 13.0, *) {
            cropViewController.modalPresentationStyle = .fullScreen
        }
        present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        takenImage = image
        self.imgView.image = image
        self.lblUploadStatus.text = "Click image to upload in Cloud"
        if #available(iOS 13.0, *) {
            cropViewController.dismiss(animated: false, completion: nil)
        }
        else {
            cropViewController.dismiss(animated: true,completion: nil)
        }
        
    }

    
    func downloadImage(from url: URL , success:@escaping((_ imageData:Data)->()),failure:@escaping ((_ msg:String)->())){
        
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else {
                failure("Image cant download from G+ or fb server")
                DispatchQueue.main.async {
                    self.lblUploadStatus.text = "Error in download"
                }
                return
            }

            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async {
                self.lblUploadStatus.text = "Download finished!"
            }
            success(data)
        }
    }
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

    @IBAction func selectPhotoTapped(_ sender: Any) {
            showImagePickerControllerActionSheet()
    }
    @IBAction func showListTapped(_ sender: Any) {
        performSegue(withIdentifier: "segueVCToDisplayItems", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let displayVC = segue.destination as? DisplayItems
        
        let vModel = GalleryViewModel()
//        vmodel.arrDownloadImageURL = self.arrDownloadImageURL
        vModel.arrImagesInLocal = DatabaseHelper.instance.getAllImages()
        
        displayVC?.viewModel = vModel
    }

    override func viewWillDisappear(_ animated: Bool)
    {
         reachability.stopNotifier()
           NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
        super.viewWillDisappear(animated)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showImagePickerControllerActionSheet() {
        
        let alertController = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)

        let photoLibraryAction = UIAlertAction(title:"Choose from Library", style: .default) { (action) in
            self.showImagePickerControllerActionSheet(sourceType: .photoLibrary)
        }
        let cameraAction = UIAlertAction(title:"Take from Camera", style: .default) { (action) in
            self.showImagePickerControllerActionSheet(sourceType: .camera)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showImagePickerControllerActionSheet(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var pickerImage : UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            pickerImage = editedImage

        }
        else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            pickerImage = originalImage
        }
        dismiss(animated: true) {
            if let image = pickerImage {
                self.presentCropViewController(image: image)
            }
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}



