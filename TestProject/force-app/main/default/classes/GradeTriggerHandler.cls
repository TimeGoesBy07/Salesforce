public with sharing class GradeTriggerHandler {
    private static Decimal calAvgScores(Decimal finalTermScore, Decimal midtermScore, Decimal practicalScore, Decimal progressScore){
        finalTermScore = finalTermScore != null ? finalTermScore : 0;
        midtermScore = midtermScore != null ? midtermScore : 0;
        practicalScore = practicalScore != null ? practicalScore : 0;
        progressScore = progressScore != null ? progressScore : 0;
        Decimal res = finalTermScore*0.5 + midtermScore*0.2 + practicalScore*0.2 + progressScore*0.1;

        return res;
    }
    
    public static void onInsert(List<Grade__c> gradeList) {
        for(Grade__c e : gradeList){
            e.Average_Score__c	= calAvgScores(e.FinalTerm_Score__c,e.Midterm_Score__c,e.Practical_Score__c,e.Progress_Score__c);
        }
    }
    
    public static void onUpdate(List<Grade__c> gradeList, Map<Id,Grade__c> gradeListOld) {
        for(Grade__c grade : gradeList){
            if(grade.FinalTerm_Score__c != gradeListOld.get(grade.Id).FinalTerm_Score__c || grade.Midterm_Score__c != gradeListOld.get(grade.Id).Midterm_Score__c || grade.Practical_Score__c != gradeListOld.get(grade.Id).Practical_Score__c || grade.Progress_Score__c != gradeListOld.get(grade.Id).Progress_Score__c){
                grade.Average_Score__c = calAvgScores(grade.FinalTerm_Score__c,grade.Midterm_Score__c,grade.Practical_Score__c,grade.Progress_Score__c);
            }
        }
        // for(Integer i = 0; i < gradeList.size(); i++){
        //     if(gradeList[i].FinalTerm_Score__c != gradeListOld[i].FinalTerm_Score__c || gradeList[i].Midterm_Score__c != gradeListOld[i].Midterm_Score__c || gradeList[i].Practical_Score__c != gradeListOld[i].Practical_Score__c || gradeList[i].Progress_Score__c != gradeListOld[i].Progress_Score__c ){
        //         Decimal finalTermScore = gradeList[i].FinalTerm_Score__c != null ? gradeList[i].FinalTerm_Score__c : 0;
        //         Decimal midtermScore = gradeList[i].Midterm_Score__c != null ? gradeList[i].Midterm_Score__c : 0;
        //         Decimal practicalScore = gradeList[i].Practical_Score__c != null ? gradeList[i].Practical_Score__c : 0;
        //         Decimal progressScore = gradeList[i].Progress_Score__c != null ? gradeList[i].Progress_Score__c : 0;
                
        //         Decimal av = finalTermScore*0.5 + midtermScore*0.2 + practicalScore*0.2 + progressScore*0.1;
        //         gradeList[i].Average_Score__c = av;
        //     }
        // }
    }
}