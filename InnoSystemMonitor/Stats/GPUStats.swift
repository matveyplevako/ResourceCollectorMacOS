import Foundation
import Cocoa

public protocol value_t {
	var widget_value: Double { get }
}

class GPUStats {
	
	init() {
		
	}
	
	public struct GPUs: value_t {
		public var list: [GPU_Info] = []
		
		internal func active() -> [GPU_Info] {
			return self.list.filter{ $0.state && $0.utilization != nil }.sorted{ $0.utilization ?? 0 > $1.utilization ?? 0 }
		}
		
		public var widget_value: Double {
			get {
				return list.isEmpty ? 0 : (list[0].utilization ?? 0)
			}
		}
	}
	
	public typealias GPU_type = String
	
	public struct GPU_Info {
		public let id: String
		public let type: GPU_type
		
		public let IOClass: String
		public var vendor: String? = nil
		public let model: String
		
		public var state: Bool = true
		
		public var fanSpeed: Int? = nil
		public var coreClock: Int? = nil
		public var memoryClock: Int? = nil
		public var temperature: Double? = nil
		public var utilization: Double? = nil
		
		init(type: GPU_type, IOClass: String, vendor: String? = nil, model: String) {
			self.id = UUID().uuidString
			self.type = type
			self.IOClass = IOClass
			self.vendor = vendor
			self.model = model
		}
	}
	
	public enum GPU_types: GPU_type {
		case unknown = ""
		case integrated = "i"
		case external = "e"
		case discrete = "d"
	}
	
	public struct device {
		public let vendor: String?
		public let model: String
		public let pci: String
		public var used: Bool
	}
	
	internal var smc: UnsafePointer<SMCService>? = nil
	private var gpus: GPUs = GPUs()
	private var devices: [device] = []
	
	public func read(callback: @escaping (GPUs) -> Void) {
		guard let accelerators = fetchIOService(kIOAcceleratorClassName) else {
			return
		}
		//        var devices = self.devices
		
		accelerators.forEach { (accelerator: NSDictionary) in
			guard let IOClass = accelerator.object(forKey: "IOClass") as? String else {
				print("Error: IOClass not found")
				return
			}
			
			guard let stats = accelerator["PerformanceStatistics"] as? [String:Any] else {
				print("PerformanceStatistics not found")
				return
			}
			
			var vendor: String? = nil
			var model: String = ""
			let accMatch = (accelerator["IOPCIMatch"] as? String ?? accelerator["IOPCIPrimaryMatch"] as? String ?? "").lowercased()
			
			for (i, device) in devices.enumerated() {
				if accMatch.range(of: device.pci) != nil && !device.used {
					model = device.model
					vendor = device.vendor
					devices[i].used = true
					break
				}
			}
			
			let ioClass = IOClass.lowercased()
			var predictModel = ""
			var type: GPU_types = .unknown
			
			let utilization: Int? = stats["Device Utilization %"] as? Int ?? stats["GPU Activity(%)"] as? Int ?? nil
			var temperature: Int? = stats["Temperature(C)"] as? Int ?? nil
			let fanSpeed: Int? = stats["Fan Speed(%)"] as? Int ?? nil
			let coreClock: Int? = stats["Core Clock(MHz)"] as? Int ?? nil
			let memoryClock: Int? = stats["Memory Clock(MHz)"] as? Int ?? nil
			
			if ioClass == "nvaccelerator" || ioClass.contains("nvidia") { // nvidia
				predictModel = "Nvidia Graphics"
				type = .discrete
			} else if ioClass.contains("amd") { // amd
				predictModel = "AMD Graphics"
				type = .discrete
				
				if temperature == nil || temperature == 0 {
					if let tmp = self.smc?.pointee.getValue("TGDD"), tmp != 128 {
						temperature = Int(tmp)
					}
				}
			} else if ioClass.contains("intel") { // intel
				predictModel = "Intel Graphics"
				type = .integrated
				
				if temperature == nil || temperature == 0 {
					if let tmp = self.smc?.pointee.getValue("TCGC"), tmp != 128 {
						temperature = Int(tmp)
					}
				}
			} else if ioClass.contains("agx") { // apple
				predictModel = stats["model"] as? String ?? "Apple Graphics"
				type = .integrated
			} else {
				predictModel = "Unknown"
				type = .unknown
			}
			
			if model == "" {
				model = predictModel
			}
			if let v = vendor {
				model = model.removedRegexMatches(pattern: v, replaceWith: "").trimmingCharacters(in: .whitespacesAndNewlines)
			}
			
			if self.gpus.list.first(where: { $0.model == model }) == nil {
				self.gpus.list.append(GPU_Info(
					type: type.rawValue,
					IOClass: IOClass,
					vendor: vendor,
					model: model
				))
			}
			guard let idx = self.gpus.list.firstIndex(where: { $0.model == model }) else {
				return
			}
			
			if let agcInfo = accelerator["AGCInfo"] as? [String:Int], let state = agcInfo["poweredOffByAGC"] {
				self.gpus.list[idx].state = state == 0
			}
			
			if let value = utilization {
				self.gpus.list[idx].utilization = Double(value)/100
			}
			if let value = temperature {
				self.gpus.list[idx].temperature = Double(value)
			}
			if let value = fanSpeed {
				self.gpus.list[idx].fanSpeed = value
			}
			if let value = coreClock {
				self.gpus.list[idx].coreClock = value
			}
			if let value = memoryClock {
				self.gpus.list[idx].memoryClock = value
			}
		}
		
		self.gpus.list.sort{ !$0.state && $1.state }
		callback(self.gpus)
	}
}
