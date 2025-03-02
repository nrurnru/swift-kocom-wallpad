import Foundation

func main() {
    Logging.shared.setLogLevel(.debug)
    
    do {
        try InfoPlistReader.checkEnvironmentValues()
    } catch {
        fatalError("\(error) \(error.localizedDescription)")
    }
    
    do {
        let app = App.shared
        try app.initialize()
        try app.start()
    } catch {
        Logging.shared.log("Failed to Start Service \(error.localizedDescription)", level: .error)
        fatalError("\(error) \(error.localizedDescription)")
    }
    
    RunLoop.current.run()
}

main()
