//
//  NewGameViewController.swift
//  TheJudge
//
//  Created by ZEYUAN XUE on 2017/12/22.
//  Copyright © 2017年 ZEYUAN XUE. All rights reserved.
//

import UIKit
import MultipeerConnectivity


class NewGameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var assignRole: UIButton!
    @IBOutlet weak var checkRole: UIButton!
    @IBOutlet weak var seatCollection: UICollectionView!
    
    @IBOutlet weak var label0: UILabel!
    @IBOutlet weak var roomNumber: UILabel!
    var appDelegate : AppDelegate!
    
    @IBOutlet weak var starGame: UIButton!
    var currentSeat : (Any)? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        seatCollection.delegate = self
        seatCollection.dataSource = self
        assignRole.isEnabled = false
        checkRole.isEnabled = false
        
        gameController.setRoomNum(num: String(arc4random_uniform(9999)))
        roomNumber.text = gameController.getRoomNum()
        starGame.isEnabled = false
        serverController.host = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.ready), name: NSNotification.Name(rawValue: "DidChangeStateNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateSeat), name: NSNotification.Name(rawValue: "ReceivedGameDataNotification"), object: nil)
        
//        serverController.setSession()
//        serverController.advertiseSelf(advertise: true, roomNum: gameController.getRoomNum())
//        serverController.setBrowser(roomNum: gameController.getRoomNum())
//        serverController.browser.startBrowsingForPeers()
        serverController.createNewGame()
        
        
        
        
    
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func checkRole(_ sender: Any) {
    }
    @IBAction func assignRole(_ sender: Any) {
        var shuffled = [Int]();
        var tempNum : [Int] = []
        for i in 0...(gameController.playerNum-1){
            tempNum.append(i)
        }
        for _ in 0..<tempNum.count
        {
            let rand = Int(arc4random_uniform(UInt32(tempNum.count)))
            
            shuffled.append(tempNum[rand])
            
            tempNum.remove(at: rand)
        }
        print(shuffled)
        gameController.rearrange(order: shuffled)
        let roleOrderData = NSKeyedArchiver.archivedData(withRootObject: ["roleOrder",shuffled])
        serverController.sendDataToPeer(data: roleOrderData)
        starGame.isEnabled = true
        checkRole.isEnabled = true
    }
    
    @objc func ready (notification : NSNotification){
        //let userInfo = NSDictionary(dictionary: notification.userInfo!)
        //let state = userInfo.object(forKey: "state") as! Int
        if serverController.session2 != nil{
            if gameController.playerNum == (serverController.session.connectedPeers.count + serverController.session2!.connectedPeers.count + 1){
                assignRole.isEnabled = true
                serverController.browser.stopBrowsingForPeers()
                
                
                
            }
        }else{
            if gameController.playerNum == serverController.session.connectedPeers.count{
                starGame.isEnabled = true
                serverController.browser.stopBrowsingForPeers()
            }
        }
    }

    @objc func updateSeat(notification : NSNotification){
        let userInfo = notification.userInfo! as NSDictionary
        let data:Data = userInfo.object(forKey: "data") as! Data
        
        let temp = NSKeyedUnarchiver.unarchiveObject(with: data) as! [Any]
        let title = temp[0] as! String
        let receivedData = temp[1]
        if title == "SeatToHost"{
            let seatNumber0 = (receivedData as! [Any])[0] as! Int
            let seatTf = (receivedData as! [Any])[1] as! Bool
            let index = IndexPath(row: seatNumber0-1, section: 0)
            //print("IndexPath : \(index)\n \(title)\n\(seatName)\n\(seatNumber0)")
            
            
            
            (seatCollection.cellForItem(at: index) as! CustomCell).seated = seatTf
            if seatTf{
                (seatCollection.cellForItem(at: index) as! CustomCell).backgroundColor = UIColor.red
                (seatCollection.cellForItem(at: index) as! CustomCell).seatLabel.text = "占用"
            }else{
                (seatCollection.cellForItem(at: index) as! CustomCell).backgroundColor = UIColor.orange
                (seatCollection.cellForItem(at: index) as! CustomCell).seatLabel.text = "空位"
            }
        }
    }
    
    
    @IBAction func test(_ sender: Any) {
        serverController.sendDataToPeer(data: serverController.dataWrapper(data: ["hello"]))
        print(serverController.session.connectedPeers)
        print("\n\n\n")
        print(serverController.session2!.connectedPeers)
        
    }
    
    @IBAction func startGame(_ sender: Any) {
        if gameController.checkSeated() {
            
            let startData = NSKeyedArchiver.archivedData(withRootObject: ["StartGame",[]])
            serverController.sendDataToPeer(data: startData)
            while (serverController.readyCount != serverController.getPeerNum()){}
            performSegue(withIdentifier: "startnewgame", sender: self)
        }else{
            seatedAlert(title: "Someone Did Not Take A Seat", message: "Please start game when all player are seated.")
        }
    }
    
    // Seated Alert
    func seatedAlert (title: String , message: String ){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    
    
   //Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameController.playerNum
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = seatCollection.dequeueReusableCell(withReuseIdentifier: "seat", for: indexPath) as! CustomCell
        
        if gameController.seatList[indexPath.row][1] as! Bool{
            cell.backgroundColor = UIColor.red
            cell.seatNum.text = String(indexPath.row + 1)
            cell.seatLabel.text = "占用"
        }else{
            cell.backgroundColor = UIColor.orange
            cell.seatNum.text = String(indexPath.row + 1)
            cell.seatLabel.text = "空位"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (currentSeat as? IndexPath) != nil{
            if (currentSeat as! IndexPath) != indexPath{
                (collectionView.cellForItem(at: (currentSeat as! IndexPath)) as! CustomCell).seated = false
                (collectionView.cellForItem(at: (currentSeat as! IndexPath)) as! CustomCell).seatLabel.text = "空位"
                (collectionView.cellForItem(at: (currentSeat as! IndexPath)) as! CustomCell).backgroundColor = UIColor.orange
                let seatMsg0 = NSKeyedArchiver.archivedData(withRootObject: ["SeatToPeer",[serverController.myName, gameController.seatNum,false]])
                serverController.sendDataToPeer(data: seatMsg0)
                gameController.updateSeatList(name: serverController.myName, seat: gameController.seatNum, tf: false)
            }
        }
        if (collectionView.cellForItem(at: indexPath) as! CustomCell).seatLabel.text == "空位"{
            (collectionView.cellForItem(at: indexPath) as! CustomCell).seatLabel.text = "自己"
            (collectionView.cellForItem(at: indexPath) as! CustomCell).seated = true
            (collectionView.cellForItem(at: indexPath) as! CustomCell).backgroundColor = UIColor.green
            currentSeat = indexPath as Any
            gameController.seatNum = indexPath.row+1
            let seatMsg1 = NSKeyedArchiver.archivedData(withRootObject: ["SeatToPeer",[serverController.myName, gameController.seatNum, true]])
            serverController.sendDataToPeer(data: seatMsg1)
            gameController.updateSeatList(name: serverController.myName, seat: gameController.seatNum, tf: true)
        }else if (collectionView.cellForItem(at: indexPath) as! CustomCell).seatLabel.text == "自己"{
            (collectionView.cellForItem(at: indexPath) as! CustomCell).seatLabel.text = "空位"
            (collectionView.cellForItem(at: indexPath) as! CustomCell).seated = false
            (collectionView.cellForItem(at: indexPath) as! CustomCell).backgroundColor = UIColor.orange
            currentSeat = nil
            let seatMsg2 = NSKeyedArchiver.archivedData(withRootObject: ["SeatToPeer", [serverController.myName, gameController.seatNum, false]])
            serverController.sendDataToPeer(data: seatMsg2)
            gameController.updateSeatList(name: serverController.myName, seat: gameController.seatNum, tf: false)
            gameController.seatNum = 0
        }else{
            (collectionView.cellForItem(at: indexPath) as! CustomCell).isSelected = false
            (collectionView.cellForItem(at: indexPath) as! CustomCell).backgroundColor = UIColor.red
        }
    }
    
}

