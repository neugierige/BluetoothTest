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
    
    let fontName = "Avenir-Heavy"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 41, green: 128, blue: 185, alpha: 1.0)
        wheel = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        
        self.view.addSubview(wheel)
    }
    
    override func viewWillAppear(animated: Bool) {
        centralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
        
        let width = self.view.frame.width
        let heightOffset: CGFloat = 60
        
        let viewsArray = [o2LevelLabel, o2LevelValue, pulseRateLabel, pulseRateValue, perfusionLabel, perfusionValue]
        for view in viewsArray {
            self.view.addSubview(view)
            view.textColor = UIColor.whiteColor()
            view.textAlignment = .Center
            view.baselineAdjustment = .AlignCenters
        }
        
        wheel.startAnimating()
        wheel.frame = CGRectMake(0, self.view.frame.maxY/2-width/2, width, width)
        wheel.transform = CGAffineTransformMakeScale(5.0, 5.0)
        
        o2LevelValue.text = "---"
        pulseRateValue.text = "---"
        perfusionValue.text = "---"
        
        o2LevelLabel.text = "oxygen level (%)"
        pulseRateLabel.text = "pulse rate"
        perfusionLabel.text = "PI (%)"
        
        o2LevelValue.frame = CGRectMake(0, 30, width, width-heightOffset)
        o2LevelValue.font = UIFont(name: fontName, size: 180)
        o2LevelLabel.frame = CGRectMake(0, self.o2LevelValue.frame.maxY, width, heightOffset)
        o2LevelLabel.font = UIFont(name: fontName, size: 20)
        
        
        pulseRateLabel.translatesAutoresizingMaskIntoConstraints = false
        perfusionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraint(NSLayoutConstraint(item: self.pulseRateLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.perfusionLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.pulseRateLabel, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.perfusionLabel, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.pulseRateLabel, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.5, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.perfusionLabel, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 0.5, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.pulseRateLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: heightOffset))
        self.view.addConstraint(NSLayoutConstraint(item: self.perfusionLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: heightOffset))
        
        pulseRateValue.font = UIFont(name: fontName, size: 60)
        pulseRateLabel.font = UIFont(name: fontName, size: 20)
        
        
        perfusionValue.font = UIFont(name: fontName, size: 60)
        perfusionLabel.font = UIFont(name: fontName, size: 20)
        
    }
    
    override func viewDidLayoutSubviews() {
        let width = self.view.frame.width
        pulseRateValue.frame = CGRectMake(0,
                                          self.o2LevelLabel.frame.maxY,
                                          width/2,
                                          self.pulseRateLabel.frame.minY-self.o2LevelLabel.frame.maxY)
        
        perfusionValue.frame = CGRectMake(self.pulseRateValue.frame.maxX,
                                          self.o2LevelLabel.frame.maxY,
                                          width/2,
                                          pulseRateValue.frame.height)
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
        
        self.view.addSubview(o2LevelValue)
        if values[0] == 129 {
            if values[1] == 255 || values[2] == 127 || values[3] == 0 {
                wheel.startAnimating()
                let labels = [pulseRateValue, o2LevelValue, perfusionValue]
                for item in labels {
                    item.text = "---"
                }
            } else {
                wheel.stopAnimating()
                
                self.view.addSubview(o2LevelValue)
                o2Level = Int(values[2])
                o2LevelValue.text = String(o2Level)
                o2LevelValue.alpha = 1.0
                UIView.animateWithDuration(0.9, delay: 0.0, options: .CurveEaseInOut, animations: {
                    self.o2LevelValue.alpha = 0
                    }, completion: {
                        (value: Bool) in
                        self.o2LevelValue.removeFromSuperview()
                })
                pulseRate = Int(values[1])
                pulseRateValue.text = String(pulseRate)
                
                let perfusionDouble = Double(values[3])/10
                perfusionValue.text = String(perfusionDouble)
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

