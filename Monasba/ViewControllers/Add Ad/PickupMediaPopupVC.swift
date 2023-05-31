//
//  PickupMediaPopupVC.swift
//  Monasba
//
//  Created by iOSayed on 01/05/2023.
//

import UIKit
import PhotosUI
import MobileCoreServices

protocol PickupMediaPopupVCDelegate: AnyObject {
    func PickupMediaPopupVC(_ controller: PickupMediaPopupVC, didSelectImages images: [UIImage] , videos:[Data])
}

class PickupMediaPopupVC: UIViewController {
 
    weak var delegate: PickupMediaPopupVCDelegate?
    var images = [UIImage]()
    var videos = [Data]()
    //MARK: App LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    //MARK: IBActions
    
    @IBAction func closeBtnAction(_ sender: UIButton) {
        print("closeBtnAction")
        dismiss(animated: false)
        
    }
    
    @IBAction func openGalleryBtnAction(_ sender: UIButton) {
        print("openGalleryBtnAction")
        openGallery()
        //dismiss(animated: true)
        
        
    }
    
    @IBAction func openVideosBtnAction(_ sender: UIButton) {
        print("openVideosBtnAction")
        openVideoGallery()
        
    }
    
    @IBAction func openCameraBtnAction(_ sender: UIButton) {
        print("openCameraBtnAction")
        openCamera(isRecordVideo: false)

    }
    
    @IBAction func recordVideoBtnAction(_ sender: UIButton) {
        print("recordVideoBtnAction")
        openCamera(isRecordVideo: true)
    }
    
}
extension PickupMediaPopupVC : PHPickerViewControllerDelegate , UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
       
        // empty the images Array
        images = []
        print(results)
        for (_,result) in results.enumerated() {
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                if let image = object as? UIImage {
                    print( "Fooo ",image)
                    let data = image.jpegData(compressionQuality: 0.01)
                    let newImage = UIImage(data: data!)
                    self.images.append(newImage! as UIImage)
//                    self.images.append(image)
                    print(self.images.count)
                }
                DispatchQueue.main.async {
                    self.delegate?.PickupMediaPopupVC(self, didSelectImages: self.images,videos: self.videos)
                    self.dismiss(animated: false)
                }
            }
            
        }
        
        
        dismiss(animated: true,completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            picker.dismiss(animated: true, completion: nil)
            
        if let mediaURL = info[.mediaURL] as? URL {
                   print("Captured video URL: \(mediaURL)")
            //Compress Video
            
            
            do {
                picker.videoQuality = .typeMedium
                let data = try Data(contentsOf: mediaURL, options: .mappedIfSafe)
                print(mediaURL)
                //compress
                let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".mp4")
                var compressedVideo : Data? =  nil
                // Encode to mp4
                compressVideo(inputURL: mediaURL, outputURL: compressedURL, handler: { [weak self] (_ exportSession: AVAssetExportSession?) -> Void in
                                    guard let self = self else {return}


                    switch exportSession!.status {
                        case .completed:

                        print("Video compressed successfully")
                        do {
                            compressedVideo = try Data(contentsOf: exportSession!.outputURL!)
                            print(compressedVideo)
                            guard let compressedVideo = compressedVideo else{return}
                            self.videos.append(compressedVideo)
                        } catch let error {
                            print ("Error converting compressed file to Data", error)
                        }

                        default:
                            print("Could not compress video")
                    }
                } )
                
                // end of compress
                let videoThumbnil = self.generateThumbnail(path: mediaURL)
                guard let videoThumbnil = videoThumbnil else{return}
                self.images.append(videoThumbnil as UIImage)
//                do {
//                    compressedVideo = try Data(contentsOf: compressedURL)
//                    self.videos.append(compressedVideo!)
//                }
            } catch let error {
                print(error)
            }

            
               } else if let capturedImage = info[.originalImage] as? UIImage {
                   print("Captured image: \(capturedImage)")
                   self.images.append(capturedImage as UIImage)
               }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.delegate?.PickupMediaPopupVC(self, didSelectImages: self.images,videos: self.videos)
            self.dismiss(animated: false)
        }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
}
    


@available(iOS 14.0, *)
extension PickupMediaPopupVC {
    
    //MARK: Methods
    private func openGallery(){
        var config = PHPickerConfiguration()
        config.selectionLimit = 6
        if #available(iOS 15.0, *) {
            config.selection = .ordered
        } else {
            // Fallback on earlier versions
        }
        let PHPickerVC = PHPickerViewController(configuration: config)
        PHPickerVC.delegate = self
        present(PHPickerVC, animated: true)
        
    }
    private func openVideoGallery() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.videoMaximumDuration = 30
        present(picker, animated: true, completion: nil)
    }
    
    private func openCamera( isRecordVideo:Bool) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        if isRecordVideo {
            picker.mediaTypes = [kUTTypeMovie as String]
        }else{
            // capture picture
            picker.mediaTypes = [kUTTypeImage as String]
        }
       
        present(picker, animated: true, completion: nil)
    }
    
    func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
                    let urlAsset = AVURLAsset(url: inputURL, options: nil)
                    guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
                        handler(nil)
                        return
                    }

                    exportSession.outputURL = outputURL
        print(outputURL)
        exportSession.outputFileType = AVFileType.mp4
        //AVFileTypeQuickTimeMovie (m4v)
                    exportSession.shouldOptimizeForNetworkUse = true
                    exportSession.exportAsynchronously { () -> Void in
                        handler(exportSession)
                    }
        
                }
    
}
