public with sharing class importData {
    private static Map<String, String> errorBuilder(String errorMsg, Decimal rowIndex){
        return new Map<String, String>{
            'row' => String.valueOf(rowIndex),
            'error' => errorMsg
        };
    }
    
    @AuraEnabled
    public static List<Map<String, String>> importData(List<Map<String, Object>> records) {
        Map<String, Id> recordTypeMap = new Map<String, Id>();
        List<Notification__c> notiToInsert = new List<Notification__c>();
        List<Map<String, String>> errorList = new List<Map<String, String>>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Notification__c').getDescribe().fields.getMap();
        Integer rowIndex = 2;
        System.debug(records);
        
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Notification__c']) {
            recordTypeMap.put(rt.DeveloperName, rt.Id);
        }
        
        for (Map<String, Object> row : records) {
            Notification__c noti = new Notification__c();
            Boolean hasError = false;
            
            for (SObjectField field : fieldMap.values()) {
                DescribeFieldResult fieldDesc = field.getDescribe();
                String fieldName = fieldDesc.getName();
                
                if (!fieldDesc.isCreateable()) continue;
                
                Object value = row.get(fieldName);
                Date parsedDate;
                
                if (!fieldDesc.isNillable() && !fieldDesc.isDefaultedOnCreate() && (value == null || String.valueOf(value).trim() == '')) {
                    errorList.add(errorBuilder('Missing required field: ' + fieldName, rowIndex));
                    hasError = true;
                    continue;
                }
                
                if (value != null) {
                    Boolean isValid = true;
                    Schema.DisplayType type = fieldDesc.getType();
                    System.debug(fieldName + ' is ' + type);
                    
                    if (type == Schema.DisplayType.Date) {
                        if (String.valueOf(value).trim() == 'Invalid Date') {
                            isValid = false;
                        } else {
                            parsedDate = Date.valueOf(String.valueOf(value).trim());
                            System.debug(parsedDate);
                        }
                    } else if ((type == Schema.DisplayType.Boolean && !(value instanceof Boolean)) || (type == Schema.DisplayType.Double && !(value instanceof Decimal)) || (type == Schema.DisplayType.Integer && !(value instanceof Integer)) || (type == Schema.DisplayType.String && !(value instanceof String)) || (type == Schema.DisplayType.REFERENCE && String.valueOf(value).trim() == 'Invalid')) {
                        isValid = false;
                    }
                    
                    if (isValid && type == Schema.DisplayType.String && value instanceof String) {
                        Integer maxLength = fieldDesc.getLength();
                        
                        if (((String)value).length() > maxLength) {
                            errorList.add(errorBuilder('Value too long for field: ' + fieldName + ' (max ' + maxLength + ')', rowIndex));
                            hasError = true;
                            continue;
                        }
                    }
                    
                    if (isValid && fieldName == 'RecordTypeId') {
                        String devName = String.valueOf(value).trim();
                        
                        if (recordTypeMap.containsKey(devName)) {
                            noti.RecordTypeId = recordTypeMap.get(devName);
                            continue;
                        } else {
                            errorList.add(errorBuilder('Invalid RecordType: ' + devName, rowIndex));
                            hasError = true;
                            continue;
                        }
                    }
                    
                    if (!isValid) {
                        errorList.add(errorBuilder('Invalid data type for field: ' + fieldName, rowIndex));
                        hasError = true;
                        continue;
                    }
                    
                    if (parsedDate != null) {
                        noti.put(fieldName, parsedDate);
                    } else {
                        noti.put(fieldName, value);
                    }
                }
            }
            
            if(hasError == false)
                notiToInsert.add(noti);
            
            rowIndex++;
        }
        
        System.debug(notiToInsert);
        
        if (!notiToInsert.isEmpty()) {
            try{
                insert notiToInsert;
            } catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
        
        return errorList;
    }
}