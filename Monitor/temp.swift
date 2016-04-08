import File

class Temp : Constants {
    
    class func cpuTemp() -> Double {
        do {
            let file = try File(path:PROC_CPU_TEMP, mode: .Read)
            let data = try String(file.read()).trim()
            if let temp = Double(data) {
                return temp / 1000.0
            }
        } catch let error {
            print("Error cpuTemp: \(error)")
        }
        return 0.0
    }
}
