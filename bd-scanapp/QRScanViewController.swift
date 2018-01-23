//
//  QRScanViewController.swift
//  bd-scanapp
//
//  Created by Hessel Bierma on 19/12/2017.
//  Copyright © 2017 Bedrijvendagen Twente. All rights reserved.
//

import UIKit
import AVFoundation

class QRScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    //---------UI element connections--------//
    @IBOutlet var previewView: UIView!
    
    //---------------------------------------//
    
    //--------------------Variables-------------------//
    var splitCode:[String] = []
    var person = API.QRparameters()
    var captureSession: AVCaptureSession?   //initialize a capturesession
    var videoPreviewLayer: AVCaptureVideoPreviewLayer? //initialize the previewlayer
    //---------------------------------------//
    
    //-------------------UI interaction functions--------------------//
    @IBAction func unwindToQR(segue: UIStoryboardSegue){} //provide function for unwind segue reference
    
    @IBAction func manualInputPressed(_ sender: UIButton) {
        person.fname = ""
        person.lname = ""
        person.uid = 0
        person.email = ""
        self.performSegue(withIdentifier: "toManualInput", sender: nil)
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    //---------------------------------------//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        let videoCaptureDevice = AVCaptureDevice.default(for: .video) //define which device is to be used for the videocapture
        let videoInput: AVCaptureDeviceInput //initialize videoInput as a capturedevice
        do{videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice!)} //put the output from the capturedevice into the videoinput
        catch{return}
        captureSession?.addInput(videoInput)
        
        let metadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(metadataOutput)//add an output for the metadata triggering
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr] //trigger on QR codes in Metadata
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!) //put the videocapture in the previewlayer
        videoPreviewLayer?.frame = view.layer.bounds
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resize //define the way the previewlayer resizes
        previewView.layer.addSublayer(videoPreviewLayer!) //put the previewlayer into the view
        
        captureSession?.startRunning() //start capturing
        
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession?.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            DispatchQueue.main.async {
                self.found(code: stringValue)
            }
        }
        return
    }
    class dataManager{
        var QRPasser = String()
    }
    
    let QR = dataManager()
    
    func found(code: String) { //function that handles when a QR code is recognised
        let splitCode = code.split(separator: ";", omittingEmptySubsequences: false) //separate the information in the qr code separated by ;
        QR.QRPasser = code
        
        if (code.prefix(2).contains("bd")){ //check if the code is a Bedrijvendagen QR code
            person.uid = Int(splitCode[1])!
            person.email = String(splitCode[2])
            person.fname = String(splitCode[3])
            person.lname = String(splitCode[4]) //put the credentials in an instance of the class, to be sent to next vc
            
            if (splitCode[2] == "Y"){
                DispatchQueue.main.async{
                    self.performSegue(withIdentifier: "toComment", sender: nil) //check if email is known and segue to comment vc
                }
            }else{
                DispatchQueue.main.async{
                    self.person.email = ""
                    self.performSegue(withIdentifier: "toManualInput", sender: nil) //otherwise segue to manual input for
                }
            }
        }else{
            DispatchQueue.main.async{
                self.person.uid = 0
                self.person.email = ""
                self.person.fname = ""
                self.person.lname = ""
                self.performSegue(withIdentifier: "toManualInput", sender: nil)
            }
        }
        return
    }
    
    // this function handles the last actions before switching to the next VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ManualInputViewController{
            let DestVC = segue.destination as! ManualInputViewController
            if QR.QRPasser.prefix(2) == "bd"{
                DestVC.person = person
            }else{
                person.uid = 0
                person.email = ""
                DestVC.person = person
            }
        }else if segue.destination is CommentViewController{ //if destination is comment view, it means there is a known email address
            let DestVC = segue.destination as! CommentViewController
            DestVC.person = person
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession?.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession?.stopRunning()
        }
    }

}
