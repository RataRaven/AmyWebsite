import App
import ConversationV1
import LeafErrorMiddleware

/// We have isolated all of our App's logic into
/// the App module because it makes our app
/// more testable.
///
/// In general, the executable portion of our App
/// shouldn't include much more code than is presented
/// here.
///
/// We simply initialize our Droplet, optionally
/// passing in values if necessary
/// Then, we pass it to our App's setup function
/// this should setup all the routes and special
/// features of our app
///
/// .run() runs the Droplet's commands, 
/// if no command is given, it will default to "serve"
let config = try Config()
config.addConfigurable(middleware: LeafErrorMiddleware.init, name: "leaf-error")
try config.setup()

let drop = try Droplet(config)
try drop.setup()
print(drop.config.workDir)

////set up watson workspace
//let username = "d80b6da5-a056-4e39-bea5-97ae977a6a49"
//let password = "4kHazvpuFatL"
//let version = "2017-05-26" // use today's date for the most recent version
//let conversation = Conversation(username: username, password: password, version: version)
//let workspaceID = "1c7f345f-fbd5-46b0-a333-bea6326173d6"
//let failure = { (error: Error) in print(error) }
//var context: ConversationV1.Context? // save context to continue conversation
//conversation.message(workspaceID: workspaceID, failure: failure) {
//    response in
//    print(response.output.text)
//    context = response.context
//}

//let input = InputData(text: "Send Package To Point B")
//let request = MessageRequest(input: input, context: context)
//
//conversation.message(workspaceID: workspaceID, request: request, failure: failure) {
//    response in
//    print(response.output.text)
//    context = response.context
//}

try drop.run()
