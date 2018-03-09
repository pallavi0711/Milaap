//
//  ProfileViewController.swift
//  Milaap
//
//  Created by dmc on 20/01/18.
//  Copyright © 2018 CDAC-DMC. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor.black.cgColor
        
        indicator.isHidden = true
        
        let userDef = UserDefaults.standard
        
        if (userDef.object(forKey: "image") as! String)=="" {
            
            let image = UIImage(named: "defaultProfileImage.png")
            profileImage.image = image
            
        }
        else
        {
            let dataDecoded:NSData = NSData(base64Encoded: userDef.object(forKey: "image") as! String, options: NSData.Base64DecodingOptions(rawValue: 0))!
            let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
            
            profileImage.image = decodedimage
        }
    }

    @IBAction func actionChangePassword(_ sender: Any) {
        
        let changePasswordCon = self.storyboard?.instantiateViewController(withIdentifier: "changepassword") as! ChangePasswordViewController
        
        self.navigationController?.pushViewController(changePasswordCon, animated: true)
        
    }
    @IBAction func actionChangePicture(_ sender: Any) {
      
    
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(myPickerController, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //profileImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    
        self.dismiss(animated: true, completion: nil)
        
        indicator.isHidden = false
        indicator.startAnimating()
        
        //converting image to base 64
        let image:UIImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        
        //let image:UIImage = UIImage(named: "iconEmail.png")!
        
        let imageData = UIImagePNGRepresentation(image)
        
        let base64String = imageData?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        
        //updating image on server
        let str = "http://salty-sea-56469.herokuapp.com/upload_image"
        
        var imageDictionary = [String:Any]()
        
        imageDictionary["id"] = UserDefaults.standard.object(forKey: "user_id")
        imageDictionary["image"] = base64String!
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: imageDictionary, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            let url = URL(string: str)
            
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(String(jsonData.count), forHTTPHeaderField: "Content-Length")
            
            request.timeoutInterval = 60
            
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) in
                
                print("--------------------- RESPONSE :",response!)
                
                let tempResponse:String = String(describing: response!)
                
                if tempResponse.range(of:"status code: 413") != nil {
                    
                    DispatchQueue.main.async {
                        self.indicator.stopAnimating()
                        self.indicator.isHidden = true
                        
                        let alert = UIAlertController(title: "Error", message: "This image is not supported , please try any other image", preferredStyle: UIAlertControllerStyle.alert)
                        
                        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
                            
                            alert.dismiss(animated: true, completion: nil)
                            
                        })
                        
                        alert.addAction(okAction)
                        
                        self.present(alert, animated: true, completion: nil)
                        
                        
                        let dataDecoded:NSData = NSData(base64Encoded: UserDefaults.standard.object(forKey: "image") as! String, options: NSData.Base64DecodingOptions(rawValue: 0))!
                        let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
                        
                        self.profileImage.image = decodedimage
                    }
                    
                }
                else
                {
                    do
                    {
                        let responseFetchedFromServer = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:Any]
                        
                        print("--------------------- RESPONSE FETCHED FROM SERVER :  ",responseFetchedFromServer)
                        
                        if responseFetchedFromServer["error"] != nil
                        {
                            DispatchQueue.main.async {
                                self.indicator.stopAnimating()
                                self.indicator.isHidden = true
                                
                                let alert = UIAlertController(title: "Error", message: "Error while updating image , Please try again later", preferredStyle: UIAlertControllerStyle.alert)
                                
                                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
                                    
                                    alert.dismiss(animated: true, completion: nil)
                                    
                                })
                                
                                alert.addAction(okAction)
                                
                                self.present(alert, animated: true, completion: nil)
                                
                                
                                let dataDecoded:NSData = NSData(base64Encoded: UserDefaults.standard.object(forKey: "image") as! String, options: NSData.Base64DecodingOptions(rawValue: 0))!
                                let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
                                
                                self.profileImage.image = decodedimage
                                
                            }
                        }
                        else
                        {
                            DispatchQueue.main.async {
                                self.indicator.stopAnimating()
                                self.indicator.isHidden = true
                                
                                let alert = UIAlertController(title: "Success", message: "Profile photo successfully updated ", preferredStyle: UIAlertControllerStyle.alert)
                                
                                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
                                    
                                    alert.dismiss(animated: true, completion: nil)
                                    
                                })
                                
                                alert.addAction(okAction)
                                
                                self.present(alert, animated: true, completion: nil)
                                
                                UserDefaults.standard.setValue(base64String!, forKey: "image")
                                
                                let dataDecoded:NSData = NSData(base64Encoded: UserDefaults.standard.object(forKey: "image") as! String, options: NSData.Base64DecodingOptions(rawValue: 0))!
                                let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
                                
                                self.profileImage.image = decodedimage
                            }
                        }
                        
                    }
                    catch
                    {
                        print("----------------------------- ERROR IN RERADING DATA FROM SERVER ---------------------",error)
                    }

                }
                
            })
          
            task.resume()
          
        } catch  {
            print("--------------------- ERROR IN WRITING DATA TO SERVER ------------------------------",error)
        }
        
        
    }
    
    @IBAction func action_signout(_ sender: Any) {
        
        let userDef = UserDefaults.standard
        
        userDef.removeObject(forKey: "email")
        userDef.removeObject(forKey: "firstname")
        userDef.removeObject(forKey: "lastname")
        userDef.removeObject(forKey: "user_id")
        userDef.removeObject(forKey: "password")
        
        let splashCon = self.storyboard?.instantiateViewController(withIdentifier: "splashview") as! SplashViewController
        
        self.present(splashCon, animated: true, completion: nil)
       
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
