
class Constants {
    #if os(OSX)
    // Static copies of files in project
    static let PROJECT = "~/projects/swift/DbTest"
    static let PROC_MAX_FREQ = "\(PROJECT)/sys/scaling_max_freq"
    static let PROC_CUR_FREQ = "\(PROJECT)/sys/scaling_cur_freq"
    static let PROC_CPU_TEMP = "\(PROJECT)/sys/temp"
    static let PROC_CPU_INFO = "\(PROJECT)/proc/cpuinfo"
    static let PROC_STAT = "\(PROJECT)/proc/stat"
    static let TEMPLATE_FOLDER = "\(PROJECT)/Template"
    
    #else
    static let PROC_MAX_FREQ = "/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq"
    static let PROC_CUR_FREQ = "/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq"
    static let PROC_CPU_TEMP = "/sys/class/thermal/thermal_zone0/temp"
    static let PROC_CPU_INFO = "/proc/cpuinfo"
    static let PROC_STAT = "/proc/stat"
    static let TEMPLATE_FOLDER = "./Template"
    #endif
    
    static let USERS = "/opt/go/users"
    static let CERTIFICATES = "/opt/go/certificates"
    
    
}
