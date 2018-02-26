%% Visualize
clear all;
close all;
addpath(genpath('/Users/jtsuvile/Documents/projects/kipupotilaat/code/BodySPM/'));
%%

cfg=[];
cfg.datapath = '/Users/jtsuvile/Documents/projects/kipupotilaat/data/mat-files/';
cfg.subinfopath = '/Users/jtsuvile/Documents/projects/kipupotilaat/data/';

%%
bgdata = csvread([cfg.subinfopath '/subs_bg_info_numeric.csv'], 1, 1);
fi = fopen([cfg.subinfopath '/subs_bg_info_numeric.csv']);
variable_names_raw = textscan(fi,'%s',46,'Delimiter',',');
fclose(fi);
variable_names = variable_names_raw{1};
variable_names(1) = [];
cfg.list = [cfg.datapath '/list.txt'];
%%
cfg.onesided = [1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0]; % does the final data have one or two shapes
cfg.mapnames = {'emotions_0','emotions_1','emotions_2','emotions_3','emotions_4','emotions_5','emotions_6','pain_0','pain_1','sensitivity_0','sensitivity_1', 'sensitivity_2'};
cfg.display_mapnames = {'Sadness','Joy','Anger','Surprise','Fear','Disgust','Neutral',...
    'Acute pain','Chronic pain',...
    'tactile sensitivity', 'pain sensitivity', 'hedonic sensitivity'};
base_oneside=uint8(imread('bodySPM_base2.png'));
mask_oneside=uint8(imread('bodySPM_base3.png'));
mask_oneside=mask_oneside*.85;


mask_front=uint8(imread('bodySPM_frontback_mask.png'));
mask_frontback = [mask_front mask_front];
mask_frontback=mask_frontback(:,:,1);
mask_frontback=mask_frontback*.85;
front_outline = double(imread('bodySPM_front_outline.png'));
back_outline = double(imread('bodySPM_back_outline.png'));
frontback_outline = [front_outline back_outline];

%% One sample t-test
% for pains: M = 25, y=7; how_many_conds = 2;
% for sensitivity: M = 40, y=9; how_many_conds = 3;
% for emotions: M=35, y=0; how_many_conds = 7;
what = 'sensitivity';
if  strcmp(what, 'emotions')
    M=30;
    y=0;
    how_many_conds = 7;
    load([cfg.datapath 'limits_ttest_emotions_joint_FDR.mat'])
    order_conds = [3,5,6,2,1,4,7];
elseif  strcmp(what, 'pains')
    M=25;
    y=7;
    how_many_conds = 2;
    load([cfg.datapath 'limits_ttest_pains_joint_FDR.mat'])
    order_conds = 1:2;
elseif  strcmp(what, 'sensitivity')
    M=40;
    y=9;
    how_many_conds=3;
    load([cfg.datapath 'limits_ttest_sensitivity_joint_FDR.mat'])
    order_conds = 1:3;
end

close all;
figure('Position', [200, 500, 900, 300])
for i=1:how_many_conds
    subplot(1,how_many_conds+1,i);
    cond = order_conds(i)+y;
    load([cfg.datapath 'bspm_ttest_' cfg.mapnames{cond} '.mat']);
    %map=cbrewer('div','RdBu',201);
    %map=flipud(map);
    map_cool = fliplr(colormap('hot'));
    map_hot = colormap('hot');
    map = [flipud(map_cool); map_hot];
    tvals = bspm.ttest.tval;
    pvals = bspm.ttest.pval;
    tvals(abs(tvals)<limits.tval(2)) = 0 ;
    %M=max(max(abs(tvals)));
    if(cfg.onesided(cond)==1)
        mask = mask_oneside;
        h = imagesc(tvals(:,1:171),[-M M]);
        %map(round(length(map)/2),:)=[.3 .3 .3];
    else
        map = map(round(length(map)/2):end,:);
        mask = mask_frontback;
        h = imagesc(tvals-frontback_outline, [0 M]);
    end
    set(h,'AlphaData',mask)
    title(cfg.display_mapnames{cond}, 'FontSize', 18)
    colormap(map)
    %colorbar
    axis off
    box off
    set(gcf,'color','w');
end
subplot(1,how_many_conds+1,i+1)
if strcmp(what, 'emotions')
    c = colorbar('westoutside', 'Ticks',-M:10:M, 'FontSize', 16);
    c.Position = [0.8411 0.1100 0.02 0.8167];
    c.AxisLocation = 'in';
    caxis([-M M]);
    
else
    c = colorbar('westoutside', 'Ticks',0:10:M, 'FontSize', 16);
    c.Position = [0.7411 0.1100 0.02 0.8167];
    c.AxisLocation = 'in';
    caxis([0 M]);
    
end

axis off
box off
set(gcf,'color','w');
%%
%print(, '-dpng', '-r0')
if strcmp(what, 'emotions')
    set(gcf, 'PaperPosition', [0 0 24 8]); %x_width=10cm y_width=15cm
elseif  strcmp(what, 'sensitivity')
    set(gcf, 'PaperPosition', [0 0 15 5]);
else
    set(gcf, 'PaperPosition', [0 0 12 5]);
end
saveas(gcf,[cfg.subinfopath 'figures/ttest_' what '.png'])
%% Visualise percentages
% for pains: M = 25, y=7; how_many_conds = 2;
% for sensitivity: M = 40, y=9; how_many_conds = 3;
% for emotions: M=35, y=0; how_many_conds = 7;if  strcmp(what, 'emotions')

M=50;
y=7;
how_many_conds = 2;
order_conds = 1:2;
close all;
figure('Position', [200, 500, 900, 300])
map_cool = fliplr(colormap('hot'));
map_hot = colormap('hot');
map = [flipud(map_cool); map_hot];
map = map(round(length(map)/2):end,:);

for i=1:how_many_conds
    subplot(1,how_many_conds+1,i);
    cond = order_conds(i)+y;
    load([cfg.datapath 'bspm_percentages_' cfg.mapnames{cond} '.mat']);
    tvals = bspm.perc;
    mask = mask_frontback;
    h = imagesc(tvals-frontback_outline, [0 M]);
    set(h,'AlphaData',mask)
    title(cfg.display_mapnames{cond}, 'FontSize', 18)
    colormap(map)
    axis off
    box off
    set(gcf,'color','w');
end
subplot(1,how_many_conds+1,i+1)

c = colorbar('westoutside', 'Ticks',0:5:M, 'FontSize', 16);
c.Position = [0.6511 0.1100 0.02 0.8167];
c.AxisLocation = 'in';

caxis([0 M]);
axis off
box off
set(gcf,'color','w');
%%
%print(, '-dpng', '-r0')

set(gcf, 'PaperPosition', [0 0 10.5 5]);
saveas(gcf,[cfg.subinfopath 'figures/percentages_pain.png'])
%% Two sample t-test
% for pains: M = 25, y=7; how_many_conds = 2;
% for sensitivity: M = 40, y=9; how_many_conds = 3;
% for emotions: M=35, y=0; how_many_conds = 7;
what = 'emotions';
if  strcmp(what, 'emotions')
    M=10;
    y=0;
    how_many_conds = 7;
    load([cfg.datapath 'limits_ttest_emotions_joint_FDR.mat'])
elseif  strcmp(what, 'pains')
    M=10;
    y=7;
    how_many_conds = 2;
    load([cfg.datapath 'limits_ttest_pains_joint_FDR.mat'])
elseif  strcmp(what, 'sensitivity')
    M=10;
    y=9;
    how_many_conds=3;
    load([cfg.datapath 'limits_ttest_sensitivity_joint_FDR.mat'])
end
grouping = 'painrecent';
close all;
figure('Position', [200, 500, 900, 300])
for i=1:how_many_conds
    subplot(1,how_many_conds,i);
    cond = i+y;
    load([cfg.datapath 'bspm_ttest2_' cfg.mapnames{cond} '_group_' grouping '.mat']);
    %map=cbrewer('div','RdBu',201);
    %map=flipud(map);
    map_cool = fliplr(colormap('hot'));
    map_hot = colormap('hot');
    map = [flipud(map_cool); map_hot];
    tvals = bspm.ttest2.tval;
    tvals(abs(tvals)<limits.tval(2)) = 0;
    %M=max(max(abs(tvals)));
    if(cfg.onesided(cond)==1)
        mask = mask_oneside;
        h = imagesc(tvals(:,1:171),[-M M]);
        %map(round(length(map)/2),:)=[.3 .3 .3];
    else
        %map = map(round(length(map)/2):end,:);
        mask = mask_frontback;
        h = imagesc(tvals+frontback_outline, [-M M]);
    end
    set(h,'AlphaData',mask)
    title(cfg.display_mapnames{cond},'FontSize', 18)
    colormap(map)
    colorbar
    axis off
    box off
    set(gcf,'color','w');
end
suptitle(['Two sample t-test with groups by ' grouping]);
%%
if strcmp(what, 'emotions')
    set(gcf, 'PaperPosition', [0 0 24 8]); %x_width=10cm y_width=15cm
elseif  strcmp(what, 'sensitivity')
    set(gcf, 'PaperPosition', [0 0 16 5]);
else
    set(gcf, 'PaperPosition', [0 0 12 5]);
end
saveas(gcf,[cfg.subinfopath 'figures/ttest2_' what '_grouping_' grouping '.png'])
%% checking stuff

temp_1 = ones(size(rawmat,1),size(rawmat,2));
temp_2 = ones(size(rawmat,1),size(rawmat,2));
temp_1(:) = P1;
temp_2(:) = P; 

subplot(1,2,1)
imagesc(temp_1)
colorbar

title('p values from ttest command')
subplot(1,2,2)
imagesc(temp_2)
colorbar
title('p values from 1-cdf')
%saveas(gcf,[cfg.subinfopath 'figures/pvalue_mystery_2.png'])
%%
temp_3 = zeros(size(mask));
temp_3(in_mask) = tdata;
imagesc(temp_3)
colorbar;
%%
temp_1 = ones(size(mask));
temp_2 = ones(size(mask));
temp_1(in_mask) = P1;
temp_2(in_mask) = P; 

subplot(1,2,1)
imagesc(temp_1)
colorbar

title('p values from ttest command')
subplot(1,2,2)
imagesc(temp_2)
colorbar
title('p values from 1-cdf')