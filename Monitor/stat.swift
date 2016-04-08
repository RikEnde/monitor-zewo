import InterchangeData

class Stat : Constants {
    
    static func stat(key: String) -> InterchangeData? {
        if let stat = stat(), let value = stat[key] {
            return InterchangeData.from([key : value])
        }
        return nil
    }
    
    static func stat() -> InterchangeData? {
        do {
            if let data = try readFileAsStrings(PROC_STAT) {
                var ret : [String: InterchangeData] = [:]
                var cpus = 0
                for line in data {
                    let chunks = line.split(" ")
                    if chunks.count > 1 {
                        let key : String = chunks[0]
                        let value = chunks[1..<chunks.count].filter{ $0.characters.count > 0 }.map { InterchangeData.from(Int($0) ?? 0) }
                        ret[key] = InterchangeData.from(value)
                        if key.startsWith("cpu") {
                            cpus += 1
                        }
                    }
                }
                ret["cpus"] = InterchangeData.from(cpus - 1)
                ret["timestamp"] = InterchangeData.from(getTimestamp())
                
                return InterchangeData.from(ret)
            }
        } catch let error {
            print("Error stat: \(error)")
        }
        return nil
    }
}
