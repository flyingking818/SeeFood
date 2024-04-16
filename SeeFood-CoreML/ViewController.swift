//
//  ViewController.swift
//  SeeFood-CoreML
//
//  Created by Angela Yu on 27/06/2017.
//  Copyright © 2017 Angela Yu. All rights reserved.
//  Updated by Jeremy Wang 4/10/2024

import UIKit
import CoreML
import Vision
import Social


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    var classificationResults : [VNClassificationObservation] = []  //array! :)
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
    }
    
    func detect(image: CIImage) {
        
        // Load the ML model through its generated class
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("can't load ML model")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first
                else {
                    fatalError("unexpected result type from VNCoreMLRequest")
            }
            //See the model resuts
            //Use cmd+K to clear the console for testing
            
            print(results)
            
            if topResult.identifier.contains("hotdog") {
                DispatchQueue.main.async {
                    self.navigationItem.title = "Hotdog!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.green
                    self.navigationController?.navigationBar.isTranslucent = false
                }
            }
            else {
                DispatchQueue.main.async {
                    //self.navigationItem.title = "Not Hotdog!"
                    self.navigationItem.title = results[0].identifier
                    self.navigationController?.navigationBar.barTintColor = UIColor.red
                    self.navigationController?.navigationBar.isTranslucent = false
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        /*
         The UIImage is being converted to a CIImage so that it can be used in the detect(image:) method. This custom method utilizes Core Image's capabilities for some form of image analysis or processing, which requires the image to be in the CIImage format.
         */
        
        
        if let image = info[.originalImage] as? UIImage {
            
            imageView.image = image // only for confirmation purpose!
            imagePicker.dismiss(animated: true, completion: nil)
            guard let ciImage = CIImage(image: image) else {
                fatalError("couldn't convert uiimage to CIImage")
            }
	            detect(image: ciImage)  //custom method
        }
    }
    
    
    @IBAction func cameraTapped(_ sender: Any) {
        
        //Camera is disabled for the simulator
        
        //imagePicker.sourceType = .camera
        imagePicker.sourceType =  UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
