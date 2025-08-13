
type FileType record {|
    string InputFilename;
    string InputFileType;
    string OutputFileType;
|};

type FileDetails record {|
    string InputFilename;
    string InputFileType;
    string OutputFileType;
    string FileContent;
    string CurrentDate;
|};

type Payment_info record {
    string InterbankSettlementDate;
    string CreditorName;
    float ChargesAmt;
    string MessageIdentification;
    string UETR;
    string Date;
    string SettlementMethod;
    int LocalInstrumentCode;
    int InstructingAgentId;
    string InstructingAgentName;
    int InstructedAgentId;
    string InstructedAgentName;
    string PaymentTypeInformation;
    string CurrencyCode;
    string ChargeDetail;
    string CreditorAgentId;
    string DebtorAgentId;
    string DebtorName;
    int NoOfTxs;
    string RemittanceInformation;
    string CreditorAccountIBAN;
    string DebtorAccountIBAN;
    string InstructingAgentBIC;
    string InstructedAgentBIC;
    string EndToEndId;
    string DebtorBIC;
    string CreditorBIC;
    float InterbankSettlementAmount;
    string PaymentMethod;
};

