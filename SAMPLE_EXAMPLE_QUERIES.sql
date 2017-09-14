Display employees where name starts with S and ends with H
----------------------------------------------------------
SQL> select ename from emp 
		where ename like 'S%H'; 

Display emp no.,name,gross sal (sal+40% on salary)
--------------------------------------------------
SQL> select empno,ename,sal+0.40*sal grosssal from emp;

Display emp no.,name,job of employees where the job contains letters P&R
------------------------------------------------------------------------
SQL>select empno,ename,job from emp 
	where ename like'%P%' and ename like '%R%'; 

Display details of employees who joined during 1982 and drawn more than 3000
----------------------------------------------------------------------------
SQL> select * from emp 
	where hiredate between '01-jan-1982' and '31-dec-1982' and sal > 3000        

Display dept no.,empname,hiredate and salary in the ascending order by dept and hire date then the descending order of sal
--------------------------------------------------------------------------------------------------------------------------
SQL> select deptno,ename,hiredate,sal from emp 
	order by deptno,hiredate,sal desc;   

Display employees where salary is less than 3000 and job is manager in the ascending order of hire date
-------------------------------------------------------------------------------------------------------
SQL> select * from emp 
	where job='manager' and sal > 3000 order by hiredate 

Display the softwares that are loaded in last 3 days
----------------------------------------------------
SQL> select * from softwares  
	where sysdate-dl < 3;

Display sid,dp and date of expiry of warranty
---------------------------------------------
SQL> select sid,dp,add_months(dp,wperiod) from systems;

Display details of softwares by rounding the space occupied to GB
-----------------------------------------------------------------
SQL> select sid,round(space/1024) from softwares; 

Display software date of loading and date on which the request was made assuming the software is loaded the nextday of request and date of verification assuming all softwares are verified on saturday
------------------------------------------------------------------------------------------------------------------------------------------
SQL> select dl-1 requestdate, next_day(dl,'sat') verificationdate from softwares;

Display software date of loading, number of months since loading, space occupied for all softwares that were loaded in last 6 months
------------------------------------------------------------------------------------------------------------------------------------
SQL> select dl, months_between(sysdate,dl) Months from softwares
				where months_between(sysdate,dl) <= 6

Change date of purchase for system 150 to previous monday
---------------------------------------------------------
SQL> update systems set dp = next_day(dp-8,'mon')
					where sid = 150;

Delete software called 'NAV' if it was loaded more than 120 days back
---------------------------------------------------------------------
SQL> delete from softwares where software  = 'NAV'
				and sysdate-dl > 120;    

Display the systems we purchase in the current year
---------------------------------------------------
SQL> Select * from systems
	where to_char(sysdate,'yyyy') = to_char(dp,'yyyy'); 

Display sid,brand, processor,ram ,hdd for systems that contain XP operating system and the price of ram in the system is more than 1000 price is calculated as 750 for each 128 mB
------------------------------------------------------------------------------------------------------------------------------------------------
SQL> select sid,brand ,processor,ram,hdd,osystems from systems 
			where os like '%xp%' and ram/128 * 750 > 1000; 

Display the softwares that are loaded on sunday in the current month
--------------------------------------------------------------------
SQL> select sid from softwares 
			where to_char(dl,'mm') = to_char(sysdate,'mm') and to_char(dl,'d') = 1

Display sid,company name and model
----------------------------------
SQL> select sid, substr(brand,instr(brand,' ')-1) company, substr(brand,instr(brand,' ') +1) model from systems;   

Display the softwares that occupy more than 1 GB and software is containing the word 'Anti'
-------------------------------------------------------------------------------------------
SQL> select scode,sum(space) from softwares_master sm,softwares s 
     where software like '%Anti%'
     group by s.scode
     having sum(space) > 1024 

Display vid,no. of systems purchased from vendor
------------------------------------------------
SQL> select vid,count(*) from systems group by vid;

Display year and no.of systems purchased from vendor
----------------------------------------------------
SQL> select to_char(dp,'yyyy'), count(*) from systems 
     group by to_char(dp,'yyyy');

Display the avg space occupied by vs and also the no. of systems containing vs
------------------------------------------------------------------------------
SQL> select count(*) Count,avg(space) AvgSpace from softwares 
      						where scode='vs'; 

Display sid,total no. of softwares,size of largest software
-----------------------------------------------------------
SQL> select sid,count(*) nosoftwares,max(space) largest_software from softwares 
     group by sid;            

Display vid,processor and no. of systems we purchase
----------------------------------------------------
SQL> select vid,proceesor,count(*) from systems 
     group by vid,processor ;   

Display sid,the date on which most recent software was loaded
-------------------------------------------------------------
SQL> select sid,max(dl) from softwares
     group by sid;
  
Display the vendor who supplied more than  1 system in a current month                               
----------------------------------------------------------------------
SQL> select vid from systems
	where to_char(sysdate,'mmyy') = to_char(dp,'mmyy')
    group by vid
    having count(*) > 1

Display the day on which most recent software was loaded into machine 3   
-----------------------------------------------------------------------
SQL> select to_char(max(dl),'day') from softwares 
					where sid=3;  

Display sid,brand,software,space for all systems with processor 'p4'
--------------------------------------------------------------------
SQL> select s.sid,brand,scode, space from systems s,softwares so
				where processor ='p4' and s.sid = so.sid;

Display vid,component and no. of  units 
---------------------------------------
SQL> select vid,component,count(*)from  components
				group by vid,component;

Display vname, no. of components supplied in this week 
------------------------------------------------------
SQL>select  v.vname,count(*) from vendors v, components c
	where  v.vid = c.vid and dp >=next_day(sysdate-7,'mon')  
    group by vname; 

Display sid,processor,ram and vname for systems which still have warranty 
-------------------------------------------------------------------------
SQL> select sid,processor,ram,vname from systems s, vendors v
	where  add_months(dp,wperiod) > sysdate and  s.vid  = v.vid;
 
Display sid and total no. of softwares,space of software should include space of os
space of os is taken as  -  XP: 1GB, 2000 server:1.3GB,Win 98:400MB,500MB others   
-----------------------------------------------------------------------------------
SQL> select so.sid, sum(space)+ max( decode(os,'winxp',1024,'win2000',1.3*1024,'win98',400,500)) space from softwares so,systems s  
	where s.sid=so.sid 
     group by so.sid;


Display OS and no .of systems with that operating systems and date on which system with os 
was most recently purchased                                                                                                                      
------------------------------------------------------------------------------------------
SQL> select os,count(*),max(dp) from systems
     group by os;

Display systems purchased from vendor who deals with wipro  
----------------------------------------------------------
SQL> select * from systems where sid in (select vid from vendors
					 where remarks like '%WIPRO%');

Display details of vendors who supplied a systems in current year
-----------------------------------------------------------------
SQL> select * from vendors
		 where vid in(select vid from systems where to_char(sysdate,'yyyy') = to_char(dp,'yyyy') ); 
                   

Display softwares loaded into systems that was purchased in current month and of brand IBM 
------------------------------------------------------------------------------------------
SQL> select * from softwares 
	where sid in(select sid from systems where brand='IBM' and to_char(dp,'mmyy')=to_char(sysdate,'mmyy') );


Delete details of components related to any systems for which warranty period expired
-------------------------------------------------------------------------------------
SQL> delete from components 
	where sid in( select sid from systems  where  Add_months(dp + wperiod) < sysdate) 
                                                                                                   
change the space occupied by vs.net in all systems to the avg space occupied by vs.net     
--------------------------------------------------------------------------------------
SQL> update softwares
      set space=(select avg(space) from softwares where scode='vs.net')
   	where scode='vs.net';                                                                                                                          
insert into components with the following details : Component is 'modem', make is 'Dlink',vendor is 'computer needs', dp is '1 st day of current month',system was the one that was purchased is last day of previous month    
------------------------------------------------------------------------------------------------------------------------------------------------
SQL> Insert into components values((select sid from systems where trunc(dp)=trunc(last_day(add_months(sysdate,-1)))),'Modem','Dlink',(select vid 	from vendors 
		where vname='computer needs'), '1-' || to_char(sysdate,'mon-yy'),12);
 

Display the systems into which we haven't installed any software in the last 30 days                  
------------------------------------------------------------------------------------
SQL> select * from systems 
	where sid not in (select sid from softwares where sysdate-dl <= 30);

Display the details of vendors who have supplied either a component or the system in the current month
------------------------------------------------------------------------------------------------------
SQL> select * from vendors 
	where vid in(select vid from systems where  to_char(sysdate,'mmyy')=to_char(dp,'mmyy') 
	union select vid from components where  to_char(sysdate,'mmyy')=to_char(dp,'mmyy'));

Display details of vendors who have supplied max .no.of systems         
---------------------------------------------------------------
SQL> select * from vendors 
	where vid in (select vid from systems group by vid having count(*)=(select max( count(*)) from systems group by vid));

Display the vendors who  supplied more than 1 unit of a component                                               
-----------------------------------------------------------------
SQL> select * from vendors 
	where vid in(select vid from components group by vid, component having count(*) > 1);   

Display the systems which contain any components or which contain more than 3 softwares and the system was purchased in the current month            -----------------------------------------------------------------------------------------------------------------------------------------            SQL> select * from systems 
	where to_char(dp,'mmyy')=to_char(sysdate,'mmyy') 
	and 
	sid in (select sid from components) 
	or 
	sid in (select sid from softwares group by sid having count(*)>3);