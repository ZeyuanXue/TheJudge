//
//  RoomViewController.swift
//  TheJudge
//
//  Created by ZEYUAN XUE on 2017/12/26.
//  Copyright © 2017年 ZEYUAN XUE. All rights reserved.
//

import UIKit

class RoomViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var checkRole: UIButton!
    
    @IBOutlet weak var roomNumber: UILabel!
    @IBOutlet weak var seatCollection: UICollectionView!
    
    var currentSeat : (Any)? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        seatCollection.delegate = self
        seatCollection.dataSource = self
        
        checkRole.isEnabled = false
        roomNumber.text = gameController.roomNum
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateSeat), name: NSNotification.Name(rawValue: "ReceivedGameDataNotification"), object: nil)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func test(_ sender: Any) {
        print("\(gameController.roleOrder)\n")
        print("\(gameController.roleAmountCollection)\n")
        print("\(gameController.roleObjectCollection)\n")
        print("\(gameController.playerNum)\n")
    }
    
    @objc func updateSeat(notification : NSNotification){
        let userInfo = notification.userInfo! as NSDictionary
        let data:Data = userInfo.object(forKey: "data") as! Data
        
        let temp = NSKeyedUnarchiver.unarchiveObject(with: data) as! [Any]
        let title = temp[0] as! String
        let receivedData = temp[1]
        if title == "SeatToPeer"{
            let seatName = (receivedData as! [Any])[0] as! String
            let seatNumber0 = (receivedData as! [Any])[1] as! Int
            let seatTf = (receivedData as! [Any])[2] as! Bool
            let index = IndexPath(row: seatNumber0-1, section: 0)
            print("IndexPath : \(index)\n \(title)\n\(seatName)\n\(seatNumber0)")
            
            if (seatName != serverController.myName){
                (seatCollection.cellForItem(at: index) as! CustomCell).seated = seatTf
                if seatTf{
                    (seatCollection.cellForItem(at: index) as! CustomCell).backgroundColor = UIColor.red
                    (seatCollection.cellForItem(at: index) as! CustomCell).seatLabel.text = "占用"
                }else{
                    (seatCollection.cellForItem(at: index) as! CustomCell).backgroundColor = UIColor.orange
                    (seatCollection.cellForItem(at: index) as! CustomCell).seatLabel.text = "空位"
                }
            }
        }else if title == "StartGame"{
            performSegue(withIdentifier: "joingamestart", sender: self)
        }else if title == "roleOrder"{
            checkRole.isEnabled = true
        }
    }
    
    
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
                let seatMsg0 = NSKeyedArchiver.archivedData(withRootObject: ["SeatToHost",[gameController.seatNum,false]])
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
            let seatMsg1 = NSKeyedArchiver.archivedData(withRootObject: ["SeatToHost",[gameController.seatNum, true]])
            serverController.sendDataToPeer(data: seatMsg1)
            gameController.updateSeatList(name: serverController.myName, seat: gameController.seatNum, tf: true)
        }else if (collectionView.cellForItem(at: indexPath) as! CustomCell).seatLabel.text == "自己"{
            (collectionView.cellForItem(at: indexPath) as! CustomCell).seatLabel.text = "空位"
            (collectionView.cellForItem(at: indexPath) as! CustomCell).seated = false
            (collectionView.cellForItem(at: indexPath) as! CustomCell).backgroundColor = UIColor.orange
            currentSeat = nil
            let seatMsg2 = NSKeyedArchiver.archivedData(withRootObject: ["SeatToHost", [gameController.seatNum, false]])
            serverController.sendDataToPeer(data: seatMsg2)
            gameController.updateSeatList(name: serverController.myName, seat: gameController.seatNum, tf: false)
            gameController.seatNum = 0
        }else{
            (collectionView.cellForItem(at: indexPath) as! CustomCell).isSelected = false
            (collectionView.cellForItem(at: indexPath) as! CustomCell).backgroundColor = UIColor.red
        }
//        for cell in collectionView.visibleCells{
//            if cell == collectionView.cellForItem(at: indexPath){
//                continue
//            }else if (cell as! CustomCell).seatLabel.text == "自己"{
//                (cell as! CustomCell).seatLabel.text = "空位"
//            }
//        }
        
        
    }
    
    
    @IBAction func checkRole(_ sender: Any) {
    }
    
    
    
}



