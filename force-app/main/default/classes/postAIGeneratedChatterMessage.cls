public with sharing class postAIGeneratedChatterMessage {

    public class Request {

        @InvocableVariable(
            required=true
            description='Opportunity record on which the Chatter notification should be posted.'
        )
        public Id opportunityId;

        @InvocableVariable(
            description='Account Owner User Id to mention in the Chatter post.'
        )
        public Id AccountOwnerId;

        @InvocableVariable(
            description='Opportunity Name for personalization.'
        )
        public String opportunityName;

        @InvocableVariable(
            description='Current Opportunity Stage.'
        )
        public String opportunityStage;

        @InvocableVariable(
            description='Contract End Date associated with the Opportunity.'
        )
        public Date contractEndDate;

        @InvocableVariable(
            description='Most recent customer activity date.'
        )
        public Date lastActivityDate;

        @InvocableVariable(
            description='Customer Satisfaction Score associated with the Opportunity.'
        )
        public Decimal csatScore;

        @InvocableVariable(
            description='Number of open support cases associated with the Account.'
        )
        public Integer openCases;

        @InvocableVariable(
            description='EmailMessage Id of the generated draft email. If omitted, the latest draft email related to the Opportunity will be used.'
        )
        public Id mailDraftId;

        @InvocableVariable(
            description='Agent generated summary of renewal risk and recommended actions.'
        )
        public String chatterSummary;
    }

    public class Response {

        @InvocableVariable
        public Id chatterPostId;

        @InvocableVariable
        public Id linkedEmailDraftId;

        @InvocableVariable
        public String summarizedContent;

        @InvocableVariable
        public String statusMessage;
    }

    @InvocableMethod(
        label='Post Renewal Chatter Notification'
        description='Posts a Chatter notification summarizing renewal risk and links the generated email draft.'
    )
    public static List<Response> postNotification(
        List<Request> requests
    ) {

        List<Response> responses = new List<Response>();

        for(Request req : requests){

            Response res = new Response();

            try{

                Id emailIdToLink = req.mailDraftId;

                /*
                 Fallback to latest draft email if not provided
                */
                if(emailIdToLink == null){

                    List<EmailMessage> emails = [
                        SELECT Id
                        FROM EmailMessage
                        WHERE ParentId = :req.opportunityId
                        AND Status = '5'
                        ORDER BY CreatedDate DESC
                        LIMIT 1
                    ];

                    if(!emails.isEmpty()){
                        emailIdToLink = emails[0].Id;
                    }
                }

                /*
                 Build default summary if none provided
                */
                String summary = req.chatterSummary;

                if(String.isBlank(summary)){

                    List<String> riskFactors = new List<String>();

                    if(req.contractEndDate != null){
                        riskFactors.add(
                            'Contract End Date: ' +
                            String.valueOf(req.contractEndDate)
                        );
                    }

                    if(req.lastActivityDate != null){
                        riskFactors.add(
                            'Last Activity Date: ' +
                            String.valueOf(req.lastActivityDate)
                        );
                    }

                    if(!String.isBlank(req.opportunityStage)){
                        riskFactors.add(
                            'Stage: ' +
                            req.opportunityStage
                        );
                    }

                    if(req.csatScore != null){
                        riskFactors.add(
                            'CSAT Score: ' +
                            String.valueOf(req.csatScore)
                        );
                    }

                    if(req.openCases != null){
                        riskFactors.add(
                            'Open Cases: ' +
                            String.valueOf(req.openCases)
                        );
                    }

                    summary =
                        'Renewal risk identified for Opportunity "' +
                        req.opportunityName +
                        '".\n\n' +
                        String.join(riskFactors, '\n') +
                        '\n\nA personalized renewal outreach draft has been generated and linked below. Please review and take further action.';
                }

                /*
                 Create feed body
                */
                ConnectApi.FeedItemInput feedInput = new ConnectApi.FeedItemInput();

                ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();

                body.messageSegments = new List<ConnectApi.MessageSegmentInput>();

                /*
                 Mention Opportunity Owner
                */
                if(
                    req.AccountOwnerId != null && String.valueOf(req.AccountOwnerId).startsWith('005')
                ){

                    ConnectApi.MentionSegmentInput mention = new ConnectApi.MentionSegmentInput();

                    mention.id = req.AccountOwnerId;

                    body.messageSegments.add(mention);
                    ConnectApi.TextSegmentInput space = new ConnectApi.TextSegmentInput();

                    space.text = ' ';

                    body.messageSegments.add(space);
                }

                /*
                 Add summary
                */
                ConnectApi.TextSegmentInput text = new ConnectApi.TextSegmentInput();

                text.text = summary;

                body.messageSegments.add(text);

                /*
                 Add email draft link
                */
                if(emailIdToLink != null){

                    ConnectApi.TextSegmentInput newLine = new ConnectApi.TextSegmentInput();

                    newLine.text =
                        '\n\nGenerated Email Draft: ';

                    body.messageSegments.add(newLine);

                    ConnectApi.EntityLinkSegmentInput link = new ConnectApi.EntityLinkSegmentInput();

                    link.entityId = emailIdToLink;

                    body.messageSegments.add(link);
                }

                feedInput.body = body;

                /*
                 Post on Opportunity feed
                */
                feedInput.subjectId =
                    req.opportunityId;

                ConnectApi.FeedElement result = ConnectApi.ChatterFeeds.postFeedElement(
                        null,
                        feedInput
                    );

                res.chatterPostId = result.id;

                res.linkedEmailDraftId = emailIdToLink;

                res.summarizedContent = summary;

                res.statusMessage = 'Chatter notification posted successfully. Opportunity Owner was notified and the email draft was linked for review.';

            }
            catch(Exception ex){

                res.statusMessage =
                    'Failed to post Chatter notification: ' +
                    ex.getMessage();
            }

            responses.add(res);
        }

        return responses;
    }
}