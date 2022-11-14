# ------------ QUESTIONS ----------

select *from products limit 10;

select productid, productname,unitsinstock from products limit 10;

select * from products order by unitsinstock desc limit 10 ;

select * from products where unitprice < 10 order by unitprice ;

select * from products where unitsinstock between 0 and 10 order by unitsinstock limit 10; 

select * from products where productname = "geitost";

select supplierid,productid, productname,discontinued from products
where supplierid in (7,9);

select * from products where productname like "%ost%";

#sp 15
select count(*) from products;

#sp 16
select count(*) as "Number of products" from products;

#sp 17
select round(avg(unitprice),3) as "Average price" from products;

#sp 18
select distinct(country) from suppliers;

#sp 20 first 10 productname and companyname for the tables products and suppliers 
# where supplierid is equal in the two tables
select productname,companyname as "supplier company" from products p, suppliers s
where p.supplierid=s.supplierid
order by 2;


#sp 21 first 10 productname and companyname for the tables products and suppliers 
# where supplierid is equal in the two tables
select productname,companyname as "supplier company" from products
join suppliers on products.supplierid=suppliers.supplierid
order by 2;

# sp 22 Three most selling employees - quantity
# first show all emp, orders and order_detail
select e.employeeid, e.lastname,e.firstname,o.orderdate,od.quantity
from employees e, orders o, order_details od
where e.employeeid=o.employeeid
and o.orderid=od.orderid
order by 1 ;

#next aggregaet
select e.employeeid, e.lastname, round(sum(od.quantity)) as "mængde solgt"
from employees e, orders o, order_details od
where e.employeeid=o.employeeid
and o.orderid=od.orderid
group by e.employeeid, e.lastname
order by 3 desc ;

# sp 22 -a  Three most selling employees - pricewise
select e.employeeid, e.lastname, round(sum(od.quantity*od.unitprice)) as "mængde solgt i kroner"
from employees e, orders o, order_details od
where e.employeeid=o.employeeid
and o.orderid=od.orderid
group by e.employeeid, e.lastname
order by 3 desc;

#sp 23 - first find all those who did place an order
select orderid, orderdate, companyname from orders
join customers on customers.customerid=orders.customerid
order by 1;

#then rightjoin and sort so NA's will show
select orderid, orderdate, companyname from orders
right join customers on customers.customerid=orders.customerid
where orderid is NULL
order by 1;

# sp 24 Most buying companies - i.e placed most orders
select companyname,count(orderid) from orders
join customers on orders.customerid=customers.customerid
group by 1
order by 2 desc;

# sp 24 Most buying companies - in terms of money paid
select companyname,round(sum(od.quantity*od.unitprice)) from orders o
join customers c on o.customerid=c.customerid
join order_details od on od.orderid=od.orderid
group by companyname
order by 2 desc;

