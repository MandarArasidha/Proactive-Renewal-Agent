public with sharing class generateMailforRequestedOpp {

    public class Request {

        @InvocableVariable(
            required=true
            description='The Salesforce Opportunity record Id for which the email draft should be generated. Use the Opportunity from the current record context or from a Get Records action.'
        )
        public Id opportunityId;


        @InvocableVariable(
            required=true
            description='The email draft that the prompt template generated'
        )
        public String generatedEmailDraft;
       
        @InvocableVariable(
            required=true
            description='The Opportunity Name used for personalization within the email draft.'
        )
        public String opportunityName;

        @InvocableVariable(
            description='The email address of the intended recipient of the draft email. Typically this is the Primary Contact email address.'
        )
        public String receiverEmail;


        @InvocableVariable(
            description='The email address of the sender of the draft email. Typically this is the custom field named - Account_mail_Id__c as email address.'
        )
        public String accountEmailAddress;
    

    }

    public class Response {

        @InvocableVariable(description = 'The Salesforce Opportunity record Id associated with the generated draft.')
        public Id opportunityId;                  

        @InvocableVariable(description = 'The Opportunity Name associated with the generated draft.')
        public String opportunityName;

        @InvocableVariable(description = 'A confirmation or error message indicating the outcome of the email draft generation process.')
        public String statusMessage;

        @InvocableVariable(
        description='The EmailMessage Id of the generated email draft.')
        public Id emailDraftId;
    }

    @InvocableMethod(
        label='Generate Renewal Email Draft'
        description='Generates and optionally saves a renewal email draft for a single Opportunity.'
    )
    public static List<Response> generateDraft(List<Request> requests) {

        List<Response> responses = new List<Response>();

        for(Request req : requests){

            Response res = new Response();

            res.opportunityName = req.opportunityName;
        
            try{

                res.emailDraftId = createEmailDraft(req, req.generatedEmailDraft );
                res.statusMessage = 'Email draft generated successfully and saved on the Opportunity record.';

            }
            catch(Exception ex){

                res.statusMessage =
                    'Failed to generate draft: ' + ex.getMessage();
            }

            responses.add(res);
        }

        return responses;
    }

    private static Id createEmailDraft( Request req, String generatedEmail){

    String subjectLine = 'Renewal Outreach';
    String body = generatedEmail;

    if(
        generatedEmail != null &&
        generatedEmail.startsWith('Subject:')
    ){

        Integer firstNewLine =
            generatedEmail.indexOf('\n');

        if(firstNewLine > -1){

            subjectLine =
                generatedEmail.substring(
                    'Subject:'.length(),
                    firstNewLine
                ).trim();

            body =
                generatedEmail.substring(
                    firstNewLine
                ).trim();
        }
    }

    EmailMessage draftEmail = new EmailMessage();

    // Relates email to Opportunity timeline
    draftEmail.relatedToId = req.opportunityId;

    // Customer recipient
    draftEmail.ToAddress = req.receiverEmail;
    system.debug('toAddresses'+req.receiverEmail);
    draftEmail.FromAddress = req.accountEmailAddress;
    system.debug('FromAddress'+req.accountEmailAddress);
    // Generated content
    draftEmail.Subject = subjectLine;
    draftEmail.TextBody = body;
    system.debug('TextBody'+body);
    //draftEmail.HtmlBody = body;

    // Draft status
    draftEmail.Status = '5';

    // Outgoing email
    draftEmail.Incoming = false;

    insert draftEmail;
    return draftEmail.Id;
}

    
}