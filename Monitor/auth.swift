import JSON
import File

class Auth : Constants {
    
    class func credentials(name: String) -> JSON? {
        do {
            let path = "\(USERS)/\(name)"
            let file = try File(path: path, mode: .Read)
            let data = try file.read()
            let json = try JSONParser().parse(data)
            return json
        } catch let error {
            print("Error credentials: \(error)")
        }
        return nil
    }
    
    class func dbCredentials() -> JSON? {
        return credentials("postgres")
    }
    
    class func authenticate(user: String, _ password: String) -> Bool {
        if let cred = credentials("users") {
            if let passwd = try! cred[user]?.asString() {
                return passwd == password
            }
        }
        return false
    }
    
}
