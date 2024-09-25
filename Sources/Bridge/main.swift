import SwiftSTLinkV3Bridge

let device = SwiftSTLinkV3Bridge.Bridge()
device.enumDevices()
device.openDevice()
device.testDevice()