clear all
close all

addpath(genpath('/scratch/braindata/eglerean/code/bodyspm/'));

cfg.outdata = '/scratch/braindata/eglerean/ClinicalBodypaint/outdata/';
cfg.datapath = '/archive/braindata/2015/bml_www/backup/emotion.becs.aalto.fi/kehot/subjects/';
cfg.Nstimuli = 29;
cfg.Nempty = 1;
cfg.phenodata = 0;
bspm=bodySPM_parseSubjects(cfg);

ids=find(bspm.data_filter(:,3)==1);
for i = 1:length(ids)
	out{i,1}=bspm.subjects(ids(i)).name;
end

fileID=fopen([cfg.outdata '/list.txt'],'w');
for i=1:length(out); 
	if(~strcmp(out{i}(1),'F')) 
		disp([out{i} ' has invalid ID for this study']); 
		continue;
	end
	fprintf(fileID,'%s\n',[out{i}]);
end
fclose(fileID)


