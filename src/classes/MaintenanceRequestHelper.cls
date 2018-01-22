public class MaintenanceRequestHelper {
    
   public static void updateWorkOrders(Set<Id> ids){
        // update workorders
        system.debug('helper is triggered');
       
	    List<Case> listCase = [Select id,Equipment__c,Vehicle__c,Equipment__r.Maintenance_Cycle__c, subject,
                              product__c, accountId, contactId, assetId, origin, reason,
        (Select Equipment__r.Maintenance_Cycle__c from Work_Parts__r) from Case where Id In :ids];
      
    	List<Case> newCases = new List<Case>();
        for(Case a: listCase){
  
            Case newCase = new Case();
            newCase.Vehicle__c = a.Vehicle__c;
            newCase.Equipment__c = a.Equipment__c;
            newCase.Type = 'Routine Maintenance';
            newCase.Subject =  String.isEmpty(a.Subject) ? 'Routine Maintenance Request' : a.Subject;
            newCase.Date_Reported__c = Date.today();
            newCase.Status = 'New';
            newCase.Product__c = a.Product__c;
            newCase.AccountId = a.AccountId;
            newCase.ContactId = a.ContactId;
            newCase.AssetId = a.AssetId;
            newCase.Origin = a.Origin;
            newCase.Reason = a.Reason;
            
            Integer shortSpan = 0;
            if(a.Work_Parts__r.size() > 0){
                for(Work_Part__c wp : a.Work_Parts__r){
                    if(wp.Equipment__r.Maintenance_Cycle__c != NULL && (wp.Equipment__r.Maintenance_Cycle__c < shortSpan || shortSpan == 0 )){
                        shortSpan = Integer.ValueOf(wp.Equipment__r.Maintenance_Cycle__c);
                    }
                }
            }
            newCase.Date_Due__c = System.today().addDays(shortSpan);

            newCases.add(newCase);
			}
        
        System.debug('new cases: ' + newCases.size());
        if(newCases.size() > 0){
            insert newCases;
            system.debug('new cases inserted');
        }
    }        
}