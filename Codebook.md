---
title: "Codebook-C3W3-Course-Project"
author: "Nagesh"
date: "Saturday 20 December 2014"
output: html_document
---
# Analytics problem
(_Copied verbatim from the assignment page_)

One of the most exciting areas in all of data science right now is wearable computing - see for example [this article](http://www.insideactivitytracking.com/data-science-activity-tracking-and-the-battle-for-the-worlds-top-sports-brand/). Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. 

## Data cleansing summary
Given a set of individuals appearing for an experiment, two sets of data are recorded; one for training and the other for test. Every observation of this experiment results in a number of parameters that are recorded. The requirement is to merge the parameter readings across the training and test data sets on the identifier assigned to individuals. The result of merging the datasets is a 'tidy dataset'. Further, some calculations are also required to be done ... 

The description of problem statement for Course 3 (__Getting and Cleaning Data__) Week 3, as described on the Coursera [page](https://class.coursera.org/getdata-016/human_grading/view?assessment_id=3).

## Required result

A script named as `run_analysis.R` that does the following:

* Merges the training and the test sets to create one data set.
* Extracts only the measurements on the mean and standard deviation for each measurement. 
* Uses descriptive activity names to name the activities in the data set
* Appropriately labels the data set with descriptive variable names. 
* From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Problem analysis
The analyis will be done in two parts, viz. raw data and tidy data. B

## Raw data
The data for this project is available [here](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip). 
_WARNING! 60MB file!_ 

We refer to the following paragraphs in the `README.txt` file in the zipped file.

__Para 1__

> The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. 
> Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. 
> Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz.

__Para 2__

> The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window).

__Para 3__

> For each record it is provided:
> ======================================

> - Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
> - Triaxial Angular velocity from the gyroscope. 
> - A 561-feature vector with time and frequency domain variables. 
> - Its activity label. 
> - An identifier of the subject who carried out the experiment.

Here is the information in a tabular format gleaned from the above paragraphs.

Item Name | Item Value
------------- | -------------
Volunteers | 30
Activities | 6
Accelerometer and gyroscope samples per second | 50
Accelerometer and gyroscope sampling window | 2.56
Triaxial acceleration from the accelerometer readings | $3 (axes) * 2 (parts) = 6$
Triaxial Angular velocity from the gyroscope | 3
Total number of samples | $2.56s*50Hz=128$
Number of signals used | $8 (signals) * 3 (axes) + 9=33$
Number of variables estimated | $17$
Number of features recorded per sample | 561

Therefore, in summary, for every subject (test or training), there can be at most six possible activities. For each activity, 128 samples are taken. These samples are fed into calculations resulting in a vector of 561 features.

## Tidy data
The two most important points about tidy data are:
* Every column is a variable.
* Every row is an observation.

Applying this principle in our case, the columns for our data will be as follows:

Column name | Description
----------- | -----------
SubjectId | Identifier of the subject
SubjectType | Test or training subject
ActivityLabel | One of the activities as described in `activity_labels.txt`
FeatureName | One of mean or standard deviation features in `features.txt`
FeatureValue | The value of the feature

And, hence, the row (or, the observation) will provide a value of a certain feature for a given subject (test or train) doing a certain activity.

## Data set - Merged data set
Using the tidy data set created above, we create the merged data set as required using the steps as described below.

### Inspection - subject files

Let us inspect the test and training data files - `test/subject_test.txt` and `train/subject_train.txt`.
```{r}
# Assuming a width of 10 for simplicity
subjectTest<-read.fwf('/home/nsubrahm/data/uci/test/subject_test.txt', widths=10, col.names='subjectId')
subjectTrain<-read.fwf('/home/nsubrahm/data/uci/train/subject_train.txt', widths=10, col.names='subjectId')
```

We have a total of `r nrow(subjectTest)` observations spread across `r nrow(unique(subjectTest))` test subjects. Similarly, we have a total of `r nrow(subjectTrain)` observations spread across `r nrow(unique(subjectTrain))` training subjects. These numbers are consistent with the experimental set-up as described in `README.txt`.

> The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data.

Subject area | Count of subjects
------------ | -----------------
Test | `r nrow(unique(subjectTest))`
Train | `r nrow(unique(subjectTrain))`
Total | `r nrow(unique(subjectTrain)) + nrow(unique(subjectTest))`

It is also clear that, the subjects were divided into two exclusive groups as can be seen from the 'null' output of `merge`  function.
```{r}
library(dplyr)
merge(subjectTrain, subjectTest, by='subjectId')
```

### Inspection - activity files
For every subject - test or train - the activities are saved in the `test/y_test.txt` and `train/y_train.txt` files for test and training data respectively. Let us inspect them.
```{r}
# Assuming a width of 10 for simplicity
testActivities<-read.fwf('/home/nsubrahm/data/uci/test/y_test.txt', widths=10, col.names='activityId')
trainActivities<-read.fwf('/home/nsubrahm/data/uci/train/y_train.txt', widths=10, col.names='activityId')
```

The number unique activities for both test and training subjects are six in number.
```{r}
# Assuming a width of 10 for simplicity
library(dplyr)
unique(testActivities)
unique(trainActivities)
```

We also note that, there are no 'invalid' activity types because the `merge` function returns the number of matched rows as exactly equal to `r nrow(subjectTest)` and `r nrow(subjectTrain)` observations for test and train data sets respectively.
```{r}
activityList<-read.csv('/home/nsubrahm/data/uci/activity_labels.txt',header=FALSE,sep=' ',col.names=c('activityId','activityLabel'))
nrow(merge(activityList, testActivities, by='activityId'))
nrow(merge(activityList, trainActivities, by='activityId'))
```

### Inspection - feature files
Let us inspect the `features.txt` file to have a look into the features.
```{r}
featureList<-read.csv('/home/nsubrahm/data/uci/features.txt',header=FALSE,sep=' ',col.names=c('featureId','featureName'))
```
We have a total of `r nrow(featureList)` features. Let us now verify this in the `test/X_test.txt` and `train/X_train.txt' files.

```{r}
rawList<-lapply(featureList$featureName, function(x) {y<-gsub('\\()','',x);y<-gsub('"','',y); y<-gsub(',','_',y); y<-gsub('\\(','',y); y<-gsub(')','',y); y<-gsub('-','.',y);y })
featureColumnNames<-sapply(rawList, '[[',1)
xTest<-read.delim('/home/nsubrahm/data/uci/test/X_test.txt',header=FALSE,sep="",col.names=featureColumnNames)
```
Item name | Count
--------- | -----
Number of columns | `r ncol(xTest)`
Number of rows | `nrow(xTest)`

### Columns of interest
Since we want to focus only on those measurements that are a mean or a standard deviation, let us generate a vector of such measurements.

```{r}
df1<-data.frame(featureColumnNames)
df1<-tbl_df(df1)
meanStdCols<-filter(df1, grepl('mean|std',ignore.case=TRUE,featureColumnNames))
testFeatureName<-as.vector(meanStdCols$featureColumnNames)
meanStdColValues<-select(xTest, one_of(testFeatureName))
```

There are a total of `r nrow(meanStdCols)` such columns.

### Building the merged dataset

We start with the first record of `X_test.txt` so that we have a list of features and its corresponding value.
```{r}
gather(slice(meanStdColValues,1),featureName,featureValue)
```
We create two separate vectors for feature name and values so that they can be added to the data frame later.
```{r}
feName<-select(gather(slice(meanStdColValues,1),featureName,featureValue),featureName)
feValue<-select(gather(slice(meanStdColValues,1),featureName,featureValue),featureValue)
temp<-data.frame(rowNum=rep(1,length=length(feName)),subjectType=rep('TEST',length=length(feName)),feName,feValue)
```
Thus, for the first record, we have vectors of feature name and values. We have to now generate other vectors of same length.
For this purpose, we have to have files with common row numbers so as to be able to compare successfully.

Row numbers for subjects
```
subjectDf0<-read.fwf('/home/nsubrahm/data/uci/test/subject_test.txt', widths=10, col.names='subjectId')
subjectDf<-mutate(subjectDf0, rowNum=seq(1,to=length(feName)))
```

Row numbers for activities
```
activityDf0<-read.csv('/home/nsubrahm/data/uci/activity_labels.txt',header=FALSE,sep=' ',col.names=c('activityId','activityLabel'))
activityDf<-mutate(activityDf0, rowNum=seq(1,to=length(feName)))
```

Final merge for test subjects
```
part1<-merge(subjectDf, activityDf, by='rowNum')
part1<-select(part1, -activityId)
part2<-merge(part1,temp,by='rowNum')
testSubject<-select(part2, -rowNum)
```

The total number of rows for test subject is `r nrow(testSubject)` that is equal to $2947*6*86$ or, the number of observations times activities and features. We now repeat the steps for the training datasets.

```{r}
xTrain<-read.delim('/home/nsubrahm/data/uci/train/X_train.txt',header=FALSE,sep="",col.names=featureColumnNames)
df1<-data.frame(featureColumnNames)
df1<-tbl_df(df1)
meanStdCols<-filter(df1, grepl('mean|std',ignore.case=TRUE,featureColumnNames))
testFeatureName<-as.vector(meanStdCols$featureColumnNames)
meanStdColValues<-select(xTrain, one_of(testFeatureName))

feName<-select(gather(slice(meanStdColValues,1),featureName,featureValue),featureName)
feValue<-lapply(meanStdColValues, function(x) {xdf<-tbl_df(data.frame(x)); select(gather(xdf,featureName,featureValue),featureValue)})

subjectDf0<-read.fwf('/home/nsubrahm/data/uci/train/subject_train.txt', widths=10, col.names='subjectId')
subjectDf<-mutate(subjectDf0, rowNum=seq(from=1,to=length(subjectDf0$subjectId)))
activityDf0<-read.csv('/home/nsubrahm/data/uci/train/y_train.txt',header=FALSE,sep=' ',col.names=c('activityId'))
activityDf<-mutate(activityDf0, rowNum=seq(from=1,to=length(activityDf0$activityId)))

xTrainDf<-mutate(xTrain, rowNum=seq(from=1,to=nrow(xTrain)))

part1<-merge(subjectDf, activityDf, by='rowNum')
part2<-merge(part1,xTestDf,by='rowNum')
part3<-gather(part2, featureName, featureValue, 4:564)
trainSubject<-select(part3, -rowNum)
```

Finally, we merge them.
```{r}
finalOutput<-rbind_list(testSubject, trainSubject)
activityList<-read.csv('/home/nsubrahm/data/uci/activity_labels.txt',header=FALSE,sep=' ',col.names=c('activityId','activityLabel'))
f2<-merge(finalOutput, activityList, by="activityId")
namedFinalOutput<-select(f2, -activityId)

```
### Subject and activity-wise average of features
To calculate the averages, we use the following:
```{r}
averages<-namedFinalOutput %>% group_by(subjectId, activityLabel, featureName) %>% summarise(mean(featureValue)
```

# References
1. FAQ for this project - https://class.coursera.org/getdata-016/forum/thread?thread_id=50 

[1]: 