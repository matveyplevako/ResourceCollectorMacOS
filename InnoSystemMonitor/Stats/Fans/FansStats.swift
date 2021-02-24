import Foundation
import os.log

public class FansStats: ReaderProtocol {
    private var smc: UnsafePointer<SMCService>
    internal var list: [Fan] = []
    public var readyCallback: () -> Void = {}
    
    init(smc: UnsafePointer<SMCService>) {
        self.smc = smc
        
        guard let count = smc.pointee.getValue("FNum") else {
            return
        }
        
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
            
//            if let value = smc.pointee.getValue("F\(self.list[i].id)Ac") {
//                self.list[i].value = value
//            }
        }
        callback(self.list)
    }
    
    var callbackHandler: (T?) -> Void = {_ in }
}
