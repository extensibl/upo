table h : { Title : string, Bogosity : int }
  PRIMARY KEY Title

val show_h : show {Title : string} = mkShow (fn r => r.Title)

table a : { Company : string, EmployeeId : int, Awesome : bool }
  PRIMARY KEY (Company, EmployeeId)

val show_a : show {Company : string, EmployeeId : int} =
    mkShow (fn r => r.Company ^ " #" ^ show r.EmployeeId)

table time : { When : time, Description : string }
  PRIMARY KEY When

val show_time : show {When : time} = mkShow (fn r => timef "%H:%M" r.When)
val eq_time : eq {When : time} = Record.equal

structure S = MeetingGrid.Make(struct
                                   val home = h
                                   val away = a
                                   val time = time
                               end)

val main =
    fg <- S.FullGrid.create;
    return <xml><body>
      {S.FullGrid.render fg}
    </body></xml>

task initialize = fn () =>
     doNothing <- oneRowE1 (SELECT COUNT( * ) > 0
                            FROM h);
     if doNothing then
         return ()
     else
         dml (INSERT INTO h (Title, Bogosity) VALUES ('A', 1));
         dml (INSERT INTO h (Title, Bogosity) VALUES ('B', 2));
         dml (INSERT INTO h (Title, Bogosity) VALUES ('C', 3));

         dml (INSERT INTO a (Company, EmployeeId, Awesome) VALUES ('Weyland-Yutani', 1, TRUE));
         dml (INSERT INTO a (Company, EmployeeId, Awesome) VALUES ('Weyland-Yutani', 2, FALSE));
         dml (INSERT INTO a (Company, EmployeeId, Awesome) VALUES ('Massive Dynamic', 1, FALSE));

         dml (INSERT INTO time (When, Description) VALUES ({[readError '2014-12-25 11:00:00']}, 'eleven'));
         dml (INSERT INTO time (When, Description) VALUES ({[readError '2014-12-25 11:30:00']}, 'eleven-thirty'));
         dml (INSERT INTO time (When, Description) VALUES ({[readError '2014-12-25 12:00:00']}, 'noon'));

         S.addMeeting {Title = 'A', Company = 'Weyland-Yutani', EmployeeId = 1, When = readError '2014-12-25 11:00:00'}