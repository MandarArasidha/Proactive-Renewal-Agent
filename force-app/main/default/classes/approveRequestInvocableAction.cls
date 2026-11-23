public with sharing class approveRequestInvocableAction {
    public class Request {
        @InvocableVariable(required=true)
        public String workItemId;

        @InvocableVariable(required=true)
        public String action;

        @InvocableVariable
        public String comments;
    }

    public class Response {
    @InvocableVariable
    public Boolean success;

    @InvocableVariable
    public String message;

    @InvocableVariable
    public String newStatus;
}

    @InvocableMethod(label='Approval Process Action')
    public static List<Response> processApproval(List<Request> requests) {

        List<Response> responses = new List<Response>();
        
        for (Request r : requests) {

            Response response = new Response();

            try {

                Approval.ProcessWorkitemRequest approvalRequest = new Approval.ProcessWorkitemRequest();

                approvalRequest.setWorkitemId(r.workItemId);
                approvalRequest.setAction(r.action);

                if (String.isNotBlank(r.comments)) {
                    approvalRequest.setComments(r.comments);
                }

                Approval.ProcessResult result = Approval.process(approvalRequest);

                response.success = result.isSuccess();

                if (result.isSuccess()) {

                    response.newStatus = r.action.equalsIgnoreCase('Approve') ? 'Approved'  : 'Rejected';

                    response.message = 'Approval request successfully ' + response.newStatus.toLowerCase() + '.';

                } else {

                    response.newStatus = 'Failed';
                    response.message = result.getErrors()[0].getMessage();
                }

            } catch (Exception ex) {

                response.success = false;
                response.newStatus = 'Failed';
                response.message = ex.getMessage();
            }

            responses.add(response);
        }

        return responses;
    }
}