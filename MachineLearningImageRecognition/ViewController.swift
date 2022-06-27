//
//  ViewController.swift
//  MachineLearningImageRecognition
//
//  Created by busraguler on 20.06.2022.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    
    @IBOutlet weak var RequestLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var chosenImage = CIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func recognitionClicked(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
        
        
        if let ciImage = CIImage(image: imageView.image!){  //ciImage  CoreMl tarafından kullanılabilecek bir görsel
            chosenImage = ciImage
        }
        recognizeImage(image: chosenImage)
    }
    
    
    //request  işlemi
    func recognizeImage(image : CIImage){
        
        if let model = try? VNCoreMLModel(for: MobileNetV2().model){
            let request = VNCoreMLRequest(model: model)  { (vnrequest, error ) in
                if let results = vnrequest.results as? [VNClassificationObservation] {
                    //görsel analiiznin sonucunda istenilen sınıflandırma
                    if results.count > 0{
                        let topresults = results.first //ilk sonucu gösterir
                        DispatchQueue.main.async {
                            let confidenceLevel = (topresults?.confidence ?? 0) * 100
                            let rounded = Int(confidenceLevel * 100) / 100
                            self.RequestLabel.text = " \(rounded)% it's  \(topresults!.identifier)"
                            
                        }
                    }
          
                }
                
            }
            
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                do{
                    try handler.perform([request])
                }catch{
                    print("error")
                }
                
            }
        }
        
        
        
    }

}

