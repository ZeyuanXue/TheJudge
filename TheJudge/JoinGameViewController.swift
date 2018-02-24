//
//  JoinGameViewController.swift
//  TheJudge
//
//  Created by ZEYUAN XUE on 2017/12/22.
//  Copyright © 2017年 ZEYUAN XUE. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class JoinGameViewController: UIViewController {

    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var roomNum: UILabel!
    @IBOutlet weak var enterRoomNum: UITextField!
    @IBOutlet weak var takeSeat: UIButton!
    
    var tf = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roomNum.isHidden = true
        enterRoomNum.keyboardType = .numberPad
        serverController.setSession()
        
        testLabel.text = GameController().testx
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.connect), name: NSNotification.Name(rawValue: "DidChangeStateNotification"), object: nil)
        
        
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func joinGame(_ sender: Any) {
        enterRoomNum.resignFirstResponder()
        if tf == 0{
            roomNum.text = enterRoomNum.text
            enterRoomNum.isHidden = true
            roomNum.isHidden = false
            serverController.advertiseSelf(advertise: true, roomNum: enterRoomNum.text!)
            tf = 1
        }
    }
    
    
    @IBAction func reset(_ sender: Any) {
        if tf == 1{
            roomNum.isHidden = true
            enterRoomNum.isHidden = false
            serverController.advertiseSelf(advertise: false, roomNum: "")
            tf = 0
        }
        
    }
    
    
    @IBAction func ff(_ sender: Any) {
        print(serverController.session.connectedPeers)
    }
    
    
    
    
    @objc func connect (notification : NSNotification){
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        let state = userInfo.object(forKey: "state") as! Int
        if state != MCSessionState.connecting.rawValue{
            self.navigationItem.title = "connected"
        }
        if state == MCSessionState.connected.rawValue{
            print(gameController.seatList)
            while(serverController.waitingDataCount != 3){}
            print(gameController.seatList)
            performSegue(withIdentifier: "takeseat", sender: self)
        }
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
