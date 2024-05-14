//
//  SwitchPluggedIn.swift
//  macRCM
//
//  Created by Constantin Clerc on 14/05/2024.
//

import Foundation
import IOKit // i see who you are, you are my enemy
import IOKit.usb

// this was so much pain i wanna kms
// THIS WORKS!!!!!!
func isSwitchPluggedIn() -> Bool {
    let vendorId = 0x0955 // (NVIDIA)
    let productId = 0x7321
    let matchingDict = IOServiceMatching(kIOUSBDeviceClassName) as NSMutableDictionary
    matchingDict[kUSBVendorID] = NSNumber(value: vendorId)
    matchingDict[kUSBProductID] = NSNumber(value: productId)

    var iterator: io_iterator_t = 0
    let result = IOServiceGetMatchingServices(kIOMainPortDefault, matchingDict, &iterator)
    guard result == KERN_SUCCESS else {
        print("fail \(result)")
        return false
    }

    defer { IOObjectRelease(iterator) }

    return IOIteratorNext(iterator) != 0
}
