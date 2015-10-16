//
//  LoginPageController.swift
//  TheBlackList
//
//  Created by Elia Chinellato on 9/24/15.
//  Copyright © 2015 Elia Chinellato. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginPageController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var userLabel: UILabel!
    @IBOutlet var fbLoginButton: FBSDKLoginButton!
    @IBOutlet var goToTblButton: UIBarButtonItem!
    @IBOutlet var profileImg: UIImageView!
    
    let baseApi = "https://theblacklist.eu-gb.mybluemix.net/api"
    var userId = ""
    var userFBname = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fbLoginButton.readPermissions = ["public_profile", "user_friends"]
        fbLoginButton.delegate = self
        
        if FBSDKAccessToken.currentAccessToken() == nil {
            self.showLogout()
        } else {
            findUserAndSegue(false)
        }
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if error == nil {
            print("User logged in")
            findUserAndSegue(true)
        } else {
            print("Mistakes happened!!")
            
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User logged out...")
        self.showLogout()
    }
    
    
    func findUserAndSegue(shouldRegister: Bool?) {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if error == nil {
                let userId: NSString = (result.valueForKey("id") as? NSString)!
                let userName: NSString = (result.valueForKey("name") as? NSString)!
                self.showLogin(userName)
                self.userId = userId as String
                self.userFBname = userName as String
                if (shouldRegister == true) {
                    self.registerUser(userId as String, name: userName as String)
                }
                ImageLoader.sharedLoader.imageForUrl("https://graph.facebook.com/\(userId)/picture?type=large", completionHandler:{(image: UIImage?, url: String) in
                    dispatch_async(dispatch_get_main_queue(), {
                        self.profileImg.image = image
                    })
                    
                })
                self.profileImg.layer.cornerRadius = self.profileImg.frame.size.width/2
                self.profileImg.clipsToBounds = true
                self.performSegueWithIdentifier("showTbl", sender: self)
            } else {
                print("Error: \(error)")
                self.showLogout()
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTbl" {
            (segue.destinationViewController as! TBLController).username = self.userId
            (segue.destinationViewController as! TBLController).userFBname = self.userFBname
            let backItem = UIBarButtonItem()
            backItem.title = "Logout"
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    
    
    func registerUser(user: String, name: String) {
        print("Registering/Updating user: \(user) - \(name)")
        let url = self.baseApi+"/register"
        print("-> \(url)")
        let request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        request.HTTPMethod = "POST"
        
        let dataBody: NSDictionary = ["user":user,"name":name]
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
                    print("User updated!")
                } else {
                    print("Could not update user (-2)")
                }
            } else {
                print("Could not update user (-1)")
            }
        })
        
    }
    
    func showLogin(username: NSString?) {
        self.descLabel.text = "You are logged in with..."
        self.userLabel.hidden = false
        self.userLabel.text = "\(username!)"
        navigationItem.rightBarButtonItems = [self.goToTblButton]
    }
    
    func showLogout() {
        self.descLabel.text = "You are not logged in"
        self.userLabel.hidden = false
        self.userLabel.text = ""
        self.profileImg.image = UIImage(named: "anonym_icon")
        navigationItem.rightBarButtonItems = []
    }

}



















