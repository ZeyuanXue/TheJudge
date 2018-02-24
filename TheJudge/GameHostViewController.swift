//
//  GameHostViewController.swift
//  TheJudge
//
//  Created by ZEYUAN XUE on 2017/12/27.
//  Copyright © 2017年 ZEYUAN XUE. All rights reserved.
//

import UIKit

class GameHostViewController: UIViewController {

    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var enterPlayerNum: UITextField!
    
    @IBOutlet weak var otherInfo: UILabel!
    @IBOutlet weak var medicineButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var poisonButton: UIButton!{
        didSet{
            print("poison button : \(poisonButton.isHidden)\n\n")
        }}
    @IBOutlet weak var electionIn: UIButton!
    @IBOutlet weak var electionOut: UIButton!
    @IBOutlet weak var speechEnd: UIButton!
    @IBOutlet weak var voteButton: UIButton!
    @IBOutlet weak var notVoteButton: UIButton!
    @IBOutlet weak var voteInfo: UILabel!
    @IBOutlet weak var startDayVote: UIButton!
    
    var tonightKilled : Int = 0
    var actNum : Int = 0
    var actType : String = ""
    var timer : Timer = Timer()
    var hunterTimer : Timer = Timer()
    var nightCount : Int = 1
    var myChoice : Int = 0
    var electionStatus : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enterPlayerNum.isHidden = true
        confirmButton.isHidden = true
        medicineButton.isHidden = true
        poisonButton.isHidden = true
        otherInfo.isHidden = true
        actType = gameController.existingRoleOrder[0]
        electionIn.isHidden = true
        electionOut.isHidden = true
        speechEnd.isHidden = true
        voteButton.isHidden = true
        notVoteButton.isHidden = true
        voteInfo.isHidden = true
        startDayVote.isHidden = true
        enterPlayerNum.keyboardType = .numberPad
        NotificationCenter.default.addObserver(self, selector: #selector(self.gameProcess), name: NSNotification.Name(rawValue: "ReceivedGameDataNotification"), object: nil)
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        werewolvsTurn()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideAllButtons(){
        enterPlayerNum.isHidden = true
        confirmButton.isHidden = true
        medicineButton.isHidden = true
        poisonButton.isHidden = true
        otherInfo.isHidden = true
        electionIn.isHidden = true
        electionOut.isHidden = true
        speechEnd.isHidden = true
        voteButton.isHidden = true
        notVoteButton.isHidden = true
    }
    
    
    func nextTurn(current : String){
        print ("in nextTurn\n")
        var next : Bool = false
        actType = ""
        for role in gameController.existingRoleOrder{
            print("role : \(role) current : \(current) next : \(next)")
            if next{
                if role == "savior"{
                    print("守卫\n")
                    saviorTurn()
                    break
                }else if role == "seer"{
                    seerTurn()
                    break
                }else if role == "witch"{
                    witchTurn()
                    break
                }else if role == "hunter"{
                    hunterTurn()
                    break
                }
            }
            if role == current{
                next = true
                if gameController.existingRoleOrder[gameController.existingRoleOrder.count-1] == current{
                    if nightCount == 1{
                        electionProcess()
                        break
                    }else{
                        announcement()
                        break
                    }
                }
            }
        }
        
    }
    
    //Game Process Handlers
    @objc func gameProcess(notification : Notification){
        let userInfo = notification.userInfo! as NSDictionary
        let data:Data = userInfo.object(forKey: "data") as! Data
        let temp = NSKeyedUnarchiver.unarchiveObject(with: data) as! [Any]
        let title = temp[0] as! String
        let receivedData = temp[1] as! [Any]
        print(title)
        
        if title == "wolvesActedToHost"{
            print("here?\n")
            tonightKilled = (receivedData[0] as! Int)
            gameController.killed(seat: (receivedData[0] as! Int))
            actNum = 0
            enterPlayerNum.isHidden = true
            confirmButton.isHidden = true
            serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["wolvesActed",[tonightKilled]]))
        }else if title == "saviorActedToHost"{
            gameController.guardedAtNight(seat: (receivedData[0] as! Int))
            actNum = 0
            enterPlayerNum.isHidden = true
            confirmButton.isHidden = true
            serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["saviorActed",[(receivedData[0] as! Int)]]))
            
        }else if title == "seerActedToHost"{
            actNum = 0
            enterPlayerNum.isHidden = true
            confirmButton.isHidden = true
            serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["seerActed",[]]))
            
        }else if title == "witchActedToHost"{
            serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["witchActed",receivedData]))
            let witchAction = (receivedData as [Any])[0] as! String
            if witchAction == "poison"{
                gameController.poisoned(seat: (receivedData as [Any])[1] as! Int)
                gameController.roleObjectCollection[((receivedData as [Any])[2] as! Int)-1].poison = false
            }else{
                gameController.rescuedByWitch(seat: (receivedData as [Any])[1] as! Int)
                gameController.roleObjectCollection[((receivedData as [Any])[2] as! Int)-1].medcine = false
            }
            actNum = 0
            poisonButton.isHidden = true
            medicineButton.isHidden = true
            otherInfo.isHidden = true
            enterPlayerNum.isHidden = true
            
        }else if title == "hunterActedToHost"{
            serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["hunterActed",[]]))
        }else if title == "unconfirmed"{
            if gameController.checkRole(role: "wolves"){
                enterPlayerNum.text = ""
                actNum = 0
                serverController.actReceivedConfirm = 0
                gameAlert(title: "队友不支持猎杀此目标", message: "请重新猎杀")
            }
            if ((receivedData as [Any])[2] as! Int != gameController.seatNum){
                serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["unconfirmedFromHost",receivedData]))
            }
        }else if title == "confirmed"{
            print("in confirmed - host game\n \((receivedData as [Any])[2] as! Int) \n\((receivedData as [Any])[1] as! Int)\n")
            print("connectedPeer : \(serverController.session.connectedPeers)")
            if ((receivedData as [Any])[2] as! Int) == gameController.seatNum && serverController.actReceivedConfirm == (gameController.roleAmountCollection["wolves"]! - 1){
                print("**** 1 ****")
                serverController.actReceivedConfirm = 0
                tonightKilled = actNum
                gameController.killed(seat: actNum)
                serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["wolvesActed",[actNum]]))
                actNum = 0
                confirmButton.isHidden = true
                enterPlayerNum.isHidden = true
                
            }else if gameController.checkRole(role: "wolves") && ((receivedData as [Any])[2] as! Int) != gameController.seatNum && serverController.actReceivedConfirm == (gameController.roleAmountCollection["wolves"]! - 2){
                print("**** 2 ****")
                if myChoice == 1{
                    serverController.sendDataToPeer(data:NSKeyedArchiver.archivedData(withRootObject: ["confirmedFromHost",receivedData]))
                    serverController.actReceivedConfirm = 0
                    tonightKilled = actNum
                    gameController.killed(seat: actNum)
                    serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["wolvesActed",[actNum]]))
                    actNum = 0
                    confirmButton.isHidden = true
                    enterPlayerNum.isHidden = true
                    myChoice = 0
                }
            }else if gameController.checkRole(role: "wolves") && ((receivedData as [Any])[2] as! Int) != gameController.seatNum && myChoice == 2{
                print("**** 3 ****")
                serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["unconfirmedFromHost",receivedData]))
                myChoice = 0
            }else if !gameController.checkRole(role: "wolves") && serverController.actReceivedConfirm == (gameController.roleAmountCollection["wolves"]!){
                print("**** 4 ****")
                serverController.actReceivedConfirm = 0
                serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["confirmedFromHost",receivedData]))
            }
        }else if title == "confirmToActToHost"{
            if ((receivedData as [Any])[0] as! String ) == "wolves"{
                if gameController.checkRole(role: "wolves") {
                    killAlert(title: "\((receivedData as [Any])[2] as! Int)号队友决定猎杀\((receivedData as [Any])[1] as! Int)", message: "请确认", start: ((receivedData as [Any])[2] as! Int), target : ((receivedData as [Any])[1] as! Int))
                    serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["confirmToAct",receivedData]))
                }else {
                    serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["confirmToAct",receivedData]))
                }
            }
        }else if title == "received"{
            print("nextTurn Communication")
            nextTurn(current: actType)
        }else if title == "electionDataToHost"{
            if electionStatus{
                gameController.updateElectionList(seat: ((receivedData as [Any])[0] as! Int), status: ((receivedData as [Any])[1] as! Bool))
            }
        }else if title == "nextElectionSpeechToHost"{
            let speechPlayer = gameController.nextSpeech()
            if speechPlayer != 0{
                serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["nextElectionSpeech",[]]))
                otherInfo.text = "\(speechPlayer)号玩家发言"
                if speechPlayer == gameController.seatNum{
                    speechEnd.isHidden = false
                }
            }else{
                otherInfo.text = "现在开始投票"
                serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["electionVote",[]]))
                electionVote()
            }
        }else if title == "voteToHost"{
            gameController.voteList[(receivedData[0] as! Int) - 1] = receivedData[1] as! Int
        }
        
    }
    
    @objc func werewolvsTurn (){
        testLabel.text = "狼人请猎杀目标"
        actType = "wolves"
        gameController.nightLog.append(NightLog(killed: 0, poisoned: 0, rescues: 0, guarded: 0) )
        let werewolvesTurnData = NSKeyedArchiver.archivedData(withRootObject: ["wolvesAct",[]])
        serverController.sendDataToPeer(data: werewolvesTurnData)
        
        print(gameController.seatNum)
        print(gameController.roleObjectCollection)
        print("\n\n")
        
        if gameController.checkRole(role: "wolves"){
            enterPlayerNum.isHidden = false
            confirmButton.isHidden = false
            
        }
        
    }
    
    func seerTurn (){
        testLabel.text = "预言家请验人"
        actType = "seer"
        if gameController.checkRole(role: "seer"){
            enterPlayerNum.isHidden = false
            confirmButton.isHidden = false
            
        }
        let seerTurnData = NSKeyedArchiver.archivedData(withRootObject: ["seerAct",[]])
        serverController.sendDataToPeer(data: seerTurnData)
    }
    
    func saviorTurn(){
        testLabel.text = "守卫请守护"
        actType = "savior"
        if gameController.checkRole(role: "savior"){
            enterPlayerNum.isHidden = false
            confirmButton.isHidden = false
            
        }
        let seerTurnData = NSKeyedArchiver.archivedData(withRootObject: ["saviorAct",[]])
        serverController.sendDataToPeer(data: seerTurnData)
    }
    
    func witchTurn (){
        testLabel.text = "女巫请使用解药或者毒药"
        actType = "witch"
        
        if gameController.checkRole(role: "witch"){
            enterPlayerNum.isHidden = false
            medicineButton.isHidden = false
            poisonButton.isHidden = false
            
            if gameController.roleObjectCollection[gameController.seatNum-1].medcine{
                otherInfo.text = "今晚被猎杀的是\(tonightKilled)号"
                otherInfo.isHidden = false
            }else {
                medicineButton.isEnabled = false
            }
            if !gameController.roleObjectCollection[gameController.seatNum-1].poison{
                poisonButton.isEnabled = false
            }
            
        }
        let witchTurnData = NSKeyedArchiver.archivedData(withRootObject: ["witchAct",[]])
        serverController.sendDataToPeer(data: witchTurnData)
        
    }
    
    func hunterTurn(){
        testLabel.text = "猎人今晚的开枪状态"
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
        serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["hunterAct",[]]))
        
    }
    
    
    @IBAction func playerNumConfirmed(_ sender: Any) {
        enterPlayerNum.resignFirstResponder()
        if gameController.checkRole(role: "seer"){
            actNum = Int(enterPlayerNum.text!)!
            let goodness = gameController.checkGoodness(seat: actNum)
            if goodness{
                testLabel.text = "\(actNum)号是好人"
            }else{
                testLabel.text = "\(actNum)是坏人"
            }
            confirmButton.isHidden = true
            perform(#selector(waitSeer), with: self, afterDelay: 8)
        }else if gameController.checkRole(role: "savior"){
            actNum = Int(enterPlayerNum.text!)!
            gameController.guardedAtNight(seat: actNum)
            enterPlayerNum.isHidden = true
            confirmButton.isHidden = true
            serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["saviorActed",[actNum]]))
            actNum = 0
        }else{
            actNum = Int(enterPlayerNum.text!)!
            if gameController.aliveWolves()  > 1{
                let actData = NSKeyedArchiver.archivedData(withRootObject: ["confirmToAct",[actType, actNum, gameController.seatNum]])
                serverController.sendDataToPeer(data: actData)
            }else {
                serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["wolvesActed",[actNum]]))
                confirmButton.isHidden = true
                enterPlayerNum.isHidden = true
            }
            
        }
        
    }
    
    //Sheriff Election
    func electionProcess(){
        print("in election Process")
        print("buttons: medicine \(medicineButton.isHidden)  poison \(poisonButton.isHidden)")
        actType = "election"
        otherInfo.isHidden = false
        testLabel.text = "现在开始警长竞选申请"
        otherInfo.text = "5秒后结束竞选警长申请"
        serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["electionTurn",[]]))
        electionIn.isHidden = false
        electionOut.isHidden = false
        perform(#selector(disableElectionButtons), with: self, afterDelay: 5)
        
    }
    
    @objc func disableElectionButtons(){
        electionOut.isHidden = true
        electionIn.isHidden = true
        electionStatus = false
        let electionPlayers = gameController.electionPlayerGeneration()
        testLabel.text = electionPlayers
        if electionPlayers == "没有玩家参选警长"{
            otherInfo.isHidden = true
            serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["electionData",[gameController.electionList, 0, true]]))
            perform(#selector(announcement), with: self, afterDelay: 5)
        }else {
            let startPlayer = gameController.electionSpeechStartNum()
            if startPlayer < 0{
                otherInfo.text = "\(-startPlayer)号玩家自动当选警长"
                gameController.roleObjectCollection[(-startPlayer)-1].isSheriff = true
                serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["becomeSheriff",[-startPlayer]]))
                perform(#selector(announcement), with: self, afterDelay: 5)
            }
            else{
                otherInfo.text = "从\(startPlayer)号玩家开始发言"
                serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["electionData",[gameController.electionList, startPlayer, gameController.clockwise]]))
                if startPlayer == gameController.seatNum{
                    speechEnd.isHidden = false
                }
            }
        }
    }
    
    @IBAction func electionIn(_ sender: Any) {
        gameController.updateElectionStatus(status: true)
        gameController.updateElectionList(seat: gameController.seatNum, status: true)
    }
    
    @IBAction func electionOut(_ sender: Any) {
        gameController.updateElectionStatus(status: false)
        gameController.updateElectionList(seat: gameController.seatNum, status: false)
    }
    
    @IBAction func speechEnd(_ sender: Any) {
        let next = gameController.nextSpeech()
        if next != 0 {
            otherInfo.text = "\(next)号玩家发言"
            speechEnd.isHidden = true
            serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["nextElectionSpeech",[]]))
        }else {
            speechEnd.isHidden = true
            otherInfo.text = "现在开始投票"
            serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["electionVote",[]]))
            print("????????????")
            electionVote()
        }
    }
    
    func electionVote(){
        gameController.initVoteList()
        if !gameController.electionList[gameController.seatNum-1]{
            enterPlayerNum.isHidden = false
            voteButton.isHidden = false
            notVoteButton.isHidden = false
            serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["voteResult",[gameController.voteList]]))
            perform(#selector(disableVoteButtons), with: self, afterDelay: 5)
        }else{
            perform(#selector(voteResult), with: self, afterDelay: 5)
        }
    }
    
    @objc func disableVoteInfo (){
        voteInfo.isHidden = true
    }
    
    @objc func voteResult (){
        let result = gameController.generateVoteResult()
        print(result)
        print("in disable vote")
        if result.count == 1 {
            print("**** vote 1 ****")
            testLabel.text = "\(result[0])号玩家当选警长"
            voteInfo.isHidden = false
            voteInfo.text = gameController.generateVoteInfo()
            serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["voteResult",[gameController.voteList]]))
            perform(#selector(disableVoteInfo), with: self, afterDelay: 5)
            gameController.roleObjectCollection[result[0]-1].isSheriff = true
            serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["becomeSheriff",[result[0]]]))
            //TODO : otherInfo with vote information
            announcement()
        }else{
            print("**** vote 2 ****")
            gameController.electionCount += 1
            if gameController.electionCount > 2 {
                testLabel.text = "本局没有警长 即将公布昨夜信息"
                otherInfo.isHidden = true
                enterPlayerNum.isHidden = true
                perform(#selector(self.announcement), with: self, afterDelay: 5)
            }else{
                voteInfo.isHidden = false
                voteInfo.text = gameController.generateVoteInfo()
                serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["voteResult",[gameController.voteList]]))
                perform(#selector(disableVoteInfo), with: self, afterDelay: 5)
                serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["redoElection",[result]]))
                gameController.redoElectionUpdate(players: result)
                var titleText = ""
                for i in 0...(result.count-1){
                    titleText += "\(result[i])号玩家 "
                }
                titleText += "重新竞选"
                testLabel.text = titleText
                otherInfo.text = "由\(result[0])号玩家开始发言"
                gameController.electionSpeech.append(result[0])
                serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["electionData",[gameController.electionList, result[0], gameController.clockwise]]))
                if result[0] == gameController.seatNum{
                    speechEnd.isHidden = false
                }
            }
        }
    }
    
    
    @objc func disableVoteButtons(){
        voteButton.isHidden = true
        notVoteButton.isHidden = true
        enterPlayerNum.isHidden = true
        if actType == "day"{
            testLabel.text = gameController.generateVoteInfo()
            otherInfo.isHidden = false
            let result = gameController.generateVoteResult()
            serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["dayVoteResult",[result]]))
            if result.count == 1{
                otherInfo.text = "\(result[0])号玩家被投出 请留遗言 限时30秒"
                gameController.voteToDie(seat: result[0])
                var B : Bool = false
                var S : String = ""
                (B,S) = gameController.checkEndGame()
                if B{
                    serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["endGame",[S]]))
                    //TODO performSegue
                }else{
                    perform(#selector(werewolvsTurn), with: self, afterDelay: 30)
                }
                
            }else {
                var temp : String = ""
                for i in result{
                    temp.append("\(i)号玩家 ")
                }
                temp.append("同票 请重新发言并进行PK")
                startDayVote.isHidden = false
            }
        }else{
            voteResult()
        }
    }
    
    @IBAction func vote(_ sender: Any) {
        enterPlayerNum.resignFirstResponder()
        if actType == "day"{
            if gameController.roleObjectCollection[Int(enterPlayerNum.text!)!-1].alive{
                gameController.voteList[gameController.seatNum-1] = Int(enterPlayerNum.text!)!
            }else {
                gameAlert(title: "该玩家已死亡", message: "请重新选择")
            }
        }else{
            if gameController.electionList[Int(enterPlayerNum.text!)!-1]{
                gameController.voteList[gameController.seatNum-1] = Int(enterPlayerNum.text!)!
            }else {
                gameAlert(title: "该玩家没有竞选警长", message: "请重新选择")
            }
        }
    }
    
    @IBAction func notVote(_ sender: Any) {
        if actType == "day"{
            if gameController.roleObjectCollection[Int(enterPlayerNum.text!)!-1].alive{
                gameController.voteList[gameController.seatNum-1] = 0
            }else {
                gameAlert(title: "该玩家已死亡", message: "请重新选择")
            }
        }else {
            if gameController.electionList[Int(enterPlayerNum.text!)!-1]{
                gameController.voteList[gameController.seatNum-1] = 0
            }else {
                gameAlert(title: "该玩家没有竞选警长", message: "请重新选择")
            }
        }
    }
    
    
    
    @objc func announcement(){
        enterPlayerNum.isHidden = true
        confirmButton.isHidden = true
        medicineButton.isHidden = true
        poisonButton.isHidden = true
        otherInfo.isHidden = true
        actType = gameController.existingRoleOrder[0]
        electionIn.isHidden = true
        electionOut.isHidden = true
        speechEnd.isHidden = true
        voteButton.isHidden = true
        notVoteButton.isHidden = true
        voteInfo.isHidden = true
        
        testLabel.text = gameController.generateNightInfo()
        gameController.nightCount += 1
        var B : Bool = false
        var S : String = ""
        (B,S) = gameController.checkEndGame()
        if B{
            serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["endGame",[S]]))
            //TODO performSegue
        }else{
            perform(#selector(dayProcess), with: self, afterDelay: 5)
        }
    }
    
    @objc func dayProcess (){
        actType = "day"
        if gameController.checkSheriff(){
            testLabel.text = "请警长决定发言顺序"
        }else {
           testLabel.text = "从\(gameController.daySpeechNext())号玩家开始发言"
        }
        serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["daySpeech",[gameController.deathAtNight]]))
        gameController.deathAtNight = []
    }
    
    @IBAction func startDayVote(_ sender: Any) {
        testLabel.text = "现在开始投票"
        enterPlayerNum.isHidden = false
        voteButton.isHidden = false
        notVoteButton.isHidden = false
        otherInfo.isHidden = true
        gameController.voteList = []
        serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["startDayVote",[]]))
        perform(#selector(disableVoteButtons), with: self, afterDelay: 5)
    }

    
    
    @IBAction func rescueButton(_ sender: Any) {
        medicineButton.isHidden = true
        poisonButton.isHidden = true
        otherInfo.isHidden = true
        enterPlayerNum.isHidden = true
        gameController.rescuedByWitch(seat: tonightKilled)
        serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["witchActed",["medicine",tonightKilled, gameController.seatNum]]))
        gameController.roleObjectCollection[gameController.seatNum-1].medcine = false
        actNum = 0
        
    }
    
    @IBAction func poisonedButton(_ sender: Any) {
        enterPlayerNum.resignFirstResponder()
        otherInfo.isHidden = true
        poisonButton.isHidden = true
        medicineButton.isHidden = true
        enterPlayerNum.isHidden = true
        poisonButton.isEnabled = false
        let poisonedNum = Int(enterPlayerNum.text!)!
        gameController.poisoned(seat: poisonedNum)
        gameController.roleObjectCollection[gameController.seatNum-1].poison = false
        serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["witchActed",["poison",poisonedNum, gameController.seatNum]]))
        actNum = 0
        
    }
    
    
    
    
    
    func gameAlert (title: String , message: String ){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func waitSeer (){
        let seerActedData = NSKeyedArchiver.archivedData(withRootObject: ["seerActed",[]])
        serverController.sendDataToPeer(data: seerActedData)
        enterPlayerNum.isHidden = true
        confirmButton.isHidden = true
        actNum = 0
    }
    
    @objc func waitHunter (){
        serverController.sendDataToPeer(data: NSKeyedArchiver.archivedData(withRootObject: ["hunterActed",[]]))
        otherInfo.isHidden = true
        actNum = 0
    }
    
    func killAlert (title: String , message: String, start : Int , target : Int){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: {(action) in
            self.myChoice = 1
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Unconfirm", style: UIAlertActionStyle.default, handler: {(action) in
            self.myChoice = 2
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    


}
