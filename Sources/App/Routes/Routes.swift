import Vapor

extension Droplet {
    func setupRoutes() throws {
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }
        
        try resource("posts", PostController.self)
        
        
        //greeting web page, asking for name
        get("greet") { req in
            
            let name = req.data["name"]?.string ?? ", what's your name? :D"
            return "Hello \(name)"
            
        }
        
        //Added webcontroller
        let webController = WebController(viewRenderer: view)
        webController.addRoutes(to: self)
        
        
    }
    
    
}
