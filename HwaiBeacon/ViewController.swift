//
//  ViewController.swift
//  HwaiBeacon
//
//  Created by 周育賢 on 2018/3/21.
//  Copyright © 2018年 周育賢. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation
import WebKit

class ViewController: UIViewController,CLLocationManagerDelegate {
    let locationManager = CLLocationManager()

    let region = CLBeaconRegion(proximityUUID: NSUUID(uuidString: "fda50693-a4e2-4fb1-afcf-c6eb07647825") as! UUID, identifier: "Helloworld")
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.delegate  = self
        if(CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse){
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startRangingBeacons(in: region)
        //loading webView(WKWebView)
        
        let myWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        if let url = URL(string: "https://sites.google.com/view/hwai-yeh"){
            let request = URLRequest(url: url)
            myWebView.load(request)
        }
        view.addSubview(myWebView)
        //local notification
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound,.badge], completionHandler: {data,error in})
        pushNotification()
        // loading data
        guard let url = URL(string: "http://itc.hwai.edu.tw/2017usr/ibeacon/api/ibeacon") else {return}
        URLSession.shared.dataTask(with: url){ (data, responce, err) in
            if let jsonData = data{
                do{
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
                    print(json)
                    /*
                     * decode json
                     * 參考： https://www.youtube.com/watch?v=ih20QtEVCa0&feature=youtu.be
                     */
                    guard let arr = json as? [Any] else { return }
                    for result in arr{
                        guard let dist = result as? [String:Any] else { return }
                        guard let title = dist["title"] as? String else { return }
                        guard let content = dist["content"] as? String else { return }
                        guard let uuid = dist["UUID"] as? String else { return }
                        guard let major_id = dist["Major_ID"] as? String else { return }
                        guard let minor_id = dist["Minor_ID"] as? String else { return }
                        guard let link = dist["link"] as? String else { return }
                        print(title)
                        print(content)
                        print(uuid)
                        print(major_id)
                        print(minor_id)
                        print(link)
                    }
                }catch{
                    print(error);
                }
            }
        }.resume()
        
    }
    // push local Notification
    func pushNotification(){
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "你好世界！"
        notificationContent.subtitle = "我在測試通知"
        notificationContent.body = "Hay Girl"
        notificationContent.badge = 1
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "SimplifiediOSNotification",
            content: notificationContent,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request,withCompletionHandler: nil)
        
    }
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print(beacons);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

