clear all;
close all;
addpath(genpath('/Users/jtsuvile/Documents/projects/kipupotilaat/code/BodySPM/'));
%%
cfg=[];
cfg.datapath = '/Users/jtsuvile/Documents/projects/kipupotilaat/ruotsi/data/mat-files/';
cfg.subinfopath = '/Users/jtsuvile/Documents/projects/kipupotilaat/ruotsi/data/';
cfg.onesided = [1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0]; % does the final data have one or two shapes
cfg.mapnames = {'emotions_0','emotions_1','emotions_2','emotions_3','emotions_4','emotions_5','emotions_6','pain_0','pain_1','sensitivity_0','sensitivity_1', 'sensitivity_2'};
cfg.display_mapnames = {'Sadness','Happiness','Anger','Surprise','Fear','Disgust','Neutral',...
    {'Acute','pain'},{'Chronic','pain'},...
    {'Tactile', 'sensitivity'}, {'Pain','sensitivity'}, {'Hedonic','sensitivity'}};
cfg.absval = 1;
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

%% draw
subid = 211459;
load([cfg.datapath num2str(subid) '.mat']);
close all;
figure('Position', [200, 500, 900, 600])
M = max(max(max(abs(resmat))));
locationtracker = [0,0,0,0,0,0,0,1,3,5,7,9];
map=cbrewer('div','RdBu',201);
map=flipud(map);
map = [0 0 0; map];

for i=1:12
    cond = i;
    glm = resmat(:,:,i);
    if(cfg.onesided(i)==1)
        subplot(2,10,i);
        glm = -1*abs(glm);
        mask = mask_binary;
        %imagesc(-1*outline_oneside,[-M M]);
        %hold on;
        h = imagesc(glm(:,1:171)-1*outline_oneside,[-M M]);
        set(h,'AlphaData',mask_oneside)
    else
        j = 10+locationtracker(i);
        subplot(2,10,[j j+1]);
        mask = mask_frontback;
        h = imagesc(glm-frontback_outline, [-M M]);
        set(h,'AlphaData',mask_frontback)
    end
    %set(h,'AlphaData',mask)
    title(cfg.display_mapnames{cond}, 'FontSize', 18)
    colormap(map);
    %colorbar
    axis off
    box off
    set(gcf,'color','w');
end

%%

set(gcf, 'PaperPosition', [0 0 12 8]); %x_width=10cm y_width=15cm
saveas(gcf,[cfg.subinfopath 'figures/sub_' num2str(subid) '.png'])