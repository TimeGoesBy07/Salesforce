public without sharing class testtest {
	public static List<Map<String, String>> toMapList(String pObjName, List<sObject> pObjList) {
		return toMapList(pObjName, pObjList, null);
	}

	public static List<Map<String, String>> toMapList(String pObjName, List<sObject> pObjList, List<String> pExtendsFields) {
		List<Map<String, String>> targetList = new List<Map<String, String>>();
		for (sObject item : pObjList) {
			targetList.add(toMap(pObjName, item, pExtendsFields));
		}
		return targetList;
	}

	public static Map<String, String> toMap(String pObjName, sObject pObj) {
		return toMap(pObjName, pObj, null);
	}

	public static Map<String, String> toMap(String pObjName, sObject pObj, List<String> pExtendsFields) {
		Map<String, String> objMap = new Map<String, String>();
		Map<String, Schema.DisplayType> fields = getFieldNames(pObjName);
		Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(pObj, false));
		for (String fieldName : fields.keySet()) {
			Schema.DisplayType fieldType = fields.get(fieldName);
			Object fieldValue;
			if (fieldName.contains('.')) {
				List<String> fieldNames = fieldName.split('\\.');
				Integer iLength = fieldNames.size();
				Map<String, Object> childObj = (Map<String, Object>)jsonMap.get(fieldNames[0]);
				for (Integer i = 1; i < iLength -1; i++) {
					childObj = (Map<String, Object>)childObj.get(fieldNames[i]);
					if (childObj == null) break;
				}
				if (childObj != null) {
					fieldValue = childObj.get(fieldNames[iLength -1]);
				}
			}else {
				fieldValue = jsonMap.get(fieldName);
			}
			String sValue = '';
			if (fieldValue != null) {
				sValue = getStrValue(fieldValue, fieldType);
			}
			objMap.put(fieldName, sValue);
		}
		if (pExtendsFields != null) {
			for (String extFieldName : pExtendsFields) {
				Object fieldValue;
				if (extFieldName.contains('.')) {
					List<String> fieldNames = extFieldName.split('\\.');
					Integer iLength = fieldNames.size();
					Map<String, Object> childObj = (Map<String, Object>)jsonMap.get(fieldNames[0]);
					for (Integer i = 1; i < iLength -1; i++) {
						childObj = (Map<String, Object>)childObj.get(fieldNames[i]);
						if (childObj == null) break;
					}
					if (childObj != null) {
						fieldValue = childObj.get(fieldNames[iLength -1]);
					}
				}else {
					fieldValue = jsonMap.get(extFieldName);
				}
				String sValue = '';
				if (fieldValue != null) {
					sValue = getStrValue(fieldValue, Schema.DisplayType.String);
				}
				objMap.put(extFieldName, sValue);
			}
		}
		return objMap;
	}

	public static sObject saveToObject(String pObjName, Map<String, String> pMap, sObject pObj) {
		Map<String, Schema.DisplayType> fields = getFieldNames(pObjName);
		for (String fieldName : pMap.keySet()) {
			if (!fieldName.contains('.Name')) {
				try {
					if (fields.get(fieldName) == Schema.DisplayType.Date) {
						pObj.put(fieldName, setStringToDate(pMap.get(fieldName)));
					}else if (fields.get(fieldName) == Schema.DisplayType.Datetime) {
						pObj.put(fieldName, setStringtoDateTime(pMap.get(fieldName)));
					}else {
						pObj.put(fieldName, pMap.get(fieldName));
					}
				}catch(Exception ex) {

				}
			}
		}
		return pObj;
	}

	public static void initMap(Map<String, String> pSrcMap) {
		for (String key : pSrcMap.keySet()) {
			if (pSrcMap.get(key) == null) {
				pSrcMap.put(key, '');
			}
		}
	}

	private static Map<String, Schema.DisplayType> getFieldNames(String pObjName) {
		Map<String, Schema.DisplayType> fieldsMap = new Map<String, Schema.DisplayType>();
		List<Schema.DescribeSObjectResult> objResults = Schema.describeSObjects(new List<String>{pObjName});
		if (objResults != null && objResults.size() > 0) {
			Map<String, Schema.SObjectField> fieldMap = objResults[0].fields.getMap();
			for( String fieldName : fieldMap.keySet() ) {
				Schema.SObjectField field = fieldMap.get( fieldName );
				Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
				fieldsMap.put(fieldDescribe.getName(), fieldDescribe.getType());
				if (fieldDescribe.getType() == Schema.DisplayType.Reference) {
					String parentName = fieldDescribe.getRelationshipName().replace('__c', '__r') + '.Name';
					fieldsMap.put(parentName, Schema.DisplayType.String);
				}
			}
		}
		return fieldsMap;
	}

	public static String getStrValue(Object pValue, Schema.DisplayType pType) {
		String sRtn = '';
		try {
			if (pType == Schema.DisplayType.Date) {
				sRtn = pValue == null ? '' : String.valueOf(pValue).split(' ')[0].replace('-', '/');
			}else if (pType == Schema.DisplayType.DateTime) {
				sRtn = pValue == null ? '' : DateTime.ValueofGmt(String.valueOf(pValue).replace('T', ' ')).format('yyyy/MM/dd HH:mm:ss', 'Asia/Tokyo');
			}else {
				if (pValue == null) {
					sRtn = '';
				}else {
					try {
						sRtn = String.valueOf(pValue);
						pattern MyPattern = pattern.compile('\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}.\\d{3}\\+\\d{4}');
						matcher MyMatcher = MyPattern.matcher(sRtn);
						if (MyMatcher.matches()) {
							sRtn = sRtn.replace('T', ' ').replaceAll('\\+\\d{4}', 'Z');
							sRtn = Datetime.valueOf(sRtn).addHours(9).format('yyyy/MM/dd HH:mm:ss', 'Asia/Tokyo');
						}
					} catch (Exception ex) {
						sRtn = String.valueOf(pValue);
					}
				}
			}
		}catch(Exception ex) {

		}

		return sRtn;
	}

	public static Date setStringToDate(String myDate) {
		String[] myDateOnly = myDate.split(' ');
		String[] strDate = myDateOnly[0].split('/');
		Integer myIntDate = integer.valueOf(strDate[2]);
		Integer myIntMonth = integer.valueOf(strDate[1]);
		Integer myIntYear = integer.valueOf(strDate[0]);
		Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
		return d;
	}

	public static Datetime setStringtoDateTime(String myDatetime) {
		String[] myDateOnly = myDatetime.split(' ');
		String[] strDate = myDateOnly[0].split('/');
		Integer myIntDate = integer.valueOf(strDate[2]);
		Integer myIntMonth = integer.valueOf(strDate[1]);
		Integer myIntYear = integer.valueOf(strDate[0]);
		String[] strTime = myDateOnly[1].split(':');
		Integer myIntHour = integer.valueOf(strTime[0]);
		Integer myIntMin = integer.valueOf(strTime[1]);
		Integer myIntSec = integer.valueOf(strTime[2]);
		Datetime d = Datetime.newInstance(myIntYear, myIntMonth, myIntDate, myIntHour, myIntMin, myIntSec);
		return d;
	}
}