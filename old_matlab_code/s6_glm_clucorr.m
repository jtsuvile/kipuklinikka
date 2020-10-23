clear all
close all
addpath(genpath('/m/nbe/scratch/braindata/eglerean/code/bodyspm/'))

map=cbrewer('div','RdBu',21);
map=flipud(map);
cfg=[];
cfg.datapath = '/m/nbe/scratch/braindata/eglerean/ClinicalBodypaint/outdata/'
cfg.list = 'pheno_filtered_list.csv' ;
model = load('pheno_filtered.csv');
sex = load('pheno_sex.csv'); % females =1;
sex = 2*(sex-1.5); % now it's with zero mean.

model=[sex model];
model_labels={'sex','age','edu','EDPS1','SCL1','TAS1','TAS2','TAS3','TAStotal'};

%


cfg.corrtype='pearson';
cfg.model=model;
cfg.niter=5000; % for cluster correction
cfg.th=0.02:0.01:0.3;
% pvalPearson('r',.0825,398) 
%
cfg.th=[.0825 .1165 .1544]; % correspondent to right tailed pvalues of 0.05 0.01 and 0.001

cfg.grid=0;
cfg.compute=1;
cfg.outfolder='/m/nbe/scratch/braindata/eglerean/ClinicalBodypaint/code/'


rng(0);



bspm = bodySPM_glm(cfg);

save -v7.3 bspm_clucorr_pearson_setP_1000perms bspm

error('stop')

	

labels={'Anger' 'Fear' 'Disgust' 'Happiness' 'Sadness' 'Surprise' 'Neutral' 'Baseline'};
base=uint8(imread('bodySPM_base2.png'));
mask=uint8(imread('bodySPM_base3.png'));
mask=mask*.85;
inmask=find(mask>128);


for modelID=1:length(model_labels);
	figure
	hist(model(:,modelID),50);
	title(model_labels{modelID})
	saveas(gcf,['pngs/hist_' model_labels{modelID} '.png'])
	close all

	for stimulus=1:length(labels);
		tempdataC=bspm.glm(:,modelID,stimulus);
		tempdataC(find(isnan(tempdataC)))=0;
		
		tempmask=double(abs(tempdataC(inmask))>bspm.cluth(stimulus,modelID));
		out(modelID,stimulus)=sum(tempmask);
		tempdataout=zeros(size(tempdataC));
		tempdataout(inmask)=tempmask.*tempdataC(inmask);
		outfig=reshape(tempdataout,size(mask,1),size(mask,2));
		min(outfig(:))
		max(outfig(:))
		h=imagesc(outfig,[-.2 .2]);
		colormap(map);
		colorbar;
		set(h,'AlphaData',mask)
		axis equal
		title([model_labels{modelID} ' vs ' labels{stimulus}]);
		saveas(gcf,['pngs/model ' model_labels{modelID} ' - ' labels{stimulus} '_clucorr.png']);
	end
end

