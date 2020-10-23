clear all;
close all;
addpath(genpath('/Users/jtsuvile/Documents/projects/kipupotilaat/code/BodySPM/'));
%% Pixel-wise two-sample t-test for two maps
allttest2={};
cfg=[];
cfg.datapath = '/Users/jtsuvile/Documents/projects/kipupotilaat/data/mat-files/';
cfg.subinfopath = '/Users/jtsuvile/Documents/projects/kipupotilaat/data/';
cfg.niter=0; % do not run cluster correction
cfg.doaverage = 0;
cfg.uncorrected = 0;
cfg.onesided = [1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0]; % does the final data have one or two shapes
cfg.mapnames = {'emotions_0','emotions_1','emotions_2','emotions_3','emotions_4','emotions_5','emotions_6','pain_0','pain_1','sensitivity_0','sensitivity_1', 'sensitivity_2'};
%%
for j=1:7%length(cfg.mapnames)
    cfg.comparemaps = 1;
    cfg.condition = j;
    cfg.rawdatafile = [cfg.datapath cfg.mapnames{j} '_raw_data_matrix.mat'];
    cfg.compdatafile = [cfg.datapath cfg.mapnames{8} '_raw_data_matrix.mat']; % 8: acute pain, 9: chronic pain
    
    disp(['running two sample t-test between ' cfg.mapnames{j} ' and ' cfg.mapnames{8}]);
    cfg.niter=0;
    cfg.uncorrected=1;
    bspm = bodySPM_ttest2_kipu(cfg);
    save([cfg.datapath 'bspm_ttest2_' cfg.mapnames{j} '_group_' variable_names{look_at(m)}], 'bspm');
    
end