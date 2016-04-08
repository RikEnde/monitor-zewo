import PostgreSQL
import InterchangeData

public enum Error : ErrorType {
    case Fatal(String)
}

class Storage {
    var connection : Connection
    
    init() throws {
        if let cred = Auth.dbCredentials(), let user = try cred["user"]?.asString(), let host = try cred["host"]?.asString(),
            let password = try cred["password"]?.asString(), let database = try cred["database"]?.asString() {
            
            connection = Connection(host: host, databaseName: database, username: user, password: password)
            try connection.open()
        } else {
            throw Error.Fatal("Can't read DB credentials")
        }
    }
    
    deinit {
        connection.close()
    }
    
    func diffies(stat0: InterchangeData, _ stat1: InterchangeData) throws -> Diffie? {
        if let t1 = stat1["timestamp"]?.int,
            let t0 = stat0["timestamp"]?.int,
            let cores = stat0["cpus"]?.int,
            let cpu1 = stat1["cpu"]?.array,
            let cpu0 = stat0["cpu"]?.array {
            let dt = t1 - t0
            if dt == 0 {
                return nil
            }
            let userHz = 100 // Todo: C.sysconf(C._SC_CLK_TCK)
            let d = Double(dt * cores * userHz)
            
            func f(key: Int) -> Double {
                if let v1 = cpu1[key].int, let v0 = cpu0[key].int {
                    return 100.0 * Double(v1 - v0) / d
                }
                return 0.0
            }
            
            let cpufreq = CpuInfo.cpuFreq()
            let freq = try cpufreq["frequency"]?.asDouble() ?? 0.0
            let max = try cpufreq["maximum"]?.asDouble() ?? 1.0
            
            let temp = Temp.cpuTemp()
            
            let diffie = Diffie(
                timestamp:    getTimestamp(),
                userland:    f(0),
                nice:    f(1),
                system:  f(2),
                idle:    f(3),
                iowait:  f(4),
                irq:     f(5),
                softirq: f(6),
                steal:   f(7),
                freq: 100.0 * freq / max,
                temperature: temp
            )
            
            return diffie
        }
        
        return nil
    }
    
    
    func storeDiffies() throws {
        print("Store diffies")
        var last = Stat.stat()
        while true {
            let stat = Stat.stat()
            let diff = try diffies(last!, stat!)
            last = stat
            if var diff = diff {
                print("Diffies: \(diff.toJSON()!)")
                try diff.save(connection)
            }
            nap(30 * second)
        }
    }
    
    func readDiffies(from: Int, to: Int) -> [Diffie] {
        do {
            let query = Diffie.selectQuery
                .filter(Diffie.field(.Time) >= "\(fromTimestamp(from))")
                .filter(Diffie.field(.Time) <= "\(fromTimestamp(to))")
                .orderBy(.Ascending(.Time))
            //                .limit(5000)
            print("query: \(query.queryComponents) \(query.dynamicType)")
            let result = try query.fetch(connection)
            
            return result
        } catch let error {
            print("Error in readDiffies: \(error)")
        }
        return []
    }
}
