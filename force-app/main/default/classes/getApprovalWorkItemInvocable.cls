public with sharing class getApprovalWorkItemInvocable {

    public class Request {
        @InvocableVariable(required=true)
        public Id recordId;
    }

    public class Response {
        @InvocableVariable
        public Boolean success;

        @InvocableVariable
        public String workItemId;

        @InvocableVariable
        public String message;
    }

    @InvocableMethod(label='Get Pending Approval Work Item')
    public static List<Response> getWorkItem(List<Request> requests) {

        List<Response> responses = new List<Response>();

        for (Request req : requests) {

            Response res = new Response();

            try {

                List<ProcessInstanceWorkitem> workItems = [
                    SELECT Id
                    FROM ProcessInstanceWorkitem
                    WHERE ProcessInstance.TargetObjectId = :req.recordId
                    LIMIT 1
                ];

                if (!workItems.isEmpty()) {
                    res.success = true;
                    res.workItemId = workItems[0].Id;
                    res.message = 'Pending approval work item found.';
                }
                else {
                    res.success = false;
                    res.message = 'No pending approval request found for this record.';
                }

            }
            catch (Exception ex) {
                res.success = false;
                res.message = ex.getMessage();
            }

            responses.add(res);
        }

        return responses;
    }

}