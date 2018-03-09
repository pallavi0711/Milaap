//
//  CreateEventViewController.swift
//  Milaap
//
//  Created by dmc on 27/01/18.
//  Copyright © 2018 CDAC-DMC. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import GooglePlacePicker

class CreateEventViewController: UIViewController,UITextFieldDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    
  
    @IBOutlet weak var buttonShowLocation: UIButton!
    
    @IBOutlet weak var Description: UITextView!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    
    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    
    var locManager:CLLocationManager?
    
    var locationLatitude:Double?
    var locationLongitude:Double?
    var locationName:String?
    
    var eventDate:String?
    var eventTime:String?
    
    var imageConvertedToString:String?
    
    var placesClient:GMSPlacesClient!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
//        emailField.leftViewMode = UITextFieldViewMode.always
//        let emailImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
//        let emailImage = UIImage(named: "iconEmail.png")
//        emailImageView.image = emailImage
//        emailField.leftView = emailImageView
        
        Description.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        locManager = CLLocationManager()
        locManager!.requestAlwaysAuthorization()
        locManager!.requestWhenInUseAuthorization()
        
        if locationLatitude==nil && locationLongitude==nil {
            buttonShowLocation.isEnabled = false
            buttonShowLocation.isHidden = true
        }
        
        indicator.isHidden = true
        
        createDatePicker()
        createTimePicker()
        
        let image = UIImage(named: "defaultEventImage.png")
        
        imageView.image = image
        
        //sample of image encoding and decoding
        
//        let image : UIImage = UIImage(named:"iconEmail.png")!
//        
//        let imageData = UIImagePNGRepresentation(image)
//        
//        let base64String = imageData?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
//        print("------------- Image converted to string : ",base64String!)
//        
//        let dataDecoded:NSData = NSData(base64Encoded: base64String!, options: NSData.Base64DecodingOptions(rawValue: 0))!
//        let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
//        //print(decodedimage)
//        imageView.image = decodedimage
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
       if(text == "\n")
       {
        Description.resignFirstResponder()
        return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(Description!.text == "Description")
        {
            Description!.text = ""
        }
        Description!.becomeFirstResponder()
        }
    func textViewDidEndEditing(_ textView: UITextView) {
        if(Description!.text == "")
        {
            Description!.text = "Description"
        }
        Description!.resignFirstResponder()
    }
    
    
    @IBAction func actionUpload(_ sender: Any) {
        
        if(!(titleTextField!.text!==""||Description!.text!==""||dateTextField!.text!==""||timeTextField!.text!==""||locationLatitude == nil))
        {
        //myImageUploadRequest()
        
        indicator.isHidden = false
        indicator.startAnimating()
        
        
        let title = titleTextField!.text!
        let description = Description!.text!
        
        let date = getFormattedDate(date: dateTextField!.text!)
        let time = getFormattedTime(time: timeTextField!.text!)
        
        let category = "test"
        
        
        let str = "http://salty-sea-56469.herokuapp.com/register_event"
        
        var eventData = Dictionary<String,Any>()
        
        eventData["title"] = title
        eventData["desc"] = description
        eventData["date"] = date
        eventData["time"] = time
        eventData["category"] = category
        eventData["latitude"] = locationLatitude!
        eventData["longitude"] = locationLongitude!
        eventData["name"] = locationName!
        
        let userDef = UserDefaults.standard
        
        eventData["user"] = userDef.object(forKey: "user_id")
        eventData["image"] = imageConvertedToString!
        
        do
        {
            let jsonData = try JSONSerialization.data(withJSONObject: eventData, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            let url = URL(string: str)
            
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(String(jsonData.count), forHTTPHeaderField: "Content-Length")
            
            request.timeoutInterval = 180
            
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: request, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) in
                
                print("-----------------------------Response",response!)
                
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
                        
                        
                        let image = UIImage(named: "defaultEventImage.png")
                        
                        self.imageView.image = image
                    }
                }
                
                else
                {
                if(error == nil && data != nil)
                {
                    
                    do
                    {
                    let responseFromServer = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:Any]
                        
                     print("------------------ Response from server : ",responseFromServer)
                        
                        if responseFromServer["error"] != nil
                        {
                            DispatchQueue.main.async {
                                self.indicator.stopAnimating()
                                self.indicator.isHidden = true
                                
                                let alert = UIAlertController(title: "Error", message: "Error occured while creating the event", preferredStyle: UIAlertControllerStyle.alert)
                                
                                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
                                    
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
                                
                                let alert = UIAlertController(title: "Created!", message: "Your event has been successfully created", preferredStyle: UIAlertControllerStyle.alert)
                                
                                let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
                                    
                                    alert.dismiss(animated: true, completion: nil)
                                    
                                })
                                
                                alert.addAction(okAction)
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                     }
                    catch
                    {
                        print("------------------------------ Error in reading data from server --------------------",error)
                    }
                    
                }
              }
            })
            
            task.resume()
        }
        catch
        {
            print("------------------------ Error in writing data to server -----------------------",error)
        }
    
      }
        else
        {
            
            let alert = UIAlertController(title: "Empty Fields", message: "You cant leave a field empty other than image", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
                
                alert.dismiss(animated: true, completion: nil)
                
            })
            
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)

        }
    }
    
    // 3/30/18 ---> 2018-03-30T00:00:00.000Z
    func getFormattedDate(date:String) -> String {
        
        let dateTemp = date
        
        var dateArray = dateTemp.components(separatedBy: "/")
        
        let finalDate = "20\(dateArray[2])-\(dateArray[0])-\(dateArray[1])T00:00:00.000Z"
        
        return finalDate
        
    }
    
    func getFormattedTime(time:String) -> String {
    
        let tempTime = time
        
        var timeArray = tempTime.components(separatedBy: " ")
        
        let ampm = timeArray[1]
        
        var hourAndMinuteArray = timeArray[0].components(separatedBy: ":")
        
        var hour:Int = Int(hourAndMinuteArray[0])!
        
        if ampm=="am" {
            
            if hour==12  {
                hour=00
            }
            
        }
        else
        {
            if hour==12 {
                hour=12
            }
            else
            {
                hour = hour + 12
            }
        }
     
        return "\(hour):\(hourAndMinuteArray[1]):00"
    }
    
    func createDatePicker() {
        
        //format for picker
        datePicker.datePickerMode = .date
        
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        //bar button item
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedForDatePicker))
        
        toolbar.setItems([doneButton], animated: false)
        
        dateTextField.inputAccessoryView = toolbar
        
        //assigning date picker to text field
        dateTextField.inputView = datePicker
        
    }
    
    func donePressedForDatePicker() {
        
        //format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        dateTextField!.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    func createTimePicker() {
        
        //format for picker
        timePicker.datePickerMode = .time
        
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        //bar button item
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedForTimePicker))
        
        toolbar.setItems([doneButton], animated: false)
        
        timeTextField.inputAccessoryView = toolbar
        
        //assigning date picker to text field
        timeTextField.inputView = timePicker

        
    }
    
    func donePressedForTimePicker() {
        
        //format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        timeTextField!.text = dateFormatter.string(from: timePicker.date)
        self.view.endEditing(true)
        
    }
    
    @IBAction func actionUploadFromGallery(_ sender: Any) {
    
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(myPickerController, animated: true, completion: nil)
    
    }
    
    @IBAction func actionShowLocation(_ sender: Any) {
        
        let alert = UIAlertController(title: "Location Selected", message: "Latitude : \(locationLatitude!) Longitude: \(locationLongitude!)", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel) { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func actionPickLocation(_ sender: Any) {
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        //converting image to base 64
        let image:UIImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        
        //let image:UIImage = UIImage(named: "iconEmail.png")!
        
        let imageData = UIImagePNGRepresentation(image)
        
        let base64String = imageData?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        
        imageConvertedToString = base64String!
        
        self.dismiss(animated: true, completion: nil)
        
        //decoding the image back to image
        let dataDecoded:NSData = NSData(base64Encoded: base64String!, options: NSData.Base64DecodingOptions(rawValue: 0))!
        let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
        
        imageView.image = decodedimage
        
   
    }

    
    
}

extension CreateEventViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("------------------- Place name: \(place.name)")
        print("------------------- Place address: \(place.formattedAddress!)")
        print("------------------- Place attributions: \(place.attributions)")
        print("------------------- Place Latitude : \(place.coordinate.latitude)")
        print("------------------- Place Longitude : \(place.coordinate.longitude)")
        
        locationLatitude = place.coordinate.latitude
        locationLongitude = place.coordinate.longitude
        locationName = place.name
        
        dismiss(animated: true, completion: nil)
        
        buttonShowLocation.isHidden = false
        buttonShowLocation.isEnabled = true
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}


