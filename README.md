---
title: "README"
author: "Nagesh"
date: "Monday 22 December 2014"
output: html_document
---


# Section 1
We create a vector of all column names after dropping invalid cahracters.

# Section 2
We read the test values file such that, we limit ourselves to only those columns whose names have either 'mean' or 'std' regardless of the case. To create this list of selected column names, we use the vector created above.

# Section 3
Read the subject and activity files for the test group. Assign row numbers to these data sets so that they can be merged later easily. Read and assign row numbers to the data set of test readings also. These readings are from the file X_test.txt and the selected columns only.

# Section 4
Merge activity and subject data sets based on row numbers. Then, merge the result with the test data on row number (using the file we created above.) Then, use `gather` to convert one-row-by-561-columns to 561 key value pairs. Finally, drop the `rowNum` as it has no further use.

# Section 5
Repeat the sections 1 to 4 for training data.

# Section 6
We now have two datasets of teh same format; one for test and the other for training. They are joined together using rbind_list to create the final output.

# Section 7
Finally, calculate the averages using the summarise and group_by function.