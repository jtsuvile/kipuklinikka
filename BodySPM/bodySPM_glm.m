function bspm = bodySPM_glm(cfg)

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
%		cfg.corrtype = 'pearson' or 'spearman' (default pearson)
%		cfg.niter = number of permutations for cluster correction (0 for no cluster corr)
%		cfg.th = thresholds for cluster correction
%		cfg.grid = 1, put one for grid computing
%	Output:
%		bspm.glm = correlations between maps and models
%		bspm.pvals = p values from corr function


base=uint8(imread('bodySPM_base2.png'));
mask=uint8(imread('bodySPM_base3.png'));
mask=mask*.85;
base2=base(10:531,33:203,:);

% todo: add input checks

%subjects=textread(cfg.list,'%8c'); 
subjects=textread(cfg.list,'%s'); 
Nsubj=size(subjects,1);
tocheck=zeros(Nsubj,1);
for ns=1:Nsubj;
    disp(['Processing subject ' subjects{ns,:} ' which is number ' num2str(ns) ' out of ' num2str(Nsubj)]);
    matname=[cfg.datapath '/' subjects{ns,:} '.mat'];
    load (matname) % 'resmat','resmat2','times'
	tempdata=reshape(resmat2,[],size(resmat2,3));
	if(ns==1)
		alldata=zeros(size(tempdata,1),size(tempdata,2),Nsubj);
	end
	alldata(:,:,ns)=tempdata;
end

disp('Computing GLM')
for stim=1:size(alldata,2)
	tempdata=squeeze(alldata(:,stim,:));
	[co(:,:,stim) pe(:,:,stim)]=corr(tempdata',cfg.model,'type',cfg.corrtype);
end
bspm=cfg;
bspm.glm=co;
bspm.pvals=pe;
bwmask=double(mask>127);
if(cfg.niter > 0) % if we do clu corr
	disp('Performing cluster correction')
	if(cfg.grid==1 && cfg.compute == 0)
    	% if grid ==1 it needs to check that they are all computed, otherwise it must set compute to 1
    end


	bspm.cluth=ones(size(alldata,2),size(cfg.model,2)); % Nstimuli X Nmodel
	bspm.clu95=zeros(size(alldata,2),size(cfg.model,2),length(cfg.th));
	bspm.clupvals=ones(size(alldata,2),size(cfg.model,2),length(cfg.th));
	
	% generate surrogate models
	surromodels=zeros(size(cfg.model,1),size(cfg.model,2),cfg.niter+1);
	for iter=0:cfg.niter
		if(iter==0)
			tempperms=1:size(cfg.model,1);
		else
			tempperms=randperm(size(cfg.model,1));
		end
		surromodels(:,:,iter+1)=cfg.model(tempperms,:);
	end

	% compute cluster thresholds
	for stim = 1:size(alldata,2)
		tempdata=squeeze(alldata(:,stim,:));
		for mm=1:size(cfg.model,2)
			thismodel=cfg.model(:,mm);
			surr_cluster_size=zeros(cfg.niter+1,length(cfg.th));
			disp(['Running cluster correction for stim ' num2str(stim) ' and model ' num2str(mm)]);
			num=cfg.niter+1;
			if(cfg.grid == 1 && cfg.compute ==1)
				outfolder='/triton/becs/scratch/braindata/eglerean/ClinicalBodypaint/code/permutations/';
				outfolder=[cfg.outfolder '/permutations/'];
				mkdir(outfolder);
				outfile=[outfolder 'perm_s' num2str(stim) '_m' num2str(mm) '.mat'];
				filename=[outfolder 'perm_s' num2str(stim) '_m' num2str(mm) '_job'];
				logfile=[outfolder 'perm_s' num2str(stim) '_m' num2str(mm) '_log'];

				% if result already exists, do not launch job or create files, unless ovewrite specified

				% prepare slurm cluster scripts
				dlmwrite(filename, '#!/bin/sh', '');
				dlmwrite(filename, '#SBATCH -p short','-append','delimiter','');
				dlmwrite(filename, '#SBATCH -t 04:00:00','-append','delimiter','');
				dlmwrite(filename, '#SBATCH --qos=short','-append','delimiter','');
				dlmwrite(filename, ['#SBATCH -o "' logfile '"'],'-append','delimiter','');
				% Adjust memory requirement
				dlmwrite(filename, '#SBATCH --mem-per-cpu=8000','-append','delimiter','');
				dlmwrite(filename, 'module load matlab','-append','delimiter','');

				dlmwrite(filename,sprintf('matlab -nosplash -nodisplay -nodesktop -r "addpath(genpath(''/triton/becs/scratch/braindata/eglerean/code/bodyspm/''));bodySPM_glm_processor(''%s'');exit"',outfile),'-append','delimiter','');



				thissurromodels=squeeze(surromodels(:,mm,:));
				% save script and input file and launch job
				corrtype=cfg.corrtype;
				th=cfg.th;
				save(outfile,'stim','mm','tempdata','thissurromodels', 'corrtype', 'mask', 'bwmask', 'num','th');
				%submit job
				disp(['Submitting job for stimulus ' num2str(stim) ' and model ' num2str(mm)]);
				unix(['sbatch ' filename]);
				


			else
				parfor iter=1:num
					surromodel=surromodels(:,mm,iter);
					temp_surr_cluster_size = bodySPM_glm_helper(surromodel,tempdata,cfg.corrtype,mask,bwmask,cfg.th);
					surr_cluster_size(iter,:)=temp_surr_cluster_size;
				end		% close parfor iter
				disp(['Permutations completed']);
			end

			if(cfg.grid==1 && cfg.compute == 0)
				% load variable surr_cluster_size
			end

			for thID=1:length(cfg.th)
				clupval=1-length(find(surr_cluster_size(2:end,thID)<surr_cluster_size(1,thID)))/cfg.niter;
				bspm.clu95(stim,mm,thID)=prctile(surr_cluster_size(2:end,thID),95);
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
