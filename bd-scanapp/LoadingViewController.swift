//
//  LoadingViewController.swift
//  bd-scanapp
//
//  Created by Hessel Bierma on 19/12/2017.
//  Copyright © 2017 Bedrijvendagen Twente. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet var loadingImage: UIImageView!
    @IBAction func retryDataSending(segue: UIStoryboardSegue){}
    
    let api = API()
    var person = API.QRparameters()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //rotate the loading image
        rotate360Degrees()
    }
    
    func uploadNewEntry() {
        let url = URL(string: "https://www.bedrijvendagentwente.nl/companies/api/student_signups")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") //set headers
        request.setValue("XmlHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.setValue("{\(authToken)}", forHTTPHeaderField: "X-Csrf-Token")
        request.httpMethod = "POST" //set request method
        
        if person.email == "Y" { //when email is known, send user ID and comment
            let parameters = ["account_id":person.uid,"comments":"\(person.comment)"] as [String : Any]
            guard let logindata = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
                return }
            request.httpBody = logindata
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let _ = data, error == nil else {                                                 // check for fundamental networking error
                    print("error=\(String(describing: error))")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    DispatchQueue.main.async {
                        if firstTry{
                            self.performSegue(withIdentifier: "toFail", sender: nil)
                        }else{
                            self.performSegue(withIdentifier: "toWrongAgain", sender: nil)
                        }
                    }
                } else{
                    DispatchQueue.main.async{
                        self.performSegue(withIdentifier: "toSuccess", sender: nil)
                    }
                }
            }
            task.resume()
            
        }else{
            if person.uid == 0{
                //when email & user id are not known, send email and comment
                let parameters = ["email":"\(person.email)","comments":"\(person.comment)","name":"\(person.fname + " " + person.lname)"] as [String : Any]
                guard let logindata = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
                    return }
                request.httpBody = logindata
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let _ = data, error == nil else {                                                 // check for fundamental networking error
                        print("error=\(String(describing: error))")
                        return
                    }
                    
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                        DispatchQueue.main.async {
                            if firstTry{ //if this is the first try, go to fail otherwise go to fail again
                                self.performSegue(withIdentifier: "toFail", sender: nil)
                            }else{
                                self.performSegue(withIdentifier: "toWrongAgain", sender: nil)
                            }
                        }
                    } else{
                        DispatchQueue.main.async{
                            self.performSegue(withIdentifier: "toSuccess", sender: nil) //if succes, go to succes view
                        }
                    }
                }
                task.resume()
            }else{
                //when email is unknown, but user id is known
                let parameters = ["email":"\(person.email)","comments":"\(person.comment)","account_id":person.uid] as [String : Any]
                guard let logindata = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
                    return }
                request.httpBody = logindata
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let _ = data, error == nil else {                                                 // check for fundamental networking error
                        print("error=\(String(describing: error))")
                        return
                    }
                    
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                        DispatchQueue.main.async {
                            if firstTry{ //if this is the first try, go to fail otherwise go to fail again
                                self.performSegue(withIdentifier: "toFail", sender: nil)
                            }else{
                                self.performSegue(withIdentifier: "toWrongAgain", sender: nil)
                            }
                        }
                    } else{
                        DispatchQueue.main.async{
                            self.performSegue(withIdentifier: "toSuccess", sender: nil) //if succes, go to succes view
                        }
                    }
                }
                task.resume()
                
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is SuccesViewController{
            let destVC = segue.destination as! SuccesViewController
            destVC.person = person
        }
    }
    
    //rotate the loading image
    func rotate360Degrees(duration: CFTimeInterval = 3) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2)
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount=Float.infinity
        self.loadingImage.layer.add(rotateAnimation, forKey: nil)
    }
    
    //when no internet connection go back to comment view so user can go to settings to connect to wifi etc.
    func backWhenNoInternet(alert: UIAlertAction) {
        dismiss(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {

        if !(scanSucceeded){
            //check internet connection
            if Reachability.isConnectedToNetwork() {
                uploadNewEntry()
            }else{
                if firstTry {
                    self.performSegue(withIdentifier: "toFail", sender: nil)
                }else{
                    self.performSegue(withIdentifier: "toWrongAgain", sender: nil)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        api.AuthCheck(vc: self)
    }
}
