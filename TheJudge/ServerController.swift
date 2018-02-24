//
//  ServerController.swift
//  TheJudge
//
//  Created by ZEYUAN XUE on 2017/12/22.
//  Copyright © 2017年 ZEYUAN XUE. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class ServerController : NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate{
    
    
    var peerID : MCPeerID! = MCPeerID(displayName: UIDevice.current.name)
    var session : MCSession! = nil
    var browser : MCNearbyServiceBrowser!
    var advertiser : MCNearbyServiceAdvertiser!
    
    var myName : String = ""
    
    var sessionCount : Int = 0
    var session2 : MCSession? = nil
    var host : Bool = false
    
    var waitingDataCount : Int = 0
    
    var readyCount : Int = 0
    var actReceivedConfirm : Int = 0
    
    
    func reset (){
        self.session = nil
        self.session2 = nil
        self.browser = nil
        self.advertiser = nil
        self.sessionCount = 0
        
    }
    
    func getPeerNum () -> Int{
        if session2 != nil{
            return (session2!.connectedPeers.count) + (session.connectedPeers.count)
        }else{
            return session.connectedPeers.count
        }
    }
    
    func setSession () {
        session = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = session.delegate ?? self
        self.sessionCount += 1
    }
    func setSession2 () {
        session2 = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .required)
        session2!.delegate = session.delegate ?? self
        self.sessionCount += 1
    }
    
    
    func setBrowser (roomNum: String) {
        gameController.roomNum = roomNum
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: "judge-\(roomNum)")
        browser.delegate = browser.delegate ?? self
        
    }
    
    func advertiseSelf (advertise : Bool , roomNum : String){
        gameController.roomNum = roomNum
        myName = self.peerID.displayName
        if advertise {
            advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "judge-\(roomNum)")
            advertiser.delegate = advertiser.delegate ?? self
            advertiser.startAdvertisingPeer()
        }else{
            advertiser.stopAdvertisingPeer()
            advertiser = nil
        }
    }
    
    func createNewGame (){
        setSession()
        setSession2()
        advertiseSelf(advertise: true, roomNum: gameController.getRoomNum())
        setBrowser(roomNum: gameController.getRoomNum())
        browser.startBrowsingForPeers()
    }
    
    func sendDataToPeer(data : Data){
        do{
            try self.session.send(data, toPeers: session.connectedPeers, with: .reliable)
        }catch{
            debugPrint(error)
        }
        if self.session2 != nil{
            do{
                try self.session2!.send(data, toPeers: session2!.connectedPeers, with: .reliable)
            }catch{
                
            }
        }
    }
    
    func dataWrapper (data : [String]) -> Data{
        var message : Data?? = nil
        do{
            message = try JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions.prettyPrinted)
            
        }catch{
            debugPrint(error)
        }
        return message!!
    }
    
    
    
    //Session Delegate
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        //TODO: Fill func didChangeState
        switch (state){
        case .notConnected:
            print("notConnected\n\n")
            
        case .connected:
            print("connected\n\n")
            if host{
                do{
                    let playerNumData = NSKeyedArchiver.archivedData(withRootObject: ["playerNum", gameController.playerNum])
                    try session.send(playerNumData, toPeers: [peerID], with: .reliable)
                    let roleAmountData = NSKeyedArchiver.archivedData(withRootObject: ["roleAmount",gameController.roleAmountCollection])
                    try session.send(roleAmountData, toPeers: [peerID], with: .reliable)
                    let seatListData = NSKeyedArchiver.archivedData(withRootObject: ["seatList", gameController.seatList])
                    try session.send(seatListData, toPeers: [peerID], with: .reliable)
                }catch{
                    debugPrint(error)
                }
            }else{
                
            }
            
        case .connecting:
            print("connecting\n\n")
        }
        let userInfo = ["peerID" : peerID, "state" : state.rawValue] as [String : Any]
        DispatchQueue.main.async(execute : {() -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DidChangeStateNotification"), object: nil, userInfo: userInfo)
        })
        
    }
    
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        //TODO: Fill func didReceiveData
//        do{
//
//            let message = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSArray
//            gameController.tempProcess(content: message[0] as! String)
//            print(message)
//        }catch{
//            debugPrint(error)
//        }
        
        let temp = NSKeyedUnarchiver.unarchiveObject(with: data) as! [Any]
        let title = temp[0] as! String
        let receivedData = temp[1]
        print("safe\n")
        if title == "roleAmount"{
            gameController.roleAmountCollection = receivedData as! [String : Int]
            gameController.createCollection(roles: gameController.roleAmountCollection)
            print("recieived\n")
            waitingDataCount += 1
        }else if title == "roleOrder"{
            gameController.roleOrder = receivedData as! [Int]
            gameController.rearrange(order: gameController.roleOrder)
            let userInfo = ["peerID" : peerID, "data" : data] as [String : Any]
            DispatchQueue.main.async (execute : { () -> Void in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReceivedGameDataNotification"), object: nil, userInfo: userInfo)
            })
        }else if title == "playerNum"{
            gameController.playerNum = receivedData as! Int
            gameController.createSeatList()
            waitingDataCount += 1
        }else if title == "SeatToHost"{
            if host{
                gameController.updateSeatList(name: peerID.displayName, seat: ((receivedData as! [Any])[0] as! Int), tf: ((receivedData as! [Any])[1] as! Bool))
                let seatMsg = NSKeyedArchiver.archivedData(withRootObject: ["SeatToPeer", [peerID.displayName, (receivedData as! [Any])[0],(receivedData as! [Any])[1]]])
                sendDataToPeer(data: seatMsg)
                if host{
                    let userInfo = ["peerID" : peerID, "data" : data] as [String : Any]
                    DispatchQueue.main.async (execute : { () -> Void in
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReceivedGameDataNotification"), object: nil, userInfo: userInfo)
                    })
                }
            }
        }else if title == "SeatToPeer"{
            if !host{
                let seatName = String(describing: (receivedData as! [Any])[0])
                print(seatName)
                let seatNumber0 = (receivedData as! [Any])[1] as! Int
                let seatTf = (receivedData as! [Any])[2] as! Bool
                gameController.updateSeatList(name: seatName, seat: seatNumber0, tf: seatTf)
                let userInfo = ["peerID" : peerID, "data" : data] as [String : Any]
                DispatchQueue.main.async (execute : { () -> Void in
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReceivedGameDataNotification"), object: nil, userInfo: userInfo)
                })
            }
        }else if title == "seatList"{
            gameController.seatList = receivedData as! [[Any]]
            waitingDataCount += 1
        }else if title == "StartGame"{
            if !host{
                do{
                    let replyData = NSKeyedArchiver.archivedData(withRootObject: ["ReceiveStart",[]])
                    try session.send(replyData, toPeers: [peerID], with: .reliable)
                }catch{
                    debugPrint(error)
                }
                let userInfo = ["peerID" : peerID, "data" : data] as [String : Any]
                DispatchQueue.main.async (execute : { () -> Void in
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReceivedGameDataNotification"), object: nil, userInfo: userInfo)
                })
            }
        }else if title ==  "ReceiveStart"{
            readyCount += 1
        }else if title == "GameDataToHost"{
            if host{
                let transferData = NSKeyedArchiver.archivedData(withRootObject: ["GameDataToPeer",receivedData])
                sendDataToPeer(data: transferData)
                //TODO
            }
        }else if title == "GameDataToPeer"{
            if !host{
                //TODO
            }
        }else if title == "received"{
            actReceivedConfirm += 1
            print("connectedPeers in SC : \(session.connectedPeers)")
            if actReceivedConfirm == getPeerNum(){
                actReceivedConfirm = 0
                let userInfo = ["peerID" : peerID, "data" : data] as [String : Any]
                DispatchQueue.main.async (execute : { () -> Void in
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReceivedGameDataNotification"), object: nil, userInfo: userInfo)
                })
            }
        }else if title == "confirmed"{
            actReceivedConfirm += 1
            let userInfo = ["peerID" : peerID, "data" : data] as [String : Any]
            DispatchQueue.main.async (execute : { () -> Void in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReceivedGameDataNotification"), object: nil, userInfo: userInfo)
            })
        }else {
            print("debugging wolves")
            let userInfo = ["peerID" : peerID, "data" : data] as [String : Any]
            DispatchQueue.main.async (execute : { () -> Void in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReceivedGameDataNotification"), object: nil, userInfo: userInfo)
            })
        }
        print("received data\n\n\n\n\n")
        
        
        
        
    }
    
    
    
//    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
//        certificateHandler(true)
//
//    }
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        //TODO: Fill func didStartReceivingResourceWithName
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL??, withError error: Error?) {
        //TODO: Fill func didFinishReceiveingResourceWithName
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        //TODO: Fill func didReceiveStream
    }
    
    //Advertiser Delegate
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Did not start advertise\n\n")
       
        
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Invitation received\n\n")
        invitationHandler(true, self.session)
        
    }
    
    
    
    //Browser Delegate
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found peer\n\n")
        
        if self.session2 != nil {
            if self.session2!.connectedPeers.count < 7 && self.session.connectedPeers.count >= 7{
                browser.invitePeer(peerID, to: self.session2!, withContext: nil, timeout: 20)
                print("1\n")
            }else if self.session2!.connectedPeers.count >= 7 && self.session.connectedPeers.count >= 7{
                //TODO max peer
            }else{
                browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 20)
                print("2\n")
            }
        }else{
            if self.session.connectedPeers.count >= 7{
                setSession2()
                browser.invitePeer(peerID, to: self.session2!, withContext: nil, timeout: 20)
                print("3\n")
            }else{
                browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 20)
                print("4\n")
            }
        }
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer \n\n")
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("did not start browsing \n\n")
        
    }

    
    
}

