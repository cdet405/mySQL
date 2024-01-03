/*
20240103 CD
returns products that are listed backordered for every supplier on a given product
along with pending sales qty
example:
if a product 123 has supplier A listed as instock but supplier B listed as out of stock 
product 123 will not be returned. 
*/
use cddb;
select
  bo.product,
  ifnull(tp.amt,0) 'pendingQty',
  count(bo.product) pc,
  sum(bo.backOrdered) bs
from (
  select
    supplier,
    product,
    backOrdered
  from productSupplier 
  join supplier using (supplierId)
) bo 
left join (
  select 
    product,
    sum(qty) amt
  from pendingSales
  group by product
) tp using (product)
group by product
having pc=bs;
