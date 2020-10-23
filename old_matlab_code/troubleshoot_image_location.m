clear all
close all
%% Change these paths to point at your relevant folders
addpath(genpath('/Users/jtsuvile/Documents/projects/kipupotilaat/code/'));
cfg.outdata = '/Users/jtsuvile/Documents/projects/kipupotilaat/testsubs/';
base=uint8(imread('bodySPM_base2.png'));
mask=uint8(imread('bodySPM_base3.png'));
mask=mask*.85;
base2=base(10:531,33:203,:);

%%
cfg.Nstimuli = 12;
cfg.Nempty = 3;
cfg.onesided = [1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0]; % does the final data have one or two shapes
cfg.mapnames = {'emotions_0','emotions_1','emotions_2','emotions_3','emotions_4','emotions_5','emotions_6','pain_0','pain_1','sensitivity_0','sensitivity_1', 'sensitivity_2'};

%%
subject='ipadtest';
Nsubj=1;
a=bodySPM_load_kipu([cfg.outdata subject], 2, cfg.mapnames);

S=length(a);
if( S ~= cfg.Nstimuli)
    disp('Mismatch between expected number of trials and loaded trials')
end
%%
resmat=zeros(522,342,cfg.Nstimuli);
% go through each stimulus
for n=1:S;
    T=length(a(n).paint(:,2));
    over=zeros(size(base,1),size(base,2));
    for t=1:T
        y=ceil(a(n).paint(t,3)+1);
        x=ceil(a(n).paint(t,2)+1);
        if(x<=0) x=1; end
        if(y<=0) y=1; end
        if(x>=900) x=900; end
        if(y>=600) y=600; end
        over(y,x)=over(y,x)+1;
    end
    h=fspecial('gaussian',[18 18],8.5);
    over=imfilter(over,h);
    M1=1;
    M2=1;
    
    % NB: run some more tests to see why some of the back info seems
    % off-centre
    if(cfg.onesided(n)==1)
       over2=[M1*over(10:531,33:203,:), M2*over(10:531,698:868,:)];
       %resmat(:,1:171,n)=over2;
       resmat(:,:,n)=over2;
    else
        over2=[over(10:531,35:205,:), over(10:531, 700:870,:)];
        resmat(:,:,n)=over2;
    end
    
end
%%
matname=[cfg.outdata '/' subject '.mat'];
save (matname, 'resmat');

%% NB: check still cutoff and scaling of images, test with outline image overlays!
back_outline = double(imread('bodySPM_back_outline.png'));
front_outline = double(imread('bodySPM_front_outline.png'));
back_outline(back_outline<50) = 0;
back_outline(back_outline>50) = 5;

front_outline(front_outline<50) = 0;
front_outline(front_outline>50) = 5;
base=uint8(imread('bodySPM_base2.png'));
mask=uint8(imread('bodySPM_base3.png'));
mask=mask*.85;
base2=base(10:531,33:203,:);
base3 = [double(base2(:,:,1)) double(base2(:,:,1))];
base3(base3>5) = 2;

base_oneside=uint8(imread('bodySPM_base2.png'));
mask_oneside=uint8(imread('bodySPM_base3.png'));
mask_oneside=mask_oneside*.85;
mask_binary = mask_oneside;
mask_binary(mask_oneside < 100) = 0;
outline_oneside=bwperim(mask_binary,4)*10;
double_oneside = [outline_oneside outline_oneside];
mask_frontback = [mask_binary mask_binary];
%%
clear resmats;
close all;
load([cfg.outdata 'mat-files/', subject '.mat'])
resmat(resmat>0) = 3;
resmat(resmat < 0 ) = -3;

%%
%resmats = sum(resmat(:,:,1:7),3); %emotions
%displaymat= resmats - double_oneside;

%resmats = sum(resmat(:,:,8:9),3); % pain
%resmats = sum(resmat(:,:,8:12),3); % sensitivity
%displaymat= resmats - [front_outline back_outline];

%%
%imagesc(displaymat, [-10 2])
%colorbar;
%close all;
map=cbrewer('div','RdBu',201);
for i=1:12
    subplot(3,4,i);
    cond = i;
    glm = resmat(:,:,cond);
    if(cfg.onesided(cond)==1)
        glm = -1*abs(glm);
        mask = mask_binary;
        h = imagesc(glm(:,1:171)-1*outline_oneside,[-5 5]);
        set(h,'AlphaData',mask_oneside)
    else
        mask = mask_frontback;
        h = imagesc(glm-double_oneside, [-5 5]);
        set(h,'AlphaData',mask_frontback)
    end
    title(cfg.mapnames{cond}, 'FontSize', 18)
    colormap(map)
    %colorbar
    axis off
    box off
    set(gcf,'color','w');
end
export_fig '/Users/jtsuvile/Documents/projects/kipupotilaat/testsubs/ipadtest_responses' -png -m3.8
