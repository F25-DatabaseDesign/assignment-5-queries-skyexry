USE united_helpers;

/* 
1) How many containers of antibiotics are currently available?
Return the quantityOnHand for 'bottle of antibiotics'.
*/
SELECT
    item.quantityOnHand
FROM item
WHERE item.itemDescription = 'bottle of antibiotics';
/* 
100
*/

/*
2) Which volunteer(s), if any, have phone numbers that do not start with 2
and whose last name is not Jones?
Return volunteerName.
*/
SELECT
    volunteer.volunteerName
FROM volunteer
WHERE volunteer.volunteerTelephone IS NOT NULL
  AND LEFT(volunteer.volunteerTelephone, 1) <> '2'
  AND volunteer.volunteerName NOT LIKE '% Jones';
/* 
Gene Lewin
*/

/*
3) Which volunteer(s) are working on transporting tasks?
Return volunteerName with no duplicates.
*/
SELECT DISTINCT
    volunteer.volunteerName
FROM volunteer
JOIN assignment
  ON volunteer.volunteerId = assignment.volunteerId
JOIN task
  ON assignment.taskCode = task.taskCode
JOIN task_type
  ON task.taskTypeId = task_type.taskTypeId
WHERE task_type.taskTypeName = 'transporting';
/* 
'George Brewer'
*/

/*
4) Which task(s) have yet to be assigned to any volunteers?
Return taskDescription.
*/
SELECT
    task.taskDescription
FROM task
LEFT JOIN assignment
  ON task.taskCode = assignment.taskCode
WHERE assignment.volunteerId IS NULL;
/* 
'Prepare 100 food packages'
'Take packages to the warehouse'
*/

/*
5) Which type(s) of package contain some kind of bottle?
Return packageTypeName with no duplicates.
*/
SELECT DISTINCT
    package_type.packageTypeName
FROM package_type
JOIN package
  ON package_type.packageTypeId = package.packageTypeId
JOIN package_contents
  ON package.packageId = package_contents.packageId
JOIN item
  ON package_contents.itemId = item.itemId
WHERE item.itemDescription LIKE '%bottle%';
/* 
'food and water'
*/

/*
6) Which items, if any, are not in any packages?
Return itemDescription.
*/
SELECT
    item.itemDescription
FROM item
LEFT JOIN package_contents
  ON item.itemId = package_contents.itemId
WHERE package_contents.packageId IS NULL;
/* 
'bottle of antibiotics'
'bottle of aspirin'
'flashlight'
'pack of bandages'
*/

/*
7) Which task(s) are assigned to volunteer(s) that live in New Jersey (NJ)?
Return taskDescription with no duplicates.
*/
SELECT DISTINCT
    task.taskDescription
FROM volunteer
JOIN assignment
  ON volunteer.volunteerId = assignment.volunteerId
JOIN task
  ON assignment.taskCode = task.taskCode
WHERE volunteer.volunteerAddress LIKE '% NJ%';
/* 
'Prepare 20 children\'s packages'
'Prepare 100 water packages'
'Prepare 5,000 packages'
*/

/*
8) Which volunteers began their assignments in the first half of 2021?
Return volunteerName with no duplicates.
Window: 2021-01-01 00:00:00 <= startDateTime < 2021-07-01 00:00:00
*/
SELECT DISTINCT
    volunteer.volunteerName
FROM volunteer
JOIN assignment
  ON volunteer.volunteerId = assignment.volunteerId
WHERE assignment.startDateTime IS NOT NULL
  AND assignment.startDateTime >= '2021-01-01 00:00:00'
  AND assignment.startDateTime <  '2021-07-01 00:00:00';
/* 
'Joan Simmons'
'Chris Jordan'
*/

/*
9) Which volunteers have been assigned to tasks that include packing spam?
"spam" means item.itemDescription = 'can of spam'.
Return volunteerName with no duplicates.
*/
SELECT DISTINCT
    volunteer.volunteerName
FROM volunteer
JOIN assignment
  ON volunteer.volunteerId = assignment.volunteerId
JOIN task
  ON assignment.taskCode = task.taskCode
JOIN package
  ON task.taskCode = package.taskCode
JOIN package_contents
  ON package.packageId = package_contents.packageId
JOIN item
  ON package_contents.itemId = item.itemId
WHERE item.itemDescription = 'can of spam';
/* 
'Julie White'
'Gerry Banks'
*/

/*
10) Which item(s), if any, have a total value of exactly 100 dollars
in one package?
Total value for an item in a package is:
item.itemValue * package_contents.itemQuantity
Return itemDescription with no duplicates.
*/
SELECT DISTINCT
    item.itemDescription
FROM package_contents
JOIN item
  ON package_contents.itemId = item.itemId
WHERE (item.itemValue * package_contents.itemQuantity) = 100;
/* 
'Baby formula'
*/

 /*
11) How many volunteers are assigned to tasks with each different status?
Return taskStatusName and number of DISTINCT volunteers.
Sort from highest numVolunteers to lowest.
*/
SELECT
    task_status.taskStatusName,
    COUNT(DISTINCT assignment.volunteerId) AS numVolunteers
FROM task_status
JOIN task
  ON task_status.taskStatusId = task.taskStatusId
JOIN assignment
  ON task.taskCode = assignment.taskCode
GROUP BY task_status.taskStatusName
ORDER BY numVolunteers DESC;
/* 
'open','4'
'closed','3'
'ongoing','2'
'pending','1'
*/

/*
12) Which task creates the heaviest set of packages and what is the weight?
Return taskCode and SUM(packageWeight) as totalWeight.
Order by totalWeight descending and take the top row.
*/
SELECT
    task.taskCode,
    SUM(package.packageWeight) AS totalWeight
FROM task
JOIN package
  ON task.taskCode = package.taskCode
GROUP BY task.taskCode
ORDER BY totalWeight DESC
LIMIT 1;
/* 
'106','308'
*/

/*
13) How many tasks are there that do not have a type of 'packing'?
Return the count as numTasksNotPacking.
*/
SELECT
    COUNT(*) AS numTasksNotPacking
FROM task
JOIN task_type
  ON task.taskTypeId = task_type.taskTypeId
WHERE task_type.taskTypeName <> 'packing';
/* 
'3'
*/

/*
14) Of those items that have been packed,
which item(s) were touched by fewer than 3 volunteers?
Definition:
An item is "touched" by a volunteer if that volunteer is assigned
to a task whose packages include that item.
Return itemDescription.
*/
SELECT
    item.itemDescription
FROM item
JOIN package_contents
  ON item.itemId = package_contents.itemId
JOIN package
  ON package_contents.packageId = package.packageId
JOIN task
  ON package.taskCode = task.taskCode
JOIN assignment
  ON task.taskCode = assignment.taskCode
GROUP BY item.itemDescription
HAVING COUNT(DISTINCT assignment.volunteerId) < 3;
/* 
'can of spam'
'dried fruit'
'men\'s coat'
'sleeping bag'
'tent'
'women\'s coat'
*/

/*
15) Which packages have a total value of more than 100 dollars?
Total value for a package is:
SUM(item.itemValue * package_contents.itemQuantity)
Return packageId and totalValue.
Sort from lowest totalValue to highest.
*/
SELECT
    package.packageId,
    SUM(item.itemValue * package_contents.itemQuantity) AS totalValue
FROM package
JOIN package_contents
  ON package.packageId = package_contents.packageId
JOIN item
  ON package_contents.itemId = item.itemId
GROUP BY package.packageId
HAVING totalValue > 100
ORDER BY totalValue ASC;
/* 
'6','150'
'2','151'
'4','350'
'10','750'
'5','1420'
*/