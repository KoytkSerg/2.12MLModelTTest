//
//  ViewController.swift
//  2.12MLModelTTest
//
//  Created by Sergii Kotyk on 18/1/2022.
//

import UIKit
import CoreML
import Vision


class AnimalClassifierController: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    
    @IBAction func takePhotoAction(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    

    var imagePicker: ImagePicker!
    
    func handleResult(request: VNRequest, error: Error? ) {
        if let classificationresult = request.results as? [VNClassificationObservation] {
            DispatchQueue.main.async {
                let confidence = "\(round(classificationresult.first!.confidence * 100 * 100) / 100)%"
                self.infoLabel.text = "это \(classificationresult.first!.identifier) на \(confidence)"
                print(classificationresult.first!.identifier)
            }
        }
        else {
            print("Unable to get the results")
        }
    }
    
    func mlrequest() -> VNCoreMLRequest {
        var myrequest: VNCoreMLRequest?
        let modelobj = AnimalClassifier()
        do {
            let animalmodel = try VNCoreMLModel(for: modelobj.model)
            myrequest = VNCoreMLRequest(model: animalmodel, completionHandler: {(request, error) in self.handleResult(request: request, error: error)
            })
        } catch {
            print("Unable to create a request")
        }
        myrequest!.imageCropAndScaleOption = .centerCrop
        return myrequest!
    }
    
    func excecuteRequest(image: UIImage) {
        guard let ciImage = CIImage(image: image)
        else {
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage)
            do {
                try handler.perform([self.mlrequest()])
            } catch {
                print("Failed to get the description")
            }
        }
    } 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
     
    }


}

extension AnimalClassifierController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        self.mainImage.image = image
        self.excecuteRequest(image: image!)
    }
}
