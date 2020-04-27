
st serveroutput on;
create or replace package course_project as
    procedure popular_subject(in_term course_selections.term%type,  in_year course_selections.year%type);
    procedure popular_teacher(in_term course_sections.term%type,  in_year course_sections.year%type, in_ders course_sections.ders_kod%type);
    procedure calculate_gpa(in_term course_selections.term%type,  in_year course_selections.year%type);
    procedure zero_reg(in_term course_selections.term%type,  in_year course_selections.year%type);
    procedure retake_fee(in_term course_selections.term%type,  in_year course_selections.year%type);
    procedure calculate_loading(in_year course_sections.year%type);
    procedure stud_schedule(in_year course_selections.year%type);
    procedure teacher_schedule(in_year course_selections.year%type);
    procedure count_subjects;
    procedure student_flow;
    procedure teacher_rating;
    procedure course_rating;
    function retake_fee return number;
end;


CREATE OR REPLACE PACKAGE BODY course_project is

procedure popular_subject(in_term course_selections.term%type,  in_year course_selections.year%type)
is
    prev number(8) := 1;  
    r_ders course_selections.ders_kod%type;
    r_num number(8);
    
    cursor c1 is select ders_kod, count(stud_id) cnt from course_selections
                     where term = in_term and year = '01-APR-16 12:00:00 AM'
                     group by ders_kod
                     order by count(stud_id) desc;

begin
     open c1;
     loop
        fetch c1 into r_ders, r_num;
        dbms_output.put_line('The most poopular course is: ' || r_ders || ' with ' || r_num || ' students selected');
        prev := prev -1;
        exit when c1%notfound or prev = 0;
     end loop;
end;


procedure popular_teacher(in_term course_sections.term%type,  in_year course_sections.year%type, in_ders course_sections.ders_kod%type)
is
    r_emp course_sections.emp_id%type;
    r_num number(8);
    prev number(8) := 1;  
    cursor c1 is select  emp_id, count(DERS_KOD)  from course_sections
                where year = in_year and term = in_term and DERS_KOD = in_ders
                group by emp_id
                order by count(DERS_KOD) desc;
begin
     open c1;
     loop
        fetch c1 into r_emp, r_num;
        dbms_output.put_line('The most poopular teacher is: ' || r_emp || ' with ' || r_num || ' courses');
        prev := prev -1;
        exit when c1%notfound or prev = 0;
     end loop;
end;
                

procedure calculate_gpa(in_term course_selections.term%type,  in_year course_selections.year%type)
is
    cursor c1 is
        select sum(QIYMET_YUZ*3)/sum(3), stud_id from course_selections 
        group by stud_id;
    r_gpa number(4);
    r_stud course_selections.stud_id%type;
begin
     open c1;
     loop
        fetch c1 into r_gpa, r_stud;
            case
                when r_gpa between 95 and 100 then dbms_output.put_line('gpa is '  || 4 || ' for ' || ' ' || r_stud);
                when r_gpa between 90 and 94 then dbms_output.put_line('gpa is '  || 3.67 || ' for ' || ' ' || r_stud);
                when r_gpa between 85 and 89 then dbms_output.put_line('gpa is '  || 3.33	 || ' for ' || ' ' || r_stud);
                when r_gpa between 80 and 84 then dbms_output.put_line('gpa is '  || 3 || ' for ' || ' ' || r_stud);
                when r_gpa between 75 and 79 then dbms_output.put_line('gpa is '  || 2.67 || ' for ' || ' ' || r_stud);
                else dbms_output.put_line('gpa is '  || 2 || ' for ' || ' ' || r_stud);
            end case;
        exit when c1%notfound;
     end loop;
end;


procedure zero_reg(in_term course_selections.term%type,  in_year course_selections.year%type)
is cursor c1 is
                select stud_id from course_selections
                having count(ders_kod) < 1
                group by stud_id;
    r_stud course_selections.stud_id%type;
begin
     open c1;
     loop
        fetch c1 into r_stud;
        dbms_output.put_line(r_stud);
        exit when c1%notfound;
     end loop;
end;


procedure retake_fee(in_term course_selections.term%type,  in_year course_selections.year%type)
is
    cursor c1 is
                select a.stud_id,a.ders_kod, count( distinct a.ders_kod) from course_selections a inner join Course_sections b  on (a.ders_kod = b.ders_kod)
                where QIYMET_HERF = 'F' and a.year = in_year and a.term = in_term
                group by a.stud_id, a.ders_kod;
    r_stud course_selections.stud_id%type;
    r_ders course_selections.ders_kod%type;
    r_cnt number(8);
begin
     open c1;
     loop
        fetch c1 into r_stud, r_ders, r_cnt;
        dbms_output.put_line('Spent on semester: ' || r_stud || ' ' || r_cnt * 25000 * 3);
        exit when c1%notfound;
     end loop;
end;


procedure calculate_loading(in_year course_sections.year%type)
is
    cursor c1 is
                select emp_id , sum(hour_num) from course_sections
                where year = in_year
                group by emp_id;
    r_emp course_sections.emp_id%type;
    r_cnt number(8);
begin
     open c1;
     loop
        fetch c1 into r_emp, r_cnt;
        dbms_output.put_line('Employee loading: ' || r_emp || ' ' || r_cnt);
        exit when c1%notfound;
     end loop;
end;



procedure stud_schedule(in_year course_selections.year%type)
is
    cursor c1 is
                    select ders_kod, section 
                    from course_selections
                    where stud_id = '004531EC911B9D3EF9A7C7A8524D054EA943BA3F' and term = 1 and year = '01-APR-16 12:00:00 AM';
    r_ders course_selections.ders_kod%type;
    r_section course_selections.section%type;
    r_time course_schedule."MIN(START_TIME)"%type;
begin
     open c1;
     loop
        fetch c1 into r_ders, r_section;
        dbms_output.put_line(r_ders || ' ' || r_section);
        exit when c1%notfound;
            select "MIN(START_TIME)" into r_time from course_schedule
            where ders_kod = r_ders and section = r_section;
        dbms_output.put_line('Time: ' ||  r_time);
     end loop;
end;


procedure teacher_schedule(in_year course_selections.year%type)
is
    cursor c1 is
                    select ders_kod, section 
                    from course_sections
                    where emp_id = '10166' and term = 1 and year = '01-APR-16 12:00:00 AM';

    r_ders course_sections.ders_kod%type;
    r_section course_sections.section%type;
    r_time course_schedule."MIN(START_TIME)"%type;
        cursor c2 is
                    select "MIN(START_TIME)" from course_schedule
                    where ders_kod = r_ders and section = r_section;
begin
     open c1;
    open c2;
     loop
        fetch c1 into r_ders, r_section;
        dbms_output.put_line(r_ders || ' ' || r_section);
        exit when c1%notfound;
        loop
            fetch c2 into r_time;
            dbms_output.put_line('Time: ' ||  nvl(r_time, '01-APR-28 12:00:00 AM'));
            exit when c2%notfound;
        end loop;
     end loop;
     close c1;
     close c2;
end;

procedure count_subjects
is
    cursor c1 is
                    select a.stud_id, count(a.ders_kod), sum(nvl(b.credits, 3))  from course_selections a inner join course_sections b on (a.ders_kod = b.ders_kod)
                    group by a.stud_id;

    r_stud course_selections.stud_id%type;
    r_cnt number(6);
    r_credits number(6);
begin
     open c1;
     loop
        fetch c1 into r_stud, r_cnt, r_credits;
        dbms_output.put_line(r_stud || ' ' || r_cnt || ' ' || r_credits);
        exit when c1%notfound;
     end loop;
     close c1;
end;

 procedure student_flow
is
    cursor c1 is
                    select ders_kod, sum(QIYMET_YUZ)/ count(QIYMET_YUZ) from course_selections
                    group by ders_kod;
    r_ders course_selections.ders_kod%type;
    r_cnt number(5);
    r_stud course_selections.stud_id%type;
    r_grade course_selections.QIYMET_YUZ%type;

        cursor c2 is
                    select stud_id, ders_kod, QIYMET_YUZ from course_selections
                    where QIYMET_YUZ > r_cnt and ders_kod = r_ders;
begin
     open c1;
    open c2;
     loop
        fetch c1 into r_ders, r_cnt;
        exit when c1%notfound;
        loop
            fetch c2 into r_stud, r_ders, r_grade ;
            dbms_output.put_line(nvl(r_stud, ' Label ') || ' course: ' || r_ders || ' grade: ' || nvl(r_grade, 70) );
            exit when c2%notfound;
        end loop;
     end loop;
     close c1;
     close c2;
end;

 
procedure teacher_rating
is
    cursor c1 is
                    select count(stud_id), ders_kod from course_selections
                    group by ders_kod
                    order by count(stud_id) desc;
    r_ders course_selections.ders_kod%type;
    r_emp course_sections.emp_id%type;
    r_cnt number(5);
    cursor c2 is    select emp_id from course_sections
                    where ders_kod = r_ders;
begin
     open c1;
     open c2;
     loop
        fetch c1 into r_cnt, r_ders;
        dbms_output.put_line(r_ders || ' ' ||  r_cnt);
        exit when c1%notfound;
        loop
            fetch c2 into r_emp;
            dbms_output.put_line(r_emp);
             exit when c2%notfound;
        end loop;
     end loop;
     close c1;
     close c2;
end;

 
procedure course_rating
is
    cursor c1 is
                    select count(stud_id), ders_kod from course_selections
                    group by ders_kod
                    order by count(stud_id) desc;
    
    r_ders course_selections.ders_kod%type;
    r_cnt number(5);
begin
     open c1;
     loop
        fetch c1 into r_cnt, r_ders;
        dbms_output.put_line(r_ders || ' ' ||  r_cnt);
        exit when c1%notfound;
     end loop;
     close c1;
end;

function retake_fee
return number is
    cursor c1 is
                select count( distinct a.ders_kod) * 25000 * 3 from course_selections a inner join Course_sections b  on (a.ders_kod = b.ders_kod)
                where QIYMET_HERF = 'F';
    r_cnt number(8);
begin
     open c1;
     loop
        fetch c1 into r_cnt;
        dbms_output.put_line('Spent on semester: ' || r_cnt);
        exit when c1%notfound;
     end loop;
     return 0;
     close c1;
end;

end;


SET AUTOCOMMIT ON; 

declare
    num number(10);
begin
    course_project.popular_subject(1, '01-APR-16 12:00:00 AM');
    course_project.popular_teacher(1, '01-APR-16 12:00:00 AM', 'ECO 101'); 
    course_project.calculate_gpa(1, '01-APR-16 12:00:00 AM'); 
    course_project.zero_reg(1, '01-APR-16 12:00:00 AM'); 
    course_project.retake_fee(1, '01-APR-16 12:00:00 AM'); 
    course_project.calculate_loading('01-APR-16 12:00:00 AM'); 
    course_project.stud_schedule('004531EC911B9D3EF9A7C7A8524D054EA943BA3F', '01-APR-16 12:00:00 AM', 1);
    course_project.teacher_schedule('01-APR-16 12:00:00 AM');
    course_project.count_subjects;
    course_project.student_flow;
    course_project.teacher_rating;
    course_project.course_rating;
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

TYPE Calendar IS VARRAY(366) OF DATE;



