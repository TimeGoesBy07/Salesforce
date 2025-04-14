public with sharing class StringListTest {
    public static List<String> generateStringList(Integer NoOfString) {
        List<String> result = new List<String>();
        
        for(Integer a = 0; a < NoOfString; a++)
            result.add('Test ' + a);
        
        return result;
    }
    
    public static void main(){
        System.debug(generateStringList(5));
    }
}