/*
Business Requirement:
The objective of this analysis is to evaluate Blinkit sales performance 
across product categories, outlet types, and outlet characteristics.

Key goals:
- Measure overall revenue performance
- Analyze product-level contribution
- Evaluate outlet-level sales distribution
- Identify high-performing segments
- Understand rating and customer satisfaction trends
*/


--  KPI -- 
select 
     count(*) no_of_item,
     round(sum(Sales),2) as Total_Sales,
	 round(avg(Sales),2) as Avg_Sales,
     round(avg(Rating),2)as Avg_Rating
from blinkit;



--  total sales by fat content
select 
     Item_Fat_Content,
     count(*) as No_of_Item,
     round(sum(Sales),2) as Total_Sales,
     round(avg(Sales),2) as Avg_Sales,
     round(avg(Rating),2) as Avg_Rating
from blinkit
group by  Item_Fat_Content
order by Total_Sales desc;


-- Top 10 Total Sales by item Type
select 
      Item_Type,
      count(*) as No_of_Item,
	 round(sum(Sales),2) as Total_Sales,
     round(avg(Sales),2) as Avg_Sales,
     round(avg(Rating),2) as Avg_Rating
from blinkit
group by  Item_Type
order by Total_Sales desc
limit 10;



-- toal sales by outler_establishment
select 
      outlet_Establishment_year,
      count(*) as No_of_Item,
      round(sum(Sales),2)as Total_Sales,
      lag(round(sum(Sales),2))
           over(order by outlet_Establishment_year) as previous_year_sales,
		round(
              (sum(sales) -lag(sum(sales))
               over(order by outlet_Establishment_year)
               ) / lag(sum(sales))
			 over(order by outlet_Establishment_year) *100,
			2) as growth_percentage
from blinkit
group by Outlet_Establishment_year
order by Outlet_Establishment_year;
 
 
-- sales percentage by outlet size
select 
     outlet_size,
     round(sum(Sales),2) as Total_Sales,
     round(
        sum(Sales) * 100 / (select sum(Sales)  from blinkit),
        2
    ) AS sales_Percentage
 from blinkit
 group by outlet_size;
 
 
 -- sales performance by outlet location
 select 
      Outlet_Location_Type,
      count(*) No_of_Item,
      round(sum(Sales),2) as Total_Sales,
      round(avg(Sales) ,2)as Avg_Sales
 from blinkit
 group by  Outlet_Location_Type;
 

 
-- Sales performance by outlet type
 select 
      Outlet_Type,
      count(*) No_of_Item,
      round(sum(Sales),2) as Total_Sales,
      round(avg(Sales) ,2)as Avg_Sales
 from blinkit
 group by  Outlet_Type;
 
 
-- outlet performance segmentation based on average revenue benchmark 
 with outlet_sales as(
     select 
           outlet_type,
           sum(Sales)as total_sales
	from blinkit
    group by outlet_type
)
 select 
       outlet_type,
       round(total_sales ,2) as total_sales,
       case
            when total_sales > (select avg(total_sales)
            from outlet_sales
            )
            then 'High Performance'
            else 'Low Performance'
            end as performance_segmentation
 from outlet_sales
 order by total_sales desc;
      
      