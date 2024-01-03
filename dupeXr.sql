/*
20240103 CD
returns xrefs that need to be deleted as they are duplicates
*/
set @r=0;
select * from(
select 
  id,
  (@product := product) as 'product',
  (@crossRef := crossRef) as 'xref',
  (@r := if((@product=product and @crossRef=crossRef), @r+1,1)) as 'k'
from productRef
order by 
  2 asc, 3 asc
) x
where x.k>1;
