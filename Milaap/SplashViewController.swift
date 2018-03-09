//
//  SplashViewController.swift
//  Milaap
//
//  Created by dmc on 18/01/18.
//  Copyright © 2018 CDAC-DMC. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    var email:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

      
        
    }

    override func viewDidAppear(_ animated: Bool) {
        // Do any additional setup after loading the view.
        let userDef = UserDefaults.standard
        
        email = userDef.object(forKey: "email") as? String
        
        if(email == nil)
        {
            let loginCon = self.storyboard?.instantiateViewController(withIdentifier: "loginnavigation") as! UINavigationController
            
            self.present(loginCon, animated: true, completion: nil)
        }
        else
        {
            let mapCon = self.storyboard?.instantiateViewController(withIdentifier: "tabs") as! UITabBarController
            
            self.present(mapCon, animated: true, completion: nil)
            
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
