//
//  ManualInputViewController.swift
//  bd-scanapp
//
//  Created by Hessel Bierma on 19/12/2017.
//  Copyright © 2017 Bedrijvendagen Twente. All rights reserved.
//

import UIKit

class ManualInputViewController: UIViewController {

    //--------------UI Outlets----------------------------//
    @IBOutlet var logoHeight: NSLayoutConstraint!
    @IBOutlet var fNameTextField: UITextField!
    @IBOutlet var lNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    //---------------------------------------------------------//
    
    //----------------Variables-----------------------//

    var person = API.QRparameters()

    let prev = dataManager()
    //---------------------------------------------------------//
    
    //--------------------------UI functions-------------------------------//
    @IBAction func unwindToManualInput(segue: UIStoryboardSegue){}
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func fnamePrimaryActionTriggered(_ sender: Any) {
        lNameTextField.becomeFirstResponder()
    }
    
    @IBAction func lnamePrimaryActionTriggered(_ sender: Any) {
        emailTextField.becomeFirstResponder()
    }
    
    @IBAction func emailPrimaryActionTriggered(_ sender: Any) {
        if (emailTextField.text?.isEmpty)! || (fNameTextField.text?.isEmpty)! || (lNameTextField.text?.isEmpty)! {
            let controller = UIAlertController(title: "One or more fields are empty", message: "Please fill in all fields", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            controller.addAction(ok)
            present(controller, animated: true, completion: nil)
        }else{
            //check if email field is not empty and contains a @ and a dot to verify if it is a valid email address
            if (emailTextField.text?.range(of: "@") != nil && emailTextField.text?.range(of: ".") != nil){
                //if true, put these values in the "person" variable.
                person.fname = fNameTextField.text!
                person.lname = lNameTextField.text!
                person.email = emailTextField.text!
                self.performSegue(withIdentifier: "toComment", sender: nil)
            }else{
                //otherwise show a warning
                let controller = UIAlertController(title: "Invalid E-mail Address", message: "Please provide a valid e-mail address", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                controller.addAction(ok)
                present(controller, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func submitPressed(_ sender: UIButton) {
        if (emailTextField.text?.isEmpty)! || (fNameTextField.text?.isEmpty)! || (lNameTextField.text?.isEmpty)! {
            let controller = UIAlertController(title: "One or more fields are empty", message: "Please fill in all fields", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            controller.addAction(ok)
            present(controller, animated: true, completion: nil)
        }else{
            //check if email field is not empty and contains a @ and a dot to verify if it is a valid email address
            if (emailTextField.text?.range(of: "@") != nil && emailTextField.text?.range(of: ".") != nil){
                //if true, put these values in the "person" variable.
                person.fname = fNameTextField.text!
                person.lname = lNameTextField.text!
                person.email = emailTextField.text!
                self.performSegue(withIdentifier: "toComment", sender: nil)
            }else{
                //otherwise show a warning
                let controller = UIAlertController(title: "Invalid E-mail Address", message: "Please provide a valid e-mail address", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                controller.addAction(ok)
                present(controller, animated: true, completion: nil)
            }
        }
    }
    //---------------------------------------------------------//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardNotifications()
        prev.height = logoHeight.constant

        fNameTextField.text = person.fname
        if person.fname != ""{
            fNameTextField.isUserInteractionEnabled = false
        }
        lNameTextField.text = person.lname
        if person.lname != ""{
            lNameTextField.isUserInteractionEnabled = false
        }
    }
    
    //-----------------change background of textboxes when editing---------------------------//
    @IBAction func fNameEditing(_ sender: UITextField) {
        fNameTextField.background = #imageLiteral(resourceName: "balk")
    }
    @IBAction func fNameNotEditing(_ sender: UITextField) {
        fNameTextField.background = #imageLiteral(resourceName: "balk-z")
    }
    @IBAction func lNameEditing(_ sender: UITextField) {
        lNameTextField.background = #imageLiteral(resourceName: "balk")
    }
    @IBAction func lNameNotEditing(_ sender: UITextField) {
        lNameTextField.background = #imageLiteral(resourceName: "balk-z")
    }
    @IBAction func emailEditing(_ sender: UITextField) {
        emailTextField.background = #imageLiteral(resourceName: "balk")
    }
    @IBAction func emailNotEditing(_ sender: UITextField) {
        emailTextField.background = #imageLiteral(resourceName: "balk-z")
    }
    //---------------------------------------------------------//
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return (true)
    }
    
    //-----------------change height of bd logo when keyboard is up---------------------------//
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    class dataManager{      //datamanager to pass data between functions
        var height = CGFloat()
    }
    
    @objc func keyboardWasShown(notification: NSNotification){
        logoHeight.constant = 0
    }
    @objc func keyboardWillBeHidden(notification: NSNotification){
        logoHeight.constant = prev.height
    }
    //-----------------------------------------------------------//

    //send person info to next vc
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! CommentViewController
        destVC.person = person
    }
    
    //check internet connection when vc is shown
    override func viewDidAppear(_ animated: Bool) {
        if Reachability.isConnectedToNetwork() != true {
            let controller = UIAlertController(title: "No Internet Detected", message: "This app requires an Internet connection", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            controller.addAction(ok)
            
            present(controller, animated: true, completion: nil)
        }
    }
}
