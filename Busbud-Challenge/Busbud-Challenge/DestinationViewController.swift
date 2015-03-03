//
//  DestinationViewController.swift
//  Busbud-Challenge
//
//  Created by Julien Saad on 2015-03-03.
//  Copyright (c) 2015 Julien Saad. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

class DestinationViewController: BusbudViewController {

    var city: City!
    var user: User!
    var destinationCity: City?
    
    private var _destinationCites = [City]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var destinationTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        cityNameLabel.text = "\(city.name)"
        cityNameLabel.font = UIFont(name: "Lucida Grande", size: 15.0)
        destinationTextField.font = UIFont(name: "Lucida Grande", size: 15.0)
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        
    }
    
    @IBAction func searchButtonTapped(sender: AnyObject) {
        destinationTextField.resignFirstResponder()
        
        self.performSegueWithIdentifier("WebView", sender: self)
    }
    
    private func fetchDestinations(q: String){
        Router.limit = 10
        Alamofire.request(Router.SearchDest(q:q, lang: user.language, lat: user.latitude, lon: user.longitude, originId: city.id))
            .responseJSON { (_, _, data, error) in
                if error == nil {
                    // Clear older cities
                    self._destinationCites = [City]()
                    for (index: String, subJson: JSON) in JSON(data!) {
                        let cityId = subJson["city_id"].string
                        
                        // Only add a city to the results if it is not the current city
                        if cityId != self.city.id {
                            let name = subJson["full_name"].string
                            let url = subJson["city_url"].string
                            
                            let aCity = City(id: cityId!, name: name!, url:url!)
                            self._destinationCites.append(aCity)
                        }
                        
                    }
                    self.tableView.reloadData()
                    
                } else {
                    println(error)
                }
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        }
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    // MARK: - Navigation

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "WebView" {
            let vc = segue.destinationViewController as WebViewViewController
            vc.originCity = self.city
            vc.destinationCity = self.destinationCity
            vc.user = self.user
        }
    }
    

}

// MARK: UITextFieldDelegate
extension DestinationViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var txtAfterUpdate:NSString = self.destinationTextField.text as NSString
        txtAfterUpdate = txtAfterUpdate.stringByReplacingCharactersInRange(range, withString: string)
        
        fetchDestinations(txtAfterUpdate)
        return true

    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: UITableViewDataSource
extension DestinationViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("CityCell") as? UITableViewCell
        cell?.backgroundColor = UIColor(red: 18/255, green: 124/255, blue: 203/255, alpha: 0.8)
        cell!.textLabel!.text = _destinationCites[indexPath.row].name
        cell?.textLabel?.font = UIFont(name: "Lucida Grande", size: 15.0)
        cell?.textLabel?.textColor = UIColor.whiteColor()
        cell?.textLabel?.shadowColor = UIColor(white: 0, alpha: 0.3)
        cell?.textLabel?.shadowOffset = CGSizeMake(1, 1)
        return cell!
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _destinationCites.count
    }
}

// MARK: UITableViewDelegate
extension DestinationViewController: UITableViewDelegate {
    /*
    Tells the delegate the table view is about to draw a cell for a particular row.
    */
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
        forRowAtIndexPath indexPath: NSIndexPath)
    {
        // Remove seperator inset
        if cell.respondsToSelector("setSeparatorInset:") {
            cell.separatorInset = UIEdgeInsetsZero
        }
        
        // Prevent the cell from inheriting the Table View's margin settings
        if cell.respondsToSelector("setPreservesSuperviewLayoutMargins:") {
            cell.preservesSuperviewLayoutMargins = false
        }
        
        // Explictly set your cell's layout margins
        if cell.respondsToSelector("setLayoutMargins:") {
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Select destination city and dismiss tableView
        
        destinationTextField.resignFirstResponder()
        destinationTextField.text = _destinationCites[indexPath.row].name
        self.destinationCity = _destinationCites[indexPath.row]
        _destinationCites = [City]()
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        destinationTextField.resignFirstResponder()
    }

}
