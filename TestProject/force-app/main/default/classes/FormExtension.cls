public class FormExtension {
    private final Case caseRecord;
    public Boolean isChecked { get; set; }
    public Date stBirthday { get; set; }
    
    public Boolean errorLastName { get; set; }
    public String errorStringLastName { get; set; }
    
    public Boolean errorEmail { get; set; }
    public String errorStringEmail { get; set; }
    
    public Boolean errorStudentName { get; set; }
    public String errorStringStudentName { get; set; }
    
    public Boolean errorBirthday { get; set; }
    public String errorStringBirthday { get; set; }
    
    public Boolean errorCourse { get; set; }
    public String errorStringCourse { get; set; }
    
    public Boolean errorLocation { get; set; }
    public String errorStringLocation { get; set; }
    
    public Boolean errorPhone { get; set; }
    public String errorStringPhone { get; set; }

    public List<Case> caseList { get; set; }
    
    public FormExtension(ApexPages.StandardController controller) {
        this.caseRecord = (Case)controller.getRecord();
        isChecked = false;
        caseList = [SELECT Id, First_Name__c, Last_Name__c, CaseNumber FROM Case];
    }
    
    public void getTheOptions(){
        getValidCourseOptions();
    }
    
    public Boolean isValidText(String input) {
        String textPattern = '^[a-zA-Z]+$';
        return Pattern.matches(textPattern, input);
    }
    
    public Boolean isValidNumber(String input) {
        String numberPattern = '^[0-9]+$';
        return Pattern.matches(numberPattern, input);
    }
    
    
    public List<SelectOption> getSalutationOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- Select --'));
        options.add(new SelectOption('Mr.', 'Mr.'));
        options.add(new SelectOption('Ms.', 'Ms.'));
        options.add(new SelectOption('Mrs.', 'Mrs.'));
        return options;
    }
    
    private List<SelectOption> getInterestedCourseOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- Select --'));
        options.add(new SelectOption('Apple Course (Age 2)', 'Apple Course (Age 2)', true));
        options.add(new SelectOption('Music Wonderland (Age 3)', 'Music Wonderland (Age 3)', true));
        options.add(new SelectOption('Yamaha Junior Course (Age 4 - 5.5)', 'Yamaha Junior Course (Age 4 - 5.5)', true));
        options.add(new SelectOption('Yamaha Piano Course (Age 5.5 and Above)', 'Yamaha Piano Course (Age 5.5 and Above)', true));
        options.add(new SelectOption('Piano Course For Children (Age 6 - 8)', 'Piano Course For Children (Age 6 - 8)', true));
        options.add(new SelectOption('Junior Electone Course (Age 6 - 8)', 'Junior Electone Course (Age 6 - 8)', true));
        options.add(new SelectOption('Electone Study Course (Age 10 and Above)', 'Electone Study Course (Age 10 and Above)', true));
        options.add(new SelectOption('Junior Guitar Course (Age 7 - 11)', 'Junior Guitar Course (Age 7 - 11)', true));
        options.add(new SelectOption('Pop Guitar for Kids (Age 6 - 11)', 'Pop Guitar for Kids (Age 6 - 11)', true));
        options.add(new SelectOption('Junior Drum Course (Age 6 - 12)', 'Junior Drum Course (Age 6 - 12)', true));
        return options;
    }
    
    public List<SelectOption> getLocationOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- Select --'));
        options.add(new SelectOption('Tampines Mall @ Tampines MRT', 'Tampines Mall @ Tampines MRT'));
        options.add(new SelectOption('SAFRA Punggol @ Sam Kee LRT', 'SAFRA Punggol @ Sam Kee LRT'));
        options.add(new SelectOption('Hougang @ Kovan MRT', 'Hougang @ Kovan MRT'));
        options.add(new SelectOption('Kallang Leisure Park @ Stadium MRT', 'Kallang Leisure Park @ Stadium MRT'));
        options.add(new SelectOption('Plaza Singapura @ Dhoby Ghaut MRT', 'Plaza Singapura @ Dhoby Ghaut MRT'));
        options.add(new SelectOption('Djitsun Mall @ Ang Mo Kio MRT', 'Djitsun Mall @ Ang Mo Kio MRT'));
        options.add(new SelectOption('Sembawang Shopping Centre via Canberra or Sembawang MRT', 'Sembawang Shopping Centre via Canberra or Sembawang MRT'));
        options.add(new SelectOption('Thomson Plaza @ Upper Thomson MRT', 'Thomson Plaza @ Upper Thomson MRT'));
        options.add(new SelectOption('Westgate Mall @ Jurong East MRT', 'Westgate Mall @ Jurong East MRT'));
        options.add(new SelectOption('Clementi @ Clementi MRT', 'Clementi @ Clementi MRT'));
        options.add(new SelectOption('Frontier Community Club @ Boon Lay MRT', 'Frontier Community Club @ Boon Lay MRT'));
        return options;
    }
    
    public PageReference save() {
        System.debug('Performing saving record!');
        
        if(invalidFields()){
            System.debug('Something is wrong');
            return null;
        }
        
        try {
            insert caseRecord;
            send();
            PageReference acctPage = new ApexPages.StandardController(caseRecord).view();
            acctPage.setRedirect(true);
            return acctPage;
        } catch (DmlException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Save Failed: ' + e.getDmlMessage(0)));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected Error: ' + e.getMessage()));
        }
        
        return null;
    }
    
    private Decimal calculateAge() {
        if(caseRecord.Student_s_Birthday__c == null ){
            return null;
        }
        
        Date birthDate = caseRecord.Student_s_Birthday__c;
        Date today = Date.today();
        
        Integer years = today.year() - birthDate.year();
        
        Integer monthsDiff = today.month() - birthDate.month();
        Integer daysDiff = today.day() - birthDate.day();
        
        if (monthsDiff < 0 || (monthsDiff == 0 && daysDiff < 0)) {
            years--;
            monthsDiff += 12;
        }
        
        Decimal age = years + (monthsDiff / 12.0);
        return age;
    }
    
    public List<SelectOption> getValidCourseOptions(){
        List<SelectOption> listOptions = getInterestedCourseOptions();
        Decimal stAge = calculateAge();
        
        if(caseRecord.Student_s_Birthday__c != null){
            for (SelectOption option : listOptions) {
                String courseName = option.getValue();
                Integer startIdx = courseName.indexOf('Age ');
                
                if (startIdx != -1) {
                    String agePart = courseName.substring(startIdx + 4, courseName.length() - 1);
                    
                    if (agePart.contains(' - ')) {
                        List<String> ageRange = agePart.split(' - ');
                        Decimal decimalMinAge = Decimal.valueOf(ageRange[0]);
                        Double minAge = decimalMinAge.doubleValue();
                        Decimal decimalMaxAge = Decimal.valueOf(ageRange[1]);
                        Double maxAge = decimalMaxAge.doubleValue();
                        
                        if (stAge >= minAge && stAge <= maxAge) {
                            option.setDisabled(false);
                        } else {
                            option.setDisabled(true);
                        }
                    } else {
                        String minAgeString;
                        
                        if (agePart.length() > 1) {
                            minAgeString = agePart.substring(0, agePart.indexOf(' '));
                        } else {
                            minAgeString = agePart;
                        }
                        
                        Decimal decimalMinAge = Decimal.valueOf(minAgeString);
                        Double minAge = decimalMinAge.doubleValue();
                        
                        if ((stAge >= minAge && agePart.length() > 1) ||(stAge.intValue() == minAge.intValue() && agePart.length() == 1)) {
                            option.setDisabled(false);
                        } else{
                            option.setDisabled(true);
                        }
                    }
                }
            }
            
            return listOptions;
        }
        
        return listOptions;
    }
    
    public Boolean isValidEmail() {
        String email = caseRecord.Email__c;
        
        if (email == null || email.length() > 50) {
            return false;
        }
        
        String emailPattern = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$';
        return Pattern.matches(emailPattern, email);
    }
    
    private Boolean invalidFields (){
        if(caseRecord.Last_Name__c == null){
            errorLastName = true;
            errorStringLastName = 'Please fill this field!';
            return true;
        }
        
        if(caseRecord.Last_Name__c != null && !isValidText(caseRecord.Last_Name__c)){
            errorLastName = true;
            errorStringLastName = 'No numbers nor space is allowed!';
            return true;
        }
        
        if((caseRecord.Last_Name__c != null && (caseRecord.Last_Name__c).length() > 80)){
            errorLastName = true;
            errorStringLastName = 'Last name is too long! Max length = 80!';
            return true;
        }
        
        errorLastName = false;
        
        if(isValidEmail() == false){
            errorEmail = true;
            errorStringEmail = 'Not a valid email!';
            return true;
        }
        
        errorEmail = false;
        
        if((caseRecord.Phone__c != null && (caseRecord.Phone__c).length() > 40)){
            errorPhone = true;
            errorStringPhone = 'Phone number is too long! Max length = 40';
            return true;
        }
        
        if((caseRecord.Phone__c != null && !isValidNumber(caseRecord.Phone__c))){
            errorPhone = true;
            errorStringPhone = 'This field can only have numbers!';
            return true;
        }
        
        errorPhone = false;
        
        if(caseRecord.Student_s_Name__c == null){
            errorStudentName = true;
            errorStringStudentName = 'Please fill this field';
            return true;
        }
        
        if(caseRecord.Student_s_Name__c != null && !isValidText(caseRecord.Student_s_Name__c)){
            errorStudentName = true;
            errorStringStudentName = 'No numbers nor space is allowed!';
            return true;
        }
        
        if((caseRecord.Student_s_Name__c != null && (caseRecord.Student_s_Name__c).length() > 100)){
            errorStudentName = true;
            errorStringStudentName = 'Student\'s name is too long! Max length = 100';
            return true;
        }
        
        errorStudentName = false;
        
        if(caseRecord.Student_s_Birthday__c != null && caseRecord.Student_s_Birthday__c > Date.today()){
            errorBirthday = false;
            errorStringBirthday = 'Invalid birthday!';
            return true;
        }
        
        if(caseRecord.Student_s_Birthday__c == null){
            errorBirthday = false;
            errorStringBirthday = 'Please fill this field!';
            return true;
        }
        
        errorBirthday = false;
        
        if(caseRecord.Interested_Course__c == null ){
            errorCourse = true;
            errorStringCourse = 'Please fill this field!';
            return true;
        }
        
        errorCourse = false;
        
        if(caseRecord.Location__c == null ){
            errorLocation = false;
            errorStringLocation = 'Please fill this field!';
            return true;
        }
        
        errorLocation = false;
        
        return false;
    }
    
    public void setCheck(){
        isChecked = !isChecked;
        System.debug(isChecked);
    }
    
    public void send() {
        if (caseRecord.Email__c != null) {
            List<String> address = new List<String>();
            address.add(caseRecord.Email__c);
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('Notification');
            email.setToAddresses(address);
            email.setPlainTextBody('Hello! This is a notification. Your case has been successfully created. Thank you!');
            
            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        }
    }
}