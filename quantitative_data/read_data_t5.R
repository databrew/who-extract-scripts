library(readxl)
library(tidyverse)
library(stringr)
library(dplyr)
library(purrr)


# =============================================================================================
# **************************************** Table from T5** ************************************
# =============================================================================================

# excel_file_path = "../../../Downloads/Background material DB 10 Feb 2022 3/Bulgaria/BUL_Appendix_tables.xlsx"


extract_t5 <- function(excel_file_path){ 
  
  sheet_num_extract <- excel_sheets(excel_file_path) %>% str_trim() %>% str_which(pattern = "\\bT5\\b")
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
    # table1[,j] <- format(round(as.numeric(unlist(table1[,j])), digits = 2),nsmall = 2)
  }
  
  # Tidy up names
  q_part <- rep(c('Poorest', '2nd', '3rd', '4th', 'Richest'), 5)
  y_part <- rep(years_extracted, each = 5) 
  
  new_names <- paste0(q_part, '_', y_part)
  
  names(table1)[2:ncol(table1)] <- new_names
  
  
  table1 <- table1 %>% slice(53) 
  # Transform from wide to long
  table1 <- table1 %>%
    tidyr::gather(year, value, names(table1)[2]:names(table1)[ncol(table1)]) %>%
    # set the same names to the each indicator
    mutate(indicator = 'No OOP spending')
  # Split the "year" column into its respective parts
  table1 <- table1 %>%
    mutate(quintile = unlist(lapply(strsplit(year, split = '_'), function(x){x[1]}))) %>%
    mutate(year = unlist(lapply(strsplit(year, split = '_'), function(x){x[2]}))) %>%
    select(year, quintile, value, indicator) %>%
    rename(
      `Income Quintile` = quintile,
      Year = year
    ) %>% 
    pivot_wider(names_from = 'indicator', values_from = 'value') %>%
    mutate(`No OOP spending - new` = 100 - `No OOP spending`)
  
  return(table1)
  
  # write.csv(table1, file = save_csv_path)
  # 
  # message("Table extracted from T5")  
}


# ====================================================================================
# USAGE: extract_t5() function example
# ====================================================================================

### NOTES FOR KATE ###
# just changes `excel_file_path` where .xls is located, 
# also you can change `save_csv_path`- directory where to save extracted .csv (it is optional)
# Then just run the R script


# extract_t5(excel_file_path = "../data-raw/LVA_Appendix_tables_Aug_2020.xlsx",
#            save_csv_path = "../data-raw/extracted_csvs/T5/T5_Figure_4_Final.csv")

# read_csv('../data-raw/extracted_csvs/T5/T5_Figure_4_Final.csv')

# ====================================================================================

