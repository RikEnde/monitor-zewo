import File
import InterchangeData

#if os(Linux)
    import SwiftDate
#else
    import Foundation
#endif


func getTimestamp() -> Int {
    #if os(Linux)
        return timestamp()
    #else
        return Int(NSDate().timeIntervalSince1970)
    #endif
}

func fromDate(str: String) -> Int? {
    #if os(Linux)
        return toTimestamp(str)
    #else
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.dateFromString(str) {
            return Int(date.timeIntervalSince1970)
        }
        return nil
    #endif
}

func fromTimestamp(seconds: Int) -> String {
    #if os(Linux)
        if let dateStr = toDate(seconds) {
            return dateStr
        }
        return "ERROR"
    #else
        let date = NSDate(timeIntervalSince1970: Double(seconds))
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.stringFromDate(date)
    #endif
}

func readFileAsStrings(path: String) throws -> [String]? {
    do {
        let data = try File(path: path, mode: .Read).read()
        let str = String(data)
        return str.split("\n", allowEmptySlices: true)
    } catch let error {
        print("Error readFileAsStrings: \(error)")
        throw error
    }
}

protocol JSONSerializable {
    func toJSON() -> String?
}

extension String : JSONSerializable {
    func toJSON() -> String? {
        return "\"\(self)\""
    }
}

extension Int : JSONSerializable {
    func toJSON() -> String? {
        return "\(self)"
    }
}

extension Double : JSONSerializable {
    func toJSON() -> String? {
        return "\(self)"
    }
}

extension Array : JSONSerializable {
    func toJSON() -> String? {
        var out : [String] = []
        for element in self {
            if let json_element = element as? JSONSerializable, let string = json_element.toJSON() {
                out.append(string)
            } else {
                return nil
            }
        }
        return "[\(out.joinWithSeparator(", "))]"
    }
}

extension Dictionary : JSONSerializable {
    func toJSON() -> String? {
        var out : [String] = []
        for (k, v) in self {
            if let json_element = v as? JSONSerializable, let string = json_element.toJSON() {
                out.append("\"\(k)\": \(string)")
            } else {
                return nil
            }
        }
        return "{\(out.joinWithSeparator(", "))}"
    }
}

extension Diffie : JSONSerializable {
    func toJSON() -> String? {
        return "{\"id\":\(id ?? 0),\"time\":\"\(time)\",\"timestamp\":\(timestamp ?? 0),\"userland\":\(userland),\"nice\":\(nice),\"system\":\(system),\"idle\":\(idle),\"iowait\":\(iowait),\"irq\":\(irq),\"softirq\":\(softirq),\"steal\":\(steal),\"freq\":\(freq),\"temperature\":\(temperature)}"
    }
}


