clear all 
close all

%% settings
addpath(genpath('/m/nbe/scratch/braindata/anikins1/EmoWorld/code/')); % toolbox folder
cfg.listspath = '/m/nbe/scratch/braindata/anikins1/EmoWorld/groups_HS'; % where my grouping lists are

%% load in the data
% 100 subjects, row is a subject, y is a single pixel value
% load('/m/nbe/scratch/braindata/anikins1/EmoWorld/outdata/full_resmat_age_hw_HS_bad_maps_cleaned.mat');
% test_pile = full_resmat;
% clear full_resmat
% % save('/m/nbe/scratch/braindata/anikins1/EmoWorld/outdata/test_pile.mat', 'test_pile', '-mat')
% % load('/m/nbe/scratch/braindata/anikins1/EmoWorld/outdata/test_pile.mat')
% 
% % reshape it so we have 14 rows per subject (1 for each emotion)
% % test=test_pile;
% s=size(test_pile);
% data_matrix=reshape(permute(test_pile,[3 4 1 2]),[s(3)*s(4) s(1)*s(2)]); 
% % Permute changes the order of the dimensions (i.e. in a matrix A 3x2, permute(A,[2 1]) will give the same matrix but as 2x3) 
% % Reshape changes the dimensions so that an matrix A 3x2x4 reshape(A,[3*2 4]) will give a matrix 6x4
% % each row is 1 emotion from 1 subject, each column is one pixel from their bodymap
% % (i.e. rows are s1emo1, s1emo2, s1emo3, ..., s1emo14, s2emo1...)
% 
% % save the reshaped data so that we don't have to load and reshape it all the time
% save('/m/nbe/scratch/braindata/anikins1/EmoWorld/pictures_HS/glm/data_reshaped.mat', 'data_matrix', '-mat', '-v7.3')

% % Now we can start from here!
% load('/m/nbe/scratch/braindata/anikins1/EmoWorld/pictures_HS/glm/data_reshaped.mat')
%

% % throw away everything that is not in the mask
base=uint8(imread('bodySPM_base2.png'));
base2=base(10:531,33:203,:); 
mask=uint8(imread('bodySPM_base3.png'));
mask=mask*.85;
inmask=find(mask>128);
% data_matrix_inmask = data_matrix(:,inmask);

% save('/m/nbe/scratch/braindata/anikins1/EmoWorld/pictures_HS/glm/data_reshaped_inmask.mat', 'data_matrix_inmask', '-mat', '-v7.3')

% Or from here!
load('/m/nbe/scratch/braindata/anikins1/EmoWorld/pictures_HS/glm/data_reshaped_inmask.mat')


%% preprare the matrix of regressors
Nsubj = size(data_matrix_inmask,1)/14;

% can rewrite it in a cycle 
% regressorname = 'Edu';
% Edu = load(sprintf('%s/regressors/%s.csv',cfg.listspath,regressorname)); % take one from ready made regressors
% regressor1 = Edu(1:Nsubj,:);

% regressorname = 'BMIgroup';
% BMIgroup = load(sprintf('%s/regressors/%s.csv',cfg.listspath,regressorname)); % take one from ready made regressors
% regressor2 = BMIgroup(1:Nsubj,:);

regressorname = 'countryName';
countryName = load(sprintf('%s/regressors/%s.csv',cfg.listspath,regressorname)); % take one from ready made regressors
regressor3 = countryName(1:Nsubj,:);

regressorname = 'civilization';
civilization = load(sprintf('%s/regressors/%s.csv',cfg.listspath,regressorname)); % take one from ready made regressors
regressor4 = civilization(1:Nsubj,:);

regressorname = 'lanfam';
lanfam = load(sprintf('%s/regressors/%s.csv',cfg.listspath,regressorname)); % take one from ready made regressors
regressor5 = lanfam(1:Nsubj,:);

% regressorname = 'Gender';
% Gender = load(sprintf('%s/regressors/%s.csv',cfg.listspath,regressorname)); % take one from ready made regressors
% regressor6 = Gender(1:Nsubj,:);

% regressorname = 'Western';
% Western = load(sprintf('%s/regressors/%s.csv',cfg.listspath,regressorname)); % take one from ready made regressors
% regressor7 = Western(1:Nsubj,:);

regressorname = 'Age';
regressor8 = load(sprintf('%s/regressors/%s.csv',cfg.listspath,regressorname)); % take one from ready made regressors

regressorname = 'Edu_all';
regressor9 = load(sprintf('%s/regressors/%s.csv',cfg.listspath,regressorname)); % take one from ready made regressors

regressorname = 'BMI_all';
regressor10 = load(sprintf('%s/regressors/%s.csv',cfg.listspath,regressorname)); % take one from ready made regressors

regressorname = 'Gender_all';
regressor11 = load(sprintf('%s/regressors/%s.csv',cfg.listspath,regressorname)); % take one from ready made regressors

regressorname = 'Western_all';
regressor12 = load(sprintf('%s/regressors/%s.csv',cfg.listspath,regressorname)); % take one from ready made regressors


% put together all the regressors in Nsubj X categories form
% reg_matrix = [regressor1, regressor2, regressor3, regressor4, regressor5, regressor6, regressor7];
reg_matrix = [regressor3 regressor4 regressor5 regressor8 regressor9 regressor10 regressor11 regressor12];
regressors_matrix = reshape(repmat(reg_matrix(:)',14,[]),[],size(reg_matrix, 2)); % reshape the regressors matrix so that we have 
                                                                   % each row repeated 14 times - for each row in the data_matrix

% build a separate regressor for emotions; it depends on the N of subjects
regressor_emo = repmat(diag(ones(1,14)), Nsubj, 1); 

% glue together all the regressors
% regressors_matrix_full = [regressors_matrix, regressor_emo];
regressors_matrix_full = [regressor_emo, regressors_matrix];
% regressors_matrix_full = [regressor_emo];

% create the labels
% labelsEdu = {'ElementarySc', 'HighSc', 'University'};
% labelsBMIgroup = {'underweight', 'normal+overweight', 'obesity'};
labelsCountryName = {'Australia', 'Brazil', 'Canada', 'Croatia', 'Finland', 'Germany', 'India', 'Italy','Mexico', 'Philippines', 'Poland', 'Romania', 'Turkey', 'UK', 'USA', 'other'};
labelsCivilization = {'African', 'Buddhist', 'Hindu', 'Islamic', 'Japanese', 'LatAmerican', 'Orthodox', 'Sinic', 'Western'};
labelsLanfam = {'CentrSemitic', 'Finnic', 'Germanic', 'Indo-Iranian', 'Malayo-Polynesian', 'Romance', 'Slavic', 'Turkic', 'other'};
% labelsGender = {'Female', 'Male'};
% labelsWestern = {'Western', 'Non-Western'};
labelsEdu_all = {'Edu'};
labelsAge = {'Age'};
labelsBMI_all = {'BMI'};
labelsGender_all = {'Gender'};
labelsWestern_all = {'Western_all'};
labelsEmotions = {'Neutral' 'Fear' 'Anger'  'Disgust' 'Sadness' 'Happiness'  'Surprise'  'Anxiety' 'Love' 'Depression' 'Contempt' 'Pride' 'Shame' 'Jealousy'};

% labels = [labelsEmotions labelsEdu labelsBMIgroup labelsCountryName labelsCivilization labelsLanfam labelsGender labelsWestern];
labels = [labelsEmotions labelsCountryName labelsCivilization labelsLanfam labelsAge labelsEdu_all labelsBMI_all labelsGender_all labelsWestern_all];

% save('/m/nbe/scratch/braindata/anikins1/EmoWorld/glm/regressors_matrix_full.mat', 'regressors_matrix_full', '-mat', '-v7.3')

%% Do the robust GLM/ridge/lasso
%  You call it for each pixel 
% robustfit(y,x)
% y single column of pixel values
% each row is a subject 
% x matrix of regressors. The one you built
x = regressors_matrix_full;
glm_results = zeros(size(data_matrix_inmask,2),size(regressors_matrix_full,2)); % +1 column for robustfit()
k = 10^7; % range or just one lambda value to examine

% do it for every pixel 
for px = 1:size(data_matrix_inmask,2)
%     px
    y = data_matrix_inmask(:,px);
%     glm = robustfit(x,y);
    glm = ridge(y,x,k);
%     glm = lasso(x,y);
    glm_results(px,:) = glm;
end

% % or for one specific to test out lambdas
% k = 10.^(-4:10);
% glm_results = zeros(1,size(regressors_matrix_full,2));
% % px = 2106;
% px = 15599;
% % px = 24763;
% y = data_matrix_inmask(:,px);
% glm = ridge(y,x,k);
% figure
% plot(k,glm,'LineWidth',2)
% grid on
% xlabel('Ridge Parameter')
% ylabel('Standardized Coefficient')
% title('{\bf Ridge Trace}')
% export_fig(['/m/nbe/scratch/braindata/anikins1/EmoWorld/glm/px15599_3.png'], '-png', '-m2', '-nocrop') % high quality      


save('/m/nbe/scratch/braindata/anikins1/EmoWorld/glm/ridge_Em_CN_Ci_LF_A_Ed_BMI_G_W_all_subjects_lambda10^7.mat', 'glm_results', '-mat')
% load('/m/nbe/scratch/braindata/anikins1/EmoWorld/glm/ridge_E_Ed_BMI_CN_C_LF_G_all_subjects_lambda10^7.mat')

%% Threshold results by 5th and 95th quantiles from the max/min stats resulting from permutations
load('/m/nbe/scratch/braindata/anikins1/EmoWorld/glm/ridge_Em_CN_Ci_LF_A_Ed_BMI_G_W_all_subjects_lambda10^7.mat')
thresh = glm_results;
load('/m/nbe/scratch/braindata/anikins1/EmoWorld/glm/min_max_values_all_7.mat')
max_th = quantile(max_all, 0.95);
min_th = quantile(min_all, 0.05);
indices=find(glm_results>min_th & glm_results<max_th);
thresh(indices) = 0;


%% Visualize the results in bodymaps similarly to ttest results
% reshape all the glm_results from vector-per-pixel back to 2D picture form
% if we were using robustfit, ignore the very first one: it's the constant term 
% % beta_maps = zeros(522, 171, size(regressors_matrix_full,2)+1); % again, only for robustfit
beta_maps = zeros(522, 171, size(glm_results,2));
for r = 1:size(glm_results,2)
    container = beta_maps(:,:,r);
    container(inmask)=glm_results(:,r);
    beta_maps(:,:,r) = container;
end

% same but for thresholded data
beta_maps = zeros(522, 171, size(glm_results,2));
for r = 1:size(glm_results,2)
    container = beta_maps(:,:,r);
    container(inmask)=thresh(:,r);
    beta_maps(:,:,r) = container;
end

% set the colormap
th = 0; % this is the threshold after which we assume the stuff is significant
NumCol = 100; % number of colors
M=max(abs(glm_results(:))); % maximum beta value
non_sig=round(th/M*NumCol); % proportion of non significant colors
hotmap=hot(NumCol-non_sig);
coldmap=flipud([hotmap(:,3) hotmap(:,2) hotmap(:,1) ]);
hotcoldmap=[
    coldmap
    zeros(2*non_sig,3);
    hotmap
    ];

% Now draw a plot
figure(11001)
set(gcf,'color','white')
plot = (figure(11001)); % store figure in a variable to change it later 
set(plot,'Units', 'Pixels', 'Position', [1, 1, 3600, 3600], 'PaperUnits', 'Points', 'PaperSize', [3600, 3600]);  % force the figure to become fullscreen, so that people in the plot won't look like noodles

make_it_tight = true;
subplot = @(m,n,p) subtightplot (m, n, p, [0.03 0], [0.01 0.03], [0.01 0.01]);
if ~make_it_tight,  clear subplot;  end


for cat=1:size(glm_results,2)
    subplot(2,8,cat) % adjust how many rows and columns in the picture needed
    h=imagesc(beta_maps(:,:,cat),[-M M]);
    set(h,'AlphaData',mask)
    colormap(hotcoldmap)
    axis off
    pbaspect([1 3.3 1])
    box off
    title(labels(cat),'FontSize',10)
end  

% Save it
% export_fig(['/m/nbe/scratch/braindata/anikins1/EmoWorld/pictures_HS/glm/ridge_E_Ed_BMI_CN_C_LF_G_all_subjects_lambda10^7.png'], '-png', '-m2', '-nocrop') % high quality      
export_fig(['/m/nbe/scratch/braindata/anikins1/EmoWorld/glm/ridge_Em_CN_Ci_LF_A_Ed_BMI_G_W_all_subjects_lambda10^7.png'], '-png', '-m2', '-nocrop') % high quality      

figure(1)
set(gcf,'color','white')
h=imagesc(beta_maps(:,:,cat),[-M M]);
% subplot(7,9,60)
% axis off
% box off
colormap(hotcoldmap)
imagesc(beta_maps(:,:,1),[-M M])
colorbar

% export_fig(['/m/nbe/scratch/braindata/anikins1/EmoWorld/pictures_HS/glm/cb_ridge_E_Ed_BMI_CN_C_LF_G_all_subjects_lambda10^7.png'], '-png', '-m2', '-nocrop') % high quality      
export_fig(['/m/nbe/scratch/braindata/anikins1/EmoWorld/pictures_HS/glm/cb_ridge_Em_CN_Ci_LF_A_Ed_BMI_G_W_all_subjects_lambda10^7.png'], '-png', '-m2', '-nocrop') % high quality      





%% Taneli's code

% % % % % % test=test_pile;
% % % % % % s=size(test)
% % % % % % test_reshaped=reshape(permute(test,[3 4 1 2]),[s(3)*s(4) s(1)*s(2)]); %% Permute changes the order of the dimensions (i.e. in a matrix A 3x2, permute(A,[2 1]) will give the same matrix but as 2x3) )
% % % % % % % Reshape changes the dimensions so that an matrix A 3x2x4 reshape(A,[3*2
% % % % % % % 4]) will give a matrix 6x4
% % % % % % % you do analysis test_reshaped
% % % % % % test_reshaped_analyzed=test_reshaped;
% % % % % % backtonormal=permute(reshape(test_reshaped_analyzed,[s(3) s(4) s(1) s(2)]),[3 4 1 2]);


