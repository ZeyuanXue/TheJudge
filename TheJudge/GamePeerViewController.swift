//
//  GamePeerViewController.swift
//  TheJudge
//
//  Created by ZEYUAN XUE on 2017/12/27.
//  Copyright © 2017年 ZEYUAN XUE. All rights reserved.
//

import UIKit

class GamePeerViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var otherInfo: UILabel!
    @IBOutlet weak var enteredPlayerNum: UITextField!
    
    @IBOutlet weak var poison: UIButton!
    @IBOutlet weak var medicine: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var electionIn: UIButton!
    @IBOutlet weak var electionOut: UIButton!
    @IBOutlet weak var speechEnd: UIButton!
    @IBOutlet weak var voteButton: UIButton!
    @IBOutlet weak var notVoteButton: UIButton!
    @IBOutlet weak var voteInfo: UILabel!
    
    var tonightKilled : Int = 0
    var actNum : Int = 0
    var actType : String = ""
    var timer : Timer = Timer()
    var hunterTimer : Timer = Timer()
    var nightCount : Int = 1
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enteredPlayerNum.isHidden = true
        confirmButton.isHidden = true
        medicine.isHidden = true
        poison.isHidden = true
        otherInfo.isHidden = true
        electionIn.isHidden = true
        electionOut.isHidden = true
        speechEnd.isHidden = true
        voteButton.isHidden = true
        notVoteButton.isHidden = true
        voteInfo.isHidden = true
        enteredPlayerNum.keyboardType = .numberPad
        NotificationCenter.default.addObserver(self, selector: #selector(self.gameProcess), name: NSNotification.Name(rawValue: "ReceivedGameDataNotification"), object: nil)

        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideAllButtons (){
        enteredPlayerNum.isHidden = true
        confirmButton.isHidden = true
        medicine.isHidden = true
        poison.isHidden = true
        otherInfo.isHidden = true
        electionIn.isHidden = true
        electionOut.isHidden = true
        speechEnd.isHidden = true
        voteButton.isHidden = true
        notVoteButton.isHidden = true
    }
    
    func wolvesTurn (){
        actType = "wolves"
        titleLabel.text = "狼人请猎杀目标"
        gameController.nightLog.append(NightLog(killed: 0, poisoned: 0, rescues: 0, guarded: 0) )
        
        if gameController.checkRole(role: "wolves"){
            enteredPlayerNum.isHidden = false
            confirmButton.isHidden = false
            
        }
    }
    
    func saviorTurn (){
        actType = "savior"
        titleLabel.text = "守卫请守护"
        
        if gameController.checkRole(role: "savior"){
            enteredPlayerNum.isHidden = false
            confirmButton.isHidden = false
            
        }
    }
    
    func seerTurn (){
        actType = "seer"
        titleLabel.text = "预言家请验人"
        
        if gameController.checkRole(role: "seer"){
            enteredPlayerNum.isHidden = false
            confirmButton.isHidden = false
            
        }
    }
    
    func witchTurn (){
        actType = "witch"
        titleLabel.text = "女巫请使用毒药或者解药"
        
        if gameController.checkRole(role: "witch"){
            enteredPlayerNum.isHidden = false
            medicine.isHidden = false
            poison.isHidden = false
            
            if gameController.roleObjectCollection[gameController.seatNum-1].medcine{
                otherInfo.text = "今晚被猎杀的是\(tonightKilled)号"
                otherInfo.isHidden = false
            }else {
                medicine.isEnabled = false
            }
            if !gameController.roleObjectCollection[gameController.seatNum-1].poison{
                poison.isEnabled = false
            }
            
        }
    }
    
    func hunterTurn (){
        titleLabel.text = "猎人今晚的开枪状态"
        actType = "hunter"
        
        if gameController.checkRole(role: "hunter"){
            if gameController.roleObjectCollection[gameController.seatNum-1].fireStatus {
                otherInfo.text = "如果死亡 你可以开枪"
            }else{
                otherInfo.text = "如果死亡 你不可以开枪"
            }
            otherInfo.isHidden = false
            perform(#selector(waitHunter), with: self, afterDelay: 8)
        }
    }
    
    func electionProcess (){
        otherInfo.isHidden = false
        titleLabel.text = "现在开始警长竞选申请"
        otherInfo.text = "5秒后结束竞选警长申请"
        electionIn.isHidden = false
        electionOut.isHidden = false
        perform(#selector(disableElectionButtons), with: self, afterDelay: 5)
    }
    
    @objc func disableElectionButtons(){
        electionOut.isHidden = true
        electionIn.isHidden = true
        
    }
    
    @IBAction func electionIn(_ sender: Any) {
        gameController.updateElectionStatus(status: true)
        gameController.updateElectionList(seat: gameController.seatNum, status: true)
        serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["electionDataToHost",[gameController.seatNum, true]]))
    }
    
    @IBAction func electionOut(_ sender: Any) {
        gameController.updateElectionStatus(status: false)
        gameController.updateElectionList(seat: gameController.seatNum, status: false)
        serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["electionDataToHost",[gameController.seatNum, false]]))
    }
    
    @IBAction func speechEnd(_ sender: Any) {
        speechEnd.isHidden = true
        serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["nextElectionSpeechToHost",[]]))
    }
    
    
    func electionVote (){
        gameController.initVoteList()
        if !gameController.electionList[gameController.seatNum-1]{
            enteredPlayerNum.isHidden = false
            voteButton.isHidden = false
            notVoteButton.isHidden = false
            perform(#selector(disableVoteButtons), with: self, afterDelay: 5)
        }
    }
    
    @objc func disableVoteButtons(){
        voteButton.isHidden = true
        notVoteButton.isHidden = true
        enteredPlayerNum.isHidden = true
    }
    
    @objc func disableVoteInfo (){
        voteInfo.isHidden = true
    }
    
    @IBAction func vote(_ sender: Any) {
        enteredPlayerNum.resignFirstResponder()
        let voted = Int(enteredPlayerNum.text!)!
        if actType == "day"{
            if gameController.electionList[voted-1]{
                serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["voteToHost",[gameController.seatNum, voted]]))
            }else{
                gameAlert(title: "该玩家已经死亡", message: "请重新选择")
            }
        }else{
            if gameController.electionList[voted-1]{
                serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["voteToHost",[gameController.seatNum, voted]]))
            }else{
                gameAlert(title: "该玩家没有竞选警长", message: "请重新选择")
            }
        }
    }
    
    @IBAction func notVote(_ sender: Any) {
        let voted = Int(enteredPlayerNum.text!)!
        if actType == "day"{
            if gameController.electionList[voted-1]{
                serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["voteToHost",[gameController.seatNum, 0]]))
            }else{
                gameAlert(title: "该玩家已经死亡", message: "请重新选择")
            }
        }else{
            if gameController.electionList[voted-1]{
                serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["voteToHost",[gameController.seatNum, 0]]))
            }else{
                gameAlert(title: "该玩家没有竞选警长", message: "请重新选择")
            }
        }
    }
    
    
    @objc func announcement (){
        enteredPlayerNum.isHidden = true
        confirmButton.isHidden = true
        medicine.isHidden = true
        poison.isHidden = true
        otherInfo.isHidden = true
        electionIn.isHidden = true
        electionOut.isHidden = true
        speechEnd.isHidden = true
        voteButton.isHidden = true
        notVoteButton.isHidden = true
        voteInfo.isHidden = true
        
        titleLabel.text = gameController.generateNightInfo()
        gameController.nightCount += 1
    }
    
    
    
    
    
    @IBAction func confirm(_ sender: Any) {
        enteredPlayerNum.resignFirstResponder()
        if actType == "wolves"{
            if gameController.aliveWolves() > 1{
                actNum = Int(enteredPlayerNum.text!)!
                let actData = NSKeyedArchiver.archivedData(withRootObject: ["confirmToActToHost",[actType, actNum, gameController.seatNum]])
                serverController.sendDataToPeer(data: actData)
            }else {
                actNum = Int(enteredPlayerNum.text!)!
                serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["wolvesActedToHost",[actNum]]))
                enteredPlayerNum.isHidden = true
                confirmButton.isHidden = true
            }
        }else if actType == "savior"{
            actNum = Int(enteredPlayerNum.text!)!
            serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["saviorActedToHost",[actNum]]))
        }else if actType == "seer"{
            actNum = Int(enteredPlayerNum.text!)!
            let goodness = gameController.checkGoodness(seat: actNum)
            if goodness{
                titleLabel.text = "\(actNum)号是好人"
            }else{
                titleLabel.text = "\(actNum)是坏人"
            }
            confirmButton.isHidden = true
            perform(#selector(waitSeer), with: self, afterDelay: 8)
        }
    }
    
    @IBAction func rescue(_ sender: Any) {
        medicine.isHidden = true
        poison.isHidden = true
        enteredPlayerNum.isHidden = true
        otherInfo.isHidden = true
        actNum = tonightKilled
        medicine.isEnabled = false
        serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["witchActedToHost", ["medicine",tonightKilled, gameController.seatNum]]))
        
    }
    
    @IBAction func usePoison(_ sender: Any) {
        enteredPlayerNum.resignFirstResponder()
        medicine.isHidden = true
        poison.isHidden = true
        enteredPlayerNum.isHidden = true
        otherInfo.isHidden = true
        actNum = Int(enteredPlayerNum.text!)!
        poison.isEnabled = false
        serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["witchActedToHost",["poison",actNum,gameController.seatNum]]))
        
        
    }
    
    
    
    
    func gameAlert (title: String , message: String ){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func killAlert (title: String , message: String, start : Int , target : Int){
        print("killAlert in Peer : start - \(start) target - \(target)")
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: {(action) in
            serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["confirmed",["wolves", target, start]]))
            print("in confirmed peer - alert")
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Unconfirm", style: UIAlertActionStyle.default, handler: {(action) in
            serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["unconfirmed",["wolves", target, start]]))
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func waitSeer (){
        serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["seerActedToHost",[]]))
    }
    
    @objc func waitHunter(){
        serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["hunterActedToHost",[]]))
    }
    
    
    
    @objc func gameProcess(notification : Notification){
        let userInfo = notification.userInfo! as NSDictionary
        let data:Data = userInfo.object(forKey: "data") as! Data
        let temp = NSKeyedUnarchiver.unarchiveObject(with: data) as! [Any]
        let title = temp[0] as! String
        let receivedData = temp[1] as! [Any]
        
        if title == "wolvesAct"{
            wolvesTurn()
        }else if title == "saviorAct"{
            saviorTurn()
        }else if title == "seerAct"{
            seerTurn()
        }else if title == "witchAct"{
            witchTurn()
        }else if title == "hunterAct"{
            hunterTurn()
        }else if title == "wolvesActed"{
            enteredPlayerNum.text = ""
            
            actType = ""
            enteredPlayerNum.isHidden = true
            confirmButton.isHidden = true
            tonightKilled = ((receivedData as [Any])[0] as! Int)
            gameController.killed(seat: tonightKilled)
            serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["received",[]]))
            actNum = 0
        }else if title == "saviorActed"{
            enteredPlayerNum.text = ""
            enteredPlayerNum.isHidden = true
            confirmButton.isHidden = true
            
            actType = ""
            gameController.guardedAtNight(seat: ((receivedData as [Any])[0] as! Int))
            serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["received",[]]))
            actNum = 0
        }else if title == "seerActed"{
            enteredPlayerNum.isHidden = true
            confirmButton.isHidden = true
            actType = ""
            
            serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["received",[]]))
            actNum = 0
        }else if title == "witchActed"{
            let witchAction = (receivedData as [Any])[0] as! String
            if witchAction == "poison"{
                gameController.poisoned(seat: (receivedData as [Any])[1] as! Int)
                gameController.roleObjectCollection[((receivedData as [Any])[2] as! Int)-1].poison = false
            }else{
                gameController.rescuedByWitch(seat: (receivedData as [Any])[1] as! Int)
                gameController.roleObjectCollection[((receivedData as [Any])[2] as! Int)-1].medcine = false
            }
            actType = ""
            actNum = 0
            poison.isHidden = true
            medicine.isHidden = true
            otherInfo.isHidden = true
            enteredPlayerNum.isHidden = true
            serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["received",[]]))
        }else if title == "hunterActed"{
            actType = ""
            actNum = 0
            otherInfo.isHidden = true
            serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["received",[]]))
        }else if title == "unconfirmedFromHost"{
            if gameController.checkRole(role: "wolves"){
                enteredPlayerNum.text = ""
                actNum = 0
                actType = ""
                gameAlert(title: "队友不支持猎杀此目标", message: "请重新猎杀")
            }
        }else if title == "confirmedFromHost"{
            if ((receivedData as [Any])[2] as! Int) == gameController.seatNum {
                tonightKilled = actNum
                print("confirmedFromHost\(actNum)")
                actType = ""
                
                confirmButton.isHidden = true
                enteredPlayerNum.isHidden = true
                serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["wolvesActedToHost",[actNum]]))
                actNum = 0
                //TODO : Find similar bugs
            }
        }else if title == "confirmToAct"{
            if ((receivedData as [Any])[0] as! String ) == "wolves"{
                if gameController.checkRole(role: "wolves"){
                killAlert(title: "\((receivedData as [Any])[2] as! Int)号队友决定猎杀\((receivedData as [Any])[1] as! Int)", message: "请确认", start: ((receivedData as [Any])[2] as! Int), target : ((receivedData as [Any])[1] as! Int))
                }
            }
        }else if title == "electionTurn"{
            electionProcess()
        }else if title == "electionData"{
            gameController.electionList = receivedData[0] as![Bool]
            let electionPlayers = gameController.electionPlayerGeneration()
            titleLabel.text = electionPlayers
            if electionPlayers == "没有玩家参选警长"{
                otherInfo.isHidden = true
                perform(#selector(announcement), with: self, afterDelay: 5)
            }else {
                let startPlayer = receivedData[1] as! Int
                gameController.electionSpeech.append(startPlayer)
                gameController.clockwise = receivedData[2] as! Bool
                otherInfo.text = "从\(startPlayer)号玩家开始发言"
                if startPlayer == gameController.seatNum{
                    speechEnd.isHidden = false
                }
            }
        }else if title == "nextElectionSpeech"{
            let speechPlayer = gameController.nextSpeech()
            otherInfo.text = "\(speechPlayer)号玩家发言"
            if speechPlayer == gameController.seatNum{
                speechEnd.isHidden = false
            }
        }else if title == "becomeSheriff"{
            otherInfo.text = "\(receivedData[0] as! Int)号玩家当选警长"
            gameController.roleObjectCollection[(receivedData[0] as! Int)-1].isSheriff = true
            perform(#selector(announcement), with: self, afterDelay: 5)
        }else if title == "electionVote"{
            electionVote()
        }else if title == "redoElection"{
            gameController.electionSpeech = []
        }else if title  == "voteResult"{
            print("received vote result")
            gameController.voteList = receivedData[0] as! [Int]
            voteInfo.isHidden = false
            voteInfo.text = gameController.generateVoteInfo()
            gameController.voteList = []
            gameController.initVoteList()
            perform(#selector(disableVoteInfo), with: self, afterDelay: 5)
        }else if title == "daySpeech"{
            actType = "day"
            gameController.deathAtNight = receivedData[0] as! [Int]
            if gameController.checkSheriff(){
                titleLabel.text = "请警长决定发言顺序"
            }else {
                titleLabel.text = "从\(gameController.daySpeechNext())号玩家开始发言"
            }
            gameController.deathAtNight = []
        }else if title == "dayVoteResult"{
            let result = receivedData[0] as! [Int]
            if result.count == 1{
                otherInfo.text = "\(result[0])号玩家被投出 请留遗言"
                gameController.voteToDie(seat: result[0])
            }else {
                var temp : String = ""
                for i in result{
                    temp.append("\(i)号玩家 ")
                }
                temp.append("同票 请重新发言并进行PK")
            }
        }else if title == "startDayVote"{
            voteButton.isHidden = false
            notVoteButton.isHidden = false
            enteredPlayerNum.isHidden = false
        }else if title == "endGame"{
            //TODO performSegue
        }
        
        
        
    }

}
