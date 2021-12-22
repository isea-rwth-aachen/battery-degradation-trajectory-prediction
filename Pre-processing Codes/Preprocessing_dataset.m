%% data preprocessing script for generating sequence to sequence learning training dataset for lifetime prediction

% Authors: Neil Sengupta, Weihan Li
% Date: December, 2020
% Institute: ISEA, RWTH Aachen University

clc;
clear;

%% load preliminary dataset file

%put current filepath of the raw dataset file in the variable 'dataset_filepath'

dataset_filepath = '';      % put filepath to load the dataset from, if not loading from current active folder

if isempty(dataset_filepath)
  filename = 'Lifetime_Prediction_Dataset_ISEA.mat';
else
  filename = dataset_filepath + 'Lifetime_Prediction_Dataset_ISEA.mat';
end
load(filename);


%% %% OPTIONAL - Add noise to input capacity history

add_noise = 0;     %% put as 1 if noise is to be added
Noisy_Prefix = '_'; %% put prefix 'Noisy' when saving file, if noise is added
%noise type is additive white (zero mean) gaussian noise (AWGN)

if (add_noise == 1)
    Noisy_Prefix = '_Noisy_';
    mu = 0;               % mean of noise
    sigma = 0.005;        % variance of noise

    for i = 1:length(TDS)
        
        TDS(i).Clean_History = TDS(i).History;  %storing the denoised history seperately
        
        for j = 1:length(TDS(i).Clean_History)
            val2 = TDS(i).Clean_History(j);     % taking each capacity value
            r2 = normrnd(mu,sigma);             % generating random noise
            nval2 = val2*r2;                    % scaling noise to value
            TDS(i).History(j) = val2 + nval2;   % adding noise 
        end
    end
end

%% Padding the dataset 

% find maximum length of input and target with a loop
for i = 1:length(TDS)
    padInp(i) = length(TDS(i).History);
    padTrg(i) = length(TDS(i).Target);
end

imax = max(padInp);       % maximum length of input (capacity history)
tmax = max(padTrg);       % maximum length of target (future capacity series)
buffer = 1;               % padding buffer, must be >= 1

for i = 1:length(TDS)
    padLengthInput = (imax + buffer) - length(TDS(i).History);    % set input padding length 
    padLengthTargt = (tmax + buffer) - length(TDS(i).Target);   % set target padding length 
    padding_input = zeros(1,padLengthInput);                      % pad input with 0
    padding_targt = zeros(1,padLengthTargt);                      % pad target with 0 
    
    TDS(i).P_History = [padding_input, TDS(i).History];           % padded history
    TDS(i).P_Target = [TDS(i).Target, padding_targt];           % padded target
end


%% seperate cells for training and testing

test_cells = [15,20,25,30,35];      % cell numbers that should be in test data, from the raw dataset

Train_Set = struct;
Test_Set = struct;
ctr = 1;                            % sample counter for training cells
cte = 1;                            % sample counter for testing cells

for i = 1:length(TDS)
    cell = TDS(i).Cell;
    if ismember(cell, test_cells)                      % check if current sample is from testing cell
        
        % put cell data into test cell dataset
        Test_Set(cte).Cell = cell;                     
        Test_Set(cte).Sample = cte;
        Test_Set(cte).History_cycle = TDS(i).History_Cycle;    % cycle numbers of capacity history
        Test_Set(cte).Target_cycle = TDS(i).Target_Cycle;      % cycle numbers of target capacity series 
        Test_Set(cte).History = TDS(i).P_History;
        Test_Set(cte).Target = TDS(i).P_Target;
        cte = cte + 1;
    else                                              % if current sample is from training cell
        
        % put cell data into training cell dataset
        Train_Set(ctr).Cell = cell;
        Train_Set(ctr).Sample = ctr;
        Train_Set(ctr).History_cycle = TDS(i).History_Cycle;   % cycle numbers of capacity history
        Train_Set(ctr).Target_Cycle = TDS(i).Target_Cycle;           % cycle numbers of target capacity series 
        Train_Set(ctr).History = TDS(i).P_History;
        Train_Set(ctr).Target = TDS(i).P_Target;
        ctr = ctr + 1;
    end
end

%% Saving the datasets

 Current_Date = convertCharsToStrings(date);    % get current date
 Label = 'S2SLearning_';                        % write custom label
 
 % Add save filepath if nessecary
 save_filepath = '';                            % put file path here if not saving to current active folder
 
 % make training and testing dataset filenames
 if isempty(save_filepath)    
    Training_dataset_filename = Label + Current_Date + Noisy_Prefix + 'Train_Set'; 
    Testing_dataset_filename = Label + Current_Date + Noisy_Prefix + 'Test_Set';
 else   
    Training_dataset_filename = save_filepath + Label + Current_Date + Noisy_Prefix + 'Train_Set'; 
    Testing_dataset_filename = save_filepath + Label + Current_Date + Noisy_Prefix + 'Test_Set';
 end
 
 % save the files
 save(Training_dataset_filename,'Train_Set') 
 save(Testing_dataset_filename,'Test_Set') 
 
 %% end






