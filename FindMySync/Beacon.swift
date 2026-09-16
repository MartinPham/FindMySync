//
//  Beacon.swift
//  FindMySync
//
//  Created by zzz on 3/18/24.
//

import Foundation

struct Beacon {
    var identifier: String
    var name: String
    var accuracy: NSNumber
    var longitude: NSNumber
    var latitude: NSNumber
    var timestamp: Date? = nil

    /// Coarse level reported by accessories in their OwnedBeacons record.
    /// -1 when unknown, which is the case for every Apple device - those carry
    /// vendorId -1 and always report 0.
    var batteryLevel: NSNumber = -1
}


