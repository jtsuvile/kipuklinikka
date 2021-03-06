clear all
close all
%% Change these paths to point at your relevant folders
addpath(genpath('/m/nbe/scratch/socbrain/kipupotilaat/code/BodySPM/'));
addpath(genpath('/m/nbe/scratch/socbrain/kipupotilaat/code/'));

cfg.outdata = '/m/nbe/scratch/socbrain/kipupotilaat/data/helsinki/subjects/mat-files/';
cfg.datapath = '/m/nbe/scratch/socbrain/kipupotilaat/data/helsinki/subjects/';
if(exist(cfg.outdata)~=7)
    mkdir(cfg.outdata)
end
%%
cfg.Nstimuli = 12;
cfg.Nempty = 3;
cfg.phenodata = 1;
cfg.list = [cfg.datapath 'subs.txt'];
cfg.doaverage = 0;
cfg.hasBaseline = 0;
cfg.posneg= [0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1];
cfg.onesided = [1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0]; % does the final data have one or two shapes
cfg.overwrite=0;
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
% %%
% ids=find(bspm.tocheck<=14);
% subjects=textread(cfg.list);
% %%
% for i = 1:length(ids)
%     out{i,1}=subjects(ids(i),:);
% end
%%
% fileID=fopen([cfg.outdata '/whitelist.txt'],'w');
% for i=1:length(out);
% %     if(~strcmp(out{i}(1),'F'))
% %         disp([out{i} ' has invalid ID for this study']);
% %         continue;
% %     end
%     fprintf(fileID,'%s\n',[out{i}]);
% end
% fclose(fileID)
%%
cfg.overwrite_raw = 1;
% NB: this will take a while!
cbspm = make_raw_data_matrices(cfg);