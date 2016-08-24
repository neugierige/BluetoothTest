//
//  ViewController.swift
//  BluetoothTest
//
//  Created by Luyuan Xing on 8/11/16.
//  Copyright © 2016 Luyuan Xing. All rights reserved.
//

import UIKit
import CoreBluetooth
import UIColor_FlatColors


class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    let serviceUDID: CBUUID = CBUUID(string: "CDEACB80-5235-4C07-8846-93A37EE6B86D")
    let characteristicsUDID: CBUUID = CBUUID(string: "CDEACB81-5235-4C07-8846-93A37EE6B86D")
    
    var centralManager = CBCentralManager()
    var myPeripheral: CBPeripheral!
    var data = NSData()
    
    var wheel = UIActivityIndicatorView()
    
    let pulseRateLabel = UILabel()
    let pulseRateValue = UILabel()
    var pulseRate = Int()
    
    let o2LevelLabel = UILabel()
    let o2LevelValue = UILabel()
    var o2Level = Int()
    
    let perfusionLabel = UILabel()
    let perfusionValue = UILabel()
    var perfusion = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.flatBelizeHoleColor()
        wheel = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        
        let viewsArray = [pulseRateLabel, pulseRateValue, o2LevelLabel, o2LevelValue, perfusionLabel, perfusionValue]
        for view in viewsArray {
            self.view.addSubview(view)
            view.textColor = UIColor.whiteColor()
        }
        self.view.addSubview(wheel)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        centralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
        
        let width = self.view.frame.width/2-20
        let height: CGFloat = 40
        let offset: CGFloat = 10
        
        wheel.startAnimating()
        wheel.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.width)
        //wheel.frame = CGRectMake(self.view.frame.midX-10, self.view.frame.maxY/8, 20, 20)
        
        pulseRateLabel.frame = CGRectMake(offset, self.view.frame.maxY/4, width, height)
        o2LevelLabel.frame = CGRectMake(offset, self.pulseRateLabel.frame.maxY+offset*2, width, height)
        perfusionLabel.frame = CGRectMake(offset, self.o2LevelLabel.frame.maxY+offset*2, width, height)
        
        pulseRateLabel.textAlignment = .Right
        o2LevelLabel.textAlignment = .Right
        perfusionLabel.textAlignment = .Right
        
        pulseRateLabel.text = "pulse rate: "
        o2LevelLabel.text = "oxygen level: "
        perfusionLabel.text = "perfusion index: "
        
        
        pulseRateValue.frame = CGRectMake(self.view.frame.midX+offset, self.view.frame.maxY/4, width, height)
        o2LevelValue.frame = CGRectMake(self.view.frame.midX+offset, self.pulseRateValue.frame.maxY+offset*2, width, height)
        perfusionValue.frame = CGRectMake(self.view.frame.midX+offset, self.o2LevelValue.frame.maxY+offset*2, width, height)
        
        pulseRateValue.textAlignment = .Left
        o2LevelValue.textAlignment = .Left
        perfusionValue.textAlignment = .Left
        
        pulseRateValue.text = "..."
        o2LevelValue.text = "..."
        perfusionValue.text = "..."
        
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
        var values = [UInt8](count:data.length, repeatedValue:0)
        data.getBytes(&values, length: data.length)
        
        if values[0] == 129 {
            if values[1] == 255 || values[2] == 127 || values[3] == 0 {
                wheel.startAnimating()
                let labels = [pulseRateValue, o2LevelValue, perfusionValue]
                for item in labels {
                    item.text = "..."
                }
            } else {
                wheel.stopAnimating()
                
                pulseRate = Int(values[1])
                pulseRateValue.text = String(pulseRate)
                
                o2Level = Int(values[2])
                o2LevelValue.text = String(o2Level) + "%"
                
                let perfusionDouble = Double(values[3])/10
                perfusionValue.text = String(perfusionDouble) + "%"
            }
            print("values are \(values)")
        }
        
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

