## Section 1
featureList<-read.csv('/home/nsubrahm/data/uci/features.txt',header=FALSE,sep=' ',col.names=c('featureId','featureName'))
rawList<-lapply(featureList$featureName, function(x) {y<-gsub('\\()','',x);y<-gsub('"','',y); y<-gsub(',','_',y); y<-gsub('\\(','',y); y<-gsub(')','',y); y<-gsub('-','.',y);y })
featureColumnNames<-sapply(rawList, '[[',1)

## Section 2
xTest<-read.delim('/home/nsubrahm/data/uci/test/X_test.txt',header=FALSE,sep="",col.names=featureColumnNames)
df1<-data.frame(featureColumnNames)
df1<-tbl_df(df1)
meanStdCols<-filter(df1, grepl('mean|std',ignore.case=TRUE,featureColumnNames))
testFeatureName<-as.vector(meanStdCols$featureColumnNames)
meanStdColValues<-select(xTest, one_of(testFeatureName))

## Section 3
subjectDf0<-read.fwf('/home/nsubrahm/data/uci/test/subject_test.txt', widths=10, col.names='subjectId')
subjectDf<-mutate(subjectDf0, rowNum=seq(from=1,to=length(subjectDf0$subjectId)))
activityDf0<-read.csv('/home/nsubrahm/data/uci/test/y_test.txt',header=FALSE,sep=' ',col.names=c('activityId'))
activityDf<-mutate(activityDf0, rowNum=seq(from=1,to=length(activityDf0$activityId)))

xTestDf<-mutate(xTest, rowNum=seq(from=1,to=nrow(xTest)))

## Section 4
part1<-merge(subjectDf, activityDf, by='rowNum')
part2<-merge(part1,xTestDf,by='rowNum')
part3<-gather(part2, featureName, featureValue, 4:564)
testSubject<-select(part3, -rowNum)

## Section 5
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

## Section 6
finalOutput<-rbind_list(testSubject, trainSubject)
activityList<-read.csv('/home/nsubrahm/data/uci/activity_labels.txt',header=FALSE,sep=' ',col.names=c('activityId','activityLabel'))
f2<-merge(finalOutput, activityList, by="activityId")
namedFinalOutput<-select(f2, -activityId)

## Section 7
averages<-namedFinalOutput %>% group_by(subjectId, activityLabel, featureName) %>% summarise(mean(featureValue)

write.table(averages, file='/home/nsubrahm/data/averages.txt', row.name=FALSE)