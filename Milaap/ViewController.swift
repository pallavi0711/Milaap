//
//  ViewController.swift
//  Milaap
//
//  Created by dmc on 18/01/18.
//  Copyright © 2018 CDAC-DMC. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITextFieldDelegate{

    var validLogin:Bool = false
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        indicator.isHidden = true
        
        //done to make sure that when user tap "Return" on keyboard , the keyboard disappear so that it does not hide "Login" button
        self.passwordTextField!.delegate = self
        
    }

    //handler for textField delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return false
    }
    
    @IBAction func actionLogin(_ sender: Any) {
        
        print("-------------- INSIDE LOGIN -----------------")
        
        
        indicator.isHidden = false
        
        indicator.startAnimating()
        
        let email = emailTextField!.text!
        
        let password = passwordTextField!.text!
        
        if(!(email==""||password==""))
        {
        
        let str = "http://salty-sea-56469.herokuapp.com/login"
            
        var loginCredentials = Dictionary<String,Any>()
            
        loginCredentials["email"] = email
        loginCredentials["pass"] = password
            
        do
        {
            print("------------------ Writing Data to server -----------------------")
            
            let jsonData = try JSONSerialization.data(withJSONObject: loginCredentials, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            let url = URL(string: str)
            
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(String(jsonData.count), forHTTPHeaderField: "Content-Length")
            
            request.timeoutInterval = 60
            
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) in
                
                print("-----------------------------Response",response!)
                //print("---------------------------- Data : ",data!)
                
                if(error == nil && data != nil)
                {
                    
                    do
                    {
                        let dictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:Any]
                        
                        print("----------------------------- INSIDE VALID CONDITION--------------------------")
                        
                        print("---------------------DATA------------------",dictionary)
                        
                        
                        if dictionary["error"] != nil
                        {
                            DispatchQueue.main.async {
                                self.indicator.stopAnimating()
                                self.indicator.isHidden = true
                                
                                let alert = UIAlertController(title: "Invalid Credentials", message: "Invalid Email and/or Password", preferredStyle: UIAlertControllerStyle.alert)
                                
                                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
                                    
                                    self.emailTextField!.text = ""
                                    self.passwordTextField!.text = ""
                                    self.emailTextField.becomeFirstResponder()
                                    alert.dismiss(animated: true, completion: nil)
                                    
                                })
                                
                                alert.addAction(okAction)
                                
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                        else
                        {
                        DispatchQueue.main.async {
                            self.indicator.stopAnimating()
                            self.indicator.isHidden = true
                            
                            var image:String = ""
                            
                            if ((dictionary["image"] as? String) != nil) {
                                
                                image = dictionary["image"] as! String
                                
                            }
                            
                            //Adding values to User Defaults so the user does not have to re-login everytime
                            let userDef = UserDefaults.standard
                            
                            userDef.setValue(email, forKey: "email")
                            userDef.setValue(dictionary["firstname"] as! String, forKey: "firstname")
                            userDef.setValue(dictionary["lastname"] as! String, forKey: "lastname")
                            userDef.setValue(dictionary["id"] as! Int, forKey: "user_id")
                            userDef.setValue(password, forKey: "password")
                            userDef.setValue(image, forKey: "image")
                            
                            userDef.synchronize()
                            
                            //print("Data Written to User default ------- Email : \(email) Password : \(password)")
                            
                            //Sending the user to Homepage
                            let mapCon = self.storyboard?.instantiateViewController(withIdentifier: "tabs") as! UITabBarController
                            
                            self.present(mapCon, animated: true, completion: nil)
                        }
                      }
                    }
                    catch
                    {
                        print("----------------- ERROR IN CONVERTING DATA FROM JSON TO STRING--------------------",error)
                        
                        DispatchQueue.main.async {
                            self.indicator.stopAnimating()
                            self.indicator.isHidden = true
                            
                            let alert = UIAlertController(title: "Invalid Credentials", message: "Invalid Email and/or Password", preferredStyle: UIAlertControllerStyle.alert)
                            
                            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
                                
                                self.emailTextField!.text = ""
                                self.passwordTextField!.text = ""
                                self.emailTextField.becomeFirstResponder()
                                alert.dismiss(animated: true, completion: nil)
                                
                            })
                            
                            alert.addAction(okAction)
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                    
                    }
                    
                    
                }
                
            })
            
            task.resume()
        }
        catch
        {
            print("--------------------- ERROR IN WRITING DATA TO SERVER ---------------------",error)
        }
        }
        else
        {
            indicator.stopAnimating()
            indicator.isHidden = true
            
            let alert = UIAlertController(title: "Invalid Credentials", message: "Invalid email and/or password", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
                
                self.emailTextField!.text = ""
                self.passwordTextField!.text = ""
                
                self.emailTextField.becomeFirstResponder();
                alert.dismiss(animated: true, completion: nil)
                
            })
            
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
        }

        
    }
    
    
    @IBAction func actionRegister(_ sender: Any) {
        
        let registerCon = self.storyboard?.instantiateViewController(withIdentifier: "register") as! RegisterViewController
        
        self.present(registerCon, animated: true, completion: nil)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

