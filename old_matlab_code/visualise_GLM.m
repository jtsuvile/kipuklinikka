clear all
close all
addpath(genpath('/Users/jtsuvile/Documents/projects/kipupotilaat/code/BodySPM/'));
%%
cfg=[];
cfg.datapath = '/Users/jtsuvile/Documents/projects/kipupotilaat/data/mat-files/';
cfg.subinfopath = '/Users/jtsuvile/Documents/projects/kipupotilaat/data/';
cfg.niter=0; % do not run cluster correction
cfg.doaverage = 0;
cfg.uncorrected = 0;
cfg.onesided = [1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0]; % does the final data have one or two shapes
cfg.mapnames = {'emotions_0','emotions_1','emotions_2','emotions_3','emotions_4','emotions_5','emotions_6','pain_0','pain_1','sensitivity_0','sensitivity_1', 'sensitivity_2'};
cfg.display_mapnames = {'Sadness','Happiness','Anger','Surprise','Fear','Disgust','Neutral',...
    'Acute pain','Chronic pain',...
    'tactile sensitivity', 'pain sensitivity', 'hedonic sensitivity'};
cfg.absval = 1;

%%
fi = fopen([cfg.subinfopath '/subs_bg_info_numeric.csv']);
variable_names_raw = textscan(fi,'%s',46,'Delimiter',',');
fclose(fi);
variable_names = variable_names_raw{1};
variable_names(1) = [];
variable_names = regexprep(variable_names,'[^a-zA-Z]','');
%variables = 38; % BPI_pain_combined = 46, pain = 37, depression = 38

%%
base_oneside=uint8(imread('bodySPM_base2.png'));
mask_oneside=uint8(imread('bodySPM_base3.png'));
mask_oneside=mask_oneside*.85;
mask_binary = mask_oneside;
mask_binary(mask_oneside < 100) = 0;
outline_oneside=bwperim(mask_binary,4)*10;

mask_front=uint8(imread('bodySPM_frontback_mask.png'));
mask_frontback = [mask_front mask_front];
mask_frontback=mask_frontback(:,:,1);
mask_frontback=mask_frontback*.85;
front_outline = double(imread('bodySPM_front_outline.png'));
back_outline = double(imread('bodySPM_back_outline.png'));
frontback_outline = [front_outline back_outline];

%% GLM
% for pains: y=7; how_many_conds = 2;
% for sensitivity:  y=9; how_many_conds = 3;
% for emotions: y=0; how_many_conds = 7;

variables = 37;
what = 'sensitivity';

if strcmp(what, 'emotions')
    order_conds = [3,5,6,2,1,4,7];
    how_many_conds = 7;
    y=0;
    map=cbrewer('div','RdBu',201);
    map=flipud(map);
    map = [0 0 0; map];
    M=0.4;

elseif strcmp(what, 'sensitivity')
    y=9;
    how_many_conds = 3;
    order_conds = 1:3;
    map=cbrewer('div','RdBu',201);
    map=flipud(map);
    map = [0 0 0; map];
    M=0.4;

elseif strcmp(what, 'pains')
    y=7;
    how_many_conds = 2;
    order_conds = 1:2;
end
%%
grouping = variable_names{variables};
close all;
% emotions
figure('Position', [200, 500, 800, 300])
% pains
% figure('Position', [200, 500, 600, 300])
% sensitivity
%figure('Position', [200, 500, 800, 300])

for i=1:how_many_conds
    subplot(1,how_many_conds+1,i);
    cond = order_conds(i)+y;
    load([cfg.datapath 'glm_' grouping '_' cfg.mapnames{cond} '.mat']);
    glm = bspm.glm;
    if(isempty(bspm.plim)|| length(bspm.plim)==1)
        glm(:) = 0;
    else
        glm(bspm.pvals>bspm.plim(2)) = 0;
    end
    
    if(cfg.onesided(bspm.condition)==1)
        glm = -1*abs(glm);
        mask = mask_binary;
        %imagesc(-1*outline_oneside,[-M M]);
        %hold on;
        h = imagesc(glm(:,1:171)-1*outline_oneside,[-M M]);
        set(h,'AlphaData',mask_oneside)
    else
        mask = mask_frontback;
        h = imagesc(glm-frontback_outline, [-M M]);
        set(h,'AlphaData',mask_frontback)
    end
    %set(h,'AlphaData',mask)
    title(cfg.display_mapnames{cond}, 'FontSize', 18)
    colormap(map)
    %colorbar
    axis off
    box off
    set(gcf,'color','w');
end

subplot(1,how_many_conds+1,i+1);

if strcmp(what, 'emotions')
    c = colorbar('westoutside', 'Ticks',-M:0.1:M, 'FontSize', 16);
    c.Position = [0.8411 0.1100 0.02 0.8167];
    c.AxisLocation = 'in';
    caxis([-M M]);
else
    c = colorbar('westoutside', 'Ticks',-M:0.1:M, 'FontSize', 16);
    c.Position = [0.7411 0.1100 0.02 0.8167];
    c.AxisLocation = 'in';
    caxis([-M M]);
    
end

axis off
box off
set(gcf,'color','w');
%%
if strcmp(what, 'emotions')
    set(gcf, 'PaperPosition', [0 0 24 8]); %x_width=10cm y_width=15cm
elseif  strcmp(what, 'sensitivity')
    set(gcf, 'PaperPosition', [0 0 15 5]);
else
    set(gcf, 'PaperPosition', [0 0 12 5]);
end
saveas(gcf,[cfg.subinfopath 'figures/GLM_' grouping '_' what '_spearman.png'])