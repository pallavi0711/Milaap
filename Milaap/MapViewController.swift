//
//  MapViewController.swift
//  Milaap
//
//  Created by dmc on 18/01/18.
//  Copyright © 2018 CDAC-DMC. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    //to connect to gps
    var locManager:CLLocationManager?
    
    //to fetch the data
    var lastLoc:CLLocation?

    
    var region:MKCoordinateRegion?
    
    var latChangedValue = 5000
    var longChangedValue = 5000
    
    let currentLatitude = 18.532017
    let currentLongitude = 73.814096
    
    var fetchedEventsFromServer = [[String:Any]]() //all the data fetched from the server
    var annotationsCreated = [MKPointAnnotation]()
    
    var amISearchingAParticularEvent:Bool = false
    var eventLatitude:String?
    var eventLongitude:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locManager = CLLocationManager()
        
        locManager!.delegate=self
        
        //ask user permission to recieve/read location
        locManager!.requestAlwaysAuthorization()
        locManager!.requestWhenInUseAuthorization()
        
        locManager!.desiredAccuracy = kCLLocationAccuracyBest
        
        locManager!.startUpdatingLocation() //this method connect with the gps tracker which connect to satellite
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: (screenWidth-(20+50)), y: (screenHeight-(20+100)), width: 40, height: 40)
        button.setTitle("+", for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
        
        self.view.addSubview(button)
        
        
        var downloadedData = [[String:Any]]()
        
        let URLString = "http://salty-sea-56469.herokuapp.com/events"
        
        let url = URL(string: URLString)
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { (data:Data?,response:URLResponse?,error:Error?)
            in
            if(error == nil && data != nil)
            {
                //convert recieved json data in array
                do
                {
                    downloadedData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [[String:Any]]
                    
                    
                    for particularEvent in downloadedData {
                        
                        
                        //dictionary of the particular event
                        var detailsOfParticularEvent = particularEvent
                        
                        //object of the particular event class
                        let event = EventsDesciption()
                        
                        event.eventID = detailsOfParticularEvent["id"] as? Int
                        event.eventTitle = detailsOfParticularEvent["title"] as? String
                        event.eventDescription = detailsOfParticularEvent["description"] as? String
                        event.date = detailsOfParticularEvent["date"] as? String
                        event.time = detailsOfParticularEvent["time"] as? String
                        event.locationID = detailsOfParticularEvent["location_id"] as? Int
                        event.eventOrganiserName = "\(detailsOfParticularEvent["firstname"] as! String ) \(detailsOfParticularEvent["lastname"] as! String ) (\(detailsOfParticularEvent["email"] as! String ))"
                        event.name = detailsOfParticularEvent["name"] as? String
                        event.latitude = detailsOfParticularEvent["latitude"] as? String
                        event.longitude = detailsOfParticularEvent["longitude"] as? String
                        
                        var imageBase64Format = ""
                        
                        if ((detailsOfParticularEvent["image"] as? String) != nil) {
                            
                            print("-------------------------- INSIDE imageBase64Format of ListViewController -------------------")
                            imageBase64Format = detailsOfParticularEvent["image"] as! String
                            
                        }
                        
                        event.imageBase64Format = imageBase64Format
                        
                        //event.coordinate = CLLocationCoordinate2DMake(Double(event.latitude!)!, Double(event.longitude!)!)
                        event.coordinate = CLLocationCoordinate2D(latitude: Double(event.latitude!)!, longitude: Double(event.longitude!)!)
                       
                        print("------------------------------------ Latitude : \(event.latitude!)------------------------- Longitude : \(event.longitude!)")
                        
//                        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
//                        myAnnotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(event.latitude!)!,CLLocationDegrees(event.longitude!)!);
//                        myAnnotation.title = "Current location"
//                        
                    
                        DispatchQueue.main.async {
                             self.mapView.addAnnotation(event)
                        }
                        
                    }
                    
                    DispatchQueue.main.async {
                        self.mapView.delegate=self
                        
                        self.mapView.showsUserLocation = true
                    }
                    
                    
                    
                }
                catch
                {
                    print("------------------------- Error in downloadPostData() ------------------",error)
                }
            }
            
            
        })
        
        task.resume()

        
        
        
     
        
    }
    
 
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //lastLoc = locations.last!
        
        //show on label
        //_ latitude = lastLoc?.coordinate.latitude
        //_ longitude = lastLoc?.coordinate.longitude

        
        //let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        //manager.stopUpdatingLocation()
        
        //let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        //let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        //mapView.setRegion(region, animated: true)
        
        // Drop a pin at user's Current Location
//
    }
    
    func buttonAction(sender : UIButton!) {
        
        self.viewDidAppear(true)
        
    }
    
    
    @IBAction func actionSlider(_ sender: UISlider) {
        
        let percent = Int((sender.value)*100)
        
        latChangedValue = percent*100
        longChangedValue = percent*100
        
        print("Percent-----------",percent)
        
        self.viewDidAppear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        viewDidLoad()
        
        let coordinate = CLLocationCoordinate2D(latitude: currentLatitude , longitude: currentLongitude)
        
        region = MKCoordinateRegionMakeWithDistance(coordinate, CLLocationDistance(latChangedValue), CLLocationDistance(longChangedValue))
        
        mapView.region=region!
        
        if amISearchingAParticularEvent {
            searchAParticularEventOnMap(eventLatitude: eventLatitude!, eventLongitude: eventLongitude!)
            
            amISearchingAParticularEvent = false
        }
        
        
    }
    
    func searchAParticularEventOnMap(eventLatitude:String , eventLongitude:String) {
        let placeOnMap:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double(eventLatitude)!, longitude: Double(eventLongitude)!)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(placeOnMap, 150, 150)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        //if user clicks on blue mark
        if(view.annotation is MKUserLocation)
        {
            let alert = UIAlertController(title: "Current location", message: "This is your current location", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
                alert.dismiss(animated: true, completion: nil)
            })
            
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
        }
            
        else
        {
        let selectedAnnotation = view.annotation as! EventsDesciption
        
        let alert = UIAlertController(title: selectedAnnotation.eventTitle!, message: "Description : \(selectedAnnotation.eventDescription!)", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction  = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (UIAlertAction) in
            
            alert.dismiss(animated: true, completion: nil)
            
            }
        
        alert.addAction(cancelAction)
        
        let viewDetailsAction = UIAlertAction(title: "View Details", style: UIAlertActionStyle.default) { (UIAlertAction) in
            
            alert.dismiss(animated: true, completion: nil)
            
            let eventsCon = self.storyboard?.instantiateViewController(withIdentifier: "eventdetails") as! EventDetailsViewController
            
            eventsCon.eventTitle = selectedAnnotation.eventTitle!
            eventsCon.eventDescription = selectedAnnotation.eventDescription!
            eventsCon.eventDate = selectedAnnotation.date!
            eventsCon.eventTime = selectedAnnotation.time!
            eventsCon.eventOrganiser = selectedAnnotation.eventOrganiserName!
            eventsCon.locationName = selectedAnnotation.name!
            eventsCon.imageBase64Format = selectedAnnotation.imageBase64Format!
            
            self.navigationController?.pushViewController(eventsCon, animated: true)
            //self.present(eventsCon, animated: true, completion: nil)
            }
        
        alert.addAction(viewDetailsAction)
        self.present(alert, animated: true, completion: nil)
        }
  }
    class EventsDesciption : NSObject,MKAnnotation
    {

        var eventID:Int?
        var eventTitle:String?
        var eventDescription:String?
        var date:String?
        var time:String?
        var locationID:Int?
        var eventOrganiserName:String?
        var name:String?
        var latitude:String?
        var longitude:String?
        var imageBase64Format:String?
        
        var coordinate = CLLocationCoordinate2D()
        
    }
    
   
    
    

}
