////
////  Fan.swift
////  InnoSystemMonitor
////
////  Created by Иван Абрамов on 22.02.2021.
////
//
//import Foundation
//
//public struct module_c {
//    public var name: String = ""
//    public var icon: NSImage? = nil
//
//    var defaultState: Bool = false
//    var defaultWidget: widget_t = .unknown
//    var availableWidgets: [widget_t] = []
//
//    var widgetsConfig: NSDictionary = NSDictionary()
//
//    init(in path: String) {
//        let dict: NSDictionary = NSDictionary(contentsOfFile: path)!
//
//        if let name = dict["Name"] as? String {
//            self.name = name
//        }
//        if let state = dict["State"] as? Bool {
//            self.defaultState = state
//        }
//
//        if let widgetsDict = dict["Widgets"] as? NSDictionary {
//            var list: [String : Int] = [:]
//            self.widgetsConfig = widgetsDict
//
//            for widgetName in widgetsDict.allKeys {
//                if let widget = widget_t(rawValue: widgetName as! String) {
//                    let widgetDict = widgetsDict[widgetName as! String] as! NSDictionary
//                    if widgetDict["Default"] as! Bool {
//                        self.defaultWidget = widget
//                    }
//                    var order = 0
//                    if let o = widgetDict["Order"] as? Int {
//                        order = o
//                    }
//
//                    list[widgetName as! String] = order
//                }
//            }
//
//            self.availableWidgets = list.sorted(by: { $0.1 < $1.1 }).map{ (widget_t(rawValue: $0.key) ?? .unknown) }
//        }
//    }
//}
//
//public class Fans {
//    public var config: module_c
//    private let store: UnsafePointer<Store>
//    private var smc: UnsafePointer<SMCService>
//    public var available: Bool = false
//    public var readyCallback: () -> Void = {}
//    private var ready: Bool = false
//    private var readers: [Reader_p] = []
//
//    private var fansReader: FansStats
////    private var settingsView: Settings
////    private let popupView: Popup = Popup()
//
//    public init(_ store: UnsafePointer<Store>, _ smc: UnsafePointer<SMCService>) {
//        self.store = store
//        self.smc = smc
//        self.fansReader = FansStats(smc: smc)
////        self.settingsView = Settings("Fans", store: store, list: &self.fansReader.list)
//
////        super.init(
////            store: store,
////            popup: self.popupView,
////            settings: self.settingsView
////        )
//        guard self.available else { return }
//
//        self.checkIfNoSensorsEnabled()
////        self.popupView.setup(self.fansReader.list)
//
////        self.settingsView.callback = { [unowned self] in
////            self.checkIfNoSensorsEnabled()
////            self.fansReader.read()
////        }
////        self.settingsView.setInterval = { [unowned self] value in
////            self.fansReader.setInterval(value)
////        }
//
//        self.fansReader.readyCallback = { [unowned self] in
//            self.readyHandler()
//        }
//        self.fansReader.callbackHandler = { value in
//            self.usageCallback(value)
//        }
//
////        self.addReader(self.fansReader)
//    }
//
//    public func isAvailable() -> Bool {
//        return smc.pointee.getValue("FNum") != nil && smc.pointee.getValue("FNum") != 0 && !self.fansReader.list.isEmpty
//    }
//
//    private func checkIfNoSensorsEnabled() {
//        if self.fansReader.list.filter({ $0.state }).count == 0 {
//            NotificationCenter.default.post(name: .toggleModule, object: nil, userInfo: ["module": self.config.name, "state": false])
//        }
//    }
//
//    private func usageCallback(_ value: [Fan]?) {
////        if value == nil {
////            return
////        }
////
//////        self.popupView.usageCallback(value!)
////
//        let label: Bool = store.pointee.bool(key: "Fans_label", defaultValue: false)
//        var list: [KeyValue_t] = []
//        value!.forEach { (f: Fan) in
//            if f.state {
//                let str = label ? "\(f.name.prefix(1).uppercased()): \(f.formattedValue)" : f.formattedValue
//                list.append(KeyValue_t(key: "Fan#\(f.id)", value: str))
//            }
//        }
//
////        if let widget = self.widget as? SensorsWidget {
////            widget.setValues(list)
////        }
//    }
//
//    public func readyHandler() {
////        os_log(.debug, log: log, "Reader report readiness")
//        self.ready = true
////
////        if !self.widgetLoaded {
////            self.loadWidget()
////        }
//    }
//
//    // add reader to module. If module is enabled will fire a read function and start a reader
//    public func addReader(_ reader: Reader_p) {
//        self.readers.append(reader)
////        os_log(.debug, log: log, "Reader %s was added", "\(reader.self)")
//    }
//}
//
//public protocol Reader_p {
//    var optional: Bool { get }
//    var popup: Bool { get }
//
//    func setup() -> Void
//    func read() -> Void
//    func terminate() -> Void
//
//    func getValue<T>() -> T
//    func getHistory() -> [value_t]
//
//    func start() -> Void
//    func pause() -> Void
//    func stop() -> Void
//
//    func lock() -> Void
//    func unlock() -> Void
//
//    func initStoreValues(title: String, store: UnsafePointer<Store>) -> Void
//    func setInterval(_ value: Int) -> Void
//}
//
//
public struct Fan {
    public let id: Int
    public let name: String
    public let minSpeed: Double
    public let maxSpeed: Double
    public var value: Double

    var state: Bool {
        get {
            return Store.shared.bool(key: "fan_\(self.id)", defaultValue: true)
        }
    }

    var formattedValue: String {
        get {
            return "\(Int(value)) RPM"
        }
    }
}
