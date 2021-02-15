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
        }
    }
}
