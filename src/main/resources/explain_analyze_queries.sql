DELETE FROM meetings;

EXPLAIN ANALYZE SELECT * FROM meetings m1 WHERE m1.meeting_date=
                                (SELECT max(m2.meeting_date) FROM meetings m2 WHERE m2.attendee_id=m1.attendee_id);
/*
Seq Scan on meetings m1  (cost=0.00..206405564.00 rows=500 width=20) (actual time=8.696..873255.966 rows=10003 loops=1)
  Filter: (meeting_date = (SubPlan 1))
  Rows Removed by Filter: 89997
  SubPlan 1
    ->  Aggregate  (cost=2064.03..2064.04 rows=1 width=8) (actual time=8.727..8.727 rows=1 loops=100000)
          ->  Seq Scan on meetings m2  (cost=0.00..2064.00 rows=10 width=8) (actual time=0.886..8.704 rows=11 loops=100000)
                Filter: (attendee_id = m1.attendee_id)
                Rows Removed by Filter: 99989
Planning time: 0.166 ms
Execution time: 873260.878 ms

*/

EXPLAIN ANALYZE SELECT * FROM meetings m
  JOIN (SELECT attendee_id, max(meeting_date) from meetings GROUP BY attendee_id) attendee_max_date
    ON attendee_max_date.attendee_id = m.attendee_id;
/*
Hash Join  (cost=5964.00..8362.13 rows=100000 width=32) (actual time=65.263..98.608 rows=100000 loops=1)
Hash Cond: (meetings.attendee_id = m.attendee_id)
->  HashAggregate  (cost=2314.00..2412.50 rows=9850 width=12) (actual time=39.168..41.959 rows=10000 loops=1)
Group Key: meetings.attendee_id
->  Seq Scan on meetings  (cost=0.00..1814.00 rows=100000 width=12) (actual time=0.136..8.431 rows=100000 loops=1)
->  Hash  (cost=1814.00..1814.00 rows=100000 width=20) (actual time=26.057..26.057 rows=100000 loops=1)
Buckets: 8192  Batches: 2  Memory Usage: 2577kB
->  Seq Scan on meetings m  (cost=0.00..1814.00 rows=100000 width=20) (actual time=0.307..8.742 rows=100000 loops=1)
Planning time: 0.315 ms
Execution time: 103.427 ms
*/

EXPLAIN ANALYZE SELECT * FROM meetings WHERE concat(attendee_id, meeting_date)
                             IN (SELECT concat(attendee_id, max(meeting_date)) from meetings GROUP BY attendee_id);
/*
Hash Join  (cost=2564.75..5878.75 rows=50000 width=20) (actual time=60.779..206.627 rows=10003 loops=1)
Hash Cond: (concat(meetings.attendee_id, meetings.meeting_date) = (concat(meetings_1.attendee_id, max(meetings_1.meeting_date))))
->  Seq Scan on meetings  (cost=0.00..1814.00 rows=100000 width=20) (actual time=0.117..9.431 rows=100000 loops=1)
->  Hash  (cost=2562.25..2562.25 rows=200 width=32) (actual time=60.632..60.632 rows=10000 loops=1)
Buckets: 1024  Batches: 1  Memory Usage: 546kB
->  HashAggregate  (cost=2560.25..2562.25 rows=200 width=32) (actual time=56.626..58.646 rows=10000 loops=1)
Group Key: concat(meetings_1.attendee_id, max(meetings_1.meeting_date))
->  HashAggregate  (cost=2314.00..2437.13 rows=9850 width=12) (actual time=38.676..52.535 rows=10000 loops=1)
Group Key: meetings_1.attendee_id
->  Seq Scan on meetings meetings_1  (cost=0.00..1814.00 rows=100000 width=12) (actual time=0.076..8.909 rows=100000 loops=1)
Planning time: 0.256 ms
Execution time: 207.720 ms
*/

EXPLAIN ANALYZE SELECT * FROM meetings
WHERE attendee_id*65536 + date_part('epoch',meeting_date)/(60*60*24)
      IN (SELECT attendee_id*65536 + date_part('epoch',max(meeting_date))/(60*60*24) from meetings GROUP BY attendee_id);
/*
Hash Join  (cost=2663.25..6477.25 rows=50000 width=20) (actual time=59.116..126.434 rows=10003 loops=1)
Hash Cond: ((((meetings.attendee_id * 65536))::double precision + (date_part('epoch'::text, meetings.meeting_date) / 86400::double precision)) = ((((meetings_1.attendee_id * 65536))::double precision + (date_part('epoch'::text, max(meetings_1.meeting_date)) / 86400::double precision))))
->  Seq Scan on meetings  (cost=0.00..1814.00 rows=100000 width=20) (actual time=0.147..8.240 rows=100000 loops=1)
->  Hash  (cost=2660.75..2660.75 rows=200 width=8) (actual time=58.933..58.933 rows=10000 loops=1)
Buckets: 1024  Batches: 1  Memory Usage: 391kB
->  HashAggregate  (cost=2658.75..2660.75 rows=200 width=8) (actual time=56.248..57.506 rows=10000 loops=1)
Group Key: (((meetings_1.attendee_id * 65536))::double precision + (date_part('epoch'::text, max(meetings_1.meeting_date)) / 86400::double precision))
->  HashAggregate  (cost=2314.00..2535.63 rows=9850 width=12) (actual time=47.083..53.211 rows=10000 loops=1)
Group Key: meetings_1.attendee_id
->  Seq Scan on meetings meetings_1  (cost=0.00..1814.00 rows=100000 width=12) (actual time=0.098..8.336 rows=100000 loops=1)
Planning time: 0.201 ms
Execution time: 127.595 ms
*/