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

public class RAMStats {
    
    public func read(callback: @escaping ([TopProcess]) -> ()) {
        let numberOfProcesses = 10
        
        if numberOfProcesses == 0 {
            return
        }
        
        let task = Process()
        task.launchPath = "/usr/bin/top"
        task.arguments = ["-l", "1", "-o", "mem", "-n", "\(numberOfProcesses)", "-stats", "pid,command,mem"]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        do {
            try task.run()
        } catch let error {
            print("Error: \(error.localizedDescription)")
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
