//
//  LoginViewController.swift
//  bd-scanapp
//
//  Created by Hessel Bierma on 19/12/2017.
//  Copyright © 2017 Bedrijvendagen Twente. All rights reserved.
//

//-----------------global variables----------------------//
var companyName : String = String()
var authToken : String = String()
var passHash : String = String()
var username : String = String()
//---------------------------------------//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    //----------------UI connection outlets-----------------------//
    @IBAction func unwindToLogInView(segue: UIStoryboardSegue){}
    @IBOutlet var logoHeight: NSLayoutConstraint!
    @IBOutlet var topLogo: UIImageView!
    @IBOutlet var userName: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var logInLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    //---------------------------------------//
    
    //-----------------Variables----------------------//
    let prev = dataManager()
    //---------------------------------------//
    
    //-----------------UI functions----------------------//
    //change background of textbox when the text is being edited
    @IBAction func usernameEditing(_ sender: UITextField) {
        userName.background = #imageLiteral(resourceName: "balk")
    }
    @IBAction func usernameNotEditing(_ sender: UITextField) {
        userName.background = #imageLiteral(resourceName: "balk-z")
    }
    @IBAction func passwordEditing(_ sender: UITextField) {
        password.background = #imageLiteral(resourceName: "balk")
    }
    @IBAction func passwordNotEditing(_ sender: UITextField) {
        password.background = #imageLiteral(resourceName: "balk-z")
    }
    @IBAction func LogInPressed(_ sender: UIButton) {
        tryLogin()
    }
    @IBAction func emailPrimaryActionTriggered(_ sender: Any) {
        password.becomeFirstResponder()
    }
    @IBAction func passwordPrimaryActionTriggered(_ sender: Any) {
        tryLogin()
    }
    
    //when lostpassword is pressed, open safari and give possibility to reset password
    @IBAction func LostPasswordPressed(_ sender: UIButton) {
        if let url = NSURL(string: "https://www.bedrijvendagentwente.nl/auth/front/accounts/lostPassword"){
            UIApplication.shared.open(url as URL)
        }
    }
    //---------------------------------------//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardNotifications() //enable the functions that shrink the topLogo when keyboard is up
        prev.height = logoHeight.constant //remember the height of the logo for future reference
        activityIndicator.isHidden = true //hide the activity indicator when not loading
        self.password.delegate = self
        self.userName.delegate = self
    }

    //-------lower keyboard when user presses outside of textfield or keyboard or presses return key
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return (true)
    }
    
    @objc func keyboardWasShown(notification: NSNotification){
        logoHeight.constant = 0
        if topLogo.image == #imageLiteral(resourceName: "Fail"){
            topLogo.image = #imageLiteral(resourceName: "Logo")
            logInLabel.text = "LOG IN HERE"
        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        logoHeight.constant = prev.height
    }
    //------------------------------------------------------
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //class that stores logo height
    class dataManager{
        var height = CGFloat()
    }  
    
    override func viewDidAppear(_ animated: Bool) {
        
        //function to check if there is an active internet connection, otherwise notify
        if Reachability.isConnectedToNetwork() != true {
            let controller = UIAlertController(title: "No Internet Detected", message: "This app requires an Internet connection", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            controller.addAction(ok)
            
            present(controller, animated: true, completion: nil)
        }
    }
    func tryLogin() {
        activityIndicator.isHidden = false
        activityIndicator.hidesWhenStopped = true   //rotate activityindicator when application is busy logging in
        activityIndicator.startAnimating()
        if topLogo.image ==  #imageLiteral(resourceName: "Fail"){
            topLogo.image =  #imageLiteral(resourceName: "Logo")
        }
        self.view.endEditing(true) //make keyboard go down when log in button is pressed
        username = userName.text!
        passHash = (password.text?.sha1())! //hash the password in SHA1 format
        let url = URL(string: "https://www.bedrijvendagentwente.nl/auth/api/accounts/session")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")    //set request headers
        request.setValue("XmlHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.httpMethod = "POST"     //set request method
        let parameters = ["email":"\(username)","password":"\(passHash)"]
        guard let logindata = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return }
        request.httpBody = logindata
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                DispatchQueue.main.async {
                    self.topLogo.image =  #imageLiteral(resourceName: "Fail")
                    self.logInLabel.text = "WRONG CREDENTIALS"  //if the credentials are invalid (HTTP401) set the picture to the red cross and change the title to "wrong credentials"
                }
            } else{
                do{
                    let User = try JSONDecoder().decode(API.loginItem.self, from: data)
                    companyName = User.company_name
                    authToken = User._csrf      //when logging in is succesfull store the token and companyname
                }catch{
                    print("error in serialization")
                }
                DispatchQueue.main.async{
                    self.performSegue(withIdentifier: "toHome", sender: nil) //after logging in segue to the home view
                }
            }
        }
        task.resume()
        
        activityIndicator.stopAnimating() //stop the activity indicator
        activityIndicator.isHidden = true
    }
}

//String Extension to use SHA1 hashing.
extension String {
    func sha1() -> String {
        let data = self.data(using: String.Encoding.utf8)!
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
    
}
