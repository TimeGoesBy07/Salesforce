public with sharing class AdditionalFunctions {
    public String salutation { get; set; }
    private final Case caseRecord;
    
    public AdditionalFunctions(ApexPages.StandardController controller) {
            this.caseRecord = (Case)controller.getRecord();
    }
    
    public List<SelectOption> getSalutationOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- Select --'));
        options.add(new SelectOption('Mr.', 'Mr.'));
        options.add(new SelectOption('Ms.', 'Ms.'));
        options.add(new SelectOption('Dr.', 'Dr.'));
        return options;
    }
}