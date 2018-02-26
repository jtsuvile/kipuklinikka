clear all;
close all;
addpath(genpath('/Users/jtsuvile/Documents/projects/kipupotilaat/code/BodySPM/'));
%%
cfg=[];
cfg.datapath = '/Users/jtsuvile/Documents/projects/kipupotilaat/data/mat-files/';
cfg.subinfopath = '/Users/jtsuvile/Documents/projects/kipupotilaat/data/';
bgdata = csvread([cfg.subinfopath '/subs_bg_info_numeric.csv'], 1, 1);
cfg.niter=0; % do not run cluster correction
cfg.doaverage = 0;
cfg.uncorrected = 0;
cfg.corrtype = 'pearson';
cfg.onesided = [1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0]; % does the final data have one or two shapes
cfg.mapnames = {'emotions_0','emotions_1','emotions_2','emotions_3','emotions_4','emotions_5','emotions_6','pain_0','pain_1','sensitivity_0','sensitivity_1', 'sensitivity_2'};
cfg.display_mapnames = {'Sadness','Joy','Anger','Surprise','Fear','Disgust','Neutral',...
    'Acute pain','Chronic pain',...
    'tactile sensitivity', 'pain sensitivity', 'hedonic sensitivity'};
%%
fi = fopen([cfg.subinfopath '/subs_bg_info_numeric.csv']);
variable_names_raw = textscan(fi,'%s',46,'Delimiter',',');
fclose(fi);
variable_names = variable_names_raw{1};
variable_names(1) = [];
variable_names = regexprep(variable_names,'[^a-zA-Z]','');
cfg.list = [cfg.datapath '/list.txt'];
cfg.grid = 0;
%%
cfg.niter=10; % for cluster correction
cfg.th=0.06:0.01:0.4;
cfg.ref = 9; %chronic pain
for i=1:7%length(cfg.mapnames)
    if i~=cfg.ref
        cfg.condition = i;
        %cfg.rawdatafile = [cfg.datapath cfg.mapnames{i} '_raw_data_matrix.mat'];
        bspm = bodySPM_glm_twomaps(cfg);
        save([cfg.datapath 'corr_'  cfg.mapnames{cfg.ref} '_' cfg.mapnames{i}], 'bspm')
    end
end
%%
clear bspm;
close all;
% NB : piirra samoilla axes?
n=12;
cfg.ref=9;
pain = bgdata(:,15);
load([cfg.datapath 'corr_' cfg.mapnames{cfg.ref} '_' cfg.mapnames{n}])
hist(bspm.correl.r(find(pain==0),1), -0.9:0.1:0.9)
title(['Subject-wise correlations between chronic pain and hedonic sensitivity nonchronic subs']);
%%
saveas(gcf,[cfg.subinfopath 'figures/hist_correl_' cfg.mapnames{cfg.ref} '_and_' cfg.mapnames{n} '_nonchronic.png'])
%%
pain = bgdata(:,37);
filt = find(pain~=0);
filt = find(~isnan(bspm.correl.r(:,1)));
corr(pain(filt), bspm.correl.r(filt,1))