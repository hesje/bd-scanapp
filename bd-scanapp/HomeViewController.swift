//
//  HomeViewController.swift
//  bd-scanapp
//
//  Created by Hessel Bierma on 19/12/2017.
//  Copyright © 2017 Bedrijvendagen Twente. All rights reserved.
//

import UIKit

var scanSucceeded : Bool = Bool()

class HomeViewController: UIViewController {

    //------------------UI connections---------------------------------
    @IBOutlet var scansLabel: UILabel!
    @IBOutlet var topNavBar: UINavigationItem!
    @IBAction func unwindToHomeView(segue: UIStoryboardSegue){}
    @IBOutlet var label0: UILabel!
    @IBOutlet var label1: UILabel!
    @IBOutlet var label2: UILabel!
    //--------------------------------------------------
    
    //----------------------Variables----------------------------
    let api = API() //instatiate the API
    var labels:[UILabel] = [] //create array of UIlabels
    //--------------------------------------------------

    //----------------------UI functions----------------------------

    //when logout is clicked, send a delete request to the api to invalidate the session.
    @IBAction func LogOutClicked(_ sender: UIBarButtonItem) {
        let url = URL(string: "https://www.bedrijvendagentwente.nl/auth/api/accounts/session")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("XmlHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.setValue("{\(authToken)}", forHTTPHeaderField: "X-Csrf-Token")
        print("{\(authToken)}")
        request.httpMethod = "DELETE"
        _ = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 200 {           // check for http errors
                authToken = ""
                companyName = ""
                passHash = ""
                username = ""
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "ToLogIn", sender: nil) //segue to the login viewcontroller
                }
            }
        }.resume()
    }
    
    //when the qr button is pressed, segue to the qr scanner viewcontroller
    @IBAction func ScanQRButtonPressed(_ sender: UIButton) {
        scanSucceeded = false
        self.performSegue(withIdentifier: "toQR", sender: nil)
    }
    //--------------------------------------------------
    
    //-----------------------functions---------------------------
    //fetch the last three scans for a certain company
    func fetchLastScans() {
        let url = URL(string: "https://www.bedrijvendagentwente.nl/companies/api/student_signups")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("XmlHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.setValue("{\(authToken)}", forHTTPHeaderField: "X-Csrf-Token")
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200{
                print(httpStatus.statusCode)
            } else{
                do{
                    let string1 = String(data: data!, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                    print(string1)
                    let lastScans = try JSONDecoder().decode([lastThreeScans].self, from: data!)
                    DispatchQueue.main.async {
                        for ScanNr in 0...lastScans.count - 1{
                            self.labels[ScanNr].text = lastScans[ScanNr].name //fill the labels with the names of the last three scanned persons.
                        }
                    }
                }catch{
                    print("error in serialization")
                }
            }
        }
        task.resume()
    }
    
    //fetch the total number of scans for a certain company
    func fetchNrOfScans(){
        let url = URL(string: "https://www.bedrijvendagentwente.nl/companies/api/student_signups/count")!
        var request = URLRequest(url: url)
        //set the headers for the request
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("XmlHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.setValue("{\(authToken)}", forHTTPHeaderField: "X-Csrf-Token")
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200{
                
            } else{
                do{
                    let Scans = try JSONDecoder().decode(nrOfScans.self, from: data!)
                    DispatchQueue.main.async {
                        self.scansLabel.text = "Total Scans: \(Scans.count)" //set the number of scans to the label
                    }
                }catch{
                    print("error in serialization")
                }
            }
        }
        task.resume()
    }
    //--------------------------------------------------
    
    
    //----------------------structs for the data receiving format (JSON)----------------------------
    struct nrOfScans : Decodable{
        let count : Int
    }
    struct lastThreeScans : Decodable{
        let name : String?
    }
    
    //--------------------------------------------------
    
    //--------------------preparation functions of vc------------------------------
    override func viewWillAppear(_ animated: Bool) {
        //check internet connectivity, otherwise notification
        if Reachability.isConnectedToNetwork() != true {
            let controller = UIAlertController(title: "No Internet Detected", message: "This app requires an Internet connection", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            controller.addAction(ok)
            
            present(controller, animated: true, completion: nil)
        }
        
        //check if current session is still valid
        //api.AuthCheck(vc: self)
        
        //empty the labels
        self.labels = [label0, label1, label2]
        for i in 0...labels.count-1{
            labels[i].text = ""
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topNavBar.title = companyName //set the title of the navigation bar to the company name
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //fill the labels with the data fetched from the server
        fetchNrOfScans()
        fetchLastScans()
    }
    //--------------------------------------------------
    
}
