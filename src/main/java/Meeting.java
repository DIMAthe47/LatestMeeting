import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

import lombok.Data;
import lombok.EqualsAndHashCode;

import javax.persistence.*;
import java.util.Date;

@Entity
@Table(schema = "public", name = "meetings")
@Data
@EqualsAndHashCode(callSuper = false)
public class Meeting {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "meeting_id")
    private Long meetingId;

    @Column(name = "meeting_date")
    private Date meetingDate;

    @Column(name = "attendee_id")
    private Long attendeeId;

}
