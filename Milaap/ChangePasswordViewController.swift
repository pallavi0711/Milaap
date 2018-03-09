//
//  ChangePasswordViewController.swift
//  Milaap
//
//  Created by dmc on 24/01/18.
//  Copyright © 2018 CDAC-DMC. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var currentPasswordField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var confirmNewPasswordField: UITextField!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    let userDef = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        indicator.isHidden = true
    }

    @IBAction func actionUpdatePassword(_ sender: Any) {
        
        indicator.isHidden = false
        indicator.startAnimating()
        
        let currentPassword = currentPasswordField!.text!
        let newPassword = newPasswordField!.text!
        let confirmNewPassword = confirmNewPasswordField!.text!
        
        if !(currentPassword=="" || newPassword=="" || confirmNewPassword=="" )
        {
        if newPassword == confirmNewPassword
        {
            let passwordFetchedFromUserDefault = userDef.object(forKey: "password") as! String
            let userIdFetchedFromUserDefault = userDef.object(forKey: "user_id") as! Int
            
            if currentPassword == passwordFetchedFromUserDefault
            {
            
                var updatedPasswordSendToServer = [String:Any]()
                
                updatedPasswordSendToServer["id"] = userIdFetchedFromUserDefault
                updatedPasswordSendToServer["pass"] = newPassword
                print("------------- ID SENT TO SERVER : ",updatedPasswordSendToServer["id"] as! Int)
                print("------------- PASSWORD SENT TO SERVER : ",updatedPasswordSendToServer["pass"] as! String)
                
                do {
                    let updatedDataToJson = try JSONSerialization.data(withJSONObject: updatedPasswordSendToServer, options: JSONSerialization.WritingOptions.prettyPrinted)
                    
                    let URLString = "http://salty-sea-56469.herokuapp.com/update_password"
                    
                    let url = URL(string: URLString)
                    
                    var request = URLRequest(url: url!)
                    request.httpMethod = "POST"
                    
                    request.httpBody = updatedDataToJson
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.addValue(String(updatedDataToJson.count), forHTTPHeaderField: "Content-Length")
                    
                    let session = URLSession.shared
                    
                    let task = session.dataTask(with: request, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) in
                        
                        do
                        {
                        let dataFetchedFromServer = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:Any]
                            
                        print("-------------------------- DATA FETCHED FROM SERVER :",dataFetchedFromServer)
                            
                            if dataFetchedFromServer["success"] != nil
                            {
                                
                                DispatchQueue.main.async {
                                    
                                    self.indicator.stopAnimating()
                                    self.indicator.isHidden = true
                                    
                                    
                                    self.userDef.removeObject(forKey: "email")
                                    self.userDef.removeObject(forKey: "firstname")
                                    self.userDef.removeObject(forKey: "lastname")
                                    self.userDef.removeObject(forKey: "user_id")
                                    self.userDef.removeObject(forKey: "password")
                                    
                                    let alert = UIAlertController(title: "Password Updated", message: "Your password has been sucessfully updated , you now need to login", preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
                                        
                                        self.currentPasswordField!.text = ""
                                        self.newPasswordField!.text = ""
                                        self.confirmNewPasswordField!.text = ""
                                        
                                        alert.dismiss(animated: true, completion: nil)
                                        
                                        let splashViewCon = self.storyboard?.instantiateViewController(withIdentifier: "splashview") as! SplashViewController
                                        
                                        self.present(splashViewCon, animated: true, completion: nil)
                                        
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
                                    
                                    let alert = UIAlertController(title: "Oops", message: "Some error occured while updating your password, please try again later", preferredStyle: UIAlertControllerStyle.alert)
                                    
                                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
                                        
                                        self.currentPasswordField!.text = ""
                                        self.newPasswordField!.text = ""
                                        self.confirmNewPasswordField!.text = ""
                                        
                                        alert.dismiss(animated: true, completion: nil)
                                        
                                    })
                                    
                                    alert.addAction(okAction)
                                    
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                            
                        }
                        catch
                        {
                            print("------------------------------- ERROR IN FETCHING DATA FROM SERVER ----------------------------")
                        }
                        
                    })
                    
                    task.resume()
                    
                } catch  {
                    print("------------------------- ERROR IN WRITING DATA TO SERVER ---------------------------")
                }
                
            }
            else
            {
                indicator.stopAnimating()
                indicator.isHidden = true
                
                let alert = UIAlertController(title: "Invalid Password", message: "Old and current password does not match", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
                    
                    self.currentPasswordField!.text = ""
                    self.newPasswordField!.text = ""
                    self.confirmNewPasswordField!.text = ""
                    
                    alert.dismiss(animated: true, completion: nil)
                    
                })
                
                alert.addAction(okAction)
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        else
        {
            
            indicator.stopAnimating()
            indicator.isHidden = true
            
            let alert = UIAlertController(title: "Password Mismatch", message: "Password and confirm password does not match", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
                
                self.currentPasswordField!.text = ""
                self.newPasswordField!.text = ""
                self.confirmNewPasswordField!.text = ""
                
                alert.dismiss(animated: true, completion: nil)
                
            })
            
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    else
    {
        indicator.stopAnimating()
        indicator.isHidden = true
        
        let alert = UIAlertController(title: "Can't leave the field empty", message: "Can't leave any field empty", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
            
            alert.dismiss(animated: true, completion: nil)
            
        })
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
  }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
