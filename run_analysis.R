
library( data.table )
library( stringr )

path <- "UCI HAR Dataset"
TR_path <- paste0( path, "/train/X_train.txt" )
TE_path <- paste0( path, "/test/X_test.txt" )


## Step 0: Preparatory work

# Examine contents of files
con <- file( TR_path )

lines <- readLines( con, n = 2L )
lines <- str_trim( lines )

line1 <- strsplit( lines[ 1 ], " +" ); line1 <- line1[[ 1 ]]
line2 <- strsplit( lines[ 2 ], " +" ); line2 <- line2[[ 1 ]]

close( con )

# Read TRAIN & TEST DATA
DT_train <- fread( TR_path, sep = " " )
DT_test <- fread( TE_path, sep = " " )
DT_YTrain <- fread( paste0( path, "/train/y_train.txt" ), sep = " " )
DT_YTest <- fread( paste0( path, "/test/y_test.txt" ), sep = " " )
DT_SubTrain <- fread( paste0( path, "/train/subject_train.txt" ), sep = " " )
DT_SubTest <- fread( paste0( path, "/test/subject_test.txt" ), sep = " " )



## Step 1: Merge Train & Test data
DT_data <- rbindlist( list( DT_train, DT_test ) )
DT_Y <- rbindlist( list( DT_YTrain, DT_YTest ) )
DT_Subj <- rbindlist( list( DT_SubTrain, DT_SubTest ) )

rm( DT_train, DT_test, DT_YTrain, DT_YTest, DT_SubTrain, DT_SubTest ); gc()



## Step 2: Extract all col for mean & std
DT_colnm <- fread( paste0( path, "/features.txt" ), sep = " " )  # Read feature names
a_selCol <- str_detect( DT_colnm$V2, "([Mm]ean|std)" )
DT_sdata <- DT_data[ , a_selCol, with = F  ]

identical( sum( a_selCol ), ncol( DT_sdata ) )  # Confirm col are correctly extracted
rm( DT_data ); gc()



## Step 3: Label the activities appropriately
DT_activLabel <- fread( paste0( path, "/activity_labels.txt" ), sep = " " )
DT_Y[ , V1 := DT_activLabel$V2[ DT_Y$V1 ] ]



## Step 4: Tidy up ColNm for renaming DT
a_ColNm <- DT_colnm$V2[ a_selCol ]
a_ColNm <- str_replace_all( a_ColNm, "\\(\\)", "" )
a_ColNm <- str_replace_all( a_ColNm, "\\(", "-" )
a_ColNm <- str_replace_all( a_ColNm, "\\)", "" )

# Rename predictor and response DTs
colnames( DT_sdata ) <- a_ColNm
DT_sdata[ , Activity := DT_Y$V1 ]



## Step 5: Create new dataset by merging subjects into DT
DT_sdata[ , Subject := DT_Subj$V1 ]
DT_data_by_subj <- DT_sdata[ , lapply( .SD, mean ), by = list(Activity, Subject ) ]



## Final steps: Generate into CSV & TXT files for uploading to Github
write.csv( DT_sdata, "Data_Filtered.csv" )
write.csv( DT_data_by_subj, "Data_by_subj.csv" )
write.table( DT_data_by_subj, "Data_by_subj.txt", row.names = F )


DT_f_sdata <- data.table( colnames( DT_sdata ) )
DT_f_data_by_subj <- data.table( colnames( DT_data_by_subj ) )

write.table( DT_f_sdata, "Codebk_Data_Filtered.txt", col.names = F, quote = F )
write.table( DT_f_data_by_subj, "Codebk_Data_by_subj.txt", col.names = F, quote = F )




## END OF CODE ##