@isTest
private class ExternalSearchTests {
    
    // Mocking HTTP response with success (status code 200)
    private class HTTPMockFactory implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            res.setBody('{"data": "dummy data"}');
            return res;
        }
    }
    
    // Mocking HTTP response with failure (status code 500)
    private class NegativeHTTPMockFactory implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            throw new CalloutException('Mock callout failed');
        }
    }
    
    // Test method for success scenario
    @isTest
    static void testPositiveMocking() {
        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        
        HttpResponse response = ExternalSearch.search();
        
        System.assertEquals(200, response.getStatusCode());
    }
    
    // Test method for failure scenario
    @isTest
    static void testNegativeMocking() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NegativeHTTPMockFactory());
        
        HttpResponse response = ExternalSearch.search(); // This line is likely causing the NullPointerException
        
        System.debug('Response: ' + response); // Add this debug statement to see if response is null
        
        System.assertEquals(500, response.getStatusCode());
        Test.stopTest();
    }
    
    // Test method to cover catch block
    @isTest
    static void testExceptionHandling() {
        Test.startTest();
        // Set up mock HTTP response to simulate an exception during the callout
        Test.setMock(HttpCalloutMock.class, new NegativeHTTPMockFactory());
        
        // Call the method to be tested
        HttpResponse response;
        try {
            response = ExternalSearch.search();
        } catch (Exception e) {
            // Handling any exception that might occur within the catch block
            response = null;
        }
        
        // Verify that the catch block is executed without causing any exceptions
        System.assertEquals(null, response);
        Test.stopTest();
    }
}