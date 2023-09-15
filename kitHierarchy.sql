-- Create a temporary table to store the results
CREATE TEMPORARY TABLE rpl (
  level INT,
  parentProductID INT,
  childProductID INT,
  qtyRequired INT,
  topParentProductID INT
);

-- Create a stored procedure to populate the temporary table recursively
DELIMITER //

CREATE PROCEDURE populate_rpl()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE currentLevel INT DEFAULT 0;

  -- Create a cursor to iterate over the records
  DECLARE cur CURSOR FOR
    SELECT
      0 AS level,
      root.parentProductID,
      root.childProductID,
      root.qtyRequired,
      root.parentProductID AS topParentProductID
    FROM
      dev_cd.boms root;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  -- Open the cursor
  OPEN cur;

  -- Loop through the records recursively
  read_loop: LOOP
    FETCH cur INTO currentLevel, parentProductID, childProductID, qtyRequired, topParentProductID;
    IF done THEN
      LEAVE read_loop;
    END IF;

    -- Insert the current record into the temporary table
    INSERT INTO rpl (level, parentProductID, childProductID, qtyRequired, topParentProductID)
    VALUES (currentLevel, parentProductID, childProductID, qtyRequired, topParentProductID);

    -- Recursive query to find child records
    INSERT INTO rpl (level, parentProductID, childProductID, qtyRequired, topParentProductID)
    SELECT
      parent.level + 1,
      child.parentProductID,
      child.childProductID,
      child.qtyRequired,
      parent.topParentProductID
    FROM
      rpl parent
    JOIN
      dev_cd.boms child ON parent.childProductID = child.parentProductID
    WHERE
      parent.level < 20; -- Limit the recursion depth to avoid infinite loops
  END LOOP;

  -- Close the cursor
  CLOSE cur;
END //

DELIMITER ;

-- Call the stored procedure to populate the temporary table
CALL populate_rpl();

-- Query the temporary table to retrieve the desired result
SELECT
  DISTINCT topParentProductID,
  level,
  parentProductID,
  childProductID,
  qtyRequired
FROM
  rpl
ORDER BY
  topParentProductID,
  level,
  parentProductID;
