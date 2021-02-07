import Foundation

public func fetchIOService(_ name: String) -> [NSDictionary]? {
	var iterator: io_iterator_t = io_iterator_t()
	var obj: io_registry_entry_t = 1
	var list: [NSDictionary] = []
	
	let result = IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching(name), &iterator)
	if result == kIOReturnSuccess {
		while obj != 0 {
			obj = IOIteratorNext(iterator)
			if let props = getIOProperties(obj) {
				list.append(props)
			}
			IOObjectRelease(obj)
		}
		IOObjectRelease(iterator)
	}
	
	return list.isEmpty ? nil : list
}

public func getIOProperties(_ entry: io_registry_entry_t) -> NSDictionary? {
	var properties: Unmanaged<CFMutableDictionary>? = nil
	
	if IORegistryEntryCreateCFProperties(entry, &properties, kCFAllocatorDefault, 0) != kIOReturnSuccess {
		return nil
	}
	
	defer {
		properties?.release()
	}
	
	return properties?.takeUnretainedValue()
}


public enum DataSizeBase: String {
	case bit = "bit"
	case byte = "byte"
}


public struct Units {
	public let bytes: Int64
	
	public init(bytes: Int64) {
		self.bytes = bytes
	}
	
	public var kilobytes: Double {
		return Double(bytes) / 1_024
	}
	public var megabytes: Double {
		return kilobytes / 1_024
	}
	public var gigabytes: Double {
		return megabytes / 1_024
	}
	public var terabytes: Double {
		return gigabytes / 1_024
	}
	
	public func getReadableTuple(base: DataSizeBase = .byte) -> (String, String) {
		let stringBase = base == .byte ? "B" : "b"
		let multiplier: Double = base == .byte ? 1 : 8
		
		switch bytes {
		case 0..<1_024:
			return ("0", "K\(stringBase)/s")
		case 1_024..<(1_024 * 1_024):
			return (String(format: "%.0f", kilobytes*multiplier), "K\(stringBase)/s")
		case 1_024..<(1_024 * 1_024 * 100):
			return (String(format: "%.1f", megabytes*multiplier), "M\(stringBase)/s")
		case (1_024 * 1_024 * 100)..<(1_024 * 1_024 * 1_024):
			return (String(format: "%.0f", megabytes*multiplier), "M\(stringBase)/s")
		case (1_024 * 1_024 * 1_024)...Int64.max:
			return (String(format: "%.1f", gigabytes*multiplier), "G\(stringBase)/s")
		default:
			return (String(format: "%.0f", kilobytes*multiplier), "K\(stringBase)B/s")
		}
	}
}
