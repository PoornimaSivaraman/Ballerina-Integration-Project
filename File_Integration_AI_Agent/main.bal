import ballerina/ai;
import ballerina/http;

listener ai:Listener FileIntegratorListener = new (listenOn = check http:getDefaultListener());

service /FileIntegrator on FileIntegratorListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {

        string stringResult = check _FileIntegratorAgent->run(request.message, request.sessionId);
        return {message: stringResult};
    }
}
