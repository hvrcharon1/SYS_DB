Find out the percentage of space in system 2 was used and display a message 50% of 20 GB was used      
-------------------------------------------------------------------------------------------------
Declare 
     v_hdd systems.hdd%type;
     v_space number(5);
Begin   
     select hdd  into v_hdd from systems where sid= 2;

     select sum(space) into v_space
     from softwares where sid=2;                         
   
     dbms_output.put_line(round(v_space/(hdd*1024)*100) || '% of '|| hdd ||'GB was used');
End;



Display the space occupied by oracle in system 3 if oracle is not found you insert a row for oracle in system 3 with space 1500MB     
---------------------------------------------------------------------------------------------------------------------------------

declare
 v_space  softwares.space%type;
begin
 select  space into v_space
 from softwares where software ='oracle' and sid = 3;
 dbms_output.put_line( v_space);

exception
 when no_data_found then
   insert into softwares values (3,'oracle',1500,sysdate);
 
end;

Change the  ram from 256 to 512 for system 3 if system has softwares VS and oracle 
----------------------------------------------------------------------------------
Update systems set ram  = 512
where sid = 3 
  and exists
   ( select sid from softwares where sid = 3 and software = 'VS'
     intersect
     select sid from softwres where sid = 3 and software = 'Oracle');


Change the size of hard disk from 40 to 80, 20 to 40 if the space occupied is more than 75% 
-------------------------------------------------------------------------------------------
Declare
 cursor syscur is select sid, hdd from systems where hdd in ( 20,40);
 v_space number(6);
Begin
 for r in syscur
 loop
    -- get total space occupied
    select sum(space) into v_space
    from softwares
    where  sid = r.sid;

    if  v_space / r.hdd > 0.75 then
          update systems hdd = hdd * 2 
          where  sid = r.sid;
    end if;
 end loop;

End;




Display sid,brand for systems 10th to 15throw                                        
---------------------------------------------
Declare 
   cursor syscur  is select sid,brand from systems;
begin
   for R in syscur
   loop
      if syscur%rowcount >= 10 and syscur%rowcount<=15 then
        dbms_output.put_line(R.sid);
        dbms_output.put_line(R.brand);
        exit when  syscur%rowcount = 15
      end if;
   end loop;
end;




create a function that takes scode and returns the sysid in which the software occupies the max space 
-----------------------------------------------------------------------------------------------------
create or replace function maxspace(pscode varchar) return number
is
 psid   systems.sid%type;
begin
     select sid into psid
     from softwares
     where scode=pscode and
           space = ( select max(space)
                     from softwares
                     where scode=pscode);

     return psid;
end;   


Write a function that takes sid and returns the software loaded into the systems by seperating softwares  with comma                         
---------------------------------------------------------------------------------------------------------------------
create or replace function getsoftwares(psid number) return varchar
is
 cursor softcur is
 select scode from softwares
 where sid=psid;
 softstr varchar(100):=' ';
begin
  for r in softcur
  loop
      softstr:=softstr ||','|| r.scode;
  end loop;
  return substr(softstr,2);
end; 


create  a procedure to take sid and scode and remove the software from system and throw an error if software is not present in system
-------------------------------------------------------------------------------------------------------------------------------------

create or replace procedure removesoftware(psid number, pscode varchar2)
is
begin
   delete from softwares where sid = psid and scode = pscode;
   if sql%notfound then
      raise_application_error(-20500,'Software not found in the system');
   end if;
end;



Object Model Of Systems Database 
--------------------------------

The following is object model of Systems application that we have implemented using relational model earlier.
-------------------------------------------------------------------------------------------------------------

VENDOR_TYPE - Object type for vendors 



create  or replace  type vendor_type as object
( name  varchar2(20),
  address varchar2(50)
);
/


SOFTWARE_TYPE  - Object type for software 



create or replace type software_type as object
( software  varchar2(20),
  dl        date,
  space     number(5),
  member procedure  changespace(newspace number),
  member procedure  changedl(newdl date)
);
/

create or replace type body software_type is
  member procedure  changespace(newspace number)
  is
  begin
       space := newspace;
  end;
  member procedure  changedl(newdl date)
  is  
  begin
      if  newdl > sysdate then
          raise_application_error(-20100,'Invalid Date');
      else
          dl := newdl;
      end if;
  end;
end;
/


 SOFTARES_TABLE - table type that contains a collection of software types 



create type software_table as table of software_type;


 SYSTEM_TYPE - Object type to store information about system 



create or replace type system_type as object
(  sid  number(3),
   brand varchar2(30),
   hdd   number(3),
   dp    date,
   price number(6),
   vendor ref  vendor_type,
   softwares   software_table,
   member function GetAvailSpace return number,
   member function GetSoftwares return varchar,
   member function IsInstalled(software varchar2)  return boolean
);
/

create or replace type body system_type is

   member function GetAvailSpace return number
   is
     space number(5) :=0;
   begin
        for i in 1..softwares.count
        loop
            space := space + softwares(i).space;
        end loop;
        return ( hdd * 1024 - space);
   end;

   member function GetSoftwares return varchar
   is
      st varchar2(100) := '';
   begin
      for i in 1..softwares.count
      loop
            st := st ||  ',' || softwares(i).software ;
      end loop;
      return substr(st,2);
   end;

   member function IsInstalled(software varchar2) return boolean
   is
     
   begin
      for i in 1..softwares.count
      loop
            if softwares(i).software = software then
                 return true;
            end if;
      end loop;
      return false;

   end;

  
     
end;
/


Creating Required Object Tables and Inserted Data



create table  vendors of vendor_type;

insert into  vendors values('computer needs','Dwarakanagar, Vizag');

insert into  vendors values('computer components','Dabagaradens, Vizag');


create table systems of system_type
nested table softwares store as softwares_table;

insert into systems 
  values (1,'Compaq Presario','20','3-feb-04',55000, 
              ( select ref(v) from vendors v where name ='computer needs'),
          software_table ( software_type( 'windows xp prof','3-feb-04',1000),
                           software_type( 'VS.NET','4-feb-04',2000)
                         )
         );



insert into systems 
  values (2,'HP Pavilion','60','1-Mar-04',45000, 
              ( select ref(v) from vendors v where name ='computer needs'),
          software_table ( software_type( 'window 2003 server','1-mar-04',2500),
                           software_type( 'Oracle9i','2-mar-04',3000)
                         )
         );



Queries and DML Commands 
------------------------


select  sid,brand,s.vendor.name from systems s;

select  sid,brand,dp,round(s.GetAvailSpace() / 1024,2) || 'GB Available' AvailSpace, s.getsoftwares() from systems s;

insert into table ( select softwares from systems where sid = 2)
  values ('Oracle Client',sysdate,'30');



Stored Procedures 
------------------



create or replace  procedure  IsExisting( v_sid number, v_software varchar2) is

sysobj system_type;

begin
   select value(s) into sysobj
   from systems s
   where  sid = v_sid;

   if  sysobj.IsInstalled( v_software) then
       dbms_output.put_line( v_software || ' Is Installed');
   else
       dbms_output.put_line( v_software || ' Is NOT Installed');
   end if;
 

end;
/

