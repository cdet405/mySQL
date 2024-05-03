-- returns invalid item priority records
use db01;
set @new_priority = -1;
set @item = NULL;
select * from (
  select
    (@new_priority := if(@item = item, @new_priority + 1, 0)) as 'newPriority',
    supplier,
    (@item := item) 'item',
    priority
  from itemInfo
  order by item, priority asc
) x where newPriority != priority
