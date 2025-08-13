import ballerina/data.csv;
import ballerina/data.xmldata;
import ballerina/ftp;
import ballerina/http;
import ballerina/io;
import ballerina/test;
import ballerina/time;

listener http:Listener httpDefaultListener = http:getDefaultListener();

isolated string ftpHost = "";
isolated string currentTime = "";
isolated string InputFileTyp = "";
isolated string OutputFileTyp = "";
isolated string FileCnt = "";
isolated string fileName = "";
string FileTypePath = "/InputBallerina/FilesType";
string InputFilepath = "/InputBallerina";
string OutputFilepath = "/output";
FileDetails fileDetails = {
    InputFilename: "",
    InputFileType: "",
    OutputFileType: "",
    FileContent: "",
    CurrentDate: ""
};

type Headers record {
    @http:Header {name: "X-API-VERSION"}
    string apiVersion;
    string id;
};

isolated function getftpHost() returns string {
    lock {
        return ftpHost;
    }
}

isolated function getcurrentTime() returns string {
    lock {
        return currentTime;
    }
}

isolated function getInputFileTyp() returns string {
    lock {
        return InputFileTyp;
    }
}

isolated function getOutputFileTyp() returns string {
    lock {
        return OutputFileTyp;
    }
}

isolated function getFileCnt() returns string {
    lock {
        return FileCnt;
    }
}

isolated function getFileName() returns string {
    lock {
        return fileName;
    }
}

function ToConvertCSVtoXML(string inputCSVContent) returns string|error {
    
    string csvContent = inputCSVContent; // Or pass as argument
    xml xmlRoot = xml `<FIToFICstmrCdtTrf/>`;
    //string[] stringLines = test:split(csvContent, "\r");
    Payment_info[] csvRecords = checkpanic csv:parseString(csvContent);

    io:println("CSV Records: ", csvRecords);
   
    json JsonRecords = csvRecords.map(rec => rec.toJson());
    json JSONResult = {
        FIToFICstmrCdtTrf: {
            payment_info: JsonRecords
        }
    };

    io:println("JSON Records: ", JSONResult);
    xml xmlResult = check xmldata:fromJson(JSONResult);
    return xmlResult.toString();

}


function ToConvertCommonCSVtoXML(string inputCSVContent) returns string|error {
    
    do {
        
    string csvContent = inputCSVContent; // Or pass as argument
    xml xmlRoot = xml `<root/>`;
    string[] stringLines = test:split(csvContent, "\n");
    io:println("CSV Records by lines: ", stringLines);
    record{}[] csvRecords = check csv:parseString(csvContent, {textEnclosure: "\"", escapeChar: "\\", lineTerminator : [ "\n", "\r\n" ]});

    io:println("CSV Records: ", csvRecords);
   
    json JsonRecords = csvRecords.map(rec => rec.toJson());
    json JSONResult = {
        root: {
            records: JsonRecords
        }
    };

    io:println("JSON Records: ", JSONResult);
    xml xmlResult = check xmldata:fromJson(JSONResult);
    return xmlResult.toString();
    }
    on fail error err {
        io:println("Error while converting CSV to XML: ", err);
        return error("Conversion failed", err);
    }

}

function ToConvertExceltoXML(string inputExcelContent) returns string|error {
    string excelContent = inputExcelContent; // Or pass as argument

    // Parse CSV to table
    return "Excel Conversion logic not implemented yet";
}

function InputTypeValidation(FileDetails fileDetails) returns string|error {

    string|error convertResult = "";

    // Perform validation logic here
    if fileDetails.InputFileType == "" || fileDetails.OutputFileType == "" {
        return error("Input or Output file type is empty");
    }
    else if (fileDetails.InputFileType != "CSV" && fileDetails.InputFileType != "EXCEL") {
        return error("Input or Output file type should be CSV or EXCEL");
    }  // Assuming validation passed, return a success message
    else {
        if (fileDetails.InputFileType == "CSV") {
            convertResult = ToConvertCSVtoXML(fileDetails.FileContent);
        }
        else if (fileDetails.InputFileType == "EXCEL") {
            convertResult = ToConvertExceltoXML(fileDetails.FileContent);
        }
    }
    return convertResult;

}

@http:ServiceConfig {
    treatNilableAsOptional: true
}
//To get specific header fields 
service /transform on httpDefaultListener {
    resource function post FilesType(
            @http:Header string Filename,
            @http:Header string InputFileType,
            @http:Header string OutputFileType
    ) returns json {
        // Create a JSON payload using header values
        json payload = {
            "InputFilename": Filename,
            "InputFileType": InputFileType,
            "OutputFileType": OutputFileType
        };
        // Return a FilesType record

        ftp:ClientConfiguration sftpConfig = {
            protocol: ftp:SFTP,
            host: "127.0.0.1",
            port: 22,
            auth: {
                credentials: {username: "poornima", password: "Tellestia@123"}
            }
        };
        string InputFilePath = "/InputBallerina/FilesType";
        ftp:Client sftpClient = checkpanic new (sftpConfig);
        
        checkpanic sftpClient->put(InputFilePath, payload.toString());
        
        

        return {"status": "success", "message": "File uploaded successfully"};
    }

    //To get all header fields
    resource function post FilesTypeAll(http:Request req) returns json {
        // Get all headerNames as a map            
        //string[] headers = req.getHeaderNames();
        // Get specific header "Accept" as a string array output:{"headers": ["application/json, application/xml"]}
        string[]|error headers = req.getHeaders("Filename");
        // Get specific header "Accept" as a string array output: { "headers": "application/json, application/xml" }
        string|http:HeaderNotFoundError header = req.getHeader("File");
        string[] acceptHeader;

        if (headers is error) {
            // The header was not found, so we assign `null`
            acceptHeader = ["null"];
        } else {
            // The header was found, so we assign its value
            acceptHeader = headers;
        }

        string acceptHdr;
        if (header is error) {
            // The header was not found, so we assign `null`
            acceptHdr = "null";
        } else {
            // The header was found, so we assign its value
            acceptHdr = header;
        }
        //get headermap

        Headers staticheader = {apiVersion: acceptHdr, id: acceptHeader[0]};
        map<string|string[]> headersMap = http:getHeaderMap(staticheader);

        // Create JSON payload
        json payload = {headers: headersMap};

        // Convert JSON to string

        return payload;

    }
}

public type payload record {|
    *http:Ok;
    json body;
    record {|
        (string|int|boolean|string[]|int[]|boolean[])...;
    |} headers;
|};

listener ftp:Listener SFTP_Listener = new (protocol = ftp:SFTP, host = "127.0.0.1", port = 22, auth = {
    credentials: {
        username: "poornima",
        password: "Tellestia@123"
    }
}, path = "/InputBallerina", fileNamePattern = "(.*)\\.txt", pollingInterval = 2);

service ftp:Service on SFTP_Listener {
    remote function onFileChange(ftp:WatchEvent & readonly event, ftp:Caller caller) returns error? {
        do {

            foreach ftp:FileInfo addedFile in event.addedFiles {

                io:println("New file detected: ", addedFile.pathDecoded, addedFile.name);

                stream<io:Block, io:Error?> fileContentStream = checkpanic caller->get(FileTypePath);
                io:println("File content received: ", fileContentStream);
                checkpanic fileContentStream.forEach(isolated function(byte[] & readonly fileTypeContent) {
                    string fileTypeContentDetails = checkpanic string:fromBytes(fileTypeContent);
                    json parsedFileTypeJson = checkpanic fileTypeContentDetails.fromJsonString();
                    FileType details = checkpanic parsedFileTypeJson.cloneWithType(FileType);
                    io:println("File content received: ", details.InputFileType, details.OutputFileType, details.InputFilename);
                    lock {
                        InputFileTyp = details.InputFileType.toString();

                    }
                    lock {
                        OutputFileTyp = details.OutputFileType.toString();
                    }
                    lock {
                        fileName = details.InputFilename.toString();
                    }

                });

                check fileContentStream.close();
                stream<byte[] & readonly, io:Error?> fileStream = check caller->get(addedFile.pathDecoded);
                check fileStream.forEach(isolated function(byte[] & readonly fileContent) {
                    string InputFileContent;
                    time:Utc currentUtc = time:utcNow();
                    lock {
                        currentTime = currentUtc[0].toString();
                    }
                    io:println("currentUtc: ", currentUtc, "civilTime", time:Date);
                    string processedPath = "/AfterProcessBallerina/";
                    InputFileContent = checkpanic string:fromBytes(fileContent);
                    io:println("FileType content received: " + InputFileContent);

                    io:println("Filetype received closed ");
                    processedPath = processedPath + addedFile.name + currentUtc[0].toString();
                    checkpanic caller->put(processedPath, InputFileContent);
                    lock {
                        FileCnt = InputFileContent;
                    }
                    //checkpanic caller->rename(addedFile.pathDecoded, processedPath+addedFile.name);
                });
                check fileStream.close();
                fileDetails = {
                    InputFilename: getFileName(),
                    InputFileType: getInputFileTyp(),
                    OutputFileType: getOutputFileTyp(),
                    FileContent: getFileCnt(),
                    CurrentDate: getcurrentTime()
                };
                io:println("File details: ", fileDetails);
                string|error convertResult = InputTypeValidation(fileDetails);

                if convertResult is string {
                    io:println("Conversion result: ", convertResult);
                    OutputFilepath = OutputFilepath + "/responseXML-" + fileDetails.CurrentDate.toString()+ ".xml";
                    check caller->put(OutputFilepath, convertResult.toString());
                } else {
                    io:println("Conversion failed with error: ", convertResult);
                }

                check caller->delete(FileTypePath);
                check caller->delete(addedFile.pathDecoded);
            }
        }
        on fail error err {
            // handle error
            string FailurePath = "/AfterFailureBallerina/";
            FailurePath = FailurePath + fileDetails.InputFilename + fileDetails.CurrentDate[0].toString();
            io:println("Failure Path: ", FailurePath);
            checkpanic caller->put(FailurePath, fileDetails.FileContent.toString());
            check caller->delete(FileTypePath);
            check caller->delete(InputFilepath + "/" + fileDetails.InputFilename);
            io:println("Error occurred while processing file: ", err);

            return error("unhandled error", err);
        }
    }
}



listener ftp:Listener SFTP_ListenerAll = new (protocol = ftp:SFTP, host = "127.0.0.1", port = 22, auth = {
    credentials: {
        username: "poornima",
        password: "Tellestia@123"
    }
}, path = "/InputBallerina", fileNamePattern = "(.*)\\.csv", pollingInterval = 5);

service ftp:Service on SFTP_ListenerAll {
    remote function onFileChange(ftp:WatchEvent & readonly event, ftp:Caller caller) returns error? {
        io:println("Processing files of type CSV...");
        do {

            foreach ftp:FileInfo addedFile in event.addedFiles {

                //io:println("New file detected: ", addedFile.pathDecoded, addedFile.name);
                
                stream<byte[] & readonly, io:Error?> fileStream = check caller->get(addedFile.pathDecoded);
                check fileStream.forEach(isolated function(byte[] & readonly fileContent) {
                    string InputFileContent;
                    InputFileContent = checkpanic string:fromBytes(fileContent);
                    //io:println("FileType content received: " + InputFileContent);
                    lock {
                        FileCnt = InputFileContent;
                    }
                });
                check fileStream.close();
                
                string|error convertResult = ToConvertCommonCSVtoXML(getFileCnt());

                if convertResult is error {
                    io:println("Conversion failed with error: ", convertResult);
                    string FailurePath = "/AfterFailureBallerina/";
                    FailurePath = FailurePath + addedFile.name;
            io:println("Failure Path: ", FailurePath);
            check caller->put(FailurePath, getFileCnt().toString());
                } else {
                    
                    io:println("Conversion result: ", convertResult);
                    OutputFilepath = OutputFilepath + "/responseXML-"+addedFile.name.substring(0, addedFile.name.length()-4)+".xml";
        
                    check caller->put(OutputFilepath, convertResult);
                }

                check caller->delete(addedFile.pathDecoded);
            }
        }
        on fail error err {
            // handle error
            
        }
    }
}




