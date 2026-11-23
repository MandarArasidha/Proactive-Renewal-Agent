trigger AiJobRunTrigger on AiJobRun (after Insert, after update) {

    switch on Trigger.operationType{

        WHEN AFTER_INSERT{
            system.debug('Status new started, Inserted');
        }

        WHEN AFTER_UPDATE{
            system.debug('status changes');
            AiJobRunTriggerhandler.emailProcessingAfterAiJobRunStatusCompete(Trigger.new,Trigger.oldMap);
        }
    }
}