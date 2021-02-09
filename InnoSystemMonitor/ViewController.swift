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
    var readerRAM: RAMStats = RAMStats()
    
    var stats = 0.0
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var representedObject: Any? {
        didSet {
        }
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
		print("\n")
		
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
                print("Name: \(gpu.gpuModel)\t GPU Usage: \(NSString(format: "%.2f", (gpu.utilization ?? 0) * 100))%")
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
