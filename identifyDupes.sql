-- identify duplicate cross refs | where cnt>1 
use cddb;
set @r=0;
select 
  crossrefID,
  (@r := IF((@productID = productID AND @desciption = description), @r+1,1)) 'cnt',
  (@productID := productID) 'productID',
  (@desciption := description) 'description'
from productcrossref
order by 
  3 asc, 
  4 asc;
