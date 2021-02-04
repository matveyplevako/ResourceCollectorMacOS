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
    var readerGPUI: GPUStats = GPUStats()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.readerCPU = CPUStats()
    }

    override var representedObject: Any? {
        didSet {
        }
    }
    
    func initializeMonitor() {
        
    }
    @IBAction func refreshButtonTapped(_ sender: Any) {
        readerCPU.read { topProcesses in
            topProcesses.forEach { process in
                print(process)
//                print("Name: \(String(describing: process.name)) Usage: \(process.usage)")
            }
        }
    }
}

