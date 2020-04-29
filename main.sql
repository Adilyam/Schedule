
SET AUTOCOMMIT ON; 

declare
    num number(10);
begin
    course_project.popular_subject(1, 2017);
    dbms_output.put_line('_________');
    course_project.popular_teacher(1, '01-APR-16 12:00:00 AM', 'ECO 101'); 
    dbms_output.put_line('_________');
    course_project.calculate_gpa(1, '01-APR-16 12:00:00 AM'); 
    dbms_output.put_line('_________');
    course_project.zero_reg(1, '01-APR-16 12:00:00 AM'); 
    dbms_output.put_line('_________');
    course_project.retake_fee(1, '01-APR-16 12:00:00 AM');
    dbms_output.put_line('_________');
    course_project.calculate_loading('01-APR-16 12:00:00 AM'); 
    dbms_output.put_line('_________');
    course_project.stud_schedule('01-APR-16 12:00:00 AM', '004531EC911B9D3EF9A7C7A8524D054EA943BA3F', 1);
    dbms_output.put_line('_________');
    course_project.teacher_schedule('01-APR-16 12:00:00 AM', '10081');
    dbms_output.put_line('_________');
    course_project.count_subjects;
    dbms_output.put_line('_________');
    course_project.student_flow;
    dbms_output.put_line('_________');
    course_project.teacher_rating;
    dbms_output.put_line('_________');
    course_project.course_rating;
    dbms_output.put_line('_________');
    num := course_project.retake_fee;
end;


CREATE OR REPLACE TRIGGER grade_changes 
BEFORE DELETE OR INSERT OR UPDATE ON course_selections 
FOR EACH ROW 
WHEN (NEW.STUD_ID is not null) 
DECLARE 
   grade_diff number; 
BEGIN 
   grade_diff := :NEW.QIYMET_YUZ  - :OLD.QIYMET_YUZ; 
   dbms_output.put_line('Old grade: ' || :OLD.QIYMET_YUZ); 
   dbms_output.put_line('New grade: ' || :NEW.QIYMET_YUZ); 
   dbms_output.put_line('Grade difference: ' || grade_diff); 
END;

update  course_selections
set QIYMET_YUZ = 84
where ders_kod = 'LAW 212' and stud_id = '004531EC911B9D3EF9A7C7A8524D054EA943BA3F'

