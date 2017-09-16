create table meetings
(
	meeting_id bigserial not null
		constraint meeting_pk
			primary key,
	meeting_date timestamp,
	attendee_id serial not null
)
;

