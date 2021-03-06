import Foundation

public class SystemMonitorStats {
	public let readerCPU: CPUStats
	public let readerGPU: GPUStats
	public let readerRAM: RAMStats
	public let readerBattery: BatteryStats
	public let readerFans: FansStats
	public let readerNet: NetworkStats
	public let readerSensors: SensorsStats
	
	init() {
		self.readerCPU = ReaderFactory.createReader(ofType: .CPU)
		self.readerGPU = ReaderFactory.createReader(ofType: .GPU)
		self.readerRAM = ReaderFactory.createReader(ofType: .RAM)
		self.readerBattery = ReaderFactory.createReader(ofType: .Battery)
		self.readerFans = ReaderFactory.createReader(ofType: .Fans)
		self.readerNet = ReaderFactory.createReader(ofType: .Network)
		self.readerSensors = ReaderFactory.createReader(ofType: .Sensors)
	}
}
