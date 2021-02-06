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

    @IBOutlet weak var energyLabel: NSTextField!
    @IBOutlet weak var memoryLabel: NSTextField!
    @IBOutlet weak var gpulabel: NSTextField!
    @IBOutlet weak var cpuLabel: NSTextField!
    
    var readerCPU: CPUStats = CPUStats()
    var readerGPU: GPUStats = GPUStats()
    
    var stats = 0.0
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTimer(withTimeInterval: 120) {
            self.readerCPU.read { topProcesses in
                topProcesses.sorted { processA, processB in
                    processA.usage > processB.usage
                }.prefix(10).forEach { process in
                    if process.name == "InnoSystemMonitor" {
                        self.stats += process.usage
                        self.count += 1
                    }
                }
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        }
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        print("Average usage: ", self.stats / Double(self.count))
        
//        readerCPU.read { topProcesses in
//            topProcesses.sorted { processA, processB in
//                processA.usage > processB.usage
//            }.prefix(10).forEach { process in
//                print("Name: \(process.name ?? process.command)\t Usage: \(process.usage)%")
//            }
//        }
//
//        readerGPU.read { cpuS in
//            cpuS.list.forEach { gpu in
//                print("GPU Utilization: \(NSString(format: "%.2f", (gpu.utilization ?? 0) * 100))%")
//            }
//        }
        
        
    }
    
    func createTimer(withTimeInterval timeInterval: TimeInterval, andClojure clojure: @escaping () -> Void) {
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { timer in
            clojure()
        }
    }
}

