function bspm = bodySPM_ttest2(cfg)

% bodySPM_glm(cfg)
%
%   Preprocess a list of parsed subjects 
%
%   Usage
%       bspm = bodySPM_glm(cfg)
%
%   Input:
%       cfg.datapath = path to your preprocessed data subjects subfolder (mandatory)
%       cfg.list = txt file with the list of subjects to process
%		cfg.model = matrix with model
%		cfg.niter = number of permutations for cluster correction
%		cfg.th = thresholds for cluster correction

base=uint8(imread('bodySPM_base2.png'));
mask=uint8(imread('bodySPM_base3.png'));
mask=mask*.85;
base2=base(10:531,33:203,:);
in_mask=find(mask>128);

% todo: add input checks

subjects=textread(cfg.list,'%8c');
Nsubj=size(subjects,1);
tocheck=zeros(Nsubj,1);

for ns=1:Nsubj;
    disp(['Processing subject ' subjects(ns,:) ' which is number ' num2str(ns) ' out of ' num2str(Nsubj)]);
    matname=[cfg.datapath '/' subjects(ns,:) '.mat'];
    load (matname) % 'resmat','resmat2','times'
	tempdata=reshape(resmat2,[],size(resmat2,3));
	if(ns==1)
		alldata=zeros(length(in_mask),Nsubj,size(tempdata,2));
	end
	alldata(:,ns,:)=tempdata(in_mask,:);
end
NC=size(alldata,3);
tdata=zeros(length(in_mask),NC);
allpvals=[];
for condit=1:NC
	temp=[alldata(:,cfg.g1,condit) alldata(:,cfg.g2,condit)];
	design=[ones(1,length(cfg.g1)) 2*ones(1,length(cfg.g2))];
	if(0)
		stats(condit)=bramila_ttest2_np(temp,design,cfg.niter);
	else
		disp('Running parametric ttest2')
		[hh pvals ci tstats]=ttest2(alldata(:,cfg.g1,condit)',alldata(:,cfg.g2,condit)');
		stats(condit).pvals=[pvals'];
		stats(condit).tvals=tstats.tstat';
	end
	
	allpvals=[allpvals;min(stats(condit).pvals,[],2);];
end

%% multiple comparisons correction across all conditions
[pID pN] = FDR(allpvals,0.05)             % BH FDR
%save -v7.3 debug
tvals=zeros(size(mask,1),size(mask,2),NC);
pmask=zeros(size(mask,1),size(mask,2),NC);
for condit=1:NC
    temp=zeros(size(mask));
    temp(in_mask)=stats(condit).tvals;
	tempmask=zeros(size(mask));
	temppvals=min(stats(condit).pvals,[],2);
	if(cfg.uncorrected==1)
		tempmask(in_mask)=double(temppvals<0.05);
	else
		tempmask(in_mask)=double(temppvals<max([pID 0]));
	end
    tvals(:,:,condit)=temp;
	pmask(:,:,condit)=tempmask;
	
end


bspm=cfg;
bspm.ttest2.tval=tvals;
bspm.ttest2.qval=[pID pN];
bspm.ttest2.pmask=pmask;

bwmask=double(mask>127);
if(0) % cluster correction for ttest not yet implemented
if(cfg.niter > 0) % if we do clu corr
	bspm.cluth=ones(size(alldata,2),size(cfg.model,2)); % Nstimuli X Nmodel
	surromodels=zeros(size(cfg.model,1),size(cfg.model,2),cfg.niter+1);
	bspm.clupvals=ones(size(alldata,2),size(cfg.model,2),length(cfg.th));
	for iter=0:cfg.niter
		if(iter==0)
			tempperms=1:size(cfg.model,1);
		else
			tempperms=randperm(size(cfg.model,1));
		end
		surromodels(:,:,iter+1)=cfg.model(tempperms,:);
	end

	for stim = 1:size(alldata,2)
		tempdata=squeeze(alldata(:,stim,:));
		for mm=1:size(cfg.model,2)
			thismodel=cfg.model(:,mm);
			surr_cluster_size=zeros(cfg.niter+1,length(cfg.th));
			disp(['Running cluster correction for stim ' num2str(stim) ' and model ' num2str(mm)]);
			num=cfg.niter+1;
			parfor iter=1:num
				%surromodel=thismodel;
				%size(surromodel)
				surromodel=surromodels(:,mm,iter);
				%size(surromodel)
				%save debug
				surrocorr=abs(reshape(corr(tempdata',surromodel),size(mask)));
				surrocorr=surrocorr.*bwmask;
				temp_surr_cluster_size=zeros(1,length(cfg.th));
				for thID=1:length(cfg.th)
					tempclusters=bwlabel(surrocorr>cfg.th(thID),4);
					if(max(tempclusters(:))>0)
						vals=unique(tempclusters);
						vals(1)=[];
						ccount=histc(tempclusters(:),vals);
						temp_surr_cluster_size(thID)=max(ccount);
					end
				end
				surr_cluster_size(iter,:)=temp_surr_cluster_size;
			end		% close parfor iter
			disp(['Permutations completed']);
			for thID=1:length(cfg.th)
				clupval=1-length(find(surr_cluster_size(2:end,thID)<surr_cluster_size(1,thID)))/cfg.niter;
				if(surr_cluster_size(1,thID)==0) clupval=NaN; end
				bspm.clupvals(stim,mm,thID)=clupval;
			end
			mmm=min(squeeze(bspm.clupvals(stim,mm,:)));
			if(isnan(mmm(1))) continue; end
			minid=find(mmm==squeeze(bspm.clupvals(stim,mm,:)))
			if(length(minid)>1) disp(num2str(minid));end
			minid=minid(end); % take the last one, most conservative
			if(mmm<0.05)
				disp(['Found significant cluster of size ' num2str(surr_cluster_size(1,minid)) ' at threshold ' num2str(cfg.th(minid)) ' for stimulus ' num2str(stim) ' and model ' num2str(mm)]);
				bspm.cluth(stim,mm)=cfg.th(minid);
			end
			disp(num2str((squeeze(bspm.clupvals(stim,mm,:)))'))
		end
	end
end
end
