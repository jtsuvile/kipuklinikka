clear all
close all
addpath(genpath('/scratch/braindata/eglerean/code/bodyspm/'))

map=cbrewer('div','RdBu',9);
map=flipud(map);
cfg=[];
cfg.datapath = '/scratch/braindata/eglerean/ClinicalBodypaint/outdata/'
cfg.list = 'pheno_filtered_list.csv' ;
model = load('pheno_filtered.csv');
sex = load('pheno_sex.csv'); % females =1;
sex = 2*(sex-1.5); % now it's with zero mean.

model=[sex model];
model_labels={'sex','age','edu','EDPS1','SCL1','TAS1','TAS2','TAS3','TAStotal'};

%



cfg.model=model;
cfg.niter=50; % for cluster correction
cfg.th=0.06:0.01:0.4;
bspm = bodySPM_glm(cfg);

error('stop')

labels={'Anger' 'Fear' 'Disgust' 'Happiness' 'Sadness' 'Surprise' 'Neutral' 'Baseline'};
base=uint8(imread('bodySPM_base2.png'));
mask=uint8(imread('bodySPM_base3.png'));
mask=mask*.85;
inmask=find(mask>128);

% idea: since distr of subj is multimodal, we need a way to subdivide group
% we can pick one score and divide in quantiles
% or we can build a network on all scores and separate accordingly/clusters
% we can include or exclude age/edu (or regress them out in the model)


modeldist=pdist(model(:,3:end));
z=linkage(modeldist,'complete');
[h t perm]= dendrogram(z,0,'Orientation','Left');
clu=cluster(z,'Maxclust',7);
for cID=1:7
	cids=find(clu==cID);
	clurez(cID,:)=[mean(model(cids,:),1) length(cids)];
end

saveas(gcf,'pngs/model_dendrogram.png');
figure
modeldistnet=squareform(modeldist);
imagesc(modeldistnet(perm,perm));
colormap(map);
saveas(gcf,'pngs/model_net.png');
close



for modelID=1:length(model_labels);
	figure
	hist(model(:,modelID),50);
	title(model_labels{modelID})
	saveas(gcf,['pngs/hist_' model_labels{modelID} '.png'])
	close all

	for stimulus=1:length(labels);
		tempdata=bspm.pvals(:,modelID,stimulus);
		tempdataC=bspm.glm(:,modelID,stimulus);
		tempdata(find(isnan(tempdata)))=0;
		q=mafdr(tempdata(inmask),'BHFDR','true');
		tempmask=double(q<0.05);
		out(modelID,stimulus)=sum(tempmask);
		tempdataout=zeros(size(tempdata));
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
		saveas(gcf,['pngs/model ' model_labels{modelID} ' - ' labels{stimulus} '.png']);
	end
end

