import InterchangeData

class CpuInfo : Constants {
    
    static func readAsNum(path: String) -> Double {
        do {
            if let data = try readFileAsStrings(path) {
                if let tmp = Double(data[0]) {
                    return tmp / 1000.0
                }
            }
        } catch let error {
            print("Error readAsNum: \(error)")
        }
        return 0
    }
    
    static func cpuFreq() -> InterchangeData {
        let data : InterchangeData = [
            "frequency": InterchangeData.from(currentFreq()),
            "maximum": InterchangeData.from(maxFreq())
        ]
        return data
    }
    
    static func currentFreq() -> Double {
        return readAsNum(PROC_CUR_FREQ)
    }
    
    static func maxFreq() -> Double {
        return readAsNum(PROC_MAX_FREQ)
    }
    
    static func cpuInfo(cpuNr: Int, key: String) -> Any? {
        if let data = cpuInfo(cpuNr) {
            return data[key]
        }
        return nil
    }
    
    static func cpuInfo(cpuNr: Int) -> InterchangeData? {
        if cpuNr >= 0 {
            let data = cpuInfo()
            do {
                if let arr = try data?.asArray() {
                    if cpuNr < arr.count {
                        return arr[cpuNr]
                    }
                }
            } catch let error {
                print("CpuInfo not of type [InterchangeData]: \(error)")
            }
        }
        return nil
    }
    
    static func cpuInfo() -> InterchangeData? {
        do {
            if let data = try readFileAsStrings(PROC_CPU_INFO) {
                let cpus = data.split { $0.characters.count == 0 }
                var ret : [InterchangeData] = []
                for cpu in cpus {
                    var dict : [String : InterchangeData] = ["timestamp": InterchangeData.from(getTimestamp())]
                    cpu.map { $0.split(":", allowEmptySlices: true) }.forEach { row in
                        let key = row[0].trim()
                        let value = row[1].trim()
                        if let num = Int(value) {
                            dict[key] = InterchangeData.from(num)
                        } else if let num = Double(value) {
                            dict[key] = InterchangeData.from(num)
                        } else {
                            dict[key] = InterchangeData.from(value)
                        }
                    }
                    ret.append(InterchangeData.from(dict))
                }
                return InterchangeData.from(ret)
            }
        } catch let error {
            print("Error cpuInfo: \(error)")
        }
        return nil
    }
}
