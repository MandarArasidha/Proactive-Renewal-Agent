public with sharing class GetAtRiskRenewalOpportunities {
    
    public class Request{
        //Variable Input
        //Renewal Days - 60 contract endDate
        //inactivityDays - 25 lastActivityDate  
        @InvocableVariable
        public Integer renewalDays;
        @InvocableVariable
        public Integer inactivityDays;
        @InvocableVariable
        public String TaskCreationInput;
    }
    
    Public class Response{
        //Output variables
        @InvocableVariable
        public String emailTemplateType;
        
        @InvocableVariable
        public Id oppportunity;
        
        @InvocableVariable
        public String opportunityName;
        
        @InvocableVariable
        public Date ContractEndDate;
        
        @InvocableVariable
        public String StageName;
        
        @InvocableVariable
        public Date LastActivityDate;
        
        @InvocableVariable
        public Decimal csatScore; 
        
        @InvocableVariable
        public Integer openCases;
        
        @InvocableVariable
        public Integer totalOpportunity;
          
        
    }
    
    //pseudocode -
    //request- asks the Agent
    //Query the opportunity with contract renewaldays = today - contract.endDate AND lastActivityDate of Opportunity as
    
    @InvocableMethod(
        label = 'get at risk Renewal Opportunity'
        description = 'returns open opportunity with contracts expiring soon and are inactive'
    )
    public static List<Response> getOpportunity(List<Request> requests){
        
        // setting Renewal Day as 60 as Default Input
        Integer renewalDays =  requests.isEmpty() ? 60 : requests[0].renewalDays;
        // Setting the default Inactivity Day as default Input
        Integer inactivityDays = requests.isEmpty() ? 14 : requests[0].inactivityDays;
        
        //calculate Date that will be the Last Activity Date and the close Date
        Date renewalcutoff = Date.Today().addDays(renewalDays); // Contract CloseDate 60 days from Now
        Date activityCutOff = Date.Today().addDays(-inactivityDays); //LastActivityDate 14 days from now 
        
        List<Response> results = new List<Response>();
        
        //Querying all the Opportunity where contract end Date is within 60days and Opportunity is Inactive from 14 days
        List<Opportunity> OppList = ([SELECT Id, Name, ContractId, StageName, CSAT_Score__c, LastActivityDate, Contract.EndDate , Account.Rating FROM Opportunity WHERE IsClosed = FALSE AND ContractId != null AND Contract.EndDate <=: renewalcutoff AND (LastActivityDate = null OR LastActivityDate <=: activityCutOff)]);
        
        
        
        set<Id> OppIdsToProcess = new set<Id>();
        set<Id> AccountIdsOfOpportunity = new set<Id>();
        
        for(Opportunity opp: OppList){
            OppIdsToProcess.add(opp.id);
            AccountIdsOfOpportunity.add(opp.AccountId);
        }
        
        List<Task> taskListToInsert = new List<Task>();
        //List<EmailMessages> SendToAllOpportunity = new List<EmailMessage>();
        
        //THese remain Empty for First Iteration
        Map<Id, Integer> OppCSATMap = new Map<Id, Integer>();
        Map<Id, Integer> noOfCasePerOpportunity = new Map<Id, Integer>();
        
        for(AggregateResult result : [SELECT Id, AVG(CSAT_Score__c ) ratingAvg FROM Opportunity WHERE Id IN : OppIdsToProcess GROUP BY Id]){
            OppCSATMap.put(result.Id, Integer.valueOf(result.get('ratingAvg')));
        }
        
        
        for(AggregateResult result2: [SELECT AccountId accId, COUNT(Id) totalCases FROM Case WHERE AccountId IN:AccountIdsOfOpportunity GROUP BY AccountId]){
            Id AccId = (Id) result2.get('accId');
            noOfCasePerOpportunity.put(AccId, (Integer) result2.get('totalCases'));                   
        }
        
        for(Opportunity opp : OppList){
            
            //calculate the Days to Renewal from Today to EndDate , if Calculation is >30 - Urgent if >60 then
            Integer daysToRenewal = date.Today().DaysBetween(opp.Contract.EndDate);
            
            String riskReason = '';
            Response r = new Response();
            
            if(daysToRenewal <= 30){
                r.emailTemplateType = 'URGENT';
                riskReason = 'Contract renewal approaching.';
                
            }else if(daysToRenewal <=60){
                r.emailTemplateType = 'NURTURING';
                riskReason = 'Renewal window within 60 days.';
            }
            
            //post Chatter Message
            postChatterAlert(opp.id, userInfo.getUserId(), riskReason);
            
            r.oppportunity = opp.id;
            r.opportunityName = opp.Name;
            r.LastActivityDate = opp.LastActivityDate;
            r.ContractEndDate	= opp.Contract.EndDate;
            r.StageName = opp.StageName;
            r.totalOpportunity = oppList.size();

            r.csatScore = opp.CSAT_Score__c;
            r.openCases = noOfCasePerOpportunity.get(opp.AccountId);
            
            results.add(r);
           

                
            //need to check if user is Asking to Create Task on those opportunities

             //if( requests[0].TaskCreationInput != null && requests[0].TaskCreationInput.toLowerCase().contains('create')){
               
             //}
         Task tsk = new Task();
            tsk.whatId = opp.Id;
            tsk.subject = 'Renewal Outreach';
            taskListToInsert.add(tsk);
        
        }
        
        
        //Create a Task on Each of such Opportunity When Prompted
        if(!taskListToInsert.isEmpty()){
                System.debug('Tasks Inserted: ' +taskListToInsert.size());
            insert taskListToInsert;
        }     

        /*
        if(!SendToAllOpportunity.isEmpty()){
                System.debug('Tasks Inserted: ' +SendToAllOpportunity.size());
            insert SendToAllOpportunity;
        } 
            */  

        return results;
        
    }
    
       public static void postChatterAlert(
        Id opportunityId,
        Id userId,
        String riskReason
    ){
        
        System.debug('Inside the Post Chatter');
        ConnectApi.FeedItemInput input =
            new ConnectApi.FeedItemInput();
        
        ConnectApi.MessageBodyInput body =
            new ConnectApi.MessageBodyInput();
        
        body.messageSegments =
            new List<ConnectApi.MessageSegmentInput>();
        
        ConnectApi.MentionSegmentInput mention =
            new ConnectApi.MentionSegmentInput();
        
        mention.id = userId;
        
        body.messageSegments.add(mention);
        
        ConnectApi.TextSegmentInput text =
            new ConnectApi.TextSegmentInput();
        
        text.text =
            ' Risk Summary: ' + riskReason;
        
        body.messageSegments.add(text);
        
        input.body = body;
        
        input.subjectId = opportunityId;
        
        ConnectApi.ChatterFeeds.postFeedElement(
            Network.getNetworkId(),
            input
        );
    }

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
        /*
        // Query Opportunity
        Opportunity opp = [SELECT Id,
                   Name,
                   StageName
            FROM Opportunity
            WHERE Id = :opportunityId
            LIMIT 1
        ];
        */
        // Prompt Input
        ConnectApi.EinsteinPromptTemplateGenerationsInput generationInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();

        generationInput.isPreview = false;

        // Input Map
        Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();

        /*
         * Opportunity Record Input
         */
        Map<String, String> oppRecordIdMap = new Map<String, String>();

        oppRecordIdMap.put('id',opportunityId);

        ConnectApi.WrappedValue freeTextWrapped = new ConnectApi.WrappedValue();
        freeTextWrapped.value = oppRecordIdMap;
        
        inputParams.put('Input:Opportunity', freeTextWrapped); 
		
        ConnectApi.WrappedValue oppNameValue = new ConnectApi.WrappedValue();

        oppNameValue.value = oppName;
        system.debug('------------------------------------------------');
		system.debug('templateTypeValue'+oppNameValue.value);
        inputParams.put('Input:Opportunity.Name',oppNameValue);

        /*
         * Email Template Type
         */
        ConnectApi.WrappedValue templateTypeValue = new ConnectApi.WrappedValue();

        templateTypeValue.value = emailTemplateType;
        system.debug('templateTypeValue'+templateTypeValue.value);
        system.debug('------------------------------------------------');

        inputParams.put('Input:emailTemplateType',templateTypeValue);

        /*
         * Open Cases
         */
        ConnectApi.WrappedValue openCasesValue = new ConnectApi.WrappedValue();

        openCasesValue.value = openCases;

        inputParams.put('Input:openCases',openCasesValue);

        /*
         * Receiver Name
         */
        ConnectApi.WrappedValue receiverValue = new ConnectApi.WrappedValue();

        receiverValue.value = OppOwner;

        inputParams.put('Input:receiverName',receiverValue);

        // Assign Inputs
        generationInput.inputParams = inputParams;

        
        generationInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
		/* Optional Config
        generationInput.additionalConfig.applicationName ='PromptTemplateTest';
		*/
        
        generationInput.additionalConfig.applicationName = 'PromptTemplateGenerationsInvocable';

        try {

            // Generate Response
            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation response = ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate('0hfdM00000UOa2fQAD', generationInput);

            System.debug('PROMPT: ' +response.prompt);

            System.debug('RESPONSE: ' +response.generations[0].text);

            return response.generations[0].text;

        } catch(Exception e){

            System.debug('ERROR: ' +e.getMessage());

            System.debug(e.getStackTraceString());

            return 'ERROR: ' + e.getMessage();
        }
    }


}