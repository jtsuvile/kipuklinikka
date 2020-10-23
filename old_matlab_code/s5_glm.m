clear all
close all
addpath(genpath('/Users/jtsuvile/Documents/projects/kipupotilaat/code/BodySPM/'));
%%
cfg=[];
cfg.datapath = '/Users/jtsuvile/Documents/projects/kipupotilaat/data/mat-files/';
cfg.subinfopath = '/Users/jtsuvile/Documents/projects/kipupotilaat/data/';
bgdata = csvread([cfg.subinfopath '/subs_bg_info_numeric.csv'], 1, 1);
cfg.niter=0; % do not run cluster correction
cfg.doaverage = 0;
cfg.uncorrected = 0;
cfg.corrtype = 'spearman';
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
cfg.list = [cfg.datapath '/list.txt'];
cfg.grid = 0;
%% NB: potentially interesting correlations
% Currently feeling:
% pain, depression, anxiety, joy, sadness, anger, fear, surprise, disgust
% pain experiences:
% painnow, painaverage, painleast, painworst, mood, enjoyinglife
% 
compound_pain = nansum(bgdata(:,25:28),2);
bgdata(:,end+1) = compound_pain;
variable_names{end+1} = 'BPI_pain_combined';
variables = 37; % BPI_pain_combined = 46, pain = 37, depression = 38

%%
cfg.niter=10; % for cluster correction
cfg.th=0.06:0.01:0.4;
for vrs=1:length(variables)
    variable = variables(vrs);
    disp(['looking at correlations with : ' variable_names{variable}])
    for i=1:length(cfg.mapnames)
        cfg.condition = i; 
        cfg.model = bgdata(:,variable);
        cfg.model_name = variable_names{variable};
        %cfg.rawdatafile = [cfg.datapath cfg.mapnames{i} '_raw_data_matrix.mat'];
        bspm = bodySPM_glm(cfg);
        if cfg.absval ==1        
            save([cfg.datapath 'glm_' cfg.model_name '_' cfg.mapnames{i}, '_abs_values'], 'bspm')
        else
            save([cfg.datapath 'glm_' cfg.model_name '_' cfg.mapnames{i}], 'bspm')
        end
    end
end
%%

% base_oneside=uint8(imread('bodySPM_base2.png'));
% mask_oneside=uint8(imread('bodySPM_base3.png'));
% mask_oneside=mask_oneside*.85;
% mask_binary = mask_oneside;
% mask_binary(mask_oneside < 100) = 0;
% outline_oneside=bwperim(mask_binary,4)*10;
% 
% mask_front=uint8(imread('bodySPM_frontback_mask.png'));
% mask_frontback = [mask_front mask_front];
% mask_frontback=mask_frontback(:,:,1);
% mask_frontback=mask_frontback*.85;
% front_outline = double(imread('bodySPM_front_outline.png'));
% back_outline = double(imread('bodySPM_back_outline.png'));
% frontback_outline = [front_outline back_outline];
% map=cbrewer('div','RdBu',201);
% map=flipud(map);
% map = [0 0 0; map];
% %% GLM
% % for pains: y=7; how_many_conds = 2;
% % for sensitivity:  y=9; how_many_conds = 3;
% % for emotions: y=0; how_many_conds = 7;
% M=0.4;
% y=0;
% how_many_conds = 7;
% variables = 37;
% order_conds = [3,5,6,2,1,4,7];
% 
% for cc=1:length(variables)
%     grouping = variable_names{variables(cc)};
%     close all;
%     % emotions
%     figure('Position', [200, 500, 800, 300])
%     % pains
%     % figure('Position', [200, 500, 600, 300])
%     % sensitivity
%     %figure('Position', [200, 500, 800, 300])
%     
%     for i=1:how_many_conds
%         subplot(1,how_many_conds+1,i);
%         cond = order_conds(i)+y;
%         load([cfg.datapath 'glm_' grouping '_' cfg.mapnames{cond} '.mat']);
%         glm = bspm.glm;
%         if(isempty(bspm.plim)|| length(bspm.plim)==1)
%             glm(:) = 0;
%         else
%             glm(bspm.pvals>bspm.plim(2)) = 0;
%         end
%         
%         if(cfg.onesided(bspm.condition)==1)
%             mask = mask_oneside;
%             imagesc(-1*outline_oneside,[-M M]);
%             hold on;
%             h = imagesc(glm(:,1:171),[-M M]);
%         else
%             mask = mask_frontback;
%             h = imagesc(glm+frontback_outline, [-M M]);
%         end
%         
%         set(h,'AlphaData',mask)
%         title(cfg.display_mapnames{cond})
%         colormap(map)
%         %colorbar
%         axis off
%         box off
%         set(gcf,'color','w');
%     end
%     
%     subplot(1,how_many_conds+1,i+1);
%     subplot(1,how_many_conds+1,i+1)
%     
%     c = colorbar('westoutside', 'Ticks',-M:0.1:M, 'FontSize', 16);
%     c.Position = [0.8087    0.1100    0.01    0.7567];
%     c.AxisLocation = 'in';
%     
%     caxis([-M M]);
%     axis off
%     box off
%     set(gcf,'color','w');
%         suptitle(['pixel-wise correlation with ' strrep(grouping,'_', ' ')]);
% 
%     %%
%     %print(, '-dpng', '-r0')
%     % emotions
%     set(gcf, 'PaperPosition', [0 0 12 4]); %x_width=10cm y_width=15cm
%     % pain
%     % set(gcf, 'PaperPosition', [0 0 24 12]); %x_width=10cm y_width=15cm
%     
%     saveas(gcf,[cfg.subinfopath 'figures/glm_pain_by_' grouping '.png'])
% end