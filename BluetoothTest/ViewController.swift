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
    var data = NSMutableData()
    

    
//    **** central manager methods ****
    
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state == CBCentralManagerState.PoweredOn {
            centralManager.scanForPeripheralsWithServices([serviceUDID], options: [ CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
        print("status updated")
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        if myPeripheral != peripheral {
            myPeripheral = peripheral
            print("myPeripheral is \(myPeripheral.name)")
            centralManager.connectPeripheral(myPeripheral, options: nil)
        }
        
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        data.length = 0
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
        
        data.appendData(characteristic.value!)
        print("data is \(data)")
        
        //TO DO: decode data
        let stringFromData = NSString.init(data: self.data, encoding: NSUTF8StringEncoding)
        print("string from Data is \(stringFromData)")
        
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        centralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
    }

    
    
    
    

}

