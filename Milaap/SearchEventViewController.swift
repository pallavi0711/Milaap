//
//  SearchEventViewController.swift
//  Milaap
//
//  Created by dmc on 26/01/18.
//  Copyright © 2018 CDAC-DMC. All rights reserved.
//

import UIKit

class SearchEventViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {

    @IBOutlet weak var eventName: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
     var downloadedEventsFromServer = [[String:Any]]()
    
    var autocompleteUrls = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //register new design of tableViewCell with tableView
        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "tablecell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = true
        tableView.isHidden = true
        
        eventName.delegate = self
        
        let URLString = "http://salty-sea-56469.herokuapp.com/events"
        
        let url = URL(string: URLString)
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            
            do
            {
                self.downloadedEventsFromServer = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [[String:Any]]
                
                print("---------------- Data fetched from server into list : ",self.downloadedEventsFromServer)
                
            }
            catch
            {
                print("------------------------------- ERROR IN DOWNLOADING DATA FROM SERVER ---------------------------")
            }
        }
        
        task.resume()

        print("------------------ viewDidLoad() completed ------------------------")
        
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //print("------------- shoudlChangeCharactersInRange() called ---------------------")
        
        tableView.isHidden = false
        
        print("-------------------- letter changed to:",string)
        
        //print("--------------------- range :",range)
        
        let substring = (eventName.text! as NSString).replacingCharacters(in: range, with: string)
        
        print("-------------------- substring: ",substring)
        
        searchAutocompleteEntriesWithSubstring(substring: substring)
        
        return true
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteUrls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("-------------- INSIDE CELL FOR ROW AT ------------------")
        
        //title,dateandtime,location,hostname
        
        let event = autocompleteUrls[indexPath.row]
        
        let eventTitle = event["title"] as! String
        
        let tempDate = event["date"] as! String
        var tempDateArray = tempDate.components(separatedBy: "T")
        var tempDateArrayAgain = tempDateArray[0].components(separatedBy: "-")
        let finalDate = "\(tempDateArrayAgain[2]) - \(tempDateArrayAgain[1]) - \(tempDateArrayAgain[0])"
        
        let eventTime = event["time"] as! String
        
        let eventDateAndTime = "\(finalDate)    \(eventTime)"
        
        let locatioName = event["name"] as! String
        
        let organiserName = "Organiser: \(event["firstname"] as!String) \(event["lastname"] as! String)  (\(event["email"] as! String)) "
        
        let eventLatitude = event["latitude"] as! String
        
        let eventLongitude = event["longitude"] as! String
        
        let eventDescription = event["description"] as! String
        
        var imageBase64Format = ""
        
        if ((event["image"] as? String) != nil) {
            
            print("-------------------------- INSIDE imageBase64Format of ListViewController -------------------")
            imageBase64Format = event["image"] as! String
            
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tablecell", for: indexPath) as! CustomTableViewCell
        
        
        cell.eventTitleLabel!.text = eventTitle
        cell.dateAndTimeLabel!.text = eventDateAndTime
        cell.locationLabel!.text = locatioName
        cell.hostNameLabel!.text = organiserName
        
        
        cell.eventTitle = eventTitle
        cell.eventDescription = eventDescription
        cell.eventDate = finalDate
        cell.eventTime = eventTime
        cell.eventOrganiser = organiserName
        cell.locationName = locatioName
        cell.imageBase64Format = imageBase64Format
        
        cell.eventLatitude = eventLatitude
        cell.eventLongitude = eventLongitude
        
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: cell.frame.size.height - width, width:  cell.frame.size.width, height: cell.frame.size.height)
        
        border.borderWidth = width
        cell.layer.addSublayer(border)
        cell.layer.masksToBounds = true
        
        cell.searchEventViewControllerObj = self
        
        //print("-------------------------- CELL RETURNED -------------------")
        return cell

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 213
    }
    
    func searchAutocompleteEntriesWithSubstring(substring: String)
    {
        autocompleteUrls.removeAll(keepingCapacity: false)
        
        let foundItems = downloadedEventsFromServer.filter { (($0["title"] as? String)?.contains(substring))! }
        
//        let arrayFiltered = downloadedEventsFromServer.filter($.["title"].contains(substring) )
//        for curString in downloadedEventsFromServer
//        {
//            let myString:NSString! = curString["name"] as! NSString
//            
//            let substringRange :NSRange! = myString.range(of: substring)
//            
//            if (substringRange.location  == 0)
//            {
//                autocompleteUrls.append(curString["name"] as! String)
//            }
//        }
        
        
        autocompleteUrls = foundItems
        
        tableView.reloadData()
    }

    
}
