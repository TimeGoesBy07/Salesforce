public with sharing class RandomContactFactory {
    public static List<Contact> generateRandomContacts(Integer a, String b) {
        List<Contact> listData = new List<Contact>();
        
        for(Integer c = 0; c < a; c++)
            listData.add(new Contact(FirstName='Test '+c, LastName=b));
        
        return listData;
    }
    
    public static void main(){
        System.debug(generateRandomContacts(3,'Lee'));
    }
}