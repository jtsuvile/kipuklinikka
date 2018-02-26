%% you can use this code to investigate responses (from one or more subjects) 
% and verify location of mask & outline for one and two sided data

addpath(genpath('/Users/jtsuvile/Documents/projects/kipupotilaat/code/BodySPM/'));
addpath(genpath('/Users/jtsuvile/Documents/projects/kipupotilaat/code/'));
cfg.outdata = '/Users/jtsuvile/Documents/projects/kipupotilaat/data/mat-files/';
back_outline = double(imread('bodySPM_back_outline.png'));
front_outline = double(imread('bodySPM_front_outline.png'));
back_outline(back_outline<50) = 0;
back_outline(back_outline>50) = 5;

front_outline(front_outline<50) = 0;
front_outline(front_outline>50) = 5;
outline = [front_outline back_outline];
outline(outline > 10) = 1;
base=double(imread('bodySPM_base2.png'));
mask=double(imread('bodySPM_base3.png'));
fb_mask=double(imread('bodySPM_frontback_mask.png'));
mask=double(mask*.85);
mask(mask<30) = 0;
mask(mask>1) = 1;
fb_mask = fb_mask(:,:,1);
fb_mask(fb_mask<30) = 0;
fb_mask(fb_mask > 1 ) =1;
fb_mask = [fb_mask fb_mask];
base2=base(10:531,33:203,:);
base3 = [double(base2(:,:,1))];
base3(base3>5) = 2;
cfg.list = [cfg.outdata 'list.txt'];
subject_ids = textread(cfg.list,'%s');
%%
clear resmats;
close all;

for i=1:1%length(subjects)
    subnum=subject_ids{i};
    load([cfg.outdata subnum '.mat'])
    resmat(resmat~=0) = 1;
    emotion_resmats = sum(resmat(:,1:171,1:7),3);
    pain_resmats = sum(resmat(:,:,8:9),3);
    sensitivity_resmats = sum(resmat(:,:,10:12),3);
end

%%
close all;
subplot(1,5,1);
imagesc(emotion_resmats .* mask - base3);
title('Emotions (combined)')
colorbar;
subplot(1,5,2:3);
imagesc(pain_resmats.*fb_mask - outline);
title('Pain (chronic + acute)')
colorbar;
subplot(1,5,4:5);
imagesc(sensitivity_resmats.*fb_mask - outline);
title('Sensitivity (all combined)')
colorbar;