//
//  FailViewController.swift
//  bd-scanapp
//
//  Created by Hessel Bierma on 19/12/2017.
//  Copyright © 2017 Bedrijvendagen Twente. All rights reserved.
//

import UIKit

class FailViewController: UIViewController {

    @IBAction func tryAgainPressed(_ sender: UIButton) {
        firstTry = false
        dismiss(animated: true) //try uploading the entry again.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //check for internet connection, so that if the upload failed because of no internet the user is reminded
    override func viewDidAppear(_ animated: Bool) {
        if Reachability.isConnectedToNetwork() != true {
            let controller = UIAlertController(title: "No Internet Connection", message: "Turn on WiFi or cellular in your settings to upload a new entry", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            controller.addAction(ok)
            
            present(controller, animated: true, completion: nil)
        }
    }
    
}
