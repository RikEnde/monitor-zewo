import Venice
import HTTPServer
import Router
import Sideburns
import Log
import LogMiddleware
import BasicAuthMiddleware
import ContentNegotiationMiddleware
import JSONMediaType


let router = Router() { router in
    
    /* Requst matched none of the accepted patterns */
    router.fallback() { request in
        print("ERR \(request) - \(request.headers)")
        let data = ["message": "Page not found"]
        return try Response(status: .NotFound, templatePath: "\(Constants.TEMPLATE_FOLDER)/404.html", templateData: data)
    }
    
    /* HTTP Bad Request with error message */
    func fail(msg: String) -> Response {
        return Response(status: .BadRequest, body: msg)
    }
    
    /* Proper way to show 'contract' and 'discoverability' of REST service */
    router.get("/") { request in
        print("OK \(request)")
        let data : [String: Any] = [
            "title":"CPU Status REST service",
            "urls": [
                ["url":"/cpu", "desc": "query cpuinfo"],
                ["url":"/cpu/1/model", "desc": "model cpu 1"],
                ["url":"/cpu/0/cpu%20MHz", "desc": "query mHz of cpu 0"],
                ["url":"/stat", "desc": "query cpustat"],
                ["url":"/stat/cpu", "desc": "query jiffies aggregate over all cores"],
                ["url":"/history", "desc": "query diffies over past hour"],
                ["url":"/temperature", "desc": "query cpu core temperature"],
                ["url":"/frequency", "desc": "query cpu clock frequency"],
                ["url":"/graph", "desc": "graph"],
            ],
            "request": "\(request)",
        ]
        
        return try Response(status: .OK, templatePath: "\(Constants.TEMPLATE_FOLDER)/index.html", templateData: data)
    }
    
    /* JSON encoded content of /proc/stat */
    router.get("/stat") { request in
        print("OK \(request): \(request.headers)")
        if let data = Stat.stat() {
            return Response(status: .OK, content: data)
        }
        return fail("Result cannot be serialized")
    }
    
    /* JSON encoded data for cpu {key} from /proc/stat */
    router.get("/stat/:key") { request in
        print("OK \(request): \(request.headers)")
        if let key = request.pathParameters["key"] {
            if let data = Stat.stat(key) {
                return Response(status: .OK, content: data)
            }
        }
        return fail("Key not valid")
    }
    
    /* JSON encoded output of /proc/cpuinfo */
    router.get("/cpu") { request in
        print("OK \(request): \(request.headers)")
        if let data = CpuInfo.cpuInfo() {
            return Response(status: .OK, content: data)
        }
        return fail("Result cannot be serialized")
    }
    
    /* JSON encoded output for cpu {cpu} of /proc/cpuinfo */
    router.get("/cpu/:cpu") { request in
        print("OK \(request): \(request.headers)")
        if let cpu = request.pathParameters["cpu"], let cpuNr = Int(cpu), let data = CpuInfo.cpuInfo(cpuNr) {
            return Response(status: .OK, content: data)
        }
        return fail("CPU id not valid")
    }
    
    /* Value of key {key} of cpu {cpu} from /proc/cpuinfo */
    router.get("/cpu/:cpu/:key") { request in
        print("OK \(request): \(request.headers)")
        if let cpu = request.pathParameters["cpu"], key = request.pathParameters["key"], let cpuNr = Int(cpu), let data = CpuInfo.cpuInfo(cpuNr, key: key) {
            return Response(status: .OK, body: "\(data)")
        }
        return fail("CPU id not valid or key doesn't exist")
    }
    
    /* JSON encoded output of stored diffies in database */
    router.get("/history") { request in
        print("OK \(request)")
        let toDate = getTimestamp()
        let fromDate = toDate - 3600
        do {
            let diffies = try Storage().readDiffies(fromDate, to: toDate)
            if let json = diffies.toJSON() {
                return Response(status: .OK, body: json)
            }
            return fail("Result cannot be serialized to JSON: \(diffies)")
        } catch {
            return fail("Database error occurred")
        }
    }
    
    /* thermal_zone0/temp */
    router.get("/temperature") { request in
        print("OK \(request)")
        let temp = InterchangeData.from(Temp.cpuTemp())
        return Response(status: .OK, content: temp)
    }
    
    /* current and max cpu frequency of cpu 0 */
    router.get("/frequency") { request in
        print("OK \(request)")
        let freq = CpuInfo.cpuFreq()
        return Response(status: .OK, content: freq)
    }
    
    /* Graph of diffies in SVG format */
    router.get("/graph") { request in
        print("OK \(request)")
        let height = 400
        let width = 800
        if let graph = Graph.graph(width, height) {
            let data : [String : String] = [
                "box" : graph.box.map{ $0.description }.joinWithSeparator(" "),
                "temperature" : graph.temperature.map{ $0.description }.joinWithSeparator(" "),
                "user" : graph.user.map{ $0.description }.joinWithSeparator(" "),
                "iowait" : graph.iowait.map{ $0.description }.joinWithSeparator(" "),
                "height" : "\(height)",
                "width" : "\(width)"
            ]
            return try Response(status: .OK, templatePath: "\(Constants.TEMPLATE_FOLDER)/graph.html", templateData: data)
        }
        return fail("Graph not available")
    }
}

co {
    print("Coroutine for database stuff")
    do {
        try Storage().storeDiffies()
    } catch let error {
        print("Diffie storage coroutine failed with error: \(error)")
    }
}

let log = Log(levels: .Debug)
let logger = LogMiddleware(log: log)

let basicAuth = BasicAuthMiddleware(realm: "Beware of the dog!") { username, password in
    log.debug("Login attempt with user: \(username)")
    if Auth.authenticate(username, password) {
        log.debug("Access granted to user \(username)")
        return .Authenticated
    }
    log.debug("Access denied to user \(username)")
    
    return .AccessDenied
}
let contentNegotiation = ContentNegotiationMiddleware(mediaTypes: JSONMediaType())

print("Server ready https://localhost:8000")
do {
    try Server(port: 8000, reusePort: true,
               middleware: logger, contentNegotiation, basicAuth,
        responder: router).start()
} catch let error {
    print("Server failed to start with error: \(error)")
}


//do {
//    try Server(port: 8000,
//        certificate: "\(Constants.CERTIFICATES)/cert.pem",
//        privateKey: "\(Constants.CERTIFICATES)/key.pem",
//        responder: router
//    ).start()
//    print("Server ready https://localhost:8000/boom/4067")
//} catch let error {
//    print("Server failed to start with error: \(error)")
//}
