//
//  CustomTableViewCell.swift
//  Milaap
//
//  Created by dmc on 22/01/18.
//  Copyright © 2018 CDAC-DMC. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var hostNameLabel: UILabel!
    
    var eventTitle:String?
    var eventDescription:String?
    var eventDate:String?
    var eventTime:String?
    var eventOrganiser:String?
    var locationName:String?
    var imageBase64Format:String?
    
    var listViewControllerObj:ListViewController?
    
    var searchEventViewControllerObj:SearchEventViewController?
    
    var eventLatitude:String?
    var eventLongitude:String?
    
    
    @IBAction func actionPinLocation(_ sender: Any) {
        
        if listViewControllerObj != nil {
            
            print("-------------------------- INSIDE actionPinLocation of CustomTableViewCell -------------------")
            
            let mapCon = listViewControllerObj?.storyboard?.instantiateViewController(withIdentifier: "mapview") as! MapViewController
            
            mapCon.amISearchingAParticularEvent = true
            mapCon.eventLatitude = eventLatitude!
            mapCon.eventLongitude = eventLongitude!
            
            listViewControllerObj?.navigationController?.pushViewController(mapCon, animated: true)
            
        }
        
        if searchEventViewControllerObj != nil {
            
            let mapCon = searchEventViewControllerObj?.storyboard?.instantiateViewController(withIdentifier: "mapview") as! MapViewController
            
            mapCon.amISearchingAParticularEvent = true
            mapCon.eventLatitude = eventLatitude!
            mapCon.eventLongitude = eventLongitude!
            
            searchEventViewControllerObj?.navigationController?.pushViewController(mapCon, animated: true)
            
        }
        
    }
    
    
    @IBAction func actionViewDetails(_ sender: Any) {
        
        if listViewControllerObj != nil {
            let eventsCon = listViewControllerObj?.storyboard?.instantiateViewController(withIdentifier: "eventdetails") as! EventDetailsViewController
            
            eventsCon.eventTitle = eventTitle!
            eventsCon.eventDescription = eventDescription!
            eventsCon.eventDate = eventDate!
            eventsCon.eventTime = eventTime!
            eventsCon.eventOrganiser = eventOrganiser!
            eventsCon.locationName = locationName!
            eventsCon.imageBase64Format = imageBase64Format!
            
            listViewControllerObj?.navigationController?.pushViewController(eventsCon, animated: true)
        }
        
        if searchEventViewControllerObj != nil {
            let eventsCon = searchEventViewControllerObj?.storyboard?.instantiateViewController(withIdentifier: "eventdetails") as! EventDetailsViewController
            
            eventsCon.eventTitle = eventTitle!
            eventsCon.eventDescription = eventDescription!
            eventsCon.eventDate = eventDate!
            eventsCon.eventTime = eventTime!
            eventsCon.eventOrganiser = eventOrganiser!
            eventsCon.locationName = locationName!
            eventsCon.imageBase64Format = imageBase64Format!
            
            searchEventViewControllerObj?.navigationController?.pushViewController(eventsCon, animated: true)
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
