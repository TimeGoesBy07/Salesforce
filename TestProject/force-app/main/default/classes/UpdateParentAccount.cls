public with sharing class UpdateParentAccount implements Queueable{
    private List<Account> accList;
    private Id parentAccId;

    public UpdateParentAccount(List<Account> accList, Id accId) {
        this.accList = accList;
        this.parentAccId = accId;
    }

    public void execute(QueueableContext context) {
        for(Account a : accList){
            a.ParentId = parentAccId;
        }

        System.debug('Out: ' + accList);
        update accList;
    }
}