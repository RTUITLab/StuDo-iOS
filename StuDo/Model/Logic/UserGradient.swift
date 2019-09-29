//
//  UserGradient.swift
//  StuDo
//
//  Created by Andrew on 9/29/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

struct UserGradient {
    
    fileprivate static let orangeGradient = (UIColor(red:0.988, green:0.871, blue:0.541, alpha:1.000), UIColor(red:0.953, green:0.510, blue:0.506, alpha:1.000))
    fileprivate static let pinkGradient = (UIColor(red:0.965, green:0.314, blue:0.627, alpha:1.000), UIColor(red:1.000, green:0.455, blue:0.475, alpha:1.000))
    fileprivate static let ocyanGradient = (UIColor(red:0.102, green:0.906, blue:0.855, alpha:1.000), UIColor(red:0.357, green:0.502, blue:0.914, alpha:1.000))
    fileprivate static let greenGradient = (UIColor(red:0.259, green:0.890, blue:0.592, alpha:1.000), UIColor(red:0.235, green:0.714, blue:0.710, alpha:1.000))
    
    
    static func cleanSavedCurrent() {
        savedCurrent = nil
    }
    
    static private var savedCurrent: (CGColor, CGColor)!
    
    static var current: (CGColor, CGColor) {
        
        if let saved = savedCurrent {
            return saved
        }
        
        let gradients = [orangeGradient, pinkGradient, ocyanGradient, greenGradient]
        
        var gradientIndex: Int!
        if let index = PersistentStore.shared.profilePictureGradientIndex {
            gradientIndex = index
        } else {
            gradientIndex = Int.random(in: 0..<gradients.count)
            PersistentStore.shared.profilePictureGradientIndex = gradientIndex
        }
        let gradient = gradients[gradientIndex]
        
        savedCurrent = (gradient.0.cgColor, gradient.1.cgColor)
        
        return savedCurrent
        
    }
    
    
    static var currentColors: [Any]? {
        return [current.0, current.1]
    }
    
    static var grayColors: [Any]? {
        return [UIColor(red:0.753, green:0.753, blue:0.753, alpha:1.000).cgColor, UIColor(red:0.527, green:0.541, blue:0.584, alpha:1.000).cgColor]
    }
    
}
