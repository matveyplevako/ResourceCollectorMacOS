//
//  ViewController.swift
//  DataCollector
//
//  Created by Иван Абрамов on 01.02.2021.
//

import Cocoa
import Foundation
import AppKit

class ViewController: NSViewController {
    
    var readerCPU: CPUStats
    var readerGPU: GPUStats
    var readerRAM: RAMStats
    
    required init?(coder aDecoder: NSCoder) {
        self.readerCPU = ReaderFactory.createReader(ofType: .CPU)
        self.readerGPU = ReaderFactory.createReader(ofType: .GPU)
        self.readerRAM = ReaderFactory.createReader(ofType: .RAM)
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var representedObject: Any? {
        didSet {
        }
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        readerCPU.read { topProcesses in
            topProcesses.sorted { processA, processB in
                processA.usage > processB.usage
            }.prefix(10).forEach { process in
                print("Name: \(process.name ?? process.command)\t CPU Usage: \(process.usage)%")
            }
        }
        
        print("\n")
        
        readerGPU.read { gpuS in
            gpuS.list.forEach { gpu in
                print("Name: \(gpu.model)\t GPU Usage: \(NSString(format: "%.2f", (gpu.utilization ?? 0) * 100))%")
            }
        }
        
        print("\n")
        
        readerRAM.read { topProcesses in
            topProcesses.forEach { process in
                print("Name: \(process.name ?? process.command) RAM Usage: \(process.usage.readableSize())")
            }
        }
    }
    
    func createTimer(withTimeInterval timeInterval: TimeInterval, andClojure clojure: @escaping () -> Void) {
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { timer in
            clojure()
        }
    }
}


