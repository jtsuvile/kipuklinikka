clear all
close all
%% Change these paths to point at your relevant folders
addpath(genpath('/Users/jtsuvile/Documents/projects/kipupotilaat/code/BodySPM/'));
cfg.outdata = '/Users/jtsuvile/Documents/projects/kipupotilaat/data/mat-files/';
cfg.datapath = '/Users/jtsuvile/Documents/projects/kipupotilaat/data/subjects/';
if(exist(cfg.outdata)~=7)
    mkdir(cfg.outdata)
end
%%
cfg.Nstimuli = 12;
cfg.Nempty = 3;
cfg.phenodata = 1;
cfg.list = [cfg.outdata 'list.txt'];
cfg.doaverage = 0;
cfg.hasBaseline = 0;
cfg.posneg= [0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1];
cfg.onesided = [1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0]; % does the final data have one or two shapes
cfg.overwrite=1;
%%
% NB: presentation is done slightly differently in this project, because
% there are three conceptually different things (emotions, pain,
% sensitivity) and in the web app each of these gets randomised within
% category. Therefore we need to explicitly define the data csv file names
% and slightly modify the bodySPM code (_kipu)

cfg.mapnames = {'emotions_0','emotions_1','emotions_2','emotions_3','emotions_4','emotions_5','emotions_6','pain_0','pain_1','sensitivity_0','sensitivity_1', 'sensitivity_2'};
bspm = bodySPM_preprocess_kipu(cfg);
%%
for ss=1:cfg.Nstimuli
	figure(ss)
	loglog(squeeze(bspm.allTimes(ss,1,:)),squeeze(bspm.allTimes(ss,2,:)),'.');
	axis square
	saveas(gcf,[cfg.outdata '/allTimes_' num2str(ss)  '.png'])
end
close all;
%%
ids=find(bspm.tocheck<=14);
subjects=textread(cfg.list);
%%
for i = 1:length(ids)
    out{i,1}=subjects(ids(i),:);
end
%%
fileID=fopen([cfg.outdata '/whitelist.txt'],'w');
for i=1:length(out);
%     if(~strcmp(out{i}(1),'F'))
%         disp([out{i} ' has invalid ID for this study']);
%         continue;
%     end
    fprintf(fileID,'%s\n',[out{i}]);
end
fclose(fileID)
%% NB: check still cutoff and scaling of images, test with outline image overlays!
back_outline = double(imread('bodySPM_back_outline.png'));
front_outline = double(imread('bodySPM_front_outline.png'));
back_outline(back_outline<50) = 0;
back_outline(back_outline>50) = 5;

front_outline(front_outline<50) = 0;
front_outline(front_outline>50) = 5;
base=uint8(imread('bodySPM_base2.png'));
mask=uint8(imread('base3.png'));
mask=mask*.85;
base2=base(10:531,33:203,:);
base3 = [double(base2(:,:,1)) double(base2(:,:,1))];
base3(base3>5) = 30;
cfg.outdata = '/Users/jtsuvile/Documents/projects/kipupotilaat/data/mat-files/';
cfg.list = [cfg.outdata 'list.txt'];

%%
clear resmats;
close all;
subjects=textread(cfg.list);

load(['./' num2str(subjects(1)) '.mat'])
resmats = sum(resmat,3);

for(i=2:20)
    subnum=subjects(i);
    load(['./' num2str(subnum) '.mat'])
    resmat(resmat~=0) = 1;
    resmats = resmats + sum(resmat,3);
end
%%
%displaymat= resmats - [front_outline back_outline] * 5;
displaymat= resmats - base3;
imagesc(displaymat)
colorbar;