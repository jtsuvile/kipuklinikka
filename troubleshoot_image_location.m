clear all
close all
%% Change these paths to point at your relevant folders
addpath(genpath('/Users/jtsuvile/Documents/projects/kipupotilaat/code/'));
cfg.outdata = '/Users/jtsuvile/Documents/projects/kipupotilaat/code/debugging/';
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
subject='test_sub';
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
       over2=[M1*over(10:531,33:203,:), M2*over(10:531,696:866,:)];
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

%%
clear resmats;
close all;
subject='test_sub';
load([cfg.outdata subject '.mat'])
resmat(resmat~=0) = 3;

%%
% resmats = sum(resmat(:,:,1:7),3); %emotions
% displaymat= resmats - base3;

%resmats = sum(resmat(:,:,8:9),3); % pain
resmats = sum(resmat(:,:,8:12),3); % sensitivity
displaymat= resmats - [front_outline back_outline];

%%
imagesc(displaymat, [-10 2])
colorbar;