//
//  ReaderFactory.swift
//  InnoSystemMonitor
//
//  Created by Иван Абрамов on 10.02.2021.
//
import Foundation

protocol ReaderProtocol {
    associatedtype T
    
    func read(callback: @escaping (T) -> Void)
}

enum ReaderType {
    case CPU
    case GPU
    case RAM
    case Battery
    case Fans
    case Network
    case Sensors
}

//  Factory create reader of special type

class ReaderFactory {
    static func createReader<T: ReaderProtocol>(ofType type: ReaderType) -> T {
        switch type {
        case .CPU:
            return CPUStats() as! T
        case .GPU:
            return GPUStats() as! T
        case .RAM:
            return RAMStats() as! T
        case .Battery:
            return BatteryStats() as! T
        case .Fans:
            var smc: SMCService = SMCService()
            return FansStats(smc: &smc) as! T
        case .Network:
            return NetworkStats() as! T
        case .Sensors:
            var smc: SMCService = SMCService()
            return SensorsStats(&smc) as! T
        }
    }
}
