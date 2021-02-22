import Cocoa
import Foundation
import AppKit

class ViewController: NSViewController {
    
    @IBOutlet weak var energyLabel: NSTextField!
    @IBOutlet weak var memoryLabel: NSTextField!
    @IBOutlet weak var gpulabel: NSTextField!
    @IBOutlet weak var cpuLabel: NSTextField!
    
    var readerCPU: CPUStats
    var readerGPU: GPUStats
    var readerRAM: RAMStats
    var readerBattery: BatteryStats
    var readerFans: FansStats
    var readerNet: NetworkStats
        
    required init?(coder aDecoder: NSCoder) {
        self.readerCPU = ReaderFactory.createReader(ofType: .CPU)
        self.readerGPU = ReaderFactory.createReader(ofType: .GPU)
        self.readerRAM = ReaderFactory.createReader(ofType: .RAM)
        self.readerBattery = ReaderFactory.createReader(ofType: .Battery)
        self.readerFans = ReaderFactory.createReader(ofType: .Fans)
        self.readerNet = ReaderFactory.createReader(ofType: .Network)
        
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
		print("\n")
		
//        readerCPU.read { topProcesses in
//            topProcesses.sorted { processA, processB in
//                processA.usage > processB.usage
//            }.prefix(10).forEach { process in
//                print("Name: \(process.name ?? process.command)\t CPU Usage: \(process.usage)%")
//            }
//        }
        
        print("\n")
        
//        readerGPU.read { gpuS in
//            gpuS.list.forEach { gpu in
//                print("Name: \(gpu.gpuModel)\t GPU Usage: \(NSString(format: "%.2f", (gpu.utilization ?? 0) * 100))%")
//            }
//        }
        
        print("\n")
        
//        readerRAM.read { topProcesses in
//            topProcesses.forEach { process in
//                print("Name: \(process.name ?? process.command) RAM Usage: \(process.usage.readableSize())")
//            }
//        }
        
        print("\n")
        
        readerBattery.read { batteryUsage in
            print("ACwatts: \(batteryUsage.ACwatts)")
            print("Amperage: \(batteryUsage.amperage)")
            print("Cycles: \(batteryUsage.cycles)")
            print("Health: \(batteryUsage.health)")
            print("Is charged: \(batteryUsage.isCharged)")
            print("Is charging: \(batteryUsage.isCharging)")
            print("Battery level: \(batteryUsage.level)")
            print("Power Source: \(batteryUsage.powerSource)")
            print("Tempersture: \(batteryUsage.temperature)")
            print("Time to charge: \(batteryUsage.timeToCharge)")
            print("Time to discharge: \(batteryUsage.timeToEmpty)")
            print("Voltage: \(batteryUsage.voltage)")
        }
    }
    
    @IBAction func refreshCPUStats(_ sender: Any) {
        var textDescription = ""
        
        readerCPU.read { topProcesses in
            topProcesses.sorted { processA, processB in
                processA.usage > processB.usage
            }.prefix(10).forEach { process in
                textDescription += "Name: \(process.name ?? process.command)\t CPU Usage: \(process.usage)%\n"
            }
        }
        
        self.statsText.stringValue = textDescription
    }
    
    @IBAction func refreshGPUStats(_ sender: Any) {
        var textDescription = ""
        
        readerGPU.read { gpuS in
            gpuS.list.forEach { gpu in
                textDescription += "Name: \(gpu.gpuModel)\t GPU Usage: \(NSString(format: "%.2f", (gpu.utilization ?? 0) * 100))% \n"
            }
        }
        
        self.statsText.stringValue = textDescription
    }
    
    @IBAction func refreshRAMStats(_ sender: Any) {
        var textDescription = ""
        
        readerRAM.read { topProcesses in
            topProcesses.forEach { process in
                textDescription += "Name: \(process.name ?? process.command) RAM Usage: \(process.usage.readableSize())\n"
            }
        }
        
        self.statsText.stringValue = textDescription
    }
    
    @IBAction func refreshBatteryStats(_ sender: Any) {
        var textDescription = ""
        
        readerBattery.read { batteryUsage in
            textDescription += "ACwatts: \(batteryUsage.ACwatts)\n"
            textDescription += "Amperage: \(batteryUsage.amperage)\n"
            textDescription += "Cycles: \(batteryUsage.cycles)\n"
            textDescription += "Health: \(batteryUsage.health)\n"
            textDescription += "Is charged: \(batteryUsage.isCharged)\n"
            textDescription += "Is charging: \(batteryUsage.isCharging)\n"
            textDescription += "Battery level: \(batteryUsage.level)\n"
            textDescription += "Power Source: \(batteryUsage.powerSource)\n"
            textDescription += "Tempersture: \(batteryUsage.temperature)\n"
            textDescription += "Time to charge: \(batteryUsage.timeToCharge)\n"
            textDescription += "Time to discharge: \(batteryUsage.timeToEmpty)\n"
            textDescription += "Voltage: \(batteryUsage.voltage)"
        }
        
        self.statsText.stringValue = textDescription
    }
    
    @IBAction func refreshFansStats(_ sender: Any) {
        var textDescription = ""

        readerFans.read { fans in
            fans.forEach { fan in
                textDescription += "Id: \(fan.id)\n"
                textDescription += "Name: \(fan.name)\n"
                textDescription += "Value: \(fan.formattedValue)\n"
                textDescription += "Max Speed: \(fan.maxSpeed)\n"
                textDescription += "Min Speed: \(fan.minSpeed)\n"
                textDescription += "State: \(fan.state)\n"
                textDescription += "Value: \(fan.value)\n"
            }
        }

        self.statsText.stringValue = textDescription
        
        
        print("\n\n")
        
//        let reader: SensorsStats = ReaderFactory.createReader(ofType: .Sensors)
//
//        reader.read { sensor in
//            sensor.forEach { sensorT in
//                print(sensorT)
//            }
//        }
        
//        var store: Store = Store()
//        var smc: SMCService = SMCService()
//
//        var fans = Fans(&store, &smc)
        
//        fans.
        
//        fans.
    }
    
    @IBAction func refreshNetworkStats(_ sender: Any) {
        var textDescription = ""
        
        readerNet.read { networkUsage in
            textDescription += "Bandwidth upload: \(Double(networkUsage.bandwidth.upload).readableSize()) / sec\n"
            textDescription += "Bandwidth download: \(Double(networkUsage.bandwidth.download).readableSize()) / sec\n"
            
            textDescription += "Total upload: \(Double(networkUsage.total.upload).readableSize()) / sec\n"
            textDescription += "Total download: \(Double(networkUsage.total.upload).readableSize()) / sec\n"
            guard let laddr = networkUsage.laddr else { return }
            textDescription += "IP adderes: \(laddr)\n"
        }
        
        self.statsText.stringValue = textDescription
    }
    
    @IBOutlet weak var statsText: NSTextField!
    
    
    func createTimer(withTimeInterval timeInterval: TimeInterval, andClojure clojure: @escaping () -> Void) {
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { timer in
            clojure()
        }
    }
}
