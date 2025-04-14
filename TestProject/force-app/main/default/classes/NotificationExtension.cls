public with sharing class NotificationExtension {
    private final Notification__c notiRecord;
    public List<NotificationWrapper> finalList { get; set; }
    public String selectedNotiId { get; set; }
    
    public NotificationExtension(ApexPages.StandardController controller) {
        this.notiRecord = (Notification__c)controller.getRecord();
        finalList = getSortedNotifications();
    }
    
    public List<NotificationWrapper> getSortedNotifications(){
        List<NotificationWrapper> sortedList = new List<NotificationWrapper>();
        List<Notification__c> notiList = [SELECT Id, Title__c, Body__c, Pin__c, ViewPublishedOn__c FROM Notification__c WHERE OwnerId = :UserInfo.getUserId()];
        List<Notification__c> pinned = new List<Notification__c>();
        List<Notification__c> unpinned = new List<Notification__c>();
        
        for (Notification__c noti : notiList) {
            if (noti.Pin__c) {
                pinned.add(noti);
            } else {
                unpinned.add(noti);
            }
        }
        
        helperFunc(pinned);
        helperFunc(unpinned);
        pinned.addAll(unpinned);
        System.debug('this function is called');
        
        for (Notification__c noti : pinned) {
            sortedList.add(new NotificationWrapper(noti));
        }
        
        
        return sortedList;
    }
    
    public class NotificationWrapper {
        public Notification__c noti { get; set; }
        public String formattedDate { get; set; }
        
        public NotificationWrapper(Notification__c noti) {
            this.noti = noti;
            
            if (noti.ViewPublishedOn__c != null) {
                DateTime dt = DateTime.newInstance(noti.ViewPublishedOn__c, Time.newInstance(0, 0, 0, 0));
                this.formattedDate = dt.format('yyyy/MM');
            } else {
                this.formattedDate = '';
            }
        }
    }
    
    private void helperFunc(List<Notification__c> pinList){
        for (Integer i = 0; i < pinList.size(); i++) {
            for (Integer j = i + 1; j < pinList.size(); j++) {
                if (pinList[j].ViewPublishedOn__c > pinList[i].ViewPublishedOn__c) {
                    Notification__c temp = pinList[i];
                    pinList[i] = pinList[j];
                    pinList[j] = temp;
                }
            }
        }
    }
    
    @RemoteAction
    public static void updateNotification(String notiId){
        NotificationStatus__c newNotiStatus = new NotificationStatus__c();
        newNotiStatus.IsRead__c = true;
        newNotiStatus.OwnerId = UserInfo.getUserId();
        newNotiStatus.Notification__c = notiId;
        upsert newNotiStatus;
    }
    
    public void toggleBookmark() {
        Notification__c newNotiStatus = new Notification__c();
        newNotiStatus.Id = selectedNotiId;
        newNotiStatus.Pin__c = true;
        update newNotiStatus;
    }
}