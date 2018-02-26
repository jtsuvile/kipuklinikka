clear all 
close all

%% Load in the data
load('/m/nbe/scratch/braindata/anikins1/EmoWorld/pictures_HS/glm/data_reshaped_inmask.mat') % painted data
load('/m/nbe/scratch/braindata/anikins1/EmoWorld/glm/regressors_matrix_full.mat') % regressors model

%% Create 5000 fake models and run analysis on them
Nperm = 5000;
max_values = zeros(1, Nperm);
min_values = zeros(1, Nperm);
rng(0); % fixes the order that we get in permutations, so those 5000 fake models would be the same if you run the loop again
k = 10^7; % range or just one lambda values to examine

for i = 76:100
    i
    rng(i);
 % Create the fake model
    temp = randperm(size(regressors_matrix_full,1)); % get random indices for all the rows in the matrix
    fake_model= regressors_matrix_full(temp,:); % create a fake matrix by taking the rows from the real one in the order specified in temp
     
 % Run the analysis on it
    x = fake_model;
    glm_results = zeros(size(data_matrix_inmask,2),size(fake_model,2)); 
    tic
    for px = 1:size(data_matrix_inmask,2)
        y = data_matrix_inmask(:,px);
        glm = ridge(y,x,k);
        glm_results(px,:) = glm;
    end
    toc
    
 % Store the min and max values from the whole matrix of results
    max_values(1,i) = max(glm_results(:));
    min_values(1,i) = min(glm_results(:));
    save('/m/nbe/scratch/braindata/anikins1/EmoWorld/glm/min_max_values_perms7_3.mat', 'max_values', 'min_values', '-mat',  '-v7.3')
   
 % Move on    
    clear fake_model
end

clear all

%% Pull the obtained values together
load('min_max_values_perms7_1.mat')
max_1 = max_values(1:50);
min_1 = min_values(1:50);
load('min_max_values_perms7_2.mat')
max_2 = max_values(51:75);
min_2 = min_values(51:75);
load('min_max_values_perms7_3.mat')
max_3 = max_values(76:100);
min_3 = min_values(76:100);
max_all = [max_1 max_2 max_3];
min_all = [min_1 min_2 min_3];

% examine
mean(max_all)
mean(min_all)
quantile(max_all, 0.95)
quantile(min_all, 0.05)

% save
save('/m/nbe/scratch/braindata/anikins1/EmoWorld/glm/min_max_values_all_7.mat', 'max_all', 'min_all', '-mat',  '-v7.3')
csvwrite('/m/nbe/scratch/braindata/anikins1/EmoWorld/glm/min_values_all', min_all)
csvwrite('/m/nbe/scratch/braindata/anikins1/EmoWorld/glm/max_values_all', max_all)
