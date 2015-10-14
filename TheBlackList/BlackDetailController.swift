//
//  BlackDetailController.swift
//  TheBlackList
//
//  Created by Elia Chinellato on 9/21/15.
//  Copyright © 2015 Elia Chinellato. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class BlackDetailController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var currencyPicker: UIPickerView!
    @IBOutlet var whoInput: UITextField!
    @IBOutlet var amountInput: UITextField!
    @IBOutlet var whyInput: UITextField!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var friendsTable: UITableView!
    
    var username = ""
    var userFBname = ""
    var black : Black?
    var friends = [String]()
    var friendsId = [String]()
    var autoFriends = [String]()
    let baseApi = "https://theblacklist.eu-gb.mybluemix.net/api"
    let currencies = ["$", "€", "£"]
    var activeField: UITextField?
    var selectedFriendId = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        currencyPicker.dataSource = self
        currencyPicker.delegate = self
        whoInput.delegate = self
        amountInput.delegate = self
        whyInput.delegate = self
        
        friendsTable.delegate = self
        friendsTable.dataSource = self
        friendsTable.scrollEnabled = false
        friendsTable.hidden = true
        
        amountInput.keyboardType = UIKeyboardType.NumbersAndPunctuation
        currencyPicker.selectRow(currencies.indexOf("€")!, inComponent: 0, animated: false)

        
    }
    
    override func viewWillAppear(animated: Bool) {
        if (black != nil) {
            deleteButton.hidden = black!.who.isEmpty
            whoInput.text = black!.who
            amountInput.text = black!.amount > 0 ? String(format: "%.2f", black!.amount) : ""
            whyInput.text = black!.why
            if (black?.currency != nil && !(black!.who.isEmpty) ) {
                currencyPicker.selectRow(currencies.indexOf((black?.currency)!)!, inComponent: 0, animated: false)
            }
        }
        self.selectedFriendId = 0
        self.getFriendList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //currency picker functions
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencies.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return currencies[row]
    }
    
    
    
  //segues functions
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "addBlack" {
            if checkParameters() {
                print("parameters are OK")
                addBlack(sender)
            } else {
                return false
            }
        } else if identifier == "deleteBlack" {
            deleteBlack(sender)

        }
        
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        (segue.destinationViewController as! TBLController).username = self.username
        dismissKeyboard()
    }
    
    func checkParameters() -> Bool {
        if !whoInput.text!.isEmpty && !amountInput.text!.isEmpty && (self.amountInput.text! as NSString).doubleValue != 0 {
            return true
        } else {
            return false
        }

        
    }
    
    
    //REST CALLS
    
    func addBlack(sender: AnyObject?) {
        let who:String = self.whoInput.text!
        let amountDouble = (self.amountInput.text! as NSString).doubleValue
        let amount:Double = Double(round(amountDouble*100)/100)
        let cur:String = self.currencies[self.currencyPicker.selectedRowInComponent(0)]
        let why:String = self.whyInput.text!
        let nowDate = NSDate()
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "eu")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        let when:String = formatter.stringFromDate(nowDate)
        
        //if self.selectedFriendId == 0 {
            callAddBlack(self.username, id: self.black!.id, who: who, amount: amount, cur: cur, why: why, when: when, sender: sender)
        //} else {
        //    print("Devo chiamare l'altra funzione")
        //}
        
        
        
        }
    
    func callAddBlack(username: String, id: Int, who: String, amount: Double, cur: String, why: String, when: String, sender: AnyObject?) {
        print("Adding black with id "+String(id))
        
        var url = "";
        if self.selectedFriendId == 0 {
            url = self.baseApi+"/addBlack?user=\(self.username)"
        } else {
            url = self.baseApi+"/addBlackAndCompl?user=\(self.username)&complUser=\(self.selectedFriendId)"
        }
        
        print("-> "+url)
        let request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        request.HTTPMethod = "PUT"
        
        let dataBody: NSDictionary = ["black":["id": id , "who": who ,"amount":amount,"currency": cur , "why": why , "when":when]];
        let jsonData = try? NSJSONSerialization.dataWithJSONObject(dataBody, options: NSJSONWritingOptions())
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if jsonData == nil {
            print("Malformed input")
            return
        }
        
        request.HTTPBody = jsonData!
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{
            
            (response:NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            
            if (data != nil) {
                let jsonResult = JSON(data: data!)
                
                if jsonResult != nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        if (jsonResult["result"].intValue != 0) {
                            let descr : String = jsonResult["descr"].string!
                            print("Could not add black with id "+String(self.black!.id)+": "+descr)
                        } else {
                            print("Black with id "+String(self.black!.id)+" successfully added!")
                            self.performSegueWithIdentifier("addBlack", sender: sender)
                        }
                    })
                    
                } else {
                    print("Could not add black with id "+String(self.black!.id)+": jsonResult is nil")
                }
            } else {
                print("Could not add black with id "+String(self.black!.id)+": data is nil!")
            }
        })

    }
    
    func deleteBlack(sender: AnyObject?) {
        print("Deleting black with id "+String(black!.id))
        let url : String = self.baseApi+"/removeBlack?user=\(self.username)&key=\(self.black!.id)"
        let request : NSMutableURLRequest = NSMutableURLRequest()
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.URL = NSURL(string: url)
        print("-> \(request.URL!)")
        request.HTTPMethod = "PUT"
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{
            
            (response:NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            
            if (data != nil) {
                let jsonResult = JSON(data: data!)
                
                if jsonResult != nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        if (jsonResult["result"].intValue != 0) {
                            let descr : String = jsonResult["descr"].string!
                            print("Could not add remove with id "+String(self.black!.id)+": "+descr)
                        } else {
                            print("Black with id "+String(self.black!.id)+" successfully removed!")
                            self.performSegueWithIdentifier("deleteBlack", sender: sender)
                        }
                    })
                    
                } else {
                    print("Could not remove black with id "+String(self.black!.id)+": jsonResult is nil")
                }
            } else {
                print("Could not remove black with id "+String(self.black!.id)+": data is nil!")
            }
        })

    }
    
    func getFriendList() {
        let friendReq:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: nil)
        friendReq.startWithCompletionHandler({(connection, result, error) -> Void in
            if (error == nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    
                    if let data = (result as! NSDictionary)["data"] {
                        print("ID's: \(self.friendsId)")
                        let dataArr = data as! NSArray
                        for friend in dataArr {
                            let friendName:String = friend["name"] as! String
                            self.friends.append(friendName)
                            self.friendsId.append(friend["id"] as! String )
                        }
                        print("FRIENDS: \(self.friends)")
                    }
                })
                
                
            }
        })
    }
    
     //AUTOCOMPLETE
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        let substring = (self.whoInput.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        searchAutocompleteEntriesWithSubstring(substring)
        return true
    }
    
    func searchAutocompleteEntriesWithSubstring(substring: String)
    {
        autoFriends.removeAll(keepCapacity: false)
        
        for curString in friends {
            let myString: NSString! = (curString as NSString).lowercaseString
            let substringRange: NSRange! = myString.rangeOfString(substring.lowercaseString)
      //      if (substringRange.location == 0)
            if (substringRange.location != NSNotFound)
            {
                autoFriends.append(curString)
            }
        }
        
        if autoFriends.count > 0 {
            friendsTable.hidden = false
        } else {
            friendsTable.hidden = true
        }
        
        friendsTable!.reloadData()
    }

   
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autoFriends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = autoFriends[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        whoInput.text = autoFriends[indexPath.row]
        if let tmpStrId = NSNumberFormatter().numberFromString(self.friendsId[indexPath.row]) {
            self.selectedFriendId = tmpStrId.integerValue
            //aggiungi qua l'azione della selezione del fb friend (e.g. l'immagine del profilo)
        } else {
            self.selectedFriendId = 0
        }
        
        friendsTable.hidden = true

    }
    
    //KEYBOARD STUFF
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func dismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
 
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        friendsTable.hidden = true
        super.touchesBegan(touches, withEvent: event)
    }

    
}