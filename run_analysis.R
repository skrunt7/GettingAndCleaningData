
library(plyr);

##Download the required dataset

filename <- "getdata_dataset.zip"
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

##Read the files in
activityTest  <- read.table("UCI HAR Dataset/test/Y_test.txt")
activityTrain <- read.table("UCI HAR Dataset/train/Y_train.txt")
subjectTrain <- read.table("UCI HAR Dataset/train/subject_train.txt")
subjectTest  <- read.table("UCI HAR Dataset/test/subject_test.txt")
featuresTest  <- read.table("UCI HAR Dataset/test/X_test.txt")
featuresTrain <- read.table("UCI HAR Dataset/train/X_train.txt")

##Merges the training and the test sets to create one data set
subject <- rbind(subjectTrain, subjectTest)
activity<- rbind(activityTrain, activityTest)
features<- rbind(featuresTrain, featuresTest)

names(subject)<-c("subject")
names(activity)<- c("activity")
featuresNames <- read.table("UCI HAR Dataset/features.txt")
names(features)<- featuresNames$V2

merged <- cbind(subject, activity)
data <- cbind(features, merged)

##Extract only the measurements on the mean and standard deviation for each measurement
featuresWanted<-featuresNames$V2[grep("mean\\(\\)|std\\(\\)", featuresNames$V2)]
selectedNames<-c(as.character(featuresWanted), "subject", "activity" )
data<-subset(data,select=selectedNames)

##Uses descriptive activity names to name the activities in the data set
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")

##Appropriately labels the data set with descriptive variable names
names(data)<-gsub("^t", "time", names(data))
names(data)<-gsub("^f", "frequency", names(data))
names(data)<-gsub("Acc", "Accelerometer", names(data))
names(data)<-gsub("Gyro", "Gyroscope", names(data))
names(data)<-gsub("Mag", "Magnitude", names(data))
names(data)<-gsub("BodyBody", "Body", names(data))

##Creates a second,independent tidy data set and ouput it
data2<-aggregate(. ~subject + activity, data, mean)
data2<-data2[order(data2$subject,data2$activity),]
write.table(data2, file = "tidydata.txt",row.name=FALSE)


library("memisc")
Write(codebook(data2),
      file="Codebook.md")
