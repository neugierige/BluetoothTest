//
//  ViewController.swift
//  BluetoothTest
//
//  Created by Luyuan Xing on 8/11/16.
//  Copyright © 2016 Luyuan Xing. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    let serviceUDID: CBUUID = CBUUID(string: "CDEACB80-5235-4C07-8846-93A37EE6B86D")
    let characteristicsUDID: CBUUID = CBUUID(string: "CDEACB81-5235-4C07-8846-93A37EE6B86D")
    
    var centralManager = CBCentralManager()
    var myPeripheral: CBPeripheral!
    var data = NSData()
    
    
    let pulseRateLabel = UILabel()
    let pulseRateValue = UILabel()
    var pulseRate = Int()
    
    let o2LevelLabel = UILabel()
    let o2LevelValue = UILabel()
    var o2Level = Int()
    
    let perfusionLabel = UILabel()
    let perfusionValue = UILabel()
    var perfusion = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        centralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
        let viewsArray = [pulseRateLabel, pulseRateValue, o2LevelLabel, o2LevelValue, perfusionLabel, perfusionValue]
        for view in viewsArray {
            self.view.addSubview(view)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        
    }
    
    
    
    
//    **** central manager methods ****
    
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch(central.state) {
        case .Resetting:
            print("resetting")
        case .PoweredOn:
            centralManager.scanForPeripheralsWithServices([serviceUDID], options: [ CBCentralManagerScanOptionAllowDuplicatesKey: true])
            print("powered on")
        case .PoweredOff:
            print("powered off")
        case .Unknown:
            print("unknown")
        case .Unsupported:
            print("unsupported")
        case .Unauthorized:
            print("unauthorized")
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        if myPeripheral != peripheral {
            myPeripheral = peripheral
            print("myPeripheral is \(myPeripheral.name)")
            centralManager.connectPeripheral(myPeripheral, options: nil)
        }
        
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
//        data.length = 0
        peripheral.delegate = self
        peripheral.discoverServices([serviceUDID])
    }
    
    
    
    
//    **** peripheral methods ****
    
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if (error != nil) {
            print("there is an error")
            print(error.debugDescription)
        }
        
        for service in peripheral.services! {
            peripheral.discoverCharacteristics([characteristicsUDID], forService: service)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if (error != nil) {
            print("there is an error")
            print(error.debugDescription)
        }
        
        for item in service.characteristics! {
            if item.UUID == characteristicsUDID {
                peripheral.setNotifyValue(true, forCharacteristic: item)
            }
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if (error != nil) {
            print("there is an error")
            print(error.debugDescription)
        }

        data = characteristic.value!
        
        
        //TO DO: decode data
        var values = [UInt8](count:data.length, repeatedValue:0)
        data.getBytes(&values, length: data.length)
        
        if values[0] == 129 {
            pulseRate = Int(values[1])
            
            
            print("values is \(values)")
            
        }
        
        
        
        //THIS WILL NEVER HAPPEN
//        if stringFromData == "EOM" {
//            centralManager.cancelPeripheralConnection(peripheral)
//        }

    }
    
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if (error != nil) {
            print("there is an error")
            print(error.debugDescription)
        }
        
        if characteristic.UUID != characteristicsUDID {
            return
        }
        
        if characteristic.isNotifying {
            print("characteristic is notifying")
        } else {
            print("characteristic is NOT notifying")
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    

    
    
    
    

}

