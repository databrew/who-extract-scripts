library(readxl)
library(tidyverse)
library(stringr)
library(dplyr)
library(purrr)


# =============================================================================================
# **************************************** Table from T4 **************************************
# =============================================================================================



extract_t4 <- function(excel_file_path){ 
  # excel_file_path <- '../../../../Downloads/LVA_Appendix_tables_Aug 2020_clean 03 Jun 2021.xlsx'
  sheet_num_extract <- excel_sheets(excel_file_path) %>% str_trim() %>% str_which(pattern = "\\bT4\\b")
  table1 <- readxl::read_excel(excel_file_path, sheet = sheet_num_extract)
  
  # Title years
  years_extracted <- readxl::read_excel(excel_file_path, sheet = sheet_num_extract, skip = 0, n_max = 1) %>% 
    gather() %>% 
    select(value) %>% 
    drop_na() %>% 
    pull() %>% 
    as.character()
  
  colnames(table1) <- c('indicator', years_extracted)
  
  for(j in 2:ncol(table1)){
    table1[,j] <- as.numeric(unlist(table1[,j]))
    # table1[,j] <- format(round(as.numeric(round(unlist(table1[,j]), digits = 2)), digits = 2),nsmall = 2)
  }
  
  table1 <- table1 %>%
    slice(24) %>% 
    pivot_longer(cols = 2:ncol(table1), names_to = "Year", values_to = "value", names_repair = "unique") %>%
    pivot_wider(names_from = "indicator", values_from = "value")
  
  # write.csv(table1, file = save_csv_path)
  # 
  # message("Table extracted from T3")  
  
  return(table1)
  
}


# ====================================================================================
# USAGE: extract_t4() function example
# ====================================================================================

### NOTES FOR KATE ###
# just changes `excel_file_path` where .xls is located, 
# also you can change `save_csv_path`- directory where to save extracted .csv (it is optional)
# Then just run the R script


# extract_t4(excel_file_path = "../data-raw/BUL_Appendix_tables.xlsx",
#            save_csv_path = "../data-raw/extracted_csvs/T4/T4_Figure_3_Final.csv")

# read_csv('../data-raw/extracted_csvs/T4/T4_Figure_3_Final.csv')

# ====================================================================================