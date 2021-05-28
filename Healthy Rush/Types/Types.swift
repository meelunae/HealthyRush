//
//  Types.swift
//  Healthy Rush
//
//

import Foundation
import UIKit

let appDI = UIApplication.shared.delegate as! AppDelegate // used for adapting the screen size

struct PhysicsCategory {
    static let Player:  UInt32 = 0b1      // 1
    static let Block:  UInt32 = 0b10      // 2
    static let Obstacle:  UInt32 = 0b100   // 4
    static let Ground:  UInt32 = 0b1000    // 8
    static let Jewel:  UInt32 = 0b10000    // 16
}
