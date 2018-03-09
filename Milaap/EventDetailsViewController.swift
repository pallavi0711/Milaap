//
//  EventDetailsViewController.swift
//  Milaap
//
//  Created by dmc on 18/01/18.
//  Copyright © 2018 CDAC-DMC. All rights reserved.
//

import UIKit
import MapKit

class EventDetailsViewController: UIViewController {
    
    
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UITextView!
    
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var userHostingEventLabel: UILabel!
    
    @IBOutlet weak var locationNameLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var eventTitle:String?
    var eventDescription:String?
    var eventDate:String?
    var eventTime:String?
    var eventOrganiser:String?
    var locationName:String?
    var imageBase64Format:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        titleLabel!.text = "Title : \(eventTitle!)"
        descriptionLabel!.text =  "Description \(eventDescription!)"
        timeLabel!.text = "Time : \(eventTime!)"
        locationNameLabel!.text = "Location Name : \(locationName!)"
        
        var eventDateTemp = eventDate!.components(separatedBy: "T")
        
        var dateFetchedBySplittng = eventDateTemp[0].components(separatedBy: "-")
        
        dateLabel!.text = "Date : \(dateFetchedBySplittng[2]) - \(dateFetchedBySplittng[1]) - \(dateFetchedBySplittng[0])"
        
        userHostingEventLabel!.text = "\(eventOrganiser!)"
        
        
        if (imageBase64Format!)==""  {
            
            let image:UIImage = UIImage(named: "defaultEventImage.png")!
            
            imageView.image = image
            
        }
        else
        {
            print("----------------------------------- image data(\(eventTitle!)) : ",imageBase64Format!)
            let dataDecoded:NSData = NSData(base64Encoded: imageBase64Format!, options: NSData.Base64DecodingOptions(rawValue: 0))!
            let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
            
            imageView.image = decodedimage
            
        }
        
    }

    

}
