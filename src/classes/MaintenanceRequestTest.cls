@IsTest
public class MaintenanceRequestTest {
	@IsTest
    static void TestSingleNegative()
    {
        Test.startTest();
        //Prepare
        Vehicle__c v = new Vehicle__c(Name='TestVehicle 01', VIN_Number__c='aqwepnvaore2424');
	    insert v;

        Case case1 = new Case(Type = 'Other', Status='Closed', Origin='Web', vehicle__c = v.Id, Subject='Test Case1');
        Case case2 = new Case(Type = 'Repair', Status='New', Origin='Web', vehicle__c = v.Id, Subject='');
        Case case3 = new Case(Type = 'Routine Maintenance', Status='New', Origin='Web', vehicle__c = v.Id, Subject='Test Case3', Date_Reported__c = Date.today()-1);
        
        List<Case> caseList = new List<Case>();
        caseList.add(case1);
        caseList.add(case2);
        caseList.add(case3);
        
        //Perform
        insert caseList;
        
        //Assert
        Case newCase1 = [SELECT id, Type, Status, Vehicle__c, Equipment__c, Subject, Origin, Date_Reported__c, Date_Due__c
                                        FROM Case WHERE Type = 'Other' limit 1];
		Case newCase2 = [SELECT id, Type, Status, Vehicle__c, Equipment__c, Subject, Origin, Date_Reported__c, Date_Due__c
                                        FROM Case WHERE Type = 'Repair' limit 1];
        Case newCase3 = [SELECT id, Type, Status, Vehicle__c, Equipment__c, Subject, Origin, Date_Reported__c, Date_Due__c
                                        FROM Case WHERE Type = 'Routine Maintenance' limit 1];
        Test.stopTest();
        
        System.assertEquals('Closed', newCase1.Status);
        System.assertEquals(null, newCase2.Subject);
        System.assertNotEquals(date.today(), newCase3.Date_Reported__c);
        
    }
    
    @IsTest
    static void TestSinglePositive()
    {
        Test.startTest();

        //Prepare
        Vehicle__c v = new Vehicle__c(Name='TestVehicle 01', VIN_Number__c='aqwepnvaore2424');
	    insert v;
        
         //create Equipments: two with different maintenance cycles
            List<Product2> prods = new List<Product2>();
            prods.add(new Product2(Name='TestProduct 01', Warehouse_SKU__c='200001', Lifespan_Months__c=12, Maintenance_Cycle__c=60, Replacement_Part__c=true));
            prods.add(new Product2(Name='TestProduct 02', Warehouse_SKU__c='200002', Lifespan_Months__c=24, Maintenance_Cycle__c=30, Replacement_Part__c=true));
            insert prods;
        
        Case case2 = new Case(Type = 'Repair', Status='New', Origin='Phone', vehicle__c = v.Id, Date_Reported__c = Date.today()-3);
        Case case3 = new Case(Type = 'Routine Maintenance', Status='New', Origin='Email', vehicle__c = v.Id, Date_Reported__c = Date.today()-1);
        
        List<Case> caseList = new List<Case>();
        caseList.add(case2);
        caseList.add(case3);
        
        insert caseList;
        
        //Add two work parts for each maintenance request created
            List<Work_Part__c> wps = new List<Work_Part__c>();
            wps.add(new Work_Part__c(Equipment__c=prods[0].id, Maintenance_Request__c=caseList[0].id, Quantity__c=1));
            wps.add(new Work_Part__c(Equipment__c=prods[1].id, Maintenance_Request__c=caseList[0].id, Quantity__c=2));
            
            insert wps;
        
         for (Case cc: caseList) {
            cc.Status = 'Closed';
        }
        update caseList;
        
        //Assert
        List<Case> newCases = [SELECT id, Type, Status, Vehicle__c, Equipment__c, Subject, Origin, Date_Reported__c, Date_Due__c, (select name from Work_Parts__r)
                                        FROM Case WHERE Date_Reported__c = :Date.today()];
       
        Test.stopTest();
        
        System.assertEquals(2, newCases.size());
        System.assertEquals('Routine Maintenance Request', newCases[0].Subject);
        System.assertEquals('New', newCases[1].Status);
        System.assertEquals(date.today(), newCases[1].Date_Due__c);
        System.assertEquals(date.today()+30, newCases[0].Date_Due__c);

    }
}