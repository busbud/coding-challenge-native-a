//
//  ViewController.swift
//  Busbud-Challenge
//
//  Created by Julien Saad on 2015-03-02.
//  Copyright (c) 2015 Julien Saad. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let bbLogoImageView = UIImageView(image: UIImage(named: "logo"))
        self.navigationItem.titleView = bbLogoImageView;

       /* Alamofire.request(Router.Authorize)
            .responseJSON { (_, _, data, _) in
                println(data)
                let json = JSON(data!)
        }*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

