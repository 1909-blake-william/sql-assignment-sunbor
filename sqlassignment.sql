--1.0 Setting up Oracle Chinook
--In this section you will begin the process of working with the Oracle Chinook database
--Task – Open the Chinook_Oracle.sql file and execute the scripts within.
--2.0 SQL Queries
--In this section you will be performing various queries against the Oracle Chinook database.
--2.1 SELECT
--Task – Select all records from the Employee table.
SELECT * FROM employee;
--Task – Select all records from the Employee table where last name is King.
SELECT * FROM employee WHERE lastname = 'King';
--Task – Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
SELECT * FROM employee WHERE firstname = 'Andrew' AND reportsto IS NULL;
--2.2 ORDER BY
--Task – Select all albums in Album table and sort result set in descending order by title.
SELECT * FROM album ORDER BY title DESC;
--Task – Select first name from Customer and sort result set in ascending order by city
SELECT firstname FROM customer ORDER BY city ASC;
--2.3 INSERT INTO
--Task – Insert two new records into Genre table
INSERT INTO genre (genreid, name)
    VALUES (26, 'Farm Animals');
INSERT INTO genre (genreid, name)
    VALUES (27, 'Snoring');
--Task – Insert two new records into Employee table
INSERT INTO employee (employeeid, lastname, firstname, title, reportsto, birthdate, hiredate, address, city, state, country, postalcode, phone, fax, email)
    VALUES (9, 'Robertson', 'Bob', 'Turtle Trainer', 8, '01-MAR-2050', '04-DEC-2040', 'Behind you', 'Gotham', 'ZZ', 'USSR', 'What the', '1 (123) 123-1234', '2 (903) 999-9999', 'bob@chinookcorp.com');
INSERT INTO employee (employeeid, lastname, firstname, title, reportsto, birthdate, hiredate, address, city, state, country, postalcode, phone, fax, email)
    VALUES (10, 'Bobson', 'Robert', 'Disk Farmer', 9, '28-FEB-2000', '30-JUN-2010', '11730 Plaza America Dr. 2nd Floor', 'Reston', 'VA', 'United States', 'Still nope', '2 (984) 819-8777', '8 (848) 984-5419', 'rob@chinookcorp.com');
--Task – Insert two new records into Customer table
INSERT INTO customer (customerid, firstname, lastname, company, address, city, state, country, postalcode, phone, fax, email, supportrepid)
    VALUES (60, 'oh', 'wow', 'there', 'are', 'so', 'many', 'fields', 'there', 'are', 'still', 'more', 9);
INSERT INTO customer (customerid, firstname, lastname, company, address, city, state, country, postalcode, phone, fax, email, supportrepid)
    VALUES (61, 'Boris', 'Sun', 'Revature', 'somewhere', 'Herndon', 'VA', 'United States', 'dont know', '1234567890', '0987654321', 'boris@boris.com', 9);
--2.4 UPDATE
--Task – Update Aaron Mitchell in Customer table to Robert Walter
UPDATE customer SET firstname = 'Robert', lastname = 'Walter' 
    WHERE customerid IN (SELECT customerid FROM customer WHERE firstname = 'Aaron' AND lastname = 'Mitchell');
--Task – Update name of artist in the Artist table “Creedence Clearwater Revival” to “CCR”
UPDATE artist SET name = 'CCR' WHERE name = 'Creedence Clearwater Revival';
--2.5 LIKE
--Task – Select all invoices with a billing address like “T%”
SELECT * FROM invoice WHERE billingaddress LIKE 'T%';
--2.6 BETWEEN
--Task – Select all invoices that have a total between 15 and 50
SELECT * FROM invoice WHERE total BETWEEN 15 AND 50;
--Task – Select all employees hired between 1st of June 2003 and 1st of March 2004
SELECT * FROM employee WHERE hiredate BETWEEN '01-JUN-2003' AND '01-MAR-2004';
--2.7 DELETE
--Task – Delete a record in Customer table where the name is Robert Walter (There may be constraints that rely on this, find out how to resolve them).
DELETE FROM invoiceline WHERE invoiceid IN 
    (SELECT invoiceid FROM invoice WHERE customerid = 
        (SELECT customerid FROM customer WHERE  firstname = 'Robert' AND lastname = 'Walter'));
DELETE FROM invoice WHERE customerid = (SELECT customerid FROM customer WHERE firstname = 'Robert' AND lastname = 'Walter');
DELETE FROM customer WHERE firstname = 'Robert' AND lastname = 'Walter';
--
--3.0 SQL Functions
--In this section you will be using the Oracle system functions, as well as your own functions, to perform various actions against the database
--3.1 System Defined Functions
--Task – Create a function that returns the current time.

CREATE OR REPLACE FUNCTION get_current_time
RETURN timestamp
IS
the_time timestamp;
BEGIN
    SELECT CURRENT_TIMESTAMP INTO the_time FROM dual;
    RETURN the_time;
END;

SELECT get_current_time FROM dual;

CREATE OR REPLACE FUNCTION do_something (a_parameter IN number)
RETURN varchar2
IS
a_variable varchar2(200);
BEGIN
    SELECT title INTO a_variable FROM album
    WHERE albumid = a_parameter;
    RETURN a_variable;
END;

SELECT do_something (1) FROM dual;

SELECT title FROM album WHERE artistid = 1;
--Task – create a function that returns the length of a mediatype from the mediatype table
CREATE OR REPLACE FUNCTION get_mediatype_length (media_type_id IN number)
RETURN number
IS
mediatype_length number;
BEGIN
    SELECT length(name) INTO mediatype_length FROM mediatype WHERE mediatypeid = media_type_id;
    RETURN mediatype_length;
END;

SELECT get_mediatype_length(1) FROM dual;

--3.2 System Defined Aggregate Functions
--Task – Create a function that returns the average total of all invoices
CREATE OR REPLACE FUNCTION get_invoice_avg_total
RETURN  number
IS
average number;
BEGIN
    SELECT AVG(total) INTO average FROM invoice;
    RETURN average;
END;

SELECT get_invoice_avg_total from dual;
--Task – Create a function that returns the most expensive track
--CREATE OR REPLACE FUNCTION dontevenknow
--RETURN sys_refcursor
--IS
--augh sys_refcursor;
--BEGIN
--    --OPEN augh FOR SELECT name FROM track WHERE trackid=1;
--    OPEN augh FOR SELECT * FROM track WHERE unitprice=(SELECT MAX(unitprice) FROM track);
--    RETURN augh;
--END;
--
--SELECT dontevenknow from dual;

DROP TYPE bad_record;
DROP TYPE bad_table;

CREATE OR REPLACE TYPE bad_record AS OBJECT(
    TrackId NUMBER,
    Name VARCHAR2(200),
    AlbumId NUMBER,
    MediaTypeId NUMBER,
    GenreId NUMBER,
    Composer VARCHAR2(220),
    Milliseconds NUMBER,
    Bytes NUMBER,
    UnitPrice NUMBER(10,2)
);
CREATE OR REPLACE TYPE bad_table AS TABLE of bad_record;
CREATE OR REPLACE FUNCTION bad_function
RETURN bad_table
IS
worse_table bad_table;
BEGIN
    SELECT bad_record(trackid, name, albumid, mediatypeid, genreid, composer, milliseconds, bytes, unitprice)
    BULK COLLECT INTO worse_table FROM track WHERE unitprice=(SELECT MAX(unitprice) FROM track);
    RETURN worse_table;
END;

SELECT * FROM TABLE(bad_function);
--3.3 User Defined Scalar Functions
--Task – Create a function that returns the average price of invoiceline items in the invoiceline table
CREATE OR REPLACE FUNCTION avg_invoiceline_price
RETURN number
IS
avg_price number;
BEGIN
    SELECT AVG(unitprice) INTO avg_price FROM invoiceline;
    RETURN avg_price;
END;
SELECT avg_invoiceline_price FROM dual;
--3.4 User Defined Table Valued Functions
--Task – Create a function that returns all employees who are born after 1968.
DROP TYPE bad_employee_record;
DROP TYPE bad_employee_table;
CREATE OR REPLACE TYPE bad_employee_record AS OBJECT (
    EmployeeId NUMBER,
    LastName VARCHAR2(20),
    FirstName VARCHAR2(20),
    Title VARCHAR2(30),
    ReportsTo NUMBER,
    BirthDate DATE,
    HireDate DATE,
    Address VARCHAR2(70),
    City VARCHAR2(40),
    State VARCHAR2(40),
    Country VARCHAR2(40),
    PostalCode VARCHAR2(10),
    Phone VARCHAR2(24),
    Fax VARCHAR2(24),
    Email VARCHAR2(60)
);
CREATE OR REPLACE TYPE bad_employee_table AS TABLE OF bad_employee_record;
CREATE OR REPLACE FUNCTION bad_employee_function
RETURN bad_employee_table
IS
worse_employee_table bad_employee_table;
BEGIN
    SELECT bad_employee_record(employeeid, lastname, firstname, title, reportsto, birthdate, hiredate, address, city, state, country, postalcode, phone, fax, email)
    BULK COLLECT INTO worse_employee_table FROM employee WHERE birthdate > '31-DEC-1968';
    RETURN worse_employee_table;
END;

SELECT * FROM TABLE(bad_employee_function);
--4.0 Stored Procedures
-- In this section you will be creating and executing stored procedures. You will be creating various types of stored procedures that take input and output parameters.
--4.1 Basic Stored Procedure
--Task – Create a stored procedure that selects the first and last names of all the employees.
CREATE OR REPLACE PROCEDURE get_employee_names
(results OUT SYS_REFCURSOR)
IS
BEGIN
    OPEN results FOR SELECT firstname, lastname FROM employee;
END get_employee_names;

SET SERVEROUTPUT ON;
DECLARE
    results SYS_REFCURSOR;
    firstname VARCHAR2(100);
    lastname VARCHAR2(100);
BEGIN
    get_employee_names(results);
    LOOP
        FETCH results INTO firstname, lastname;
        EXIT WHEN results%notfound;
        dbms_output.put_line(firstname || ' ' || lastname);
    END LOOP;
END;
--4.2 Stored Procedure Input Parameters
--Task – Create a stored procedure that updates the personal information of an employee.
CREATE OR REPLACE PROCEDURE update_employee
(   EmployeeI IN NUMBER,
    LastNam IN VARCHAR2,
    FirstNam IN VARCHAR2,
    Titl IN VARCHAR2,
    ReportsT IN NUMBER,
    BirthDat IN DATE,
    HireDat IN DATE,
    Addres IN VARCHAR2,
    Cit IN VARCHAR2,
    Stat IN VARCHAR2,
    Countr IN VARCHAR2,
    PostalCod IN VARCHAR2,
    Phon IN VARCHAR2,
    Fa IN VARCHAR2,
    Emai IN VARCHAR2
)
IS
BEGIN
    UPDATE employee SET
    lastname = lastnam,
    firstname = firstnam,
    title = titl,
    reportsto = reportst,
    birthdate = birthdat,
    hiredate = hiredat,
    address = addres,
    city = cit,
    state = stat,
    country = countr,
    postalcode = postalcod,
    phone = phon,
    fax = fa,
    email = emai
    WHERE employeeid = employeei;
END;
BEGIN
    update_employee(10, 'bobso', 'rober', 'disk farme', 8, '27-FEB-00', '29-JUN-10', '11730 Plaza America Dr. 2nd Floo', 'Resto', 'V', 'United Stat', 'a', 'a', 'a', 'a');
END;
    
--Task – Create a stored procedure that returns the managers of an employee.
/*CREATE OR REPLACE PROCEDURE get_manager(
underling_id IN NUMBER,
boss_id IN NUMBER
)
IS
BEGIN
    SELECT reportsto INTO boss_id FROM employee WHERE employeeid = underling_id;
END;
*/
--i quit
--4.3 Stored Procedure Output Parameters
--Task – Create a stored procedure that returns the name and company of a customer.
--6.0 Triggers
--In this section you will create various kinds of triggers that work when certain DML statements are executed on a table.
--6.1 AFTER/FOR
--Task - Create an after insert trigger on the employee table fired after a new record is inserted into the table.
--Task – Create an after update trigger on the album table that fires after a row is inserted in the table
--Task – Create an after delete trigger on the customer table that fires after a row is deleted from the table.
--Task – Create a trigger that restricts the deletion of any invoice that is priced over 50 dollars.
--7.0 JOINS
--In this section you will be working with combing various tables through the use of joins. You will work with outer, inner, right, left, cross, and self joins.
--7.1 INNER
--Task – Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.
SELECT lastname, firstname, invoiceid FROM customer c INNER JOIN invoice i ON (c.customerid = i.customerid);
--7.2 OUTER
--Task – Create an outer join that joins the customer and invoice table, specifying the CustomerId, firstname, lastname, invoiceId, and total.
SELECT c.customerid, firstname, lastname, invoiceid, total FROM customer c LEFT OUTER JOIN invoice i ON (c.customerid = i.customerid);
--7.3 RIGHT
--Task – Create a right join that joins album and artist specifying artist name and title.
SELECT name, title FROM album l RIGHT JOIN artist r ON (l.artistid = r.artistid);
--7.4 CROSS
--Task – Create a cross join that joins album and artist and sorts by artist name in ascending order.
SELECT * FROM album l CROSS JOIN artist r ORDER BY name ASC;
--7.5 SELF
--Task – Perform a self-join on the employee table, joining on the reportsto column.
SELECT u.firstname, u.lastname, b.firstname, b.lastname FROM employee u LEFT JOIN employee b ON(u.reportsto = b.employeeid);
--
--14
--
--
