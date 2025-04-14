public class ExternalSearch {
    public static HttpResponse search() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.example.com/search');
        req.setMethod('GET');
        
        try {
            Http http = new Http();
            return http.send(req);
        } catch (Exception e) {
            //  System.debug('Exception occurred: ' + e.getMessage());
            return null;
        }
    }
}