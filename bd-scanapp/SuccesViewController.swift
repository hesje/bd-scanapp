//
//  SuccesViewController.swift
//  bd-scanapp
//
//  Created by Hessel Bierma on 19/12/2017.
//  Copyright © 2017 Bedrijvendagen Twente. All rights reserved.
//

import UIKit

class SuccesViewController: UIViewController {

    @IBOutlet var progressRing: UICircularProgressRingView!
    @IBOutlet var wasAddedLabel: UILabel!
    
    var person = API.QRparameters()
    
    var animationduration : TimeInterval = 3 //time that the progressbar takes to fill the bar
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scanSucceeded = true
        wasAddedLabel.text = "\(person.fname)" + " was added" //set label to "<person> was added"
        
        _ = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(startProgressBar), userInfo: nil, repeats: false) //execute startProgressBar when timer has run out
    }
    
    @objc func startProgressBar(){
        progressRing.setProgress(value: 100.0, animationDuration: animationduration, completion: GoBackToHome) //make progressbar animate to 100% in 3 seconds
    }
    
    @objc func GoBackToHome(){
        self.performSegue(withIdentifier: "unwindToHomeView", sender: nil) //after finishing progressbar fill, segue back to home
    }
    
}
