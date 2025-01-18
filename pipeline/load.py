import luigi
import logging
import pandas as pd
import time
import sqlalchemy
from datetime import datetime
from pipeline.extract import Extract
from pipeline.utils.db_conn import db_connection
from pipeline.utils.read_sql import read_sql_file
from sqlalchemy.orm import sessionmaker
import os
from pangres import upsert


# Define DIR
DIR_ROOT_PROJECT = os.getenv("DIR_ROOT_PROJECT")
DIR_TEMP_LOG = os.getenv("DIR_TEMP_LOG")
DIR_TEMP_DATA = os.getenv("DIR_TEMP_DATA")
DIR_LOAD_QUERY = os.getenv("DIR_LOAD_QUERY")
DIR_LOG = os.getenv("DIR_LOG")

class Load(luigi.Task):
    
    def requires(self):
        return Extract()
    
    def run(self):
         
        # Configure logging
        logging.basicConfig(filename = f'{DIR_TEMP_LOG}/logs.log', 
                            level = logging.INFO, 
                            format = '%(asctime)s - %(levelname)s - %(message)s')
        
 
        # Read Data to be load
        try:
            # Read csv
            aircrafts = pd.read_csv(self.input()[0].path)
            airlines = pd.read_csv(self.input()[1].path)
            airports = pd.read_csv(self.input()[2].path)
            customers = pd.read_csv(self.input()[3].path)
            hotels = pd.read_csv(self.input()[4].path)
            flight_bookings = pd.read_csv(self.input()[5].path)
            hotel_bookings = pd.read_csv(self.input()[6].path)

            
            logging.info(f"Read Extracted Data - SUCCESS")
            
        except Exception:
            logging.error(f"Read Extracted Data  - FAILED")
            raise Exception("Failed to Read Extracted Data")
        
        
        #----------------------------------------------------------------------------------------------------------------------------------------
        # Establish connections to DWH
        try:
            _, dwh_engine = db_connection()
            logging.info(f"Connect to DWH - SUCCESS")
            
        except Exception:
            logging.info(f"Connect to DWH - FAILED")
            raise Exception("Failed to connect to Data Warehouse")
        
        
        #----------------------------------------------------------------------------------------------------------------------------------------
        # Record start time for loading tables
        start_time = time.time()  
        logging.info("==================================STARTING LOAD DATA=======================================")
        # Load to tables to dvdrental schema
        try:
            
            try:
                aircrafts = aircrafts.set_index("aircraft_id")
                airlines = airlines.set_index("airline_id")
                airports = airports.set_index("airport_id")
                customers = customers.set_index("customer_id")
                hotels = hotels.set_index("hotel_id")
                flight_bookings = flight_bookings.set_index(["trip_id", "flight_number", "seat_number"])
                hotel_bookings = hotel_bookings.set_index("trip_id")


                tables_to_load = {
                    "aircrafts": aircrafts,
                    "airlines": airlines,
                    "airports": airports,
                    "customers": customers,
                    "hotels": hotels,
                    "flight_bookings": flight_bookings,
                    "hotel_bookings": hotel_bookings

                }

                for table_name, dataframe in tables_to_load.items():
                    upsert(
                        con=dwh_engine,
                        df=dataframe,
                        table_name=table_name,
                        schema='pactravel',
                        if_row_exists='update'
                    )
                    logging.info(f"LOAD 'staging.{table_name}' - SUCCESS")

                logging.info(f"LOAD All Tables To DWH-dvdrental - SUCCESS")
                
            except Exception:
                logging.error(f"LOAD All Tables To DWH-dvdrental - FAILED")
                raise Exception('Failed Load Tables To DWH-dvdrental')        
        
            # Record end time for loading tables
            end_time = time.time()  
            execution_time = end_time - start_time  # Calculate execution time
            
            # Get summary
            summary_data = {
                'timestamp': [datetime.now()],
                'task': ['Load'],
                'status' : ['Success'],
                'execution_time': [execution_time]
            }

            # Get summary dataframes
            summary = pd.DataFrame(summary_data)
            
            # Write Summary to CSV
            summary.to_csv(f"{DIR_TEMP_DATA}/load-summary.csv", index = False)
            
                        
        #----------------------------------------------------------------------------------------------------------------------------------------
        except Exception:
            # Get summary
            summary_data = {
                'timestamp': [datetime.now()],
                'task': ['Load'],
                'status' : ['Failed'],
                'execution_time': [0]
            }

            # Get summary dataframes
            summary = pd.DataFrame(summary_data)
            
            # Write Summary to CSV
            summary.to_csv(f"{DIR_TEMP_DATA}/load-summary.csv", index = False)
            
            logging.error("LOAD All Tables To DWH - FAILED")
            raise Exception('Failed Load Tables To DWH')   
        
        logging.info("==================================ENDING LOAD DATA=======================================")
        
    #----------------------------------------------------------------------------------------------------------------------------------------
    def output(self):
        return [luigi.LocalTarget(f'{DIR_TEMP_LOG}/logs.log'),
                luigi.LocalTarget(f'{DIR_TEMP_DATA}/load-summary.csv')]