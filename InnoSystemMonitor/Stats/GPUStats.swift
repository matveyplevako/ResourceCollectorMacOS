import Foundation
import Cocoa

class GPUStats {
	
	init() {
	}
	
	public struct GPUs {
		public var list: [GPU_Info] = []
		
		internal func active() -> [GPU_Info] {
			return self.list.filter{ $0.state && $0.utilization != nil }.sorted{ $0.utilization ?? 0 > $1.utilization ?? 0 }
		}
	}
	
	public typealias GPU_type = String
	
	public struct GPU_Info {
		
		public let IOClass: String
		public var vendor: String? = nil
		public let model: String
		
		public var state: Bool = true
		
		public var utilization: Double? = nil
		
		init(IOClass: String, vendor: String? = nil, model: String) {
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
			
			let utilization: Int? = stats["Device Utilization %"] as? Int ?? stats["GPU Activity(%)"] as? Int ?? nil
			
			if ioClass == "nvaccelerator" || ioClass.contains("nvidia") { // nvidia
				predictModel = "Nvidia Graphics"
			} else if ioClass.contains("amd") { // amd
				predictModel = "AMD Graphics"
			} else if ioClass.contains("intel") { // intel
				predictModel = "Intel Graphics"
			} else if ioClass.contains("agx") { // apple
				predictModel = stats["model"] as? String ?? "Apple Graphics"
			} else {
				predictModel = "Unknown"
			}
			
			if model == "" {
				model = predictModel
			}
			if let v = vendor {
				model = model.removedRegexMatches(pattern: v, replaceWith: "").trimmingCharacters(in: .whitespacesAndNewlines)
			}
			
			if self.gpus.list.first(where: { $0.model == model }) == nil {
				self.gpus.list.append(GPU_Info(
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
		}
		
		self.gpus.list.sort{ !$0.state && $1.state }
		callback(self.gpus)
	}
}
