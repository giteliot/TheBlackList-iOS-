//
//  TBLController.swift
//  TheBlackList
//
//  Created by Elia Chinellato on 9/14/15.
//  Copyright (c) 2015 Elia Chinellato. All rights reserved.
//

import UIKit

class TBLController: UITableViewController {
    var username = ""
    var userFBname = ""
    var blacks = [Black]()
    let baseApi = "https://theblacklist.eu-gb.mybluemix.net/api"

    @IBOutlet var cellLabel2: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Loading Black List for user: "+username)
        if !username.isEmpty {
            loadBlackList()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: "back:")
        self.navigationItem.leftBarButtonItem = newBackButton;
        super.viewWillAppear(animated)
    }
    
    func back(sender: UIBarButtonItem) {
        // Perform your custom actions
        // ...
        // Go back to root
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func loadBlackList() {
        let url : String = baseApi+"/retrievebl?user="+username
        let request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        request.HTTPMethod = "GET"
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            
            if (data != nil) {
                let jsonResult = JSON(data: data!)
                let dataRes = jsonResult["data"]
                
                if (dataRes != nil) {
                    dispatch_async(dispatch_get_main_queue(), {
                        var tmpBlack: Black
                        var i = 0
                        for i = 0; i < dataRes.count; i++ {
                            let currentBlack = dataRes[i]
                            var imgUrl = ""
                            if currentBlack["complBlack"] != nil {
                                let complUserId = currentBlack["complBlack"]["userId"].string!
                                imgUrl = "https://graph.facebook.com/\(complUserId)/picture?type=large"
                            }
                            
                            tmpBlack = Black(id: currentBlack["id"].int!,who: currentBlack["who"].string!, amount: currentBlack["amount"].double!, currency: currentBlack["currency"].string!, why: currentBlack["why"].string!, when: currentBlack["when"].string!, imageUrl: imgUrl)
                            
                            self.insertBlack(tmpBlack)
                        }
                    })
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("MISTAKES HAPPENED")
                })
            }
            
        })
    }
    
    
    func insertBlack(jsonBlack: Black) {
        let indexPath = NSIndexPath(forRow: blacks.count, inSection: 0)
        blacks.append(jsonBlack)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    //table view overriderz
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blacks.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! BlackCell

        let tmpB = blacks[indexPath.row]
        if tmpB.imageUrl.isEmpty {
            cell.blackImage.image = UIImage(named: "anonym_icon")
        } else {
            ImageLoader.sharedLoader.imageForUrl(tmpB.imageUrl, completionHandler:{(image: UIImage?, url: String) in
                dispatch_async(dispatch_get_main_queue(), {
                    cell.blackImage.image = image
                })
                
            })
            
            cell.blackImage.layer.cornerRadius = cell.blackImage.frame.size.width/2
            cell.blackImage.clipsToBounds = true
        }
        let amountString = String(format:"%.2f", tmpB.amount)+"\(tmpB.currency)"
        let coloredAmount = NSMutableAttributedString(string: "\(amountString)  \(tmpB.why)")
        var amountColor = UIColor.redColor()
        if (tmpB.amount > 0) {
            amountColor = UIColor(red: 0.33, green: 0.8, blue: 0.25, alpha: 1)
        }
        coloredAmount.addAttribute(NSForegroundColorAttributeName, value: amountColor, range: NSRange(location: 0, length: amountString.characters.count))
        coloredAmount.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(17), range: NSRange(location: 0, length: amountString.characters.count))
        cell.usernameLabel.text = tmpB.who
        cell.priceLabel.attributedText = coloredAmount
        if !tmpB.when.isEmpty {
            let formatter = NSDateFormatter()
            formatter.locale = NSLocale(localeIdentifier: "eu")
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
            var fromDate = formatter.dateFromString(tmpB.when)
            if fromDate == nil {
                fromDate = NSDate()
            }
            let toDate = NSDate()
            let cal = NSCalendar.currentCalendar()
            let unit:NSCalendarUnit = NSCalendarUnit.Day
            let components = cal.components(unit, fromDate: fromDate!, toDate: toDate, options: NSCalendarOptions())
            cell.timeLabel.text = "\(components.day)d"
        } else {
            cell.timeLabel.text = ""
        }
        
        /*var cellTxt = tmpB.who+" "+String(format:"%.2f", tmpB.amount)
        cellTxt += tmpB.currency+" "+tmpB.why+" "+tmpB.when
        cell.textLabel!.text = cellTxt*/
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "newBlack" {
            let mySegue = segue.destinationViewController as! BlackDetailController
            mySegue.username = self.username
            mySegue.userFBname = self.userFBname
            if blacks.count > 0 {
                mySegue.black = Black(id: blacks[blacks.count-1].id+1)
            } else {
                mySegue.black = Black(id: 0)
            }
            
            
        }
        
        if segue.identifier == "editBlack" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = blacks[indexPath.row]
                let mySegue = segue.destinationViewController as! BlackDetailController
                mySegue.username = self.username
                mySegue.black = Black(id: object.id, who: object.who, amount: object.amount, currency: object.currency, why: object.why, when: object.when, imageUrl: object.imageUrl)
            }
        }
        
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        navigationItem.backBarButtonItem = backItem
    }

    
}