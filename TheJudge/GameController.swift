//
//  GameController.swift
//  TheJudge
//
//  Created by ZEYUAN XUE on 2017/12/22.
//  Copyright © 2017年 ZEYUAN XUE. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

struct NightLog {
    var killed : Int
    var poisoned : Int
    var rescues : Int
    var guarded : Int
}


class GameController : NSObject {
    var roomNum : String = ""
    var playerNum : Int = 0
    var roleAmountCollection : [String : Int] = [:]
    var roleObjectCollection : [Role] = []
    var roleTypteCollection : [String] = []
    var nightCount : Int = 1
    var roleOrder : [Int] = []
    var seatNum : Int = 0
    var existingRoleOrder : [String] = []
    var electionList : [Bool] = []
    var electionSpeech : [Int] = []
    var clockwise : Bool = true
    var voteList : [Int] = []
    var voteResult : [Int : Int] = [:]
    var electionCount : Int = 1
    var deathAtNight : [Int] = []
    
    var nightLog : [NightLog] = []
    var sheriffLog : [String] = []
    var dayLog : [String] = []

    

    
    
    let roleName : [String] = ["wolves" , "savior" , "seer" , "witch" , "hunter" , "townfolks" ]
    
    var testx : String = "?"
    
    var seatList : [[Any?]] = []
    
    
    func setRoomNum (num : String){
        if (roomNum == ""){
            self.roomNum = num
        }
    }
    
    func getRoomNum () -> String {
        return roomNum
    }
    
    func tempProcess( content : String){
        self.testx = content
    }
    
    func rearrange (order : [Int]){
        print("Before Check \(roleObjectCollection)\n\n")
        var tempObj : [Role] = []
        var tempType : [String] = []
        for i in order{
            tempObj.append(roleObjectCollection[i])
            tempType.append(roleTypteCollection[i])
        }
        roleObjectCollection = tempObj
        roleTypteCollection = tempType
        print("Check !! \(roleObjectCollection)\n\n")
        
        //Set turn order of existing roles
        for roles in roleName{
            if roleAmountCollection[roles]! > 0{
                existingRoleOrder.append(roles)
            }
        }
        
        //Set Up electionList
        for _ in 0...(playerNum-1){
            electionList.append(false)
        }
        
        
        
    }
    
    
    func createSeatList(){
        for _ in 0...(playerNum-1){
            seatList.append(["",(false as Bool!)])
        }
    }
    
    func updateSeatList(name : String, seat : Int, tf : Bool){
        if tf {
            seatList[seat-1][0] = name
        }else{
            seatList[seat-1][0] = ""
        }
        seatList[seat-1][1] = tf
        
    }
    
    func checkRole(role : String) -> Bool{
        print(role)
        if role == roleObjectCollection[seatNum-1].getRole(){
            return true
        }else {
            return false
        }
    }
    
    
    func checkSeated () -> Bool{
        var allSeated = false
        var seatedNum : Int = 0
        
        for seatInfo in seatList{
            if seatInfo[1] as! Bool{
                seatedNum += 1
            }
        }
        if seatedNum == seatList.count{
            allSeated = true
        }
        return allSeated
    }
    
    
    //TODO
    func checkEndGame () -> (Bool,String){
        var wolvesAlive : Int = 0
        var godAlive : Int = 0
        var townfolksAlive : Int = 0
        
        var outputB : Bool = false
        var outputS : String = ""
        
        for role in roleObjectCollection{
            if role.getRole() == "townfolks"{
                if role.alive{
                    townfolksAlive += 1
                }
            }else if role.getRole() == "wolves"{
                if role.alive{
                    wolvesAlive += 1
                }
            }else{
                if role.alive{
                    godAlive += 1
                }
            }
        }
        
        
        
        if wolvesAlive == 0 && godAlive > 0 && townfolksAlive > 0 {
            outputB = true
            outputS = "好人胜利"
        }else if wolvesAlive > 0 && (godAlive == 0 || townfolksAlive == 0){
            outputB = true
            outputS = "狼人胜利"
        }else{
            outputB = false
            outputS = ""
        }
        return (outputB, outputS)
    }
    
    
    
    func createCollection(roles : [String : Int]){
        var count : Int = 0
        for name in roleName{
            switch name{
            case "wolves" :
                if roles[name] == 0{
                    break
                }
                for i in 1...roles[name]!{
                    print ("In createCollection : for loop \(i)")
                    count += 1
                    let tempRole = Role()
                    tempRole.setRole(roleType: "wolves")
                    roleObjectCollection.append(tempRole)
                    roleTypteCollection.append("wolves")
                    }
                break
            case "townfolks":
                if roles[name] == 0{
                    break
                }
                for _ in 1...roles[name]!{
                    count += 1
                    let tempRole = Role()
                    tempRole.setRole(roleType: "townfolks")
                    roleObjectCollection.append(tempRole)
                    roleTypteCollection.append("townfolks")
                }
                break
            case "seer":
                if roles[name] == 0{
                    break
                }
                for _ in 1...roles[name]!{
                    count += 1
                    let tempRole = Role()
                    tempRole.setRole(roleType: "seer")
                    roleObjectCollection.append(tempRole)
                    roleTypteCollection.append("seer")
                }
                break
            case "witch":
                if roles[name] == 0{
                    break
                }
                for _ in 1...roles[name]!{
                    count += 1
                    let tempRole = Role()
                    tempRole.setRole(roleType: "witch")
                    roleObjectCollection.append(tempRole)
                    roleTypteCollection.append("witch")
                }
                break
            case "hunter":
                if roles[name] == 0{
                    break
                }
                for _ in 1...roles[name]!{
                    count += 1
                    let tempRole = Role()
                    tempRole.setRole(roleType: "hunter")
                    roleObjectCollection.append(tempRole)
                    roleTypteCollection.append("hunter")
                }
                break
            case "savior":
                if roles[name] == 0{
                    break
                }
                for _ in 1...roles[name]!{
                    count += 1
                    let tempRole = Role()
                    tempRole.setRole(roleType: "savior")
                    roleObjectCollection.append(tempRole)
                    roleTypteCollection.append("savior")
                }
                break
            default:
                break
            }
        }
        print(count)
    }
    
    
    //Handle Game Events
    func killed(seat : Int){
        print("debug for killed() in gameController : \(roleObjectCollection) \n\(seat)")
        roleObjectCollection[seat-1].killedAtNight()
        nightLog[nightCount-1].killed = seat
    }
    
    func poisoned (seat : Int){
        roleObjectCollection[seat-1].poisoned()
        nightLog[nightCount-1].poisoned = seat
        
    }
    
    func  shot (seat : Int){
        roleObjectCollection[seat-1].shotByHunter()
    }
    
    func ateInDay (seat : Int){
        roleObjectCollection[seat-1].ateInDayByWolf()
    }
    
    func ateInDayByWhiteWolf (seat : Int){
        roleObjectCollection[seat-1].ateInDayByWhiteWolf()
    }
    
    func guardedAtNight (seat : Int){
        roleObjectCollection[seat-1].guardedAtNight()
        nightLog[nightCount-1].guarded = seat
    }
    
    func rescuedByWitch (seat : Int){
        roleObjectCollection[seat-1].rescued()
        print(nightLog)
        print(nightCount)
        nightLog[nightCount-1].rescues = seat
    }
    
    func voteToDie (seat : Int){
        roleObjectCollection[seat-1].votedToDie()
    }
    
    func checkGoodness (seat : Int) -> Bool{
        let goodness = roleObjectCollection[seat-1].checkGoodness()
        return goodness
    }
    
    func redoElectionUpdate (players : [Int]){
        for i in 0...(electionList.count-1){
            if players.contains(i+1){
                electionList[i] = true
            }else {
                electionList[i] = false
            }
        }
        electionSpeech = []
    }
    
    func updateElectionStatus (status : Bool){
        roleObjectCollection[seatNum-1].electionStatus = status 
    }
    func updateElectionList (seat : Int, status : Bool){
        roleObjectCollection[seat-1].electionStatus = status
        electionList[seat-1] = status
    }
    
    func electionPlayerGeneration () -> String{
        var outputList : String = ""
        print("election list : \(electionList)\n\n")
        for i in 0...(electionList.count-1){
            if electionList[i]{
                outputList.append("\(i+1)号玩家 ")
            }
        }
        if outputList == ""{
            outputList.append("没有玩家参选警长")
        }else {
            outputList.append("参选警长")
        }
        return outputList
    }
    
    func electionSpeechStartNum () -> Int{
        var outputNum = 0
        repeat{
            for i in Int(arc4random_uniform(UInt32(electionList.count)))...(electionList.count-1){
                if electionList[i]{
                    outputNum = i+1
                    break
                }
            }
        }while (outputNum == 0)
        
        if arc4random_uniform(10) > 5{
            clockwise = true
        }else {
            clockwise = false
        }
        electionSpeech.append(outputNum)
        
        var count = 0
        for x in 0...(electionList.count-1){
            if electionList[x]{
                count += 1
            }
        }
        if count == 1{
            outputNum = -outputNum
        }
        
        
        return outputNum
    }
    
    func nextSpeech () -> Int{
        var next : Int = 0
        if clockwise{
            for i in (electionSpeech[electionSpeech.count-1] - 1)...(electionList.count-1){
                if electionList[i] && !electionSpeech.contains(i+1){
                    next = i+1
                    break
                }
            }
            if next == 0{
                for i in 0...(electionSpeech[electionSpeech.count-1] - 1){
                    if electionList[i] && !electionSpeech.contains(i+1){
                        next = i+1
                        break
                    }
                }
            }
        }else{
            for i in (0...(electionSpeech[electionSpeech.count-1])-1).reversed(){
                print("nextSpeech : \n\(electionList[i])\n\(i)\n")
                if electionList[i] && !electionSpeech.contains(i+1){
                    next = i+1
                    break
                }
            }
            if next == 0{
                for i in (electionSpeech[electionSpeech.count-1]-1...(electionList.count-1)).reversed(){
                    if electionList[i] && !electionSpeech.contains(i+1){
                        next = i+1
                        break
                    }
                }
            }
        }
        if next != 0{
            electionSpeech.append(next)
        }
        return next
    }
    
    func aliveWolves () -> Int {
        var output = 0
        for i in roleObjectCollection{
            if i.role == "wolves" && i.alive{
                output += 1
            }
        }
        return output
    }
    
    func initVoteList (){
        for i in 0...(playerNum-1){
            if electionList[i]{
                voteList.append(-1)
            }else
            {
                voteList.append(0)
            }
        }
    }
    
    func generateVoteResult () -> [Int]{
        var resultList : [Int] = []
        var output : [Int] = []
        for i in 0...(voteList.count-1){
            if voteList[i] != 0 && voteList[i] != -1{
                if voteResult[voteList[i]] != nil{
                    voteResult[voteList[i]]! += 1
                }else {
                    voteResult[voteList[i]] = 1
                }
                if !resultList.contains(voteList[i]){
                    resultList.append(voteList[i])
                }
            }
        }
        for x in resultList{
            if output.isEmpty{
                output.append(x)
            }else if voteResult[output[0]]! < voteResult[x]!{
                output[0] = x
            }
        }
        for y in resultList{
            if voteResult[y]! == voteResult[output[0]]! && y != output[0]{
                output.append(y)
            }
        }
        return output
    }
    
    func generateVoteInfo () -> String{
        print(voteList)
        var output : String = ""
        for i in 0...(voteList.count-1){
            if voteList[i] == 0{
                output.append("\(i+1)号：弃票 ")
            }else if voteList[i] != 0 && voteList[i] != -1{
                output.append("\(i+1)号：\(voteList[i]) ")
            }
        }
        return output
    }
    
    func generateNightInfo () -> String{
        let temp = nightLog[nightCount-1]
        var output : String = ""
        if temp.killed == 0 && temp.poisoned == 0{
            output += "昨天晚上是个平安夜"
            print(output)
            return output
        }else{
            if temp.killed != 0{
                if temp.killed == temp.guarded && temp.killed == temp.rescues{
                    output += "\(temp.killed)号玩家 "
                    deathAtNight.append(temp.killed)
                }else if temp.killed == temp.guarded{
                    
                }else if temp.killed == temp.rescues{
                    
                }else{
                    output += "\(temp.killed)号玩家 "
                    deathAtNight.append(temp.killed)
                }
            }
            if temp.poisoned != 0{
                if temp.poisoned == temp.killed{
                    
                }else{
                    output += "\(temp.poisoned)号玩家死亡"
                    deathAtNight.append(temp.poisoned)
                }
            }
        }
        if output == ""{
            output = "昨天晚上是个平安夜"
        }
        return output
    }
    
    func checkSheriff () -> Bool{
        var output : Bool = false
        for role in roleObjectCollection{
            if role.isSheriff{
                output = true
                break
            }
        }
        return output
    }
    
    func daySpeechNext () -> Int{
        voteResult = [:]
        var output : Int = 0
        if deathAtNight.count >= 1 {
            for i in (deathAtNight[0] - 1)...(roleObjectCollection.count - 1){
                if roleObjectCollection[i].alive{
                    output = i + 1
                }
            }
            
            if output == 0{
                for i in 0...(deathAtNight[0] - 1){
                    if roleObjectCollection[i].alive{
                        output = i + 1
                    }
                }
            }
        }else {
            for i in 0...(roleObjectCollection.count - 1){
                if roleObjectCollection[i].alive{
                    output = i + 1
                }
            }
        }
        
        return output
    }
}
