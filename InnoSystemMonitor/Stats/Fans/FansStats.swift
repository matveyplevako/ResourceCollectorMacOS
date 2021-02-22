//
//  FansStats.swift
//  InnoSystemMonitor
//
//  Created by Иван Абрамов on 22.02.2021.
//

import Foundation
import os.log

public class FansStats: ReaderProtocol {
    private var smc: UnsafePointer<SMCService>
    internal var list: [Fan] = []
    public var readyCallback: () -> Void = {}
    
    init(smc: UnsafePointer<SMCService>) {
        self.smc = smc
//        super.init()
        
        guard let count = smc.pointee.getValue("FNum") else {
            return
        }
        
//        let count = 1969829920
//        let count = 0
//        os_log(.debug, log: self.log, "Found %.0f fans", count)
        
        for i in 0..<Int(count) {
            self.list.append(Fan(
                id: i,
                name: smc.pointee.getStringValue("F\(i)ID") ?? "Fan #\(i)",
                minSpeed: smc.pointee.getValue("F\(i)Mn") ?? 1,
                maxSpeed: smc.pointee.getValue("F\(i)Mx") ?? 1,
                value: smc.pointee.getValue("F\(i)Ac") ?? 0
            ))
        }
    }
    
    public func read(callback: @escaping ([Fan]) -> Void) {
        for i in 0..<self.list.count {
//            print("Test: \(String(describing: smc.pointee.getValue("F\(self.list[i].id)Ac")))")
            
            if let value = smc.pointee.getValue("F\(self.list[i].id)Ac") {
                self.list[i].value = value
            }
        }
        callback(self.list)
    }
    
    var callbackHandler: (T?) -> Void = {_ in }
}
