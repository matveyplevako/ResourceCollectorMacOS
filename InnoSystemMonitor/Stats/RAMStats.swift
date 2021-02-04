//
//  readers.swift
//  Memory
//
//  Created by Serhiy Mytrovtsiy on 12/04/2020. we did not stole it
//  Using Swift 5.0.
//  Running on macOS 10.15.
//
//  Copyright © 2020 Serhiy Mytrovtsiy. All rights reserved.
//

import Cocoa


public struct RAM_Usage: value_t {
    var total: Double
    var used: Double
    var free: Double
    
    var active: Double
    var inactive: Double
    var wired: Double
    var compressed: Double
    
    var app: Double
    var cache: Double
    var pressure: Double
    
    var pressureLevel: Int
    var swap: Swap
    
    public var widget_value: Double {
        get {
            return self.usage
        }
    }
    
    public var usage: Double {
        get {
            return Double((self.total - self.free) / self.total)
        }
    }
}

public struct Swap {
    var total: Double
    var used: Double
    var free: Double
}

public class RAM {
    private var usageReader: UsageReader? = nil
    private var processReader: ProcessReader? = nil
    
    public init(_ store: UnsafePointer<Store>) {
        self.settingsView = Settings("RAM", store: store)
        self.popupView = Popup("RAM", store: store)
        
        super.init(
            store: store,
            popup: self.popupView,
            settings: self.settingsView
        )
        guard self.available else { return }
        
        self.settingsView.setInterval = { [unowned self] value in
            self.processReader?.read()
            self.usageReader?.setInterval(value)
        }
        
        self.usageReader = UsageReader()
        self.processReader = ProcessReader(self.config.name, store: store)
        
        self.settingsView.callbackWhenUpdateNumberOfProcesses = {
            self.popupView.numberOfProcessesUpdated()
            DispatchQueue.global(qos: .background).async {
                self.processReader?.read()
            }
        }
        
        self.usageReader?.readyCallback = { [unowned self] in
            self.readyHandler()
        }
        self.usageReader?.callbackHandler = { [unowned self] value in
            self.loadCallback(value)
        }
        
        self.processReader?.callbackHandler = { [unowned self] value in
            if let list = value {
                self.popupView.processCallback(list)
            }
        }
        
        if let reader = self.usageReader {
            self.addReader(reader)
        }
        if let reader = self.processReader {
            self.addReader(reader)
        }
    }
    
    private func loadCallback(_ raw: RAM_Usage?) {
        guard raw != nil, let value = raw else {
            return
        }
        
        self.popupView.loadCallback(value)
        if let widget = self.widget as? Mini {
            widget.setValue(value.usage)
            widget.setPressure(value.pressureLevel)
        }
        if let widget = self.widget as? LineChart {
            widget.setValue(value.usage)
            widget.setPressure(value.pressureLevel)
        }
        if let widget = self.widget as? BarChart {
            widget.setValue([value.usage])
            widget.setPressure(value.pressureLevel)
        }
        if let widget = self.widget as? PieChart {
            let total: Double = value.total
            widget.setValue([
                circle_segment(value: value.app/total, color: NSColor.systemBlue),
                circle_segment(value: value.wired/total, color: NSColor.systemOrange),
                circle_segment(value: value.compressed/total, color: NSColor.systemPink)
            ])
        }
        if let widget = self.widget as? MemoryWidget {
            let free = Units(bytes: Int64(value.free)).getReadableMemory()
            let used = Units(bytes: Int64(value.used)).getReadableMemory()
            widget.setValue((free, used))
        }
    }
}


class UsageReader{
    public var totalSize: Double = 0
    
    public func setup() {
        var stats = host_basic_info()
        var count = UInt32(MemoryLayout<host_basic_info_data_t>.size / MemoryLayout<integer_t>.size)
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_info(mach_host_self(), HOST_BASIC_INFO, $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            self.totalSize = Double(stats.max_mem)
            return
        }
        
        self.totalSize = 0
        print(String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error")
    }
    
    public func read(callback: @escaping (RAM_Usage) -> Void) {
        var stats = vm_statistics64()
        var count = UInt32(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        
        let result: kern_return_t = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            let active = Double(stats.active_count) * Double(vm_page_size)
            let speculative = Double(stats.speculative_count) * Double(vm_page_size)
            let inactive = Double(stats.inactive_count) * Double(vm_page_size)
            let wired = Double(stats.wire_count) * Double(vm_page_size)
            let compressed = Double(stats.compressor_page_count) * Double(vm_page_size)
            let purgeable = Double(stats.purgeable_count) * Double(vm_page_size)
            let external = Double(stats.external_page_count) * Double(vm_page_size)
            
            let used = active + inactive + speculative + wired + compressed - purgeable - external
            let free = self.totalSize - used
            
            var int_size: size_t = MemoryLayout<uint>.size
            var pressureLevel: Int = 0
            sysctlbyname("kern.memorystatus_vm_pressure_level", &pressureLevel, &int_size, nil, 0)
            
            var string_size: size_t = MemoryLayout<xsw_usage>.size
            var swap: xsw_usage = xsw_usage()
            sysctlbyname("vm.swapusage", &swap, &string_size, nil, 0)
            
            callback(RAM_Usage(
                total: self.totalSize,
                used: used,
                free: free,
                
                active: active,
                inactive: inactive,
                wired: wired,
                compressed: compressed,
                
                app: used - wired - compressed,
                cache: purgeable + external,
                pressure: 100.0 * (wired + compressed) / self.totalSize,
                
                pressureLevel: pressureLevel,
                
                swap: Swap(
                    total: Double(swap.xsu_total),
                    used: Double(swap.xsu_used),
                    free: Double(swap.xsu_avail)
                )
            ))
            return
        }
        
        os_log(.error, log: log, "host_statistics64(): %s", "\((String(cString: mach_error_string(result), encoding: String.Encoding.ascii) ?? "unknown error"))")
    }
}

public class ProcessReader {
    private let store: UnsafePointer<Store>
    private let title: String
    
    private var numberOfProcesses: Int {
        get {
            return self.store.pointee.int(key: "\(self.title)_processes", defaultValue: 8)
        }
    }
    
    init(_ title: String, store: UnsafePointer<Store>) {
        self.title = title
        self.store = store
        super.init()
    }
    
    public override func setup() {
        self.popup = true
    }
    
    public override func read() {
        if self.numberOfProcesses == 0 {
            return
        }
        
        
        
        do {
            try task.run()
        } catch let error {
            os_log(.error, log: log, "top(): %s", "\(error.localizedDescription)")
            return
        }
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: outputData, as: UTF8.self)
        _ = String(decoding: errorData, as: UTF8.self)
        
        if output.isEmpty {
            return
        }
        
        var processes: [TopProcess] = []
        output.enumerateLines { (line, _) -> () in
            if line.matches("^\\d+ +.* +\\d+[A-Z]*\\+?\\-? *$") {
                var str = line.trimmingCharacters(in: .whitespaces)
                let pidString = str.findAndCrop(pattern: "^\\d+")
                let usageString = str.suffix(5)
                var command = str.replacingOccurrences(of: pidString, with: "")
                command = command.replacingOccurrences(of: usageString, with: "")
                
                if let regex = try? NSRegularExpression(pattern: " (\\+|\\-)*$", options: .caseInsensitive) {
                    command = regex.stringByReplacingMatches(in: command, options: [], range: NSRange(location: 0, length:  command.count), withTemplate: "")
                }
                
                let pid = Int(pidString.filter("01234567890.".contains)) ?? 0
                var usage = Double(usageString.filter("01234567890.".contains)) ?? 0
                if usageString.contains("G") {
                    usage *= 1024 // apply gigabyte multiplier
                } else if usageString.contains("K") {
                    usage /= 1024 // apply kilobyte divider
                }
                
                var name: String? = nil
                var icon: NSImage? = nil
                if let app = NSRunningApplication(processIdentifier: pid_t(pid) ) {
                    name = app.localizedName ?? nil
                    icon = app.icon
                }
                
                let process = TopProcess(pid: pid, command: command, name: name, usage: usage * Double(1024 * 1024), icon: icon)
                processes.append(process)
            }
        }
        
        callback(processes)
    }
}
