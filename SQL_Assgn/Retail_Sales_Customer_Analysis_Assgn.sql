create database Retail_Cust_Sales;

use Retail_Cust_Sales;

create table Customers(
CustomerID int primary key,
CustomerName varchar(50),
City varchar(50),
JoinDate date
);

insert into Customers(CustomerID,CustomerName,City ,JoinDate) 
values
	(101,"Amit Sharma","Delhi",'2022-01-10'),
    (102,"Neha Verma","Mumbai",'2022-03-15'),
	(103,'Rahul Mehta','Bangalore','2022-05-01'),
    (104,'Priya Singh','Delhi','2023-01-12'),
    (105,'Karan Patel','Ahmedabad','2023-02-20'),
    (106,'Sneha Reddy','Hyderabad','2023-03-18'),
    (107,'Arjun Nair','Kochi','2023-04-10'),
	(108,'Pooja Gupta','Jaipur','2023-05-05');
    

create table Products(
ProductID int primary key,
ProductName varchar(50),
Category varchar(50),
Price int
);
insert into Products(ProductID,	ProductName,Category,Price)
values
	(201,'Laptop','Electronics',55000),
	(202,'Mobile','Electronics',25000),
	(203,'Tablet','Electronics',18000),
	(204,'Headphones','Accessories',2000),
	(205,'Keyboard','Accessories',1500),
	(206,'Mouse','Accessories',800),
	(207,'Monitor','Electronics',12000),
	(208,'Printer','Electronics',9000);

create table Orders(
OrderID int primary key,
CustomerID int ,
OrderDate date,
EmployeeID int,
Foreign key (CustomerID) references Customers(CustomerID),
Foreign key (EmployeeID) references Employees(EmployeeID)
);
 insert into Orders(OrderID,CustomerID,OrderDate,EmployeeID)
 values
	(301,101,'2023-01-15',401),
	(302,102,'2023-01-18',402),
	(303,103,'2023-02-05',401),
	(304,104,'2023-02-10',403),
	(305,105,'2023-03-01',404),
    (306,106,'2023-03-15',402),
	(307,107,'2023-04-01',401),
	(308,108,'2023-04-20',403);


create table OrderDetails(
OrderdetailID int,
OrderID int,
ProductID int,
Quantity int,
Foreign key (OrderID) references Orders(OrderID),
Foreign key (ProductID) references Products(ProductID)
);
insert into OrderDetails(OrderDetailID,OrderID,ProductID,Quantity)
values 
	(1,301,201,1),
	(2,301,204,2),
	(3,302,202,1),
	(4,303,203,1),
	(5,304,207,2),
	(6,305,205,3),
	(7,306,206,5),
	(8,307,208,1),
	(9,308,201,1);
    
create table Employees(
EmployeeID int primary key,
EmployeeName Varchar(50),
Department varchar(50),
HireDate date
);
 insert into Employees(EmployeeID,EmployeeName,Department,HireDate)
 values
	(401,'Rajesh Kumar','Sales','2020-02-01'),
	(402,'Meena Iyer','Sales','2021-06-15'),
	(403,'Vikram Shah','Sales','2022-09-10'),
	(404,'Anil Gupta','Sales','2023-01-05');

select *from  Customers;
select * from Products;
select * from Employees;
select * from Orders;
select * from OrderDetails;

-- 1.Display all orders with customer names
select OrderID,OrderDate,CustomerName from Customers as Cust
inner join Orders as O where cust.CustomerID = O.CustomerID;

-- 2.	Show product names and quantities for each order.
select ProductName,Quantity,OrderID from Products as Prod
inner join OrderDetails as OD where Prod.ProductID = OD.ProductID;

-- 3.	Display employee name who handled each order.
select O.OrderID,EmployeeName,emp.EmployeeID from Employees as Emp
inner join Orders as O  where Emp.EmployeeID = O.EmployeeID;

-- 4.	Show all customers and their orders (including customers without orders).
select Cust.CustomerID,Cust.CustomerName,O.OrderID from Customers as Cust
left join Orders as O on Cust.CustomerID = O.CustomerID;

-- 5.	Display total number of orders handled by each employee.
Select Emp.EmployeeName,count(O.OrderID) as Total_Orders from Employees as Emp
left join Orders as O on Emp.EmployeeID = O.EmployeeID group by Emp.EmployeeID, Emp.EmployeeName;

-- 6.	Find customers who placed more than 1 order.
select Cust.CustomerName,Cust.CustomerID, count(O.OrderID) as Total_Orders from Customers as Cust
inner join Orders as O on Cust.CustomerID = O.CustomerID group by Cust.CustomerName,Cust.CustomerID having count(O.OrderID)>1;

-- 7.	Display products with price higher than the average product price.
select Prod.Price,Prod.ProductID, Prod.ProductName from Products as Prod
where Prod.Price > (select Avg(Prod.Price) from Products as Prod);

-- 8.	Find the customer who placed the highest number of orders.
select Cust.CustomerName,Cust.CustomerID, count(O.OrderID) as Total_orders from Customers As Cust
Join Orders as O on Cust.CustomerID = O.CustomerID group by Cust.CustomerName,Cust.CustomerID
order by Total_orders desc limit 1;

-- 9.	Show orders where total quantity is greater than the average quantity.
select OD.OrderID,Quantity from OrderDetails as OD
where Quantity > ( select avg(OD.Quantity) from OrderDetails as OD);

-- 10.	Find employees who handled more orders than the average employee.
select Emp.EmployeeID,Emp.EmployeeName , count(O.OrderID) from Employees as Emp
join Orders as O on Emp.EmployeeID= O.EmployeeID group by  Emp.EmployeeID,Emp.EmployeeName
having count(O.OrderID) >(select avg(Order_count) from (select count(OrderID) as Order_count from Orders group by EmployeeID) temp);

-- 11.	Using CTE, calculate total sales amount for each order.
with TotalSales as (
select OD.OrderID,OD.Quantity,Prod.Price,(OD.Quantity*Prod.Price) as Total_Sales from Orderdetails as OD 
join Products as Prod on OD.ProductID = Prod.ProductID)
select OrderID,sum(Total_Sales) as TotalSalesAmount from Totalsales group by OrderID;

-- 12.	Using CTE, find customers whose total purchase amount is greater than 20,000.
with HighestSales as(
select Cust.CustomerID, Cust.CustomerName,sum(OD.Quantity *Prod.Price) as TotalPurchase from Customers as Cust
join Orders as O on Cust.CustomerID = O.CustomerID
join OrderDetails as OD on O.OrderID = OD.OrderID
join Products as Prod on OD.ProductID = Prod.ProductID group by Cust.CustomerID, Cust.CustomerName)
select * from HighestSales where TotalPurchase > 20000;

-- 13.	Using CTE, display the total revenue generated by each product category.
With ProductCategory as(
select Prod.Category,Prod.Price,OD.Quantity,(OD.Quantity*Prod.Price) as Revenue from Products as Prod
join Orderdetails as OD on OD.ProductID = Prod.ProductID)
select Category, sum(Revenue) as Total_Revenue from ProductCategory
group by Category;

-- 14.	Using CTE, find the top 3 customers based on total spending.
with Top3customers as (
select Cust.CustomerName,Cust.CustomerID,sum(OD.Quantity*Prod.Price) as Total_Spending
from Customers as Cust
join Orders as O on O.CustomerID = Cust.CustomerID
join OrderDetails as OD on OD.OrderID = O.OrderID
join Products as Prod on Prod.ProductID = OD.ProductID
group by Cust.CustomerID,Cust.CustomerName)
select CustomerName, Total_Spending from Top3customers
order by Total_Spending desc
limit 3;

-- 15.	Assign rank to customers based on total purchase amount.
select cust.CustomerID,Cust.CustomerName,Sum(OD.Quantity*Prod.Price) as Total_purchase, 
rank() over (order by Sum(OD.Quantity*Prod.Price) desc) as Rank_position
from Customers as Cust
join Orders as O on O.CustomerID = Cust.CustomerID
join OrderDetails as OD on OD.OrderID = O.OrderID
join Products as Prod on Prod.ProductID = OD.ProductID
group by Cust.CustomerID,Cust.CustomerName;

-- 16.	Display cumulative sales amount by order date.
select O.OrderDate, Sum(OD.Quantity*Prod.Price) as sales,
sum(Sum(OD.Quantity*Prod.Price)) over (order by O.OrderDate) as CumulativeSales
from Orders as O
join OrderDetails as OD on OD.OrderID = O.OrderID
join Products Prod on Prod.ProductID = OD.ProductID
group by O.OrderDate
Order by O.OrderDate;

-- 17.	Display running total of sales for each employee.
select Emp.EmployeeName,O.OrderDate,sum(OD.Quantity*Prod.Price) as TotalSales,
sum(sum(OD.Quantity*Prod.Price)) over (partition by Emp.EmployeeID Order by O.OrderDate) as RunningTotal
from Employees as Emp
join Orders as O on Emp.EmployeeID = O.EmployeeID
join OrderDetails as OD on OD.OrderID = O.OrderID
join Products Prod on Prod.ProductID = OD.ProductID
group by Emp.EmployeeID,Emp.EmployeeName,O.OrderDate
order by Emp.EmployeeID,O.OrderDate;


-- 18.	Find the highest priced product in each category.
select ProductID,ProductName,Category,Price from (
select ProductID,ProductName,Category,Price,row_number() over( partition by Category order by price desc)
as highprice from Products)temp
where highprice= 1;

