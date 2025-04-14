public class TestFactory {
    public static User generateUser(String profileName) {
        Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        return new User(
            ProfileId = profile.Id,
        FirstName = 'Test',
        LastName = 'User',
        Email = 'testuser@example.com',
        Username = 'testuser@example.com' + System.currentTimeMillis(),
        Alias = 'tuser',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        TimeZoneSidKey = 'America/Los_Angeles'
            );
    }
}