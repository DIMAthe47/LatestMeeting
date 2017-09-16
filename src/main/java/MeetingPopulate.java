import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import java.util.Date;
import java.util.Random;

public class MeetingPopulate {

    public static void main(String[] args) {
        EntityManagerFactory emf = Persistence.createEntityManagerFactory("NewPersistenceUnit");
        EntityManager em = emf.createEntityManager();

        int entitiesCount = 100000;
        int maxAttendeeId = 10000;
        int maxDateInDays = 17425;
        long daysToMillis = 24 * 60 * 60 * 1000;
        Random random = new Random();

        em.getTransaction().begin();
        for (int i = 0; i < entitiesCount; i++) {
            Meeting meeting = new Meeting();
            meeting.setAttendeeId(Long.valueOf(random.nextInt(maxAttendeeId)) + 1L);
            long nextRandomDateInMillis = random.nextInt(maxDateInDays) * daysToMillis;
            Date randomDate = new Date(nextRandomDateInMillis);
            meeting.setMeetingDate(randomDate);
            em.persist(meeting);
        }
        em.getTransaction().commit();

        em.close();
        emf.close();
    }
}
