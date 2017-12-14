import Vapor
import ConversationV1
import Dispatch
import Foundation
class WebController {
    let room = Room()

    let viewRenderer: ViewRenderer
    let username = "d80b6da5-a056-4e39-bea5-97ae977a6a49"
    let password = "4kHazvpuFatL"
    let version = "2017-05-26" // use today's date for the most recent version
    let workspaceID = "1c7f345f-fbd5-46b0-a333-bea6326173d6"
    
    let failure = { (error: Error) in print(error) }
    var context: ConversationV1.Context? // save context to continue conversation
    
    	
    init(viewRenderer: ViewRenderer) {
        self.viewRenderer = viewRenderer
        //set up watson workspace
        let conversation = Conversation(username: username, password: password, version: version)

        conversation.message(workspaceID: workspaceID, failure: failure) {
            response in
            //print(response.output.text)
            self.context = response.context
        }

    }
    
    func addRoutes(to drop: Droplet) {
        drop.get("watson", handler: indexHandler)
        drop.get("/") {req in
            return try self.viewRenderer.make("welcome.html")
        }
        drop.socket("chat") { req, ws in
            
            var pingTimer: DispatchSourceTimer? = nil
            pingTimer = DispatchSource.makeTimerSource()
            pingTimer?.schedule(deadline: .now(), repeating: .seconds(25))
            pingTimer?.setEventHandler { try? ws.ping() }
            pingTimer?.resume()
            var userMessage = ""
            var username: String? = nil
            ws.onText = { ws, text in
                let json = try JSON(bytes: text.makeBytes())

                if let u = json.object?["username"]?.string {
                    username = u
                    self.room.connections[u] = ws
                    self.room.bot("Hello I am Amy👋, ask me about what I can do or about my team")
                    //self.room.bot("You can type: \n Apple=>>>>")
                    sleep(3)
//                    self.room.bot("You can ask me about our team, project, or other things")
                }

                if let u = username, let m = json.object?["message"]?.string {
                    self.room.send(name: u, message: m)
                    userMessage = m
                    
                    let input = InputData(text: userMessage)
                    let request = MessageRequest(input: input, context: self.context)
                    let conversation = Conversation(username: self.username, password: self.password, version: self.version)
                    var answer = ""
                    
                    let dispatchGroup = DispatchGroup()
                    dispatchGroup.enter()
                    conversation.message(workspaceID: self.workspaceID, request: request, failure: self.failure) {
                        response in
                        self.context = response.context
                        answer = response.output.text[0].string
                        print(answer)
                        dispatchGroup.leave()
                        self.room.bot(answer)
                    }
                    dispatchGroup.wait(timeout: .distantFuture)
                    
                }

                
                
                print("get message from user \(userMessage)")
                

            }
        
            ws.onClose = { ws, _, _, _ in
                pingTimer?.cancel()
                pingTimer = nil
                
                guard let u = username else {
                    return
                }
                
                self.room.bot("\(u) has left")
                self.room.connections.removeValue(forKey: u)
            }
            
            print("get socket request\(ws)")
            
//            if req.data["question"] != nil{
//
//                print(req.data["question"]!.string!)
//            }
            
            //return try self.viewRenderer.make("welcome.html")
            
        }
        
//        socket("chat"){ req,ws in
//
//
//        }
//        drop.post("watson") { request in
//
//            guard let question = request.data["question"]?.string else {
//
//                throw Abort.badRequest
//            }
//
//            print("get question \(question)")
//

//            var parameters: [String: NodeRepresentable] = [:]
//
        
//            return try self.viewRenderer.make("index", parameters)
//        }

    }
    
    func indexHandler(_ req: Request) throws -> ResponseRepresentable {
        
        var parameters: [String: NodeRepresentable] = [:]
        if req.data["question"] != nil {
            let question = req.data["question"]!.string
            let input = InputData(text: question!)
            let request = MessageRequest(input: input, context: self.context)
            let conversation = Conversation(username: self.username, password: self.password, version: self.version)
            var answer = ""
            
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            conversation.message(workspaceID: self.workspaceID, request: request, failure: self.failure) {
                response in
                self.context = response.context
                answer = response.output.text[0].string
                print(answer)
                dispatchGroup.leave()
            }
            dispatchGroup.wait(timeout: .distantFuture)
            parameters["answer"] = answer


        }
        else{
            parameters["answer"] = "Ask amy"
        }
        print(parameters)
        return try viewRenderer.make("index", parameters)

    }
    
}


