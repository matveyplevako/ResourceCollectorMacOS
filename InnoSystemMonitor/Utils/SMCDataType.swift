import Foundation
import IOKit

enum SMCKeys: UInt8 {
	case KERNEL_INDEX = 2
	case READ_BYTES = 5
	case WRITE_BYTES = 6
	case READ_INDEX = 8
	case READ_KEYINFO = 9
	case READ_PLIMIT = 11
	case READ_VERS = 12
}

struct SMCKeyData_t {
	typealias SMCBytes_t = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
							UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
							UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
							UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
							UInt8, UInt8, UInt8, UInt8)
	
	struct vers_t {
		var major: CUnsignedChar = 0
		var minor: CUnsignedChar = 0
		var build: CUnsignedChar = 0
		var reserved: CUnsignedChar = 0
		var release: CUnsignedShort = 0
	}
	
	struct LimitData_t {
		var version: UInt16 = 0
		var length: UInt16 = 0
		var cpuPLimit: UInt32 = 0
		var gpuPLimit: UInt32 = 0
		var memPLimit: UInt32 = 0
	}
	
	struct keyInfo_t {
		var dataSize: IOByteCount = 0
		var dataType: UInt32 = 0
		var dataAttributes: UInt8 = 0
	}
	
	var key: UInt32 = 0
	var vers = vers_t()
	var pLimitData = LimitData_t()
	var keyInfo = keyInfo_t()
	var padding: UInt16 = 0
	var result: UInt8 = 0
	var status: UInt8 = 0
	var data8: UInt8 = 0
	var data32: UInt32 = 0
	
	var bytes: SMCBytes_t = (UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
							 UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
							 UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
							 UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
							 UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0), UInt8(0),
							 UInt8(0), UInt8(0))
}

struct SMCVal_t {
	var key: String
	var dataSize: UInt32 = 0
	var dataType: String = ""
	var bytes: [UInt8] = Array(repeating: 0, count: 32)
	
	init(_ key: String) {
		self.key = key
	}
}

public class SMCService {
	private var conn: io_connect_t = 0;
	
	public init() {
		var result: kern_return_t
		var iterator: io_iterator_t = 0
		let device: io_object_t
		
		let matchingDictionary: CFMutableDictionary = IOServiceMatching("AppleSMC")
		result = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDictionary, &iterator)
		if (result != kIOReturnSuccess) {
			print("Error IOServiceGetMatchingServices(): " + (String(cString: mach_error_string(result), encoding: String.Encoding.ascii) ?? "unknown error"))
			return
		}
		
		device = IOIteratorNext(iterator)
		IOObjectRelease(iterator)
		if (device == 0) {
			print("Error IOIteratorNext(): " + (String(cString: mach_error_string(result), encoding: String.Encoding.ascii) ?? "unknown error"))
			return
		}
		
		result = IOServiceOpen(device, mach_task_self_, 0, &conn)
		IOObjectRelease(device)
		if (result != kIOReturnSuccess) {
			print("Error IOServiceOpen(): " + (String(cString: mach_error_string(result), encoding: String.Encoding.ascii) ?? "unknown error"))
			return
		}
	}
	
	public func close() -> kern_return_t{
		return IOServiceClose(conn)
	}
	
	private func read(_ value: UnsafeMutablePointer<SMCVal_t>) -> kern_return_t {
		var result: kern_return_t = 0
		var input = SMCKeyData_t()
		var output = SMCKeyData_t()
		
		input.key = FourCharCode(value.pointee.key)!
		input.data8 = SMCKeys.READ_KEYINFO.rawValue
		
		result = call(SMCKeys.KERNEL_INDEX.rawValue, input: &input, output: &output)
		if result != kIOReturnSuccess {
			print("Error call(READ_KEYINFO): " + (String(cString: mach_error_string(result), encoding: String.Encoding.ascii) ?? "unknown error"))
			return result
		}
		
		value.pointee.dataSize = UInt32(output.keyInfo.dataSize)
		value.pointee.dataType = String(output.keyInfo.dataType)
		input.keyInfo.dataSize = output.keyInfo.dataSize
		input.data8 = SMCKeys.READ_BYTES.rawValue
		
		result = call(SMCKeys.KERNEL_INDEX.rawValue, input: &input, output: &output)
		if result != kIOReturnSuccess {
			print("Error call(READ_BYTES): " + (String(cString: mach_error_string(result), encoding: String.Encoding.ascii) ?? "unknown error"))
			return result
		}
		
		memcpy(&value.pointee.bytes, &output.bytes, Int(value.pointee.dataSize))
		
		return kIOReturnSuccess;
	}
	
	private func call(_ index: UInt8, input: inout SMCKeyData_t, output: inout SMCKeyData_t) -> kern_return_t {
		let inputSize = MemoryLayout<SMCKeyData_t>.stride
		var outputSize = MemoryLayout<SMCKeyData_t>.stride
		
		return IOConnectCallStructMethod(
			conn,
			UInt32(index),
			&input,
			inputSize,
			&output,
			&outputSize
		)
	}
}
