public with sharing class AiJobRunTriggerhandler {
    public static void emailProcessingAfterAiJobRunStatusCompete(List<AiJobRun> newJobStatus, Map<Id,AiJobRun> oldJobStatusMap) {

        //Psudocode
        //if job status changed
        
        Boolean CreateMails = false;
        set<Id> completedJobIds = new set<Id>();
        for(AiJobRun newJob : newJobStatus){
            //RunningJobId = newJob.Id;
            AiJobRun oldJob = oldJobStatusMap.get(newJob.id);
            
            if(newJob.status == 'Completed' && oldJob.status != 'Completed' && newJob.status != oldJob.status){
                system.debug('status changes');
                //Then Start the Mail Creation
                completedJobIds.add(newJob.id);

            }
        }
        if(!completedJobIds.isEmpty()){
            //Query List of AiJobRunItem - pass the AiJobRunId to get the Detail response
            List<AiJobRunItem> items = [ SELECT Id, Status, Response, Input FROM AiJobRunItem WHERE AiJobRunId IN : completedJobIds ];
            createDraftEmails(items);
        }
    }   

        private static void createDraftEmails(List<AiJobRunItem> items){

            List<EmailMessage> EmailDraftList = new List<EmailMessage>();
            for(AiJobRunItem item : items){
    
            Map<String,Object> responseMap = (Map<String,Object>) JSON.deserializeUntyped(item.Response);

            Map<String,Object> inputMap = (Map<String,Object>) JSON.deserializeUntyped(item.Input);

            String generatedEmail = (String)responseMap.get('promptResponse');

            Id oppId = (Id)String.valueOf(inputMap.get('OpportunityId'));

            String accountMailId = String.valueOf(inputMap.get('AccountEmail'));

            String contactMailId = String.valueOf(inputMap.get('ContactEmail'));

            String SubjectLine = '';
            String Body = generatedEmail;
            String toAddressM = contactMailId;
            String fromAddressM = accountMailId;
            
            
            if(generatedEmail.startsWith('Subject:')){
                Integer firstNewLine = generatedEmail.indexOf('\n');
                if(firstNewLine > -1){
                    SubjectLine = generatedEmail.substring('Subject:'.length(),firstNewLine).trim();
                    Body = generatedEmail.substring(firstNewLine).trim();
                }
            }

           
            System.debug('Generated Email response with Prompt Builder'+generatedEmail);
            EmailMessage draftEmail = new EmailMessage();
            draftEmail.RelatedToId = oppId;
            draftEmail.ToAddress = toAddressM;
            draftEmail.FromAddress = fromAddressM;
            
            draftEmail.Subject = SubjectLine;
            draftEmail.TextBody = Body;
            draftEmail.status = '5';
            draftEmail.Incoming = false;
            EmailDraftList.add(draftEmail); 

        }
        
        if(!EmailDraftList.isEmpty()){
            insert EmailDraftList;
        }
    }
}