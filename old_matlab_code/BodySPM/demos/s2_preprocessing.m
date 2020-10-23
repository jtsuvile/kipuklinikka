clear all
close all

cfg.outdata = '/scratch/braindata/eglerean/ClinicalBodypaint/outdata/';
cfg.datapath = '/archive/braindata/2015/bml_www/backup/emotion.becs.aalto.fi/kehot/subjects/';
cfg.Nstimuli = 29;
cfg.list = '/scratch/braindata/eglerean/ClinicalBodypaint/outdata/list.txt'
cfg.doaverage = 1;
cfg.averageMatrix=(reshape([1:28]',[4 7]))';
cfg.shuffleAverage = [2 1 3 5 7 6 4];
cfg.hasBaseline = 1;
cfg.posneg=0;
cfg.overwrite=1;
bspm = bodySPM_preprocess(cfg);

for ss=1:cfg.Nstimuli
	figure(ss)
	loglog(squeeze(bspm.allTimes(ss,1,:)),squeeze(bspm.allTimes(ss,2,:)),'.');
	axis square
	saveas(gcf,[cfg.outdata '/allTimes_' num2str(ss)  '.png'])
end


ids=find(bspm.tocheck<=14);
subjects=textread(cfg.list,'%8c');

for i = 1:length(ids)
    out{i,1}=subjects(ids(i),:);
end

fileID=fopen([cfg.outdata '/whitelist.txt'],'w');
for i=1:length(out);
    if(~strcmp(out{i}(1),'F'))
        disp([out{i} ' has invalid ID for this study']);
        continue;
    end
    fprintf(fileID,'%s\n',[out{i}]);
end
fclose(fileID)
	
