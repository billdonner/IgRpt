# IgRpt
Report Generation Package for IGBlu apps



### to utilize Package 

    let package = Package(
        name: "Kitura-Starter",
        dependencies: [
            .Package(url: "https://github.com/billdonner/FmzSrv", majorVersion: 1) ]
        )


### Main Bootstrap 

This is a full kitura server. To utilize it, create a main program somewhere with this code:

    import LoggerAPI
    import HeliumLogger
    import FmzSrv
    import KitCommons
    
    do {
        HeliumLogger.use(LoggerMessageType.info)
        let controller = try StandardController()
        controller.setupBasicRoutes(router:controller.router)
        try controller.start()
    } 
    catch let error {
        Log.error(error.localizedDescription)
        Log.error("Oops... something went wrong. Server did not start!")
    }


## Notes

# FmzSrv
igblue mid level test server works on BlueMix or Standalone
 
## supported routes

coming soon

### to utilize Package 

    let package = Package(
        name: "Kitura-Starter",
        dependencies: [
            .Package(url: "https://github.com/billdonner/FmzSrv", majorVersion: 1) ]
        )


### Main Bootstrap 

This is a full kitura server. To utilize it, create a main program somewhere with this code:

    import LoggerAPI
    import HeliumLogger
    import FmzSrv
    import KitCommons
    
    do {
        HeliumLogger.use(LoggerMessageType.info)
        let controller = try StandardController()
        controller.setupBasicRoutes(router:controller.router)
        try controller.start()
    } 
    catch let error {
        Log.error(error.localizedDescription)
        Log.error("Oops... something went wrong. Server did not start!")
    }


## Notes
dependent on KitCommons 
