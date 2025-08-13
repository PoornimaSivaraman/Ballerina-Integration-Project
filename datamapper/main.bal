import ballerina/http;
import ballerina/data.xmldata;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /test on httpDefaultListener {
    resource function post toXml(@http:Payload json input) returns xml|http:InternalServerError|error {
        do {
            xml xmlResult = check xmldata:fromJson(input);
            return xmlResult;
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}

service / on httpDefaultListener {
    resource function post transform(@http:Payload Input input) returns error|json|http:InternalServerError {
        do {
            Output output = transformed(input);
            return output;

        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}