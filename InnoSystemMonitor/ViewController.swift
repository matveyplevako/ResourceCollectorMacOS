import Cocoa
import Foundation
import AppKit

class ViewController: NSViewController {
    
    @IBOutlet weak var statsText: NSTextField!
    
    let systemMonitorStats: SystemMonitorStats
        
    required init?(coder aDecoder: NSCoder) {
        self.systemMonitorStats = SystemMonitorStats()
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var representedObject: Any? {
        didSet {
        }
    }
    
    @IBAction func refreshBatteryTapped(_ sender: Any) {
        systemMonitorStats.readerBattery.read { batteryUsage in
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
        
        systemMonitorStats.readerCPU.read { topProcesses in
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
        
        systemMonitorStats.readerGPU.read { gpuS in
            gpuS.list.forEach { gpu in
                textDescription += "Name: \(gpu.gpuModel)\t GPU Usage: \(NSString(format: "%.2f", (gpu.utilization ?? 0) * 100))% \n"
            }
        }
        
        self.statsText.stringValue = textDescription
    }
    
    @IBAction func refreshRAMStats(_ sender: Any) {
        var textDescription = ""
        
        systemMonitorStats.readerRAM.read { topProcesses in
            topProcesses.forEach { process in
                textDescription += "Name: \(process.name ?? process.command) RAM Usage: \(process.usage.readableSize())\n"
            }
        }
        
        self.statsText.stringValue = textDescription
    }
    
    @IBAction func refreshBatteryStats(_ sender: Any) {
        var textDescription = ""
        
        systemMonitorStats.readerBattery.read { batteryUsage in
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
	
//	is not working refreshing
//	@IBAction func refreshFansTapped(_ sender: Any) {
//		readerFans.read { fans in
//			fans.forEach { fan in
//				print("Id: \(fan.id)\n")
//				print("Name: \(fan.name)\n")
//				print("Value: \(fan.formattedValue)\n")
//				print("Max Speed: \(fan.maxSpeed)\n")
//				print("Min Speed: \(fan.minSpeed)\n")
//				print("State: \(fan.state)\n")
//				print("Value: \(fan.value)\n")
//			}
//		}
//	}

    @IBAction func refreshFansStats(_ sender: Any) {
        var textDescription = ""

        systemMonitorStats.readerFans.read { fans in
            fans.forEach { fan in
                textDescription += "Id: \(fan.id)\n"
                textDescription += "Name: \(fan.name)\n"
                textDescription += "Value: \(fan.formattedValue)\n"
                textDescription += "Max Speed: \(fan.maxSpeed)\n"
                textDescription += "Min Speed: \(fan.minSpeed)\n"
                textDescription += "State: \(fan.state)\n"
                textDescription += "Value: \(fan.value)\n"
				textDescription += "\n"
            }
        }
        
        self.statsText.stringValue =  textDescription
    }
    
    @IBAction func refreshNetworkStats(_ sender: Any) {
        var textDescription = ""
        
        systemMonitorStats.readerNet.read { networkUsage in
            textDescription += "Bandwidth upload: \(Double(networkUsage.bandwidth.upload).readableSize()) / sec\n"
            textDescription += "Bandwidth download: \(Double(networkUsage.bandwidth.download).readableSize()) / sec\n"
            
            textDescription += "Total upload: \(Double(networkUsage.total.upload).readableSize()) / sec\n"
            textDescription += "Total download: \(Double(networkUsage.total.upload).readableSize()) / sec\n"
            guard let laddr = networkUsage.laddr else { return }
            textDescription += "IP adderes: \(laddr)\n"
        }
        
        self.statsText.stringValue = textDescription
    }
    
    @IBAction func refreshSensorsStats(_ sender: Any) {
        var textDescription = ""
        
        systemMonitorStats.readerSensors.read { sensors in
            sensors.forEach { sensor in
                textDescription += "Name: \(sensor.name)\n"
//                textDescription += "State: \(sensor.state)\n"
                textDescription += "Type: \(sensor.type)\n"
                textDescription += "Group: \(sensor.group)\n"
                textDescription += "Key: \(sensor.key)\n"
                textDescription += "Unit: \(sensor.unit)\n"
				textDescription += "Value: \(sensor.value)\n"
				textDescription += "\n"
            }
        }
        self.statsText.stringValue = textDescription
    }
    
    
    func createTimer(withTimeInterval timeInterval: TimeInterval, andClojure clojure: @escaping () -> Void) {
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { timer in
            clojure()
        }
    }
}
