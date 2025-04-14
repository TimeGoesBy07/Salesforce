public with sharing class OOPTest {
    public interface Human {
        void MorningActivities();
    }
    
    public class Kid implements Human {
        public void MorningActivities() {
            System.debug('Play catch');
        }
    }
    
    public virtual class Man implements Human {
        public virtual void MorningActivities() {
            System.debug('Do something');
        }

        public void NightActivities() {
            System.debug('Sleep');
        }
    }
    
    public class Teacher extends Man {
        public override void MorningActivities() {
            System.debug('Homework');
        }
        
        public void AfternoonActivities() {
            System.debug('Teach class');
        }
    }
    
    public static void exampleTest() {
        Kid kidInstance = new Kid();
        kidInstance.MorningActivities(); 
        
        Man manInstance = new Man();
        manInstance.MorningActivities(); 
        
        Teacher teacherInstance = new Teacher();
        teacherInstance.MorningActivities(); 
        teacherInstance.AfternoonActivities(); 
        teacherInstance.NightActivities();
    }
}