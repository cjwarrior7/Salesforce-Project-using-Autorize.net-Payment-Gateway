public class AuthorizeDotNet {
    //variables to hold our login Credentials
    public static string apiLogin ;
    public static string apiTranskey ;
    
    public static void getAuthCred(){
        Authorize_Net_Setting__c apiLoginSetting = Authorize_Net_Setting__c.getInstance('API Login');
        Authorize_Net_Setting__c apiTranskeySetting  = Authorize_Net_Setting__c.getInstance('Transkey') ;
        apiLogin = apiLoginSetting.Value__c ;
        apiTranskey = apiTranskeySetting.Value__c ;   
        System.debug('apiLogin:'+apiLogin );
        System.debug('apiTranskey:'+ apiTranskey);
    }
    
    public static AuthnetResponseWrapper getAuthCharge(AuthnetRequestWrapper input){
        getAuthCred();
        //construct request
        HttpRequest req=new HttpRequest();
        req.setEndpoint('https://test.authorize.net/gateway/transact.dll');
        req.setMethod('POST');
        //build message
        Map<String,String> messageString = new  Map<String,String>();
        messageString.put('x_login', apiLogin);
        messageString.put('x_tran_key', apiTranskey);
        messagestring.put('x_version', '3.1');
        messagestring.put('x_delim_data', 'TRUE');
        //specify delimiter character for response
        messagestring.put('x_delim_char', ';');
        messagestring.put('x_relay_response', 'FALSE');  
        //The type of transaction
        messagestring.put('x_type', 'AUTH_CAPTURE');
        //Processing credit card
        messagestring.put('x_method', 'CC');
        
        //Transaction Specific Information
        //card numbers, expiration, security codes
        messagestring.put('x_card_num', input.ccnum);
        messagestring.put('x_exp_date', input.ccexp);
        messagestring.put('x_card_code', input.ccsec);
        
        //transaction amount
        messagestring.put('x_amount', input.amt);
        //description of transaction
        messagestring.put('x_description', 'Your Transaction: '+input.ordername);
        
        //billing information
        messagestring.put('x_first_name', input.firstname);
        messagestring.put('x_last_name', input.lastname);
        messagestring.put('x_address', input.billstreet);
        messagestring.put('x_city', input.billcity);
        messagestring.put('x_state', input.billstate);
        messagestring.put('x_zip', input.billzip);
        //encode message components
        String encodedMsg='';
        
        for (string s : messagestring.keySet()){
            string v = messagestring.get(s);
            //fix null values
            if (string.isblank(v)) v='';
            encodedmsg += s+'='+EncodingUtil.urlEncode(v, 'UTF-8')+'&';
            //debug message value being added
            system.debug('TRACE: message bit '+s+' added');
        } 
        //add message termination
        encodedmsg += 'endofdata';
        System.debug('TRACE: Encoded Message: \n\n' + encodedmsg);
        
        //set the body of the httprequest
        req.setBody(encodedmsg);
        //send and collect response
        Http http = new Http();
        String resp = http.send(req).getbody();
        //debug response
        System.debug(resp);
        //split response by our delimiter
        list<string> responses = resp.split(';');
        
        //use parsing methodto return response wrapper
        AuthnetResponseWrapper parsedResponse = parseIntoResponseWrapper(responses);
         
        //debug response wrapper
        system.debug(parsedResponse);
        return parsedResponse;
        
        
    }
    public class AuthnetRequestWrapper {
        
        public String ccnum {get;set;} 
        public String ccexp {get;set;} 
        public String ccsec {get;set;} 
        public String amt {get;set;} 
        public String firstname {get;set;} 
        public String orderName {get;set;} 
        public String lastname {get;set;} 
        public String billstreet {get;set;} 
        public String billcity {get;set;} 
        public String billstate {get;set;} 
        public String billzip {get;set;}
        public String transid {get; set;}
        public String routingnumber {get; set;}
        public String accountnumber {get; set;}
        public String bankaccounttype {get; set;}
        public String bankname {get; set;}
        public String bankaccountname {get; set;}
        
        public AuthnetRequestWrapper(){
            
        }
        
    }
    public class  AuthnetResponseWrapper {
    // value, index in split string list
    public string responseCode {get;set;} //0
    public string responseSubcode{get;set;} //1
    public string responseReasonCode{get;set;} //2
    public string responseReasonText{get;set;} //3
    public string authorizationCode{get;set;} //4
    public string avsResponse{get;set;} //5
    public string transactionID{get;set;} //6
    public string invoiceNumber{get;set;} //7
    public string description{get;set;} //8
    public string amount{get;set;} //9
    public string method{get;set;} //10
    public string transactionType{get;set;} //11
    public string customerID{get;set;} //12
    public string firstName{get;set;} //13
    public string lastName{get;set;} //14
    public string company{get;set;} //15
    public string address{get;set;} //16
    public string city{get;set;} //17
    public string state{get;set;} //18
    public string zipCode{get;set;} //19
    public string country{get;set;} //20
    public string phone{get;set;} //21
    public string fax{get;set;} //22
    public string emailAddress{get;set;} //23
    public string shipToFirstName{get;set;} //24
    public string shipToLastName{get;set;} //25
    public string shipToCompany{get;set;} //26
    public string shipToAddress{get;set;} //27
    public string shipToCity{get;set;} //28
    public string shipToState{get;set;} //29
    public string shipToZIPCode{get;set;} //30
    public string shipToCountry{get;set;} //31
    public string tax{get;set;} //32
    public string duty{get;set;} //33
    public string freight{get;set;} //34
    public string taxExempt{get;set;} //35
    public string purchaseOrderNumber{get;set;} //36
    public string md5Hash{get;set;} //37
    public string cardCodeResponse{get;set;} //38
    public string cardholderAuthenticationVerificationResponse{get;set;} //39
    public string accountNumber{get;set;} //40
    public string cardType{get;set;} //41
    public string splitTenderID{get;set;} //42
    public string requestedAmount{get;set;} //43
    public string balanceOnCard{get;set;} //44
    public  AuthnetResponseWrapper (){}
  }
    public static  AuthnetResponseWrapper  parseIntoResponseWrapper(List<String> input){
        
     AuthnetResponseWrapper temp = new  AuthnetResponseWrapper() ;
          temp.responseCode =input[0];
          temp.responseSubcode=input[1];
          temp.responseReasonCode=input[2];
          temp.responseReasonText=input[3];
          temp.authorizationCode=input[4];
          temp.avsResponse=input[5];
          temp.transactionID=input[6];
          temp.invoiceNumber=input[7];
          temp.description=input[8];
          temp.amount=input[9];
          temp.method=input[10];
          temp.transactionType=input[11];
          temp.customerID=input[12];
          temp.firstName=input[13];  
          temp.lastName=input[14];
          temp.company=input[15];
          temp.address=input[16];
          temp.city=input[17];
          temp.state=input[18];
          temp.zipCode=input[19];
          temp.country=input[20];
          temp.phone=input[21];
          temp.fax=input[22];
          temp.emailAddress=input[23];
          temp.shipToFirstName=input[24];
          temp.shipToLastName=input[25];
          temp.shipToCompany=input[26];
          temp.shipToAddress=input[27];
          temp.shipToCity=input[28];
          temp.shipToState=input[29];
          temp.shipToZIPCode=input[30];
          temp.ShipToCountry=input[31];
          temp.tax=input[32];
          temp.duty=input[33];  
          temp.freight=input[34];
          temp.taxExempt=input[35];
          temp.purchaseOrderNumber=input[36];
          temp.md5Hash=input[37];
          temp.cardCodeResponse=input[38];
          temp.CardholderAuthenticationVerificationResponse=input[39];
          temp.accountNumber=input[40];
          temp.cardType=input[41];
          temp.splitTenderID=input[42];
          temp.requestedAmount=input[43];
          temp.balanceOnCard=input[44];
        
     return temp ;    
    }
}