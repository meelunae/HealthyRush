//
//  CGFloat+Ext.swift
//  Healthy Rush
//
//

import CoreGraphics

extension CGFloat {
    func radiansToDegrees() -> CGFloat {
        return self * 180.0 / CGFloat.pi
    }
    
    func degreesToRadiants() -> CGFloat {
        return self * CGFloat.pi / 180.0
    }
    
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(0xFFFFFFFF)) // return 0, 1
    }
    
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        assert(min < max)
        return CGFloat.random() * (max - min) + min // return min or max
    }
}
