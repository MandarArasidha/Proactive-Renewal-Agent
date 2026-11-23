public with sharing class generateMailForOpportnuityRenewal {

   public class Request{
       
        @InvocableVariable(description = 'The maximum number of days remaining until Contract End Date for Opportunities to qualify for bulk outreach generation. Examples: If the user asks for opportunities renewing within 30 days, set this value to 30. If omitted, use the default renewal threshold configured by the business process.')
        public Integer renewalDays;
        @InvocableVariable(description = 'The minimum number of days since the last customer activity required for an Opportunity to qualify for outreach generation. Examples: If the user asks for opportunities with no activity for 14 or more days, set this value to 14. If the user specifies inactivity periods such as 7 days, 30 days, or 60 days, populate this value accordingly. Use Opportunity LastActivityDate to evaluate inactivity.')
        public Integer inactivityDays;
        @InvocableVariable(description = 'Check if the User is mentioning the Opportunity Closed or Open. if user specify Open then put Parameter as FALSE and if Closed then Put Parameter TRUE inside this Input.')
        public Boolean IsClosed;
    }
    
    Public class Response{
       
        @InvocableVariable(description = 'should not normally be shown directly to end users.')
        public String emailTemplateType;
        @InvocableVariable(description = 'should not normally be shown directly to end users.')
        public Id opportunity;
        @InvocableVariable(description = 'should not normally be shown directly to end users.')
        public String opportunityName;
        @InvocableVariable(description = 'should not normally be shown directly to end users.')
        public String OpportunityOwner;
        @InvocableVariable(description = 'should not normally be shown directly to end users.')
        public Date ContractEndDate; 
        @InvocableVariable(description = 'should not normally be shown directly to end users.')
        public String StageName; 
        @InvocableVariable(description = 'should not normally be shown directly to end users.')
        public Date LastActivityDate; 
        @InvocableVariable(description = 'should not normally be shown directly to end users.')
        public Decimal csatScore;   
        @InvocableVariable(description = 'should not normally be shown directly to end users.')
        public Integer openCases; 
        @InvocableVariable(description = 'The total number of Opportunities selected for processing during the current bulk operation. This is recommended to be shown to end user.')
        public Integer totalOpportunity;
        @InvocableVariable(description = 'should not normally be shown directly to end users.')
        public String RecieverName;
        public String accountMailId;   
        public String contactMailId;
        public String SenderAccountName;
    
    }
    
 
    @InvocableMethod(
        label = 'Generate mail draft for Bulk Opportunity renewal'
        description = 'This invocable method loads all the opportunity with criteria based on the Contract End Date and Last Activity Date, and then Drafts a email for based on the email template type specified.'
    )
    public static List<Response> getOpportunity(List<Request> requests){
        

     
        /*
        if(requests != null && !requests.isEmpty() && requests[0] != null){

            if(requests[0].renewalDays != null){
                renewalDays = requests[0].renewalDays;
            }

            if(requests[0].inactivityDays != null){
                inactivityDays = requests[0].inactivityDays;
            }
           
            
        }

        Integer renewalDays =  requests.isEmpty() ? 60 : requests[0].renewalDays;
        Integer inactivityDays = requests.isEmpty() ? 14 : requests[0].inactivityDays;

        Date renewalcutoff = Date.Today().addDays(renewalDays); 
        Date activityCutOff = Date.Today().addDays(-inactivityDays); 


        
        List<Opportunity> OppList ;

        OppList = [SELECT Id, Name, AccountId, Owner.Name, ContractId, Account.Account_mail_Id__c, 
                    Account.Name, StageName, CSAT_Score__c, LastActivityDate, Contract.EndDate , Account.Rating 
                    FROM Opportunity WHERE IsClosed = FALSE AND ContractId != null
                    AND Contract.EndDate <=: renewalcutoff
                    AND (LastActivityDate = null OR LastActivityDate <=: activityCutOff)];

     */

       // List<Opportunity> oppListToUpdate = new List<Opportunity>();    
        List<Response> results = new List<Response>();

     // Default values
        Integer renewalDays = 60;
        Integer inactivityDays = 14;
        Boolean isClosed = false;

        // Read user supplied filters if available
        if(
            requests != null &&
            !requests.isEmpty() &&
            requests[0] != null
        ){
            Request req = requests[0];

            if(req.renewalDays != null){
                renewalDays = req.renewalDays;
            }

            if(req.inactivityDays != null){
                inactivityDays = req.inactivityDays;
            }

            if(req.IsClosed != null){
                isClosed = req.IsClosed;
            }
        }

        // Dates used in filters if required
        Date renewalCutoff = Date.today().addDays(renewalDays);
        Date activityCutOff = Date.today().addDays(-inactivityDays);

        // Build WHERE conditions dynamically
        List<String> whereClauses = new List<String>();

        // Open / Closed filter
        whereClauses.add('IsClosed = :isClosed');

        // Apply renewal filter only if explicitly provided
        if(
            requests != null &&
            !requests.isEmpty() &&
            requests[0] != null &&
            requests[0].renewalDays != null
        ){
            whereClauses.add('ContractId != null');
            whereClauses.add('Contract.EndDate <= :renewalCutoff');
        }

        // Apply inactivity filter only if explicitly provided
        if(
            requests != null &&
            !requests.isEmpty() &&
            requests[0] != null &&
            requests[0].inactivityDays != null
        ){
            whereClauses.add(
                '(LastActivityDate = null OR LastActivityDate <= :activityCutOff)'
            );
        }

        // Construct SOQL query
        String query =
            'SELECT Id, Name, AccountId, Owner.Name, ContractId, ' +
            'Account.Account_mail_Id__c, ' +
            'Account.Name, StageName, CSAT_Score__c, ' +
            'LastActivityDate, Contract.EndDate, Account.Rating ' +
            'FROM Opportunity';

        // Add WHERE clause if filters exist
        if(!whereClauses.isEmpty()){
            query +=
                ' WHERE ' +
                String.join(
                    whereClauses,
                    ' AND '
                );
        }

        System.debug('Generated Query: ' + query);

        // Execute query
        List<Opportunity> OppList = Database.query(query);

        
        
        set<Id> OppIdsToProcess = new set<Id>();
        set<Id> AccountIdsOfOpportunity = new set<Id>();
        for(Opportunity opp: OppList){
            OppIdsToProcess.add(opp.id);
            AccountIdsOfOpportunity.add(opp.AccountId);
        }
        
        List<Contact> conOpportunityList = new List<Contact>([SELECT Name, Email, AccountId FROM Contact  WHERE AccountId IN: AccountIdsOfOpportunity]);
        map<Id,String> recieverNames = new map<Id,String>();
        map<Id,String> contacteMails = new map<Id,String>();
        for(Contact con : conOpportunityList){
            if(con.name != null){
                recieverNames.put(con.AccountId, con.Name);
                contacteMails.put(con.AccountId, con.Email);
            }
        }

        Map<Id, Integer> noOfCasePerOpportunity = new Map<Id, Integer>();
        
              
        for(AggregateResult result2: [SELECT AccountId accId, COUNT(Id) totalCases FROM Case WHERE AccountId IN:AccountIdsOfOpportunity GROUP BY AccountId]){
            Id AccId = (Id) result2.get('accId');
            noOfCasePerOpportunity.put(AccId, (Integer) result2.get('totalCases'));                   
        }

        List<Opportunity> opportunityListToUpdate = new List<Opportunity>();
  
        for(Opportunity opp : OppList){
            
            Integer daysToRenewal = date.Today().DaysBetween(opp.Contract.EndDate);
            
            String EmailDraftResponse = '';
            String riskReason = '';
            Response r = new Response();
            
            if(daysToRenewal <= 30){
                r.emailTemplateType = 'URGENT';
                riskReason = 'Contract renewal approaching.';
                
            }else if(daysToRenewal <=60){
                r.emailTemplateType = 'NURTURING';
                riskReason = 'Renewal window within 60 days.';
            }
            r.opportunity = opp.id;
            r.opportunityName = opp.Name;
            r.LastActivityDate = opp.LastActivityDate;
            r.ContractEndDate   = opp.Contract.EndDate;
            r.StageName = opp.StageName;
            r.totalOpportunity = oppList.size();
            r.OpportunityOwner = opp.Owner.Name;
            r.RecieverName = recieverNames.get(opp.AccountId);
            r.SenderAccountName = opp.Account.Name;
            r.csatScore = opp.CSAT_Score__c;           
            r.openCases = noOfCasePerOpportunity.get(opp.AccountId);
            r.accountMailId = opp.Account.Account_mail_Id__c;
            r.contactMailId = contacteMails.get(opp.AccountId);

            results.add(r);
    
        }
        Id AiJobID = createPromptBatchJob(results);
        system.debug('Id Generated for AIJobRun'+AiJobID);
       

        return results;
    }
 
    //Not Efficient for 50+ Prompt Generations //Agent Builder Response Time- 60secs 
    public static String generatePromptResponse(
        Id opportunityId,
        String oppName,
        String emailTemplateType,
        String OppOwner,
        Date ContractEndDate,
        String StageName,
        Date LastActivityDate,
        Decimal csatScore,
        Integer openCases,
        String RecieverName
    ) {
        
        ConnectApi.EinsteinPromptTemplateGenerationsInput generationInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        generationInput.isPreview = false;


        Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();

   
        Map<String, String> oppRecordIdMap = new Map<String, String>();
        oppRecordIdMap.put('id',opportunityId);

        ConnectApi.WrappedValue freeTextWrapped = new ConnectApi.WrappedValue();
        freeTextWrapped.value = oppRecordIdMap; 
        inputParams.put('Input:Opportunity', freeTextWrapped); 

        ConnectApi.WrappedValue oppNameValue = new ConnectApi.WrappedValue();
        oppNameValue.value = oppName;
        inputParams.put('Input:Opportunity.Name',oppNameValue);

        ConnectApi.WrappedValue templateTypeValue = new ConnectApi.WrappedValue();
        templateTypeValue.value = emailTemplateType;
        inputParams.put('Input:emailTemplateType',templateTypeValue);

        ConnectApi.WrappedValue openCasesValue = new ConnectApi.WrappedValue();
        openCasesValue.value = openCases;
        inputParams.put('Input:openCases',openCasesValue);

        ConnectApi.WrappedValue receiverValue = new ConnectApi.WrappedValue();
        receiverValue.value = RecieverName;
        inputParams.put('Input:receiverName',receiverValue);
  

        generationInput.inputParams = inputParams;

        generationInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        generationInput.additionalConfig.applicationName = 'PromptTemplateGenerationsInvocable';

        try {

            
            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation response = ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate('0hfdM00000UYYu1QAH', generationInput);

            System.debug('PROMPT: ' +response.prompt);

            System.debug('RESPONSE: ' +response.generations[0].text);

            return response.generations[0].text;

        } catch(Exception e){

            System.debug('ERROR: ' +e.getMessage());

            System.debug(e.getStackTraceString());

            return 'ERROR: ' + e.getMessage();
        }
    }

    public static Id createPromptBatchJob(List<Response> opportunities){

        AiJobRun job = new AiJobRun(
        JobType = 'PromptTemplate',
        Target = '0hfdM00000UYYu1QAH',
        Status = 'New'
    );

        insert job;

        System.debug('createPromptBatchJob'+job.Id);

        List<AiJobRunItem> Items = new List<AiJobRunItem>();

        for(Response r : opportunities){

            System.debug('Opportunity Id = ' + r.opportunity);
            System.debug('Opportunity Name = ' + r.opportunityName);
            System.debug('Template Type = ' + r.emailTemplateType);
            System.debug('Receiver Name = ' + r.RecieverName);

            AiJobRunItem item = new AiJobRunItem();
            item.AiJobRunId = job.Id;

            Map<String,Object> payload = new Map<String,Object>();
            payload.put('OpportunityId',r.opportunity);
            payload.put('AccountEmail',r.accountMailId);
            payload.put('ContactEmail',r.contactMailId);
            payload.put('Input:Opportunity', new Map<String,Object>{
                'id' => r.opportunity
                    }
                );

            payload.put(
                'Input:receiverName',
                r.RecieverName
            );

            payload.put(
                'Input:AccountName',
                r.SenderAccountName
            );

            payload.put(
                'Input:Opportunity.Name',
                r.opportunityName
            );
            
            payload.put(
                'Input:Opportunity.Owner.Alias',
                r.OpportunityOwner
            );

            payload.put(
                'Input:Opportunity.StageName',
                r.StageName
            );

            payload.put(
                'Input:Opportunity.Contract.EndDate',
                r.ContractEndDate
            );

            payload.put(
                'Input:Opportunity.LastActivityDate',
                r.LastActivityDate
            );

            payload.put(
                'Input:Opportunity.CSAT_Score__c',
                r.csatScore
            );

            payload.put(
                'Input:openCases',
                r.openCases
            );

            payload.put(
                'Input:emailTemplateType',
                r.emailTemplateType
            );
            
            String payloadJson = JSON.serialize(payload);

            System.debug('Payload JSON: ' + payloadJson);

            item.input = JSON.serialize(payload);

            item.Status = 'Ready';

            items.add(item);
        }
        insert items;

        job.Status = 'ReadyToStart';

        update job;

        system.debug('JobId'+job.Id);

        return job.Id;


    }

   


}