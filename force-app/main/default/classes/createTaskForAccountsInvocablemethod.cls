public with sharing class createTaskForAccountsInvocablemethod {

    public class Request{

        @InvocableVariable
        public Integer renewalDays;
        @InvocableVariable
        public Integer inactivityDays;
        @InvocableVariable
        public String searchOpportunityName;

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
        public String OpportunityOwner;
        
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

        @InvocableVariable
        public String RecieverName;
               
    }
    
 
    @InvocableMethod(
        label = 'Create task for opportunity'
        description = 'returns open opportunity with contracts expiring soon and are inactive and creates task'
    )
    public static List<Response> getOpportunity(List<Request> requests){
        
        Integer renewalDays = 60;
        Integer inactivityDays = 14;
        String searchOpportunityN;

        if(requests != null && !requests.isEmpty() && requests[0] != null){

            if(requests[0].renewalDays != null){
                renewalDays = requests[0].renewalDays;
            }

            if(requests[0].inactivityDays != null){
                inactivityDays = requests[0].inactivityDays;
            }

            searchOpportunityN = requests[0].searchOpportunityName;
        }

        Date renewalcutoff = Date.Today().addDays(renewalDays); 
        Date activityCutOff = Date.Today().addDays(-inactivityDays); 

        List<Opportunity> oppListToUpdate = new List<Opportunity>();
        
        List<Response> results = new List<Response>();
        
            List<Opportunity> OppList;

        if(!String.isBlank(searchOpportunityN)){
                                 //Querying all the Opportunity where contract end Date is within 60days and Opportunity is Inactive from 14 days
         OppList = [SELECT Id, Name, AccountId, Owner.Name, ContractId, StageName, CSAT_Score__c, LastActivityDate, Contract.EndDate , Account.Rating 
                                      FROM Opportunity WHERE Name =: searchOpportunityN];  
        }else{

                                //Querying all the Opportunity where contract end Date is within 60days and Opportunity is Inactive from 14 days
         OppList = [SELECT Id, Name, AccountId, Owner.Name, ContractId, StageName, CSAT_Score__c, LastActivityDate, Contract.EndDate , Account.Rating 
                                      FROM Opportunity WHERE IsClosed = FALSE AND ContractId != null AND Contract.EndDate <=: renewalcutoff 
                                      AND (LastActivityDate = null OR LastActivityDate <=: activityCutOff)];
        }






        
        
        set<Id> OppIdsToProcess = new set<Id>();
        set<Id> AccountIdsOfOpportunity = new set<Id>();

        for(Opportunity opp: OppList){
            OppIdsToProcess.add(opp.id);
            AccountIdsOfOpportunity.add(opp.AccountId);
        }

        List<Task> taskListToInsert = new List<Task>();
        
        for(Opportunity opp : OppList){
     
            Response r = new Response();
            
            r.opportunityName = opp.Name;
            if(opp.LastActivityDate != null ){
            r.LastActivityDate = opp.LastActivityDate;
            }
            if(opp.Contract != null){
            r.ContractEndDate = opp.Contract.EndDate;
            }
            r.StageName = opp.StageName;
            results.add(r);

           
               system.debug('Task being inserted');
                System.debug('Opportunity Id: ' + opp.Id);
                System.debug('Opportunity Name: ' + opp.Name);
                System.debug('TaskCreationInput: ' + requests[0].searchOpportunityName);
                Task tsk = new Task();
                tsk.whatId = opp.Id;
                tsk.subject = 'Renewal Outreach';
                tsk.Status = 'Not Started';
                tsk.Priority = 'Normal';
                taskListToInsert.add(tsk);
             
        }

        if(!taskListToInsert.isEmpty()){

            System.debug( 'About to insert ' +  taskListToInsert.size() +  ' tasks' );

            Database.SaveResult[] resultsInsert = Database.insert(taskListToInsert, false);

            for(Database.SaveResult r : resultsInsert){

                if(r.isSuccess()){

                    System.debug('SUCCESS: ' +r.getId());

                }else{

                    for(Database.Error e : r.getErrors()){

                        System.debug( 'FAILED: ' + e.getMessage());
                    }
                }
            }
        } 

        return results;
        
    }

}