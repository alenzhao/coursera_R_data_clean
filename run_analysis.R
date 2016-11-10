## get the data

url.location<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(url.location, destfile="CSCdata.zip", method ="wget")

unzip(zipfile="CSCdata.zip", exdir ="CSCfolder")


#### writing a function of fetching zip files from URL, saving with good filename, and unzip to better named folder

fetchUNzip <- function(url.site, destfile, exdir, method="wget"){
                       if(destfile %in% dir())
                               {print("rename destfile")
                                return(0)}
                       else{
                               download.file(url.site, destfile=destfile, method ="wget")
                           }
                        if (exdir %in% dir())
                                {print("rename exdir")
                                return(0)
                        }
                        else{
                           unzip(zipfile=destfile, exdir = exdir)
                        }
}

##
## testing
url.location<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
fetchUNzip(url.site = url.location, destfile ="CSC1.zip", exdir = "CSC2", method="wget")
##
#############
### take a look at the folder

########################

myFiles <- dir(path="CSC2", recursive = TRUE)

#  data files

## description
###   README file:   "UCI HAR Dataset/README.txt",                myFiles[4]
###   Feature file:  "UCI HAR Dataset/features.txt",              myFiles[3]
###   Activity_labels: "UCI HAR Dataset/activity_labels.txt",     myfiles[1]

## Subject files
###   Subject file:  "UCI HAR Dataset/test/subject_test.txt" ,    myFiles[14]
###   Subject file:  "UCI HAR Dataset/train/subject_train.txt",   myFiles[26]

## Activity files:
###   Activity files:"UCI HAR Dataset/test/y_test.txt",          myFiles[16]
###   Activity files:"UCI HAR Dataset/train/y_train.txt",        myFiles[28]

## Feature files:
###  "UCI HAR Dataset/test/X_test.txt",                         myFiles[15]
###  "UCI HAR Dataset/train/X_train.txt",                       myFiles[27]

## read feature name
featName <-read.table(file=myFiles[3], sep="\t", header =FALSE, stringsAsFactors=FALSE)
str(featName)
###

### set working directory
setwd("CSC2")

## read and merge subject files
subjTrain <- read.table( file = myFiles[26], header = FALSE)
subjTest  <- read.table( file = myFiles[14], header = FALSE)
subj <- rbind(subjTrain, subjTest)
colnames(subj) <- "subject"
str(subj)
## 'data.frame':	10299 obs. of  1 variable:
## $ subject: int  1 1 1 1 1 1 1 1 1 1 ...
##

## read and merge Activity files
actiTrain <- read.table(file = myFiles[28], header = FALSE )
actiTest  <- read.table(file = myFiles[16], header = FALSE)
acti <- rbind(actiTrain, actiTest)
colnames(acti) <- "activity"
str(acti)
## data.frame':	10299 obs. of  1 variable:
## $ activity: int  5 5 5 5 5 5 5 5 5 5 ...
##

## read and merge Features
featTrain <-read.table(file =myFiles[27], fill= TRUE, header=FALSE)
featTest <- read.table(file = myFiles[15], fill =TRUE, header=FALSE)
feat <- rbind(featTrain, featTest)
colnames(feat) <- featName[,1]
str(feat)
##

## Resuest 1: Merging the training and testing data sets into one data set.
bigTable <- cbind(subj, acti, feat)
str(bigTable)
write.table(bigTable, file="bigTable.txt", sep="\t", row.names =FALSE)
##

## Request 2:   Extract only the measurements on the mean and standard deviations for each measurement.
indexMeanStd <- c(grep("mean",colnames(feat)),grep("Mean", colnames(feat)), grep("std",colnames(feat)))
str(indexMeanStd)
featureMeanStd <- feat[, indexMeanStd]
str(featureMeanStd)
save(featureMeanStd, file="featureMeanStd.Rdata")
##

## Request 3: Use descriptive activity names to name the activity in the dataset
actiLevels <- read.table(file= myFiles[1], header = FALSE,stringsAsFactors = FALSE)
bigTable[,2] <- factor(bigTable[,2], labels= actiLevels[,2])
save(bigTable, file="bigTableWithActivityLabled.Rdata")
## 

## Request 4: Approciate labels the data set with descriptive varible names
colnames(bigTable) <- gsub("^[0-9]+ ","", colnames(bigTable))
colnames(bigTable) <- gsub("^t","time", colnames(bigTable))
colnames(bigTable) <- gsub("^f", "frequency", colnames(bigTable))
colnames(bigTable) <- gsub("Acc", "AccelerateMeter", colnames(bigTable))
colnames(bigTable) <- gsub("Mag", "Magnitude", colnames(bigTable))
colnames(bigTable) <- gsub("BodyBody","Body", colnames(bigTable))
save(bigTable, file = "bigTableWithFineNames.Rdata")
##
colnames(featureMeanStd) <- gsub("^[0-9]+ ","", colnames(featureMeanStd))
colnames(featureMeanStd) <- gsub("^t","time", colnames(featureMeanStd))
colnames(featureMeanStd) <- gsub("^f", "frequency", colnames(featureMeanStd))
colnames(featureMeanStd) <- gsub("Acc", "AccelerateMeter", colnames(featureMeanStd))
colnames(featureMeanStd) <- gsub("Mag", "Magnitude", colnames(featureMeanStd))
colnames(featureMeanStd) <- gsub("BodyBody","Body", colnames(featureMeanStd))
save(featureMeanStd, file = "featureMeanStd.Rdata")
## 


##

## Request 5: From the data set in step 2, creats a second, independent tidy data set with the 
############## with the average of each varible for each activity and each subject.

cateVec = paste(bigTable[,1],bigTable[,2])
tidyBy <- by(featureMeanStd,cateVec,FUN=colMeans)
tidy_average <- do.call(rbind, tidyBy)
subject_activity <-rownames(tidy_average)
tidy_average <-cbind(subject_activity,tidy_average)
write.table(tidy_average, file="tidy_average.txt", sep="\t", row.names =FALSE)

##





