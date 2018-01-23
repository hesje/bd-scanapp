//
//  FailAgainViewController.swift
//  bd-scanapp
//
//  Created by Hessel Bierma on 19/12/2017.
//  Copyright © 2017 Bedrijvendagen Twente. All rights reserved.
//

import UIKit

class FailAgainViewController: UIViewController {

    @IBAction func returnHomePressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "unwindToHome", sender: nil) //segue to home view when button is pressed.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
