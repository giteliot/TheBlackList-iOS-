//
//  StarterViewController.swift
//  TheBlackList
//
//  Created by Elia Chinellato on 9/11/15.
//  Copyright (c) 2015 Elia Chinellato. All rights reserved.
//

import UIKit


class StarterViewController: UIViewController {
    @IBOutlet weak var printLabel: UILabel!
    @IBOutlet var usernameField: UITextField!
    let baseApi = "https://theblacklist.eu-gb.mybluemix.net/api"
    
    @IBAction func writeToLabel(sender: UIButton) {
   /*     let user = usernameField.text
        var url : String = baseApi+"/retrievebl?user="+user
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        request.HTTPMethod = "GET"
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            let jsonResult = JSON(data: data)
            if (jsonResult != nil) {
                dispatch_async(dispatch_get_main_queue(), {
              /*      let name = jsonResult[0]["who"].string
                    self.printLabel.text = name */
                    let newBlack = Black(id: 0,who: jsonResult[0]["who"].string!, amount: jsonResult[0]["amount"].double!, currency: jsonResult[0]["currency"].string!, friendlyName: "", why: "", when: "")
                    self.printLabel.text = newBlack.currency
                })

            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.printLabel.text = "an error occurred :/"
                })
            }

        }) */
    }

    override func shouldPerformSegueWithIdentifier(identifier: String!, sender: AnyObject!) -> Bool {
        if identifier == "showTbl" {
            
            let user = usernameField.text
            if (user.isEmpty) {
                self.printLabel.text = "Insert a username!"

            } else {
                
                var url : String = baseApi+"/login?user="+user
                var request : NSMutableURLRequest = NSMutableURLRequest()
                request.URL = NSURL(string: url)
                request.HTTPMethod = "GET"
                
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{
                    
                    (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                    let jsonResult = JSON(data: data)
                    if (jsonResult != nil) {
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            if (jsonResult["user_auth"].boolValue == false) {
                                self.printLabel.text = "Not a valid username!"
                                
                            } else {
                                self.printLabel.text = "User successfully logged in"
                                self.performSegueWithIdentifier("showTbl", sender: sender)
                            }
                        })
                        
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.printLabel.text = "an error occurred :/"
                        })
                    }
                })
            }
            
        }
        
        return false
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTbl" {
            (segue.destinationViewController as! TBLController).username = usernameField.text!
 /*           if let indexPath = self.tableView.indexPathForSelectedRow() {
                let object = objects[indexPath.row] as! NSDate
                (segue.destinationViewController as! DetailViewController).detailItem = object
            }*/
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}