//
//  ViewController.swift
//  Busbud-Challenge
//
//  Created by Julien Saad on 2015-03-02.
//  Copyright (c) 2015 Julien Saad. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import MBProgressHUD

class OriginViewController: BusbudViewController, CLLocationManagerDelegate {

    @IBOutlet weak var shareLocationButton: UIButton!
    private var _locationManager:CLLocationManager!
    private var _currentCity:City?
    private var _user:User!
    
    private var _didFetchCityInfo = false

    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

        contentView.layer.shadowColor = UIColor.blackColor().CGColor
        contentView.layer.shadowRadius = 3.0
        contentView.layer.shadowOffset = CGSizeMake(1, 1)
        contentView.layer.shadowOpacity = 0.3
        
        let language = NSBundle.mainBundle().preferredLocalizations.first as NSString
        
        _user = User(language: language)
        
        println(language)
        languageLabel.text = "Lang: \(_user.language)"

    }
    
    private func fetchUserLocation() {
        _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.requestAlwaysAuthorization()
        _locationManager.startUpdatingLocation()
    }
    
    @IBAction func didTapShareLocation(sender: AnyObject) {
        _didFetchCityInfo = false
        // Start loading animation
        _loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        _loadingNotification.mode = MBProgressHUDModeIndeterminate
        _loadingNotification.labelText = "Fetching your location..."
        
        fetchUserLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func authorizeApp() {
        _loadingNotification.labelText = "Connecting to Busbud servers..."
        // Get Busbud API Token
        Alamofire.request(Router.Authorize)
            .responseJSON { (_, _, data, error) in
                if error == nil {
                    let json = JSON(data!)
                    if let token = json["token"].string {
                        Router.BusbudToken = token
                    }
                    self.findUserCity()
                } else {
                    Alert.Warning(self, message: "There was an error connecting to the Busbud servers")
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                }
                
        }
    }
    
    private func findUserCity() {
        _loadingNotification.labelText = "Finding closest city..."
        
        
        let currentLocation = _locationManager.location
        
        _user.latitude = "\(currentLocation.coordinate.latitude)"
        _user.longitude = "\(currentLocation.coordinate.longitude)"
        
        Alamofire.request(Router.SearchOrigin(lang: _user.language, lat: _user.latitude, lon: _user.longitude))
            .responseJSON { (_, _, data, error) in
                if error == nil {
                    let json = JSON(data!)
                    
                    if json.count > 0 {
                        self.parseFirstCityResults(json[0])
                    }
                    
                } else {
                    Alert.Warning(self, message: "There was an error finding the nearest city")
                }
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                
        }
    }
    
    private func parseFirstCityResults(json: JSON){
        
        let cityId = json["city_id"].string
        let name = json["full_name"].string
        let url = json["city_url"].string
        
        _currentCity = City(id: cityId!, name: name!, url:url!)
        
        
        if !_didFetchCityInfo {
            _didFetchCityInfo = true
            self.performSegueWithIdentifier("destinationSegue", sender: self)
        }
        
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "destinationSegue" {
            let vc = segue.destinationViewController as DestinationViewController
            vc.city = self._currentCity
            vc.user = self._user
        }
    }

}

// MARK: CLLocationManagerDelegateDelegate
extension OriginViewController: CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        // Get get token from Busbud API
        authorizeApp()
        _locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        Alert.Warning(self, message: "Please allow this app to use location services in your Settings")
    }

}

