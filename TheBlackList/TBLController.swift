//
//  TBLController.swift
//  TheBlackList
//
//  Created by Elia Chinellato on 9/14/15.
//  Copyright (c) 2015 Elia Chinellato. All rights reserved.
//

import UIKit

class TBLController: UITableViewController {
    var username = "No username"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        println(username)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}