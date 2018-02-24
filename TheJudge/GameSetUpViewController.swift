//
//  GameSetUpViewController.swift
//  TheJudge
//
//  Created by ZEYUAN XUE on 2017/12/25.
//  Copyright © 2017年 ZEYUAN XUE. All rights reserved.
//

import UIKit

class GameSetUpViewController: UIViewController {

    
    @IBOutlet weak var playerNum: UILabel!
    @IBOutlet weak var wolves: UILabel!
    @IBOutlet weak var townfolks: UILabel!
    @IBOutlet weak var seer: UILabel!
    @IBOutlet weak var witch: UILabel!
    @IBOutlet weak var hunter: UILabel!
    @IBOutlet weak var sheriff: UILabel!
    @IBOutlet weak var gameSetUpButton: UIButton!
    
    let role : [String] = ["wolves" , "townfolks" , "seer" , "witch" , "hunter" , "savior" ]
    
    var playerNumber : Int = 0
    var wolvesNumber : Int = 0
    var townfolksNumber : Int = 0
    var seerNumber : Int = 0
    var witchNumber : Int = 0
    var hunterNumber : Int = 0
    var saviorNumber : Int = 0
    var roleAmount : [String : Int] = ["wolves" : 0, "townfolks" : 0, "seer" : 0, "witch" : 0, "hunter" : 0, "savior" : 0]
    var totalRole : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerNumber = 0
        wolvesNumber = 0
        townfolksNumber = 0
        seerNumber = 0
        witchNumber = 0
        hunterNumber = 0
        saviorNumber = 0
        roleAmount = ["wolves" : 0, "townfolks" : 0, "seer" : 0, "witch" : 0, "hunter" : 0, "savior" : 0]
        totalRole = 0

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playerNumStepper(_ sender: UIStepper) {
        playerNum.text = String(sender.value)
        playerNumber = Int(sender.value)
            }
    
    @IBAction func wolvesNum(_ sender: UIStepper) {
        wolves.text = String(sender.value)
        wolvesNumber = Int(sender.value)
        roleAmount["wolves"] = Int(sender.value)
    }
    
    @IBAction func townfolksNum(_ sender: UIStepper) {
        townfolks.text = String(sender.value)
        townfolksNumber = Int(sender.value)
        roleAmount["townfolks"] = Int(sender.value)
    }
    
    @IBAction func seerNum(_ sender: UIStepper) {
        seer.text = String(sender.value)
        seerNumber = Int(sender.value)
        roleAmount["seer"] = Int(sender.value)
    }
    
    @IBAction func witchNum(_ sender: UIStepper) {
        witch.text = String(sender.value)
        witchNumber = Int(sender.value)
        roleAmount["witch"] = Int(sender.value)
    }
    
    @IBAction func hunterNum(_ sender: UIStepper) {
        hunter.text = String(sender.value)
        hunterNumber = Int (sender.value)
        roleAmount["hunter"] = Int(sender.value)
    }
    
    @IBAction func sheriffNum(_ sender: UIStepper) {
        sheriff.text = String (sender.value)
        saviorNumber = Int(sender.value)
        roleAmount["savior"] = Int(sender.value)
    }
    
    
    
    
    
    
    
    
    @IBAction func setUp(_ sender: Any) {
        var total : Int = 0
        for name in role{
            total += roleAmount[name]!
        }
        
        if playerNumber>15{
            playerNumberAlert(title: "Over Size", message: "Cannot have more than 15 player in the game.")
        }else if playerNumber != total {
            playerNumberAlert(title: "Not Enough/Too Much Roles", message: "The room size is \(playerNumber) player, but you have set up \(total) roles.")
        }else{
            gameController.playerNum = playerNumber
            gameController.createCollection(roles: roleAmount)
            gameController.roleAmountCollection = roleAmount
            gameController.createSeatList()
            print(gameController.seatList)
            print("Player Number: \(gameController.playerNum)\n\n")
            print("Roles: \(gameController.roleObjectCollection)\n")
            performSegue(withIdentifier: "setup", sender: self)
            
            
            print("Wolves:\(roleAmount["wolves"]!)\nTownfolks:\(townfolksNumber)")
        }
    }
    
    func playerNumberAlert (title: String , message: String ){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
  
}
