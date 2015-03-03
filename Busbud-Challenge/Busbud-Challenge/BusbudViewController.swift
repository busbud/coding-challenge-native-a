//
//  BusbudViewController.swift
//  Busbud-Challenge
//
//  Created by Julien Saad on 2015-03-03.
//  Copyright (c) 2015 Julien Saad. All rights reserved.
//

import UIKit
import MBProgressHUD

class BusbudViewController: UIViewController {

    var _loadingNotification:MBProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let bbLogoImageView = UIImageView(image: UIImage(named: "logo"))
        self.navigationItem.titleView = bbLogoImageView;
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
