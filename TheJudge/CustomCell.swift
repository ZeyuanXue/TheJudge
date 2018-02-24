//
//  CustomCell.swift
//  TheJudge
//
//  Created by ZEYUAN XUE on 2017/12/27.
//  Copyright © 2017年 ZEYUAN XUE. All rights reserved.
//

import Foundation
import UIKit

class CustomCell : UICollectionViewCell{
    
    @IBOutlet weak var seatLabel: UILabel!
    @IBOutlet weak var seatNum: UILabel!
    var seated : Bool = false
}
