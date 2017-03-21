struct IgRpt {

    var text = "Hello, World from IgRpt"
}
//
//  db model data
//
//  Created by bill donner on 1/15/17.
//
//

import Foundation
import Kitura
import LoggerAPI
import Configuration
import CloudFoundryEnv
import CloudFoundryConfig
import CloudFoundryDeploymentTracker
import KitCommons

let serverConfigRpt = ServerConfig( version: "0.998920",
                                 title: "IGBLUEREPORTS",
                                description: "/report and /report-list routes",
                                ident : "https://igblue.mybluemix.net")
// MARK: custom routes
extension   StandardController {
    public convenience init() throws {
        try self.init(serverConfigRpt)
        CloudFoundryDeploymentTracker(repositoryURL: "https://github.com/IBM-Bluemix/Kitura-Starter.git", codeVersion: nil).track()
        
    }
    
    open func start() throws {
        let s = Kitura.addHTTPServer(onPort:  port, with:  router)
        s.started {
            // wait for Kitura to get the server going
            
        }
        // Start Kitura-Starter server
        Kitura.run()
    }
    
    open func setupBasicRoutes(router:Router) {
        /// offer public files here - it is used internally to load files at startup as well
        
        
        // Basic GET request
        router.get("/", handler: getJSON)
        
        
        // JSON Get request
        router.get("/json", handler: getJSON)
        
        
        // these take a ?smtoken=xyz
        
        router.get("/report-list/:userid", handler: getReportList)
        
        router.get("/report/:userid/:rptid", handler: getReportForID)
        
        
        
    }
    
    
    
}


typealias ReportBody = [String:Any]

enum ReportKind {
    case aboutPosts
    case aboutPeople
    case aboutFollowers
    case aboutTags
    case adHoc
    func description() -> String {
        switch self {
        case .aboutPosts: return "Posts"
        case .aboutPeople: return "People"
        case .aboutFollowers: return "Followers"
        case .aboutTags: return "Tags"
        case .adHoc: return "Adhoc"
        }
    }
}
typealias ReportResult = (Int,ReportBody,ReportKind)
typealias ReportingFunc = () -> ()
func dummy() {
    
}
let reportfuncs:[String : ( ReportKind,ReportingFunc)] =
    [
        "top-posts": ( ReportKind.aboutPosts, dummy),// ReportMakerMainServer.top_posts_report),
        "top-comments": ( ReportKind.aboutPosts, dummy),// ReportMakerMainServer.top_comments_report),
        "when-posting": ( ReportKind.adHoc, dummy),// ReportMakerMainServer.when_posting_report),
        "when-topost": ( ReportKind.adHoc, dummy),// ReportMakerMainServer.when_topost_report),
        
        "all-followers": ( ReportKind.aboutFollowers,  dummy),// ReportMakerMainServer.all_followers_report),
        "ghost-followers": ( ReportKind.aboutFollowers,  dummy),// ReportMakerMainServer.ghost_followers_report),
        "unrequited-followers": ( ReportKind.aboutFollowers,  dummy),//ReportMakerMainServer.unrequited_followers_report),
        "booster-followers": ( ReportKind.aboutFollowers,  dummy),//ReportMakerMainServer.booster_followers_report),
        "secret-admirers": ( ReportKind.aboutFollowers,  dummy),//ReportMakerMainServer.secret_admirer_followers_report),
        
        "most-popular-tags": ( ReportKind.aboutTags,  dummy),//ReportMakerMainServer.most_popular_tags_report),
        "most-popular-taggedusers": ( ReportKind.aboutTags,  dummy),//ReportMakerMainServer.most_popular_taggedusers_report),
        "most-popular-filters": ( ReportKind.aboutTags, dummy),// ReportMakerMainServer.most_popular_filters_report),
        
        "all-followings": ( ReportKind.aboutPeople,   dummy),//ReportMakerMainServer.all_followings_report),
        "top-likers": ( ReportKind.aboutPeople,  dummy),//ReportMakerMainServer.top_likers_report),
        "top-commenters": ( ReportKind.aboutPeople, dummy),// ReportMakerMainServer.top_commenters_report),
        "speechless-likers": ( ReportKind.aboutPeople,  dummy),//ReportMakerMainServer.speechless_likers_report),
        "heartless-commenters": ( ReportKind.aboutPeople,  dummy),//ReportMakerMainServer.heartless_commenters_report)
]


extension  StandardController {
    
    fileprivate     static func reportsDict() ->[String:Any] {
        
        var newrows :[[String:Any]] = []
        var row = 0
        for (key,thing) in reportfuncs {
            let(kind,_) = thing
            let type = kind.description()
            newrows.append(["report-id":row as Any,"type":type as Any,"report-name":key as Any])
            row += 1
        }
        return ["reports":newrows as Any]
    }
    
    func loadReportsInfo(_ s:String)->[String:Any] {
        return ["report-list":s,"data": StandardController.reportsDict()]
    }
    func loadReportDataForID(id:Int)->[String:Any] {
        return ["report-id":id,"data":"coming soon"]
    }
    
    
    
    //MARK:- Target actions for Routes
    
    
    /**
     * Handler for getting an application/json response.
     */
    public func getJSON(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        global.apic.getIn += 1
        try finishJSONStatusResponse(["reports-list":StandardController.reportsDict()], request: request, response: response, next: next)
        
    }
    
    /// VALIDATE TOKEN, THEN GET THE REPORT
    
    public func getReportForID(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void)  {
       /// guard self.fullyInitialized else { self.sendCallAgainSoon(response); return }
        guard let smtoken = request.queryParameters["smtoken"],let userid = request.parameters["userid"] else { return  self.missingID(response) }
        
        global.apic.getIn += 1
        
        /// now make remote call to .... /igtoken/:userid"
        let targeturl = ""
        
        
        fetchWithTokens(userid: userid, smtoken: smtoken, targeturl: targeturl, request: request, response: response){ status, data in
            /// now , finally we can go ahead and do the original call
            guard let rid = request.parameters["rptid"]else { return  self.missingID(response)  }
            
            /////////
            
            let reportfunc =  reportfuncs[rid]
            guard reportfunc !=  nil else { return self.unkownOP(response) }
            let fetchurl = "https://billdonner.com/tr/config.json"
            Fetch.get(fetchurl, session: nil, use: .tKituraSynch)  { status, data in
                // should be all settled
                if let data = data {
                    //
                    do {
                        let out = ["report-data":data ] as [String : Any]
                        // send ack to caller
                        try self.finishJSONStatusResponse(out, request: request, response: response, next: next)
                    }
                    catch {
                        try! self.finishJSONStatusResponse(["report-status":408 ], request: request, response: response, next: next)
                    }
                }
            }//inner fetch
        }// completion
        
    }//getReportForID
    
    /// VALIDATE TOKEN, THEN GET THE REPORTLIST
    public func getReportList(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void)  {
       /// guard self.fullyInitialized else { self.sendCallAgainSoon(response); return }
        guard let smtoken = request.queryParameters["smtoken"],let userid = request.parameters["userid"] else { return  self.missingID(response) }
        
        let targeturl = ""
        
        global.apic.getIn += 1
        fetchWithTokens(userid: userid, smtoken: smtoken, targeturl: targeturl, request: request, response: response){ status, data in
            
            /// now make remote call to .... /igtoken/:userid"
            
            /// get list of reports
            
            let rpt = self.loadReportsInfo("user:\(userid)")
            ///
            //
            do {
                let out = ["report-data":rpt,"report-status":200 ] as [String : Any]
                // send ack to caller
                try self.finishJSONStatusResponse(out, request: request, response: response, next: next)
                return
            }
            catch {
                try! self.finishJSONStatusResponse(["report-status":408 ], request: request, response: response, next: next)
            }
            
        }//fetch w tokens
        
    }// end of completion
} // getreportlist
