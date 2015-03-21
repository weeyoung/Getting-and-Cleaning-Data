# if file doesnt exist -> download it
if (!file.exists("getdata-projectfiles-UCI HAR Dataset.zip")){
  dataurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(dataurl, destfile = "getdata-projectfiles-UCI HAR Dataset.zip",method = "curl")
}
if(!file.exists("UCI HAR Dataset")) {
	unzip("getdata-projectfiles-UCI HAR Dataset.zip")
}

# extract all data 
x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
features <- read.table("UCI HAR Dataset/features.txt")

#1. Merges the training and the test sets to create one data set.
x_merged <- rbind(x_train,x_test)
y_merged <- rbind(y_train, y_test)
subject_merged <- rbind(subject_train, subject_test)

colnames(subject_merged) <- "SubjectID"
colnames(y_merged) <- "ActivityID"
featureColumnNames <- gsub("\\(|\\)", "", features[[2]])
featureColumnNames <- tolower(featureColumnNames)
colnames(x_merged) <- featureColumnNames
merged <- cbind(cbind(subject_merged, y_merged), x_merged)

#2. Extracts only the measurements on the mean and standard deviation for each measurement. 
fmean <- grep("mean",featureColumnNames,value = TRUE)
fstd <- grep("std",featureColumnNames,value = TRUE)
mean_std <- c(fmean,fstd)
subject_activity <- c("SubjectID","ActivityID")
data <- merged[c(subject_activity, mean_std)]

#3.Uses descriptive activity names to name the activities in the data set
colnames(activity_labels) <- c("ActivityID", "Activity")

activity_labels$Activity <- gsub(pattern = "_", replacement = " ",x = activity_labels$Activity)
activity_labels$Activity <- tolower(activity_labels$Activity)

#4.Appropriately labels the data set with descriptive variable names. 
cleanData <- merge(x = data,y = activity_labels, by = "ActivityID")
cleanData <- cleanData[,!(names(cleanData) %in% c("ActivityID"))]

#5 From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
averageData <- aggregate(cleanData[mean_std],
          by=list(SubjectID=cleanData$SubjectID,Activity=cleanData$Activity),
          FUN=mean)
averageData <- averageData[order(averageData$SubjectID,averageData$Activity),]

write.table(averageData, file = "result.txt", row.names = FALSE)
