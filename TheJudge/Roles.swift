//
//  Roles.swift
//  TheJudge
//
//  Created by ZEYUAN XUE on 2017/12/25.
//  Copyright © 2017年 ZEYUAN XUE. All rights reserved.
//

import Foundation

class Role : NSObject{
    var role : String = ""
    var alive : Bool = true
    var goodness : Bool = true
    var guarded : Bool = true
    var whiteWolf : Bool = false
    var fireStatus : Bool = true
    var bullet : Bool = true
    var medcine : Bool = true
    var poison : Bool = true
    var isSheriff : Bool = false
    var electionStatus : Bool = false
    
    func setRole (roleType : String){
        role = roleType
        if role == "wolves"{
            goodness = false
        }
    }
    
    
    func getRole () -> String{
        return role
    }
    
    func killedAtNight (){
        alive = false
    }
    
    func poisoned (){
        alive = false
        if role == "hunter"{
            fireStatus = false
        }
    }
    
    func shotByHunter (){
        alive = false
    }
    
    func ateInDayByWolf (){
        alive = false
    }
    
    func ateInDayByWhiteWolf (){
        alive = false
    }
    
    func guardedAtNight (){
        guarded = true
    }
    
    func rescued (){
        if guarded == true && alive == false{
            alive = false
        }else if alive == false && guarded == false{
            alive = true
        }
    }
    
    func votedToDie (){
        alive = true
    }
    
    func checkGoodness () -> Bool{
        return goodness
    }
    
}

