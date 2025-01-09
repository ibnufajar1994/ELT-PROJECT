# ELT-PROJECT
Build and Orchestrate an ELT Data Pipeline Using DBT &amp; LUIGI

This project is focus on designing the ELT pipeline for datawarehouse with implementing the SCD strategies using. This project uses the "Kimball Method" approach to design the data warehouse model. You can access the source of the database [here](https://github.com/Kurikulum-Sekolah-Pacmann/pactravel-dataset)

Before we jump in to the step of designing the data warehouse, first we need understand the bussiness process. Imagine you are a data engineer, you have a client called "pactravel" that manage application for online bookings for airline & hotel ticket. The picture shown bellow is the ERD from database of pactravel
![erd-pactravel](https://github.com/user-attachments/assets/c827b969-fcae-405a-802c-74bb599ef937)

 Here’s a breakdown of the business process based on the ERD:
 1. Customer Registration
    - Customers register their details in the system, creating a profile with personal and contact information.
 
 2. Flight Booking:
    - Customers can book flights by selecting an airline and flight details.
    - The system records the flight number, airline, aircraft, and airport information.
    - Pricing and class are also selected during booking.
 
 3. Hotel Booking:
    - Customers can book hotels by choosing a hotel and specifying check-in/check-out dates.
    - Pricing and additional services (e.g., breakfast) are recorded.

 4. Integration:
    - The system integrates flight and hotel bookings, allowing seamless travel planning.
    - Customers can manage their bookings through the system.
   
After we know and understand the business process from the client, now we will move to step of designing data warehouse model. We will use the kimball method approach to design and implemented the data warehouse model.

## 1. Requiremens Gathering
In this process, we will collect all the information needed from the client. This information will guided us to design the build the data warehouse model. As Data Engineer, we will conduct the discussion and sharing session with client. Here the possible scenario of Q&A session between the Data engineer & Client to gather the information:

**Question 1:**
What is the main purpose of creating the data warehouse for your system?

**Possible Answer:**
The main purpose of creating a data warehouse for PacTravel is primarily focused on three key objectives:

1. Business Performance Analysis
   - We need to track our revenue trends from both flight and hotel bookings
   - Understand which routes and destinations are most profitable
   - Analyze booking patterns across different seasons
   - Monitor the performance of our partnerships with airlines and hotels

2. Customer Behavior & Personalization.
   - We want to better understand our customers' travel preferences
   - Track booking history to identify loyal customers
   - Analyze customer demographics and their booking patterns
   - This will help us create more personalized travel packages and marketing campaigns
     
3. Decision Making Support
   - We need consolidated reports for executive decision making
   - Want to make data-driven decisions about which new routes or hotel partnerships to pursue
   - Need to identify potential business opportunities and areas for improvement
   - Better forecast demand for different seasons and adjust our strategies accordingly
     
Currently, our operational database is transaction-focused and it's challenging to run complex analytical queries without affecting system performance. A data warehouse would solve this issue and provide us with the analytical capabilities we need.

**Question 2:**
What kind of data do you want to store in your data warehouse?

**Possible Answer:**
For our data warehouse, we want to store several key categories of data:

1. Booking Transactions
- Flight booking details including:
  * Flight numbers, routes, departure times
  * Ticket prices
  * Travel class
  * Seat numbers
  * Flight duration
- Hotel booking information including:
  * Check-in/check-out dates
  * Room rates
  * Breakfast inclusion status
  * Length of stay

2. Customer Data
- Customer demographics (name, gender, country)
- Contact information
- Booking history
- Customer preferences
- We want to track how customer behavior changes over time

3. Flight Operations Data
- Aircraft information
- Airline details
- Route information
- Airport details including locations (latitude/longitude)

4. Hotel Information
- Hotel details (name, location, address)
- Hotel ratings/scores
- City and country information
- Hotel facilities/amenities

5. Time-based Data
- We need to store historical data to analyze:
  * Seasonal trends
  * Year-over-year comparisons
  * Peak booking periods
  * Price fluctuations over time

We'd like to maintain at least 5 years of historical data for trend analysis and forecasting purposes.

**Question 3:**
Who will use your data in the data warehouse?

**Possible Answer:**
In PacTravel, several key stakeholders will use the data warehouse:

1. Executive Management Team
- CEO and CFO need high-level business performance dashboards
- Need to monitor overall company KPIs
- Revenue analysis and growth trends
- Market performance insights

2. Sales and Marketing Team
- Need customer segmentation analysis
- Campaign performance tracking
- Customer behavior analysis
- Identify potential upselling opportunities
- Track popular destinations and routes

3. Operations Team
- Monitor booking patterns
- Analyze route performance
- Track hotel partnership performance
- Optimize pricing strategies
- Capacity planning

4. Customer Service Team
- Access to customer booking history
- Understanding customer preferences
- Track customer satisfaction metrics
- Identify frequent customers for special handling

5. Business Analysts
- Need to perform ad-hoc analysis
- Create regular performance reports
- Conduct market research
- Forecast trends and demand
  
Each of these user groups will need different levels of access and different types of reports.

**Question 4:**
How frequently should your data will be updated or refreshed in the your data warehouse?

**Possible Answer:**
For PacTravel's data warehouse, we have different refresh requirements based on the type of data:

1. Booking Transactions (Flight & Hotel)
- Need daily updates
- This is critical as we need to track our daily business performance
- Should be refreshed during off-peak hours (preferably after midnight)
- This includes new bookings, modifications, and cancellations

2. Booking Transactions (Flight & Hotel)
 - Need daily updates
 - This is critical as we need to track our daily business performance
 - Should be refreshed during off-peak hours (preferably after midnight)
 - This includes new bookings, modifications, and cancellations

3. Customer Data
 - Daily updates would be ideal
 - New customer registrations and profile updates
 - Customer preference changes
 - Contact information updates
 - Reference Data

4. Airlines and Aircraft Information: Weekly updates
5. Hotel Information: Weekly updates
 - These don't change very frequently but need to be current

**Question 5:**
Which dimension do you think are most critical to track historical changes?

**Possible Answer:**
I believe the customers, airlines, and hotel  is the critical aspect need to be tracked over time.

**Question 6:**
 For these dimensions, do you need to keep a full history of all changes, or is it sufficient to know the current state and the previous state?

**Possible Answer:**
For customers, airlines, and hotels we need a full history as it's crucial for our product evolution analysis. For other dimensions, knowing the current and previous state should be sufficient.

**Question 7:**
How long do you need to retain historical data for these slowly changing dimensions?

**Possible Answer:**
We'd like to keep the history indefinitely, except for customers dimension. For customers, retaining history for the past 3 years should be sufficient.

## Declare Grain ##

  The level of detail at which data is stored in a fact table. When we declare the grain, we’re essentially specifying what one row in a fact table represents. This decision is critical because it affects the granularity of the data, the types of analysis that can be performed, and the overall size of the Data Warehouse. From the selected business process above, we can declare the grain as follow:

1. **Flight Transaction Grain:**
   **Grain:** A single data represented  One row per flight booking per customer per trip

   **Dimension:** 
 - Aircrafts
 - Airlines
 - Airports
 - Customers

**Fact Table: fact_flight_bookings**
   

2. **Hotel Booking Transaction Grain:**
   **Grain:** A single data represented by One row per hotel stay per customer per trip.
    
  **Dimension:** 
 - Hotel
 - Customers

**Fact Table: fact_hotel_bookings**

## Identify the Dimension ##
Identifying dimensions is a critical step in designing a Data Warehouse because dimensions provide the descriptive context for the quantitative data stored in fact tables. Dimensions help categorize, filter, and segment data, making it easier to perform meaningful analysis. 

Based on the database provided, here the dimension for the key business process of pactravel:

**1.Date Dimension**
provides a comprehensive breakdown of time-related attributes. It allows for analysis across various time periods (days, weeks, months, quarters, years) and includes flags for weekends and holidays. This dimension is crucial for trend analysis, seasonality studies, and periodic reporting across all business processes.
![image](https://github.com/user-attachments/assets/2edadd14-7111-4b8a-8b6b-6f23023b3f1c)


**2. Aircraft Dimension**
This dimension store all of the information of aircraft that used by the airlines.
![image](https://github.com/user-attachments/assets/375bc6e0-bee4-401e-bd47-71bc3aa8011f)


**3. Airlines Dimension**
This dimension provided information of the Airlines that sell ticket to all availaible routes for the customers. 
![image](https://github.com/user-attachments/assets/a12eb39f-e330-460a-8b00-eeebed425e06)

**4. Airport Dimension**
 Contain all information about airports. This information is crucial because it will give insight about favourite destination of customers.
 ![image](https://github.com/user-attachments/assets/d374004f-19f8-4c50-b7a1-ed66c34819bb)


**5. Customers Dimension**
Contains key information about pactravel's customers, including their unique identifiers and geographical information. This dimension supports customer segmentation, regional analysis, and tracking of individual customer behaviors over time.
![image](https://github.com/user-attachments/assets/f0c442ce-a9fa-4929-b8c7-a7a3e984e6df)


**6. Hotel Dimension**
Contain information related to all hotel that have partnership's with pactravel. This dimension will provide valuable insight about what hotel to be customer's preferences and choices
![image](https://github.com/user-attachments/assets/6e093616-e0c8-4d5f-9925-da26811b1f43)


## IDENTIFY THE FACT  ##
A fact table stores quantitative, numeric data (facts) that are the subject of analysis. Fact tables typically represent events or transactions in the business, such as sales, payments, shipments, or reviews. Each row in a fact table corresponds to an occurrence of that event or transaction at the declared grain (level of detail). Based on the PACTRAVEL dataset and business requirements, the fact table will be identify as follow:

**1. Flight Bookings Fact Table**
The FACT_FLIGHT_BOOKINGS table captures all flight transaction details including pricing, routes, and scheduling information, allowing analysis of flight-related metrics like revenue, popular routes, and travel patterns.

Measures: 
 - Price
 - Flight Duration
   
Dimensional References:
 - customer_id (dim_customer)
 - airline_id (dim_airlines)
 - aircraft_id (dim_aircraft)
 - airport_id (dim_airport)
 - departure_date_id (dim_date)
 - departure_time_id (dim_date)

Additional Attributes:
 - trip_id
 - flight_number
 - travel_class
 - seat_number

**2. Hotel Bookings Fact Table**
 The FACT_HOTEL_BOOKINGS table tracks hotel stay transactions with details on pricing, length of stay, and amenities, enabling analysis of accommodation metrics such as revenue per hotel and booking patterns.

 Measures:
  - Price
  - length_of_stay (derived from check_in_date and check_out_date)

Dimensional References:
 - customer_id (dim_customer)
 - hotel_id (dim_hotel)
 - checkin_date_id (dim_date)
 - checkout_date_id (dim_date)

Additional Attributes:
 - trip_id
 - breakfast_included

To provides a clear overview of how each dimension is shared across multiple business processes, ensuring that the design remains consistent, scalable and flexible, we can use the Bus Matrix as the tool like shown bellow:
![image](https://github.com/user-attachments/assets/f0da2d89-7ad5-4fd3-86b1-7395eda403d5)

here the final ERD of the data warehouse:
![ERD_PACTRAVEL_DWH](https://github.com/user-attachments/assets/1429940b-1c17-4f1d-a4fe-cffe478e9b84)

## DETERMINE THE SCD STRATEGIES ##

Based on the information gathered from the client, we can determine the appropriate Slowly Changing Dimension (SCD) strategies for the pactravel data warehouse model. Let's break it down by dimension:

**Customers Dimension**
 - SCD: Type 2
 - Reason: The client want to track historical data change on this dimension, especially on phone number and country change

**Airlines Dimension**
 - SCD: Type 2
 - Reason: Sometimes the airlines  rebrand their airlines and change the name, we need to track this historical change. The analyst team can collect data and measure if the rebranding will affect the airlines performances.

**Hotels Dimension**
- SCD: Type 2
- Reason: Same with the airlines, sometimes the hotel do the rebranding and change their name, event their location.

**Other Dimensions**
- SCD: type 1
- Reason: Other dimension's seems like not to change on long period. Keep the information to the current status will be sufficient.

## SCD IMPLEMENTATION ##
| Dimension   | SCD Type | Retention Policy | Rationale |
|-------------|----------|------------------|-----------|
| Customers   | Type 2   | 3 Years          | Name & Address need historical tracking. |
| Airlines    | Type 2   | Indefinetely     | Names need historical tracking. Other attributes only need current state. |
| Hotels      | Type 2   | indefinitely     | Name & Address changes need historical tracking. Other attributes only need current state. |
| Aircrafts   | Type 1   | indefinitely     | Most recent version of data is typically sufficient. |
| Airports    | Type 1   | indefinitely     | Most recent version of data is typically sufficient. |
| Date        | None    | indefinitely      | Date dimension is static and doesn't change.|

# ELT WORKFLOW
In this project, we will use 2 database. one database for the source of the data, and the other database for build the datawarehouse. we will copy all of the the data from the source database to target database. on target database, will consist of 2 schema, pactravel and final. pactravel will store all information from sources, and the final will be the schema for our datawarehouse. On final schema, the data will be transformed. Here the work flow:

![Screenshot 2024-11-16 231424](https://github.com/user-attachments/assets/24dc58b1-88fb-4e64-b287-07efd790b4a1)

# ELT PIPELINE ORCHESTRATION
In this project, we will use luigi as the orchestration tools. We will extract all the data from the database as the csv file format, and then dump the data to the pactravel schema on the target database where we will implemented the datawarehouse schema. As the data from pactravel schema is ready, we will use dbt as the tool for transform the data and dump it to the final schema. Sentry will be used as alerting and notification tools. 

![FIGURE](https://github.com/user-attachments/assets/4896131f-d994-4504-a385-09afc3038c2c)

Tools:
- Orchestration: Luigi
- Schedulling: Cron
- Write summary : pandas
- Logging: logging.info for write logs for every step of the proccess and logging.error for write error
- alerting & notification: sentry. you can visit the sentry website to read the documentation in this [link](https://sentry.io/welcome/)

 How to use this repo:
## 1. Requirements
- **OS:**
  - Linux
  - WSL
- **Tools:**
  - Dbeaver
  - Docker
  - Cron
  - dbt
- **Programming Language:**
  - Python
  - SQL
- **Python Library:**
  - Luigi
  - Pandas
  - Sentry-SDK
- **Platforms**
   - Sentry

## 2.Preparations
- Clone this repo using the following command:

  ```bash
  https://github.com/ibnufajar1994/ELT-PROJECT.git
  ```
run the command below on the terminal:
  ```bash
  docker compose up -d
  ```
  
- Create Sentry Project
  - visit: https://www.sentry.io
  - Signup with email that you want get notifications and alert
  - Create Project on sentry:
    - use python as a platform
    - set alert frequency as "on every new issue"
    - Create project name
    - **Copy the DSN of your project into .env file**

- Create temp dir. on your root project directory:
```bash
mkdir pipeline/temp/data
mkdir pipeline/temp/log
```
- Create & use virtual environment on your root directory project
- Install the requirements using the following command:
```bash
pip install -r requirements.txt
```

- **Create env file in your root project directory, copy this variable into it.you need to adjust the value based on your preferences:**
  
```bash
SRC_POSTGRES_DB=...
SRC_POSTGRES_HOST=...
SRC_POSTGRES_USER=...
SRC_POSTGRES_PASSWORD=...
SRC_POSTGRES_PORT=...

# DWH
DWH_POSTGRES_DB=...
DWH_POSTGRES_HOST=...
DWH_POSTGRES_USER=...
DWH_POSTGRES_PASSWORD=...
DWH_POSTGRES_PORT=...

# SENTRY DSN
SENTRY_DSN=... # Fill with your Sentry DSN Project 

# DIRECTORY
# Adjust with your directory. make sure to write full path
DIR_ROOT_PROJECT=...     # <project_dir>
DIR_TEMP_LOG=...         # <project_dir>/pipeline/temp/log
DIR_TEMP_DATA=...        # <project_dir>/pipeline/temp/data
DIR_EXTRACT_QUERY=...    # <project_dir>/pipeline/src_query/extract
DIR_LOAD_QUERY=...       # <project_dir>/pipeline/src_query/load
DIR_DBT_TRANSFORM=...    # <project_dir>/dbt_transform/
DIR_LOG=...              # <project_dir>/logs/
```
- run this command on the backround process:
  ```bash
  luigid --port 8082 &
  ```
- you can run this command directly on the terminal to run the pipeline:
   ```bash
   python3 elt_main.py
   ```
- or you can schedulling using cron, for example on the code below is the command to run the pipeline every one hour.
    ```bash
   0 * * * * <project_dir>/elt_run.sh
   ```




