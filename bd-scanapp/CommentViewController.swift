//
//  CommentViewController.swift
//  bd-scanapp
//
//  Created by Hessel Bierma on 19/12/2017.
//  Copyright © 2017 Bedrijvendagen Twente. All rights reserved.
//

var firstTry : Bool = Bool()

import UIKit

class CommentViewController: UIViewController, UITextViewDelegate {
    
    //UI element outlets
    @IBOutlet var studentNameLabel: UILabel!
    @IBOutlet var commentTextView: UITextView!
    @IBOutlet var logoHeight: NSLayoutConstraint!
    
    //Variables
    let prev = dataManager()
    var person = API.QRparameters()
    
    @IBAction func submitPressed(_ sender: UIButton) {
        person.comment = commentTextView.text
        self.performSegue(withIdentifier: "toLoading", sender: nil) //when the submit button has been pressed, segue to the loading view
    }

    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        if person.email == "Y"{
            self.performSegue(withIdentifier: "unwindToQR", sender: nil)
        }else{
            self.performSegue(withIdentifier: "unwindToManualInput", sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstTry = true //reset firsttry when vc is loaded
        studentNameLabel.text = person.fname + " " + person.lname //set the label to the students name
        registerForKeyboardNotifications() //enable keyboard notifications --> bd logo goes away/returns
        
        //comment text field style change-------------------
        commentTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        commentTextView.layer.borderWidth = 1.0
        commentTextView.layer.cornerRadius = 5
        commentTextView.text = "Add Comment..."
        commentTextView.textColor = UIColor.lightGray
        //--------------------------------------------------
        
        prev.height = logoHeight.constant  //register prev. height of bd logo to put it back at the same height
    }
    
    class dataManager{
        var height = CGFloat()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is LoadingViewController{
            let destVC = segue.destination as! LoadingViewController
            destVC.person = person
        }
    }
    
    //-----------------------make keyboard go down when touches outside text field----------------------------------//
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){self.view.endEditing(true)}
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {textField.resignFirstResponder();return (true)}
    
    func registerForKeyboardNotifications(){
        //Adding notifications on keyboard appearing and disappearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    //to execute when keyboard waw shown
    @objc func keyboardWasShown(notification: NSNotification){
        logoHeight.constant = 0
        if commentTextView.textColor == UIColor.lightGray{
            commentTextView.text = nil
            commentTextView.textColor = UIColor.black
        }
        commentTextView.layer.borderColor = UIColor(red: 0.129, green: 0.62, blue: 0.847, alpha: 1.0).cgColor
    }
    //to execute when keyb. will be hidden
    @objc func keyboardWillBeHidden(notification: NSNotification){
        logoHeight.constant = prev.height
        if commentTextView.text.isEmpty{
            commentTextView.text = "Add Comment..."
            commentTextView.textColor = UIColor.lightGray
        }
        commentTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
    }
    //---------------------------------------------------------//
    
    override func viewDidAppear(_ animated: Bool) {
        //check internet connection
        if Reachability.isConnectedToNetwork() != true {
            let controller = UIAlertController(title: "No Internet Detected", message: "This app requires an Internet connection", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            controller.addAction(ok)
            
            present(controller, animated: true, completion: nil)
        }
    }

}
