**NOTE: For access to the modeling code, please contact Weihan Li at weihan.li@isea.rwth-aachen.de for the academic license. Only the data preprocessing code is available without agreeing to a license.**

# Preprocessing data in MATLAB
The 'Degradation_Prediction_Dataset_ISEA.mat' file contains the preliminary dataset, which can be further processed to obtain the training and testing cell datasets to be used for training a sequence-to-sequence LSTM-RNN model for lifetime prognosis of Li-ion cells. The file contains a MATLAB structure 'TDS' (short for training data set). This is an already pre-organised and arranged dataset file for ease of use, from the raw battery sensor data obtained from the aging experiments. The complete raw sensor data files is planned to be made available upon reasonable request. 

The TDS structure contains the following (column) fields:

1. **Cell**: The cell number to which the row data belongs.
2. **Sample**: The sample number of the current row.
3. **History_Cycle**: The series of cycle numbers associated with the input capacity history series of the present row, beginning with 0 and having 5 cycle intervals.
4. **History**: The capacity history of the present cell, for the current sample row, corresponding to the 'History_Cycle' array. This is an array of maximum capacity values, in Ah.
5. **Target_Cycle_Expanded**: The series of cycle numbers associated with the target future capacity series of the present row, continuing after the last cycle number of the 'History_Cycle' array and having 5 cycle intervals.
6. **Target_Expanded**: The future capacity degradation series of the present cell, for the current sample row, corresponding to the 'Target_Cycle_Expanded' array. This is an array of maximum capacity values, in Ah.
7. **Target_Cycle**: The series of cycle numbers associated with the target future capacity series of the present row, continuing after the last cycle number of the 'History_Cycle' array and having 50 cycle intervals. This array is used as output labels to the model.
8. **Target**: The future capacity degradation series of the present cell, for the current sample row, corresponding to the 'Target_Cycle' array. This is an array of maximum capacity values, in Ah. This array is used as output labels to the model.   

This structure needs some further preprocessing steps which can be done with the attached MATLAB script 'Preprocessing_MATLAB_dataset.m'. The function of that script are as follows:

1. **OPTIONAL - Add Additive white gaussian noise to the input**. The default values are those which are used in the paper, but the user can choose the mean and variance of the noise.
2. **Add zero padding** to the input and target arrays. User can choose the padding buffer. 
3. **Split the complete dataset into training and testing datasets.** User can choose the number of cells to be kept aside for testing, as well as the specific cell numbers. 

# Further preprocessing data in Python

The file 'Generating_features_labels_and_training_testing_split.py' is used to convert the training and testing dataset generated by MATLAB using the previous script, and further process it to generate the features and labels arrays required by tensorflow for setting up the deep learning models. This script is also used split the training data into training and validation-while-training datasets, which is optional before modelling. 

The file contains two functions:

1. **array_shuffler(array_1,array_2)** - This function takes two arrays of equal length and shuffles them in tandem, simultaneously, so that the correlation between individual rows of both arrays are maintained.

2. **generate_dataset_from_rawfile(datapath, dataname, savepath, shuffle=True)** - This function takes the file path of the .mat file generated using the matlab script, gets the dataset as a pandas dataframe and finally seperates the features and labels into two seperate numpy arrays and saves them, while also returning them back for further use. 

Further details can be found as comments in the code files. 
