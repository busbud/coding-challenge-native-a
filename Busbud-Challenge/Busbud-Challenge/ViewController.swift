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

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var shareLocationButton: UIButton!
    var locationManager:CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let bbLogoImageView = UIImageView(image: UIImage(named: "logo"))
        self.navigationItem.titleView = bbLogoImageView;
        shareLocationButton.backgroundColor = BusbudConstants.blueColor
        
       /* Alamofire.request(Router.Authorize)
            .responseJSON { (_, _, data, _) in
                println(data)
                let json = JSON(data!)
        }*/
        
    }
    
    private func fetchUserLocation() {
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func didTapShareLocation(sender: AnyObject) {
        fetchUserLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: CLLocationManagerDelegate {
    // MARK: CLLocationManagerDelegateDelegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        // self.performSegueWithIdentifier("locationRece", sender: <#AnyObject?#>)
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        Alert.Warning(self, message: "Please allow this app to use location services in your Settings")
    }

}

