
import PostgreSQL

struct Diffie {
    let id: Int?
    let time: String
    let timestamp: Int?
    let userland: Double
    let nice: Double
    let system: Double
    let idle: Double
    let iowait: Double
    let irq: Double
    let softirq: Double
    let steal: Double
    let freq: Double
    let temperature: Double
    
    var dirtyFields: [Field] = []
    
    init(timestamp: Int?, userland: Double, nice: Double, system: Double, idle: Double, iowait: Double, irq: Double, softirq: Double, steal: Double, freq: Double, temperature: Double) {
        let timeStr = fromTimestamp(timestamp!)  // TODO: handle this
        self.init(time: timeStr, userland: userland, nice: nice, system: system, idle: idle, iowait: iowait, irq: irq, softirq: softirq, steal: steal, freq: freq, temperature: temperature)
    }
    
    init(time: String, userland: Double, nice: Double, system: Double, idle: Double, iowait: Double, irq: Double, softirq: Double, steal: Double, freq: Double, temperature: Double) {
        self.id = nil
        self.time = time
        self.userland = userland
        self.nice = nice
        self.system = system
        self.idle = idle
        self.iowait = iowait
        self.irq = irq
        self.softirq = softirq
        self.steal = steal
        self.freq = freq
        self.temperature = temperature
        self.timestamp = fromDate(time)
    }
}

extension Diffie: Model {
    enum Field: String, FieldType {
        case Id = "id"
        case Time = "time"
        case Userland = "userland"
        case Nice = "nice"
        case System = "system"
        case Idle = "idle"
        case Iowait = "iowait"
        case Irq = "irq"
        case Softirq = "softirq"
        case Steal = "steal"
        case Freq = "freq"
        case Temperature = "temperature"
    }
    
    static let tableName: String = "cpuinfo"
    
    static let fieldForPrimaryKey: Field = .Id
    
    static let selectFields: [Field] = [
        .Id,
        .Time,
        .Userland,
        .Nice,
        .System,
        .Idle,
        .Iowait,
        .Irq,
        .Softirq,
        .Steal,
        .Freq,
        .Temperature,
        ]
    
    var primaryKey: Int? {
        return id
    }
    
    
    init(row: Row) throws {
        id = try row.value(Diffie.field(.Id))
        time = try row.value(Diffie.field(.Time))
        timestamp = fromDate(time)
        userland = try row.value(Diffie.field(.Userland))
        nice = try row.value(Diffie.field(.Nice))
        system = try row.value(Diffie.field(.System))
        idle = try row.value(Diffie.field(.Idle))
        iowait = try row.value(Diffie.field(.Iowait))
        irq = try row.value(Diffie.field(.Irq))
        softirq = try row.value(Diffie.field(.Softirq))
        steal = try row.value(Diffie.field(.Steal))
        freq = try row.value(Diffie.field(.Freq))
        temperature = try row.value(Diffie.field(.Temperature))
    }
    
    var persistedValuesByField: [Field: SQLDataConvertible?] {
        return [
            .Time: time,
            .Userland: userland,
            .Nice: nice,
            .System: system,
            .Idle: idle,
            .Iowait: iowait,
            .Irq: irq,
            .Softirq: softirq,
            .Steal: steal,
            .Freq: freq,
            .Temperature: temperature,
        ]
    }
}

