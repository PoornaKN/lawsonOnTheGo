# Lawson On-the-Go Database Management Solutions

The grab-and-go type of food has always been an important demand of boilermakers during
weekday classes. Lawson OTG is Purdue’s unique premiere On-the-GO dining that offers
extensive meal options keeping in mind the fast-paced lives of the students. With their long
menu, speedy supply of sandwiches, coffee and much more to students who are running for
classes, it is imperative to create an efficient work-flow structure to cater to students’ needs
and create efficient shift allotment system.

The objective of the study is to –
- Determine the data flow of multiple databases used by Lawson OTG
- Analyze/query the data to find business solutions to the problem statement
- Create an effective inventory management system for OTG


## Tech Stack

**Language:** MYSQL

**Tools:** MYSQL workbench


## Project Description

#### DATASET:

Provided with 8 tables as hard copies by the Lawson OTG –
- Employee related information:
        
        Employee table has employee information such as name, phone number etc.
        Role table has salary for each role
        Employee shift has the shift of each employee with shift timings
- Food Inventory data:
        
        Product Item includes Item and category composition
        Category tables includes category name, purchasing quantity and expiry date
        Vendor data includes vendor details
- Food Orders data:
        
        Order details which includes Order ID, payment type, dates etc.
        Product details which includes meal prices of all the products
Created 8 entity, 3 associative entity and 3 relationships in our dataset.

ERD was plotted using MYSQL workbench (project review available in GITLAB)

#### INSIGHTS AND RECOMMENDATION:
- It is crucial to check for out of stock quantities in order to prevent items from being excluded from the menu, and hence maximize the revenue.
- From the snippet, it is clear that cheese and bagel are running out of stock which puts the desserts part of the menu at risk.
- Also, this could be automated as it is important to check for quantities of items that might run out of stock soon


