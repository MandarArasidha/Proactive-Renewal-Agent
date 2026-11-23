public with sharing class createTaskWithAllParmetersInvocable {
    public class Request {

        @InvocableVariable(required=true)
        public String taskSubject;

        @InvocableVariable(required=true)
        public String taskComments;

        @InvocableVariable(required=true)
        public Id relatedRecordId; // Opportunity Id

        @InvocableVariable
        public Id assignedToUserId;

        @InvocableVariable
        public String primaryContactName;

        @InvocableVariable
        public Date dueDate;

        @InvocableVariable
        public String priority;

        @InvocableVariable
        public String status;
    }

    public class Response {

        @InvocableVariable
        public Id taskId;

        @InvocableVariable
        public String resultMessage;
    }

    @InvocableMethod(
        label='Create Task'
        description='Creates a Task from Agentforce inputs'
    )
    public static List<Response> createTask(List<Request> requests) {

        List<Response> responses = new List<Response>();

        if(requests == null || requests.isEmpty()) {
            return responses;
        }

        List<Task> tasksToInsert = new List<Task>();

        for(Request req : requests) {

            Task t = new Task();

            t.Subject = String.isBlank(req.taskSubject)
                ? 'Follow Up'
                : req.taskSubject;

            t.Description = String.isBlank(req.taskComments)
                ? ''
                : req.taskComments;

            t.WhatId = req.relatedRecordId;

            if(req.assignedToUserId != null) {
                t.OwnerId = req.assignedToUserId;
            }

            if(req.primaryContactName != null) {
                t.WhoId = req.primaryContactName;
            }

            t.ActivityDate = req.dueDate != null
                ? req.dueDate
                : Date.today().addDays(7);

            t.Priority = String.isBlank(req.priority)
                ? 'Normal'
                : req.priority;

            t.Status = String.isBlank(req.status)
                ? 'Not Started'
                : req.status;

            tasksToInsert.add(t);
        }

        insert tasksToInsert;

        for(Task taskRecord : tasksToInsert) {

            Response res = new Response();
            res.taskId = taskRecord.Id;
            res.resultMessage =
                'Task created successfully with Id: ' + taskRecord.Id;

            responses.add(res);
        }

        return responses;
    }
}