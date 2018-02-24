//
//  ViewController.swift
//  TheJudge
//
//  Created by ZEYUAN XUE on 2017/12/22.
//  Copyright © 2017年 ZEYUAN XUE. All rights reserved.
//

import UIKit

var gameController : GameController = GameController()
var serverController : ServerController = ServerController()


class ViewController: UIViewController {

    @IBOutlet weak var labe1: UILabel!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        if serverController.session != nil{
//            serverController.reset()
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}

