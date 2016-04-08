

func ==(lhs: Point, rhs: Point) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

struct Point : Hashable, CustomStringConvertible {
    var x : Int
    var y : Int
    
    var hashValue : Int {
        return description.hashValue
    }
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
    
    var description : String {
        return "\(x),\(y)"
    }
}

class Graph : Constants {
    
    class func graph(width: Int, _ height: Int) -> (user: [Point], iowait: [Point], temperature: [Point], box: [Point])? {
        func add(point: Point, inout list:[Point], inout set: Set<Point>) -> Bool {
            if !set.contains(point) {
                list.append(point)
                set.insert(point)
                return true
            }
            return false
        }
        
        do {
            let toDate = getTimestamp()
            let fromDate = toDate - 3600 * 24
            
            let diffies = try Storage().readDiffies(fromDate, to: toDate)
            let t0 = fromDate
            let d = toDate - t0
            
            /* No ordered set available at this time */
            
            
            let p0 = Point(0, height)
            var users : [Point] = [p0]
            var io : [Point] = [p0]
            var temp : [Point] = [p0]
            
            var userSet = Set<Point>(users)
            var ioSet = Set<Point>(io)
            var tempSet = Set<Point>(temp)
            
            var xold = 0
            for diff in diffies {
                let xi = Int(Double(width) * (Double(diff.timestamp! - t0) / Double(d)))
                
                /* Handle discontinuity (service downtime) */
                if xi - xold > 10 {
                    let p1 = Point(xold, height)
                    add(p1, list: &users, set:&userSet)
                    add(p1, list: &io, set:&ioSet)
                    add(p1, list: &temp, set:&tempSet)
                    
                    let p2 = Point(xi, height)
                    add(p2, list: &users, set:&userSet)
                    add(p2, list: &io, set:&ioSet)
                    add(p2, list: &temp, set:&tempSet)
                }
                
                let yu = height - Int(diff.userland * Double(height) / 100.0)
                add(Point(xi, yu), list: &users, set:&userSet)
                
                let yi = height - Int(diff.iowait * Double(height) / 100.0)
                add(Point(xi, yi), list: &io, set:&ioSet)
                
                let yt = height - Int(diff.temperature * Double(height) / 100.0)
                add(Point(xi, yt), list: &temp, set:&tempSet)
                
                xold = xi
            }
            let pf = Point(width, height)
            users.append(pf)
            io.append(pf)
            temp.append(pf)
            let box: [Point] = [Point(0, 0), Point(width, 0), Point(width, height), Point(0, height)]
            return (user: users, iowait:io, temperature:temp, box:box)
        } catch let error {
            print("Read diffies failed: \(error)")
        }
        return nil
    }
}