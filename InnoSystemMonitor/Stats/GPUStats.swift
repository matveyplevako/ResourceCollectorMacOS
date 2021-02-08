import Foundation
import Cocoa

class GPUStats {
	public struct GPUs {
		public var list: [GPU_Info] = []
	}
	
	public struct GPU_Info {
		public let IOClass: String
		public let gpu_model: String

		public var utilization: Double? = nil
		
		init(IOClass: String, model: String) {
			self.IOClass = IOClass
			self.gpu_model = model
		}
	}
	
	private var gpus: GPUs = GPUs()
	
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
			
			let ioClass = IOClass.lowercased()
			var gpu_model: String = ""
			
			let utilization: Int? = stats["Device Utilization %"] as? Int ?? stats["GPU Activity(%)"] as? Int ?? nil
			
			if ioClass == "nvaccelerator" || ioClass.contains("nvidia") {
				gpu_model = "Nvidia Graphics"
			} else if ioClass.contains("amd") {
				gpu_model = "AMD Graphics"
			} else {
				gpu_model = "Intel Graphics"
			}
			
			if self.gpus.list.first(where: { $0.gpu_model == gpu_model }) == nil {
				self.gpus.list.append(GPU_Info(
					IOClass: IOClass,
					model: gpu_model
				))
			}
			guard let idx = self.gpus.list.firstIndex(where: { $0.gpu_model == gpu_model }) else {
				return
			}
			if let value = utilization {
				self.gpus.list[idx].utilization = Double(value)/100
			}
		}
		callback(self.gpus)
	}
}
