//
//  RegisterViewController.swift
//  Milaap
//
//  Created by dmc on 20/01/18.
//  Copyright © 2018 CDAC-DMC. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        indicator.isHidden = true
        
    }

    @IBAction func actionBackToLogin(_ sender: Any) {
        
        let loginCon = self.storyboard?.instantiateViewController(withIdentifier: "loginnavigation") as! UINavigationController
        
        self.present(loginCon, animated: true, completion: nil)
        
    }
   
    @IBAction func actionRegister(_ sender: Any) {
        
        let firstName = firstNameField!.text!
        let lastName = lastNameField!.text!
        let email = emailField!.text!
        let password = passwordField!.text!
        let confirmPassword = confirmPasswordField!.text!

        
        if(!(firstName == "" || lastName == "" || email == "" || password == "" || confirmPassword == ""))
        {
        indicator.isHidden = false
        indicator.startAnimating()
        
            
        if(password ==  confirmPassword)
        {
            //check the length of password for validation
            if(password.characters.count > 7)
            {
                //we finally send data to server
                
                let URLString = "http://salty-sea-56469.herokuapp.com/register"
                
                var registerCredentials = Dictionary<String,Any>()
                
                registerCredentials["fname"] = firstName
                registerCredentials["lname"] = lastName
                registerCredentials["email"] = email
                registerCredentials["pass"] = password
                
                do
                {
                let jsonData = try JSONSerialization.data(withJSONObject: registerCredentials, options: JSONSerialization.WritingOptions.prettyPrinted)
                
                let url = URL(string: URLString)
                
                var request = URLRequest(url: url!)
                    
                request.httpMethod = "POST"
                request.httpBody = jsonData
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue(String(jsonData.count), forHTTPHeaderField: "Content-Length")
                
                request.timeoutInterval = 60
                    
                let session  = URLSession.shared
                    
                    let task = session.dataTask(with: request, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) in
                        
                        print("-----------------------------Response",response!)
                        //print("---------------------------- Data : ",data!)
                        
                        if(error == nil && data != nil)
                        {
                            
                            do
                            {
                                
                                //--------------------------------------- CHANGE THE CASTING HERE ----------------------------------------------
                                let responseFromServerUponRegisteration = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:Any]
                                
                                print("---------------------DATA------------------ :  ",responseFromServerUponRegisteration)
                                
                                 if responseFromServerUponRegisteration["error"] != nil
                                 {
                                    let errorKey = responseFromServerUponRegisteration["error"] as! String
                                    
                                    //Email Id already exists
                                    if(errorKey == "1")
                                    {
                                        DispatchQueue.main.async {
                                           
                                            self.indicator.stopAnimating()
                                            self.indicator.isHidden = true
                                            
                                            let alert = UIAlertController(title: "User Already registered", message: "User with this email ID already exists , Please Login or try another Email ID for registeration", preferredStyle: UIAlertControllerStyle.alert)
                                            
                                            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
                                            
                                                self.emailField!.text = ""
                                                self.passwordField!.text = ""
                                                self.confirmPasswordField!.text = ""
                                                
                                                self.emailField.becomeFirstResponder()
                                                alert.dismiss(animated: true, completion: nil)
                                                
                                            })
                                            
                                            alert.addAction(okAction)
                                            
                                            self.present(alert, animated: true, completion: nil)
                                        }
                                    }
                                    
                                    //some other exception raised at server
                                    if(errorKey == "5" )
                                    {
                                        DispatchQueue.main.async {
                                            
                                            self.indicator.stopAnimating()
                                            self.indicator.isHidden = true
                                            
                                            let alert = UIAlertController(title: "Error Occured", message: "Some Error occured while connecting to the database , Please try again later", preferredStyle: UIAlertControllerStyle.alert)
                                            
                                            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
                                                
                                                self.firstNameField!.text = ""
                                                self.lastNameField!.text = ""
                                                self.emailField!.text = ""
                                                self.passwordField!.text = ""
                                                self.confirmPasswordField!.text = ""
                                                
                                                self.firstNameField.becomeFirstResponder()
                                                alert.dismiss(animated: true, completion: nil)
                                                
                                            })
                                            
                                            alert.addAction(okAction)
                                            
                                            self.present(alert, animated: true, completion: nil)
                                            
                                        }
                                    }
                                 }
                                
                                if responseFromServerUponRegisteration["success"] != nil
                                {
                                DispatchQueue.main.async {
                                    
                                    self.indicator.stopAnimating()
                                    self.indicator.isHidden = true
                                    
                                    let alert = UIAlertController(title: "Registered", message: "You have been Successfullt registered , Please click 'Ok' to login into your account ", preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                                        alert.dismiss(animated: true, completion: nil)
                                        
                                        let loginCon = self.storyboard?.instantiateViewController(withIdentifier: "loginnavigation") as! UINavigationController
                                        
                                        self.present(loginCon, animated: true, completion: nil)
                                    })
                                    
                                    alert.addAction(okAction)
                                    
                                    self.present(alert, animated: true, completion: nil)
                                }
                                
                               }
                            }
                            catch
                            {
                                print("----------------- ERROR IN CONVERTING DATA FROM JSON TO STRING--------------------",error)
                                
                                
                                
                            }
                            
                            
                        }
                        
                    })
                    
                    task.resume()
                        
            
                
                }
                catch
                {
                    print("-------------------------------- Exception in Writing data to server--------------- ",error)
                }
                
        
                
            }
            else
            {
                //password is less than 8 characters
                
                indicator.stopAnimating()
                indicator.isHidden = true
                
                passwordField!.text = ""
                confirmPasswordField!.text = ""
                
                passwordField.becomeFirstResponder() //sets the pointer to password field
                
                let alert = UIAlertController(title: "Oops!", message: "Your Password must be atleast 8 characters long", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
                    
                    alert.dismiss(animated: true, completion: nil)
                    
                })
                
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        else
        {
            //password and confirm password does not match
            
            indicator.stopAnimating()
            indicator.isHidden = true
            
            passwordField!.text = ""
            confirmPasswordField!.text = ""
            
            passwordField.becomeFirstResponder() //sets the pointer to password field
            
            let alert = UIAlertController(title: "Oops!", message: "Your Password and Confirm Password field does not match", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
                
                alert.dismiss(animated: true, completion: nil)
                
            })
            
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
      
      }
        else
        {
            //if any field is left empty
            
            let alert = UIAlertController(title: "Can't leave empty fields", message: "Please enter all the fields as all fields are mandatory", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
                
                alert.dismiss(animated: true, completion: nil)
                
            })
            
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    
    }
    
}

    


