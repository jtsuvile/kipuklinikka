clear all
close all

addpath(genpath('/Users/jtsuvile/Documents/projects/kipupotilaat/code/BodySPM/'));

cfg.outdata = '/Users/jtsuvile/Documents/projects/kipupotilaat/data/mat-files/';
if(exist(cfg.outdata)~=7)
    mkdir(cfg.outdata)
end
cfg.datapath = '/Users/jtsuvile/Documents/projects/kipupotilaat/data/subjects/';
cfg.Nstimuli = 12;
cfg.Nempty = 3;
cfg.phenodata = 1;
bspm=get_good_subjects_kipu(cfg);
%%
ids=find(bspm.data_filter(:,4)==1);
for i = 1:length(ids)
	out{i,1}=bspm.subjects(ids(i)).name;
end
%%
fileID=fopen([cfg.outdata '/list.txt'],'w');
for i=1:length(out); 
% 	if(~strcmp(out{i}(1),'F')) 
% 		disp([out{i} ' has invalid ID for this study']); 
% 		continue;
% 	end
	fprintf(fileID,'%s\n',[out{i}]);
end
fclose(fileID)


