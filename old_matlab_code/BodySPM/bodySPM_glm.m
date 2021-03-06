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


% if(cfg.onesided(cfg.condition)==1)
%     base=uint8(imread('bodySPM_base2.png'));
%     mask=uint8(imread('bodySPM_base3.png'));
% elseif(cfg.onesided(cfg.condition)==0)
mask_oneside=uint8(imread('bodySPM_frontback_mask.png'));
mask = [mask_oneside mask_oneside];
%     mask=mask(:,:,1);
% else 
%     error('what kind of mask should I use?');
% end
% mask=mask*.85;
%in_mask=find(mask>128);


% todo: add input checks

%subjects=textread(cfg.list,'%8c'); 
subjects=textread(cfg.list,'%s'); 
Nsubj=size(subjects,1);
%tocheck=zeros(Nsubj,1);
co = zeros(size(mask,1), size(mask,2),length(cfg.condition));
pe = zeros(size(mask,1), size(mask,2),length(cfg.condition));

for ns=1:length(cfg.condition)
    condition = cfg.condition(ns);
    cfg.rawdatafile = [cfg.datapath cfg.mapnames{condition} '_raw_data_matrix.mat'];
    load(cfg.rawdatafile) %rawmat
    if cfg.absval==1
        rawmat = abs(rawmat);
    end
    tempdata=reshape(rawmat,[],size(rawmat,3));

    if(ns==1)
		alldata=zeros(size(tempdata,1),size(tempdata,2),length(cfg.condition));
	end
    alldata(:,:,ns) = tempdata;

    disp(['Computing GLM for condition ' num2str(cfg.condition) ' out of ' num2str(length(cfg.mapnames))])

    cfg.model(isnan(cfg.model))=0; % note! for pain (recent, worst etc) stuff, we set NaNs to 0 

    [cr, ps]=corr(tempdata',cfg.model(~isnan(cfg.model)),'type',cfg.corrtype);
    co_tmp = co(:,:,ns);
    co_tmp(:) = cr;
    co(:,:,ns) = co_tmp;
    pe_tmp = pe(:,:,ns);
    pe_tmp(:) = ps;
    pe(:,:,ns) = pe_tmp;
end
[pID, pN] = FDR(pe, 0.05);

%not tested yet!
if(isempty(pN))
    pN=0;
end

bspm=cfg;
bspm.glm=co;
bspm.pvals=pe;
bspm.plim = [pID pN];
bspm.conditions = cfg.mapnames(cfg.condition);
%bwmask=double(mask>127);

% if(cfg.niter > 0) % if we do clu corr
% 	disp('Performing cluster correction')
% 	if(cfg.grid==1 && cfg.compute == 0)
%     	% if grid ==1 it needs to check that they are all computed, otherwise it must set compute to 1
%     end
% 
% 
% 	bspm.cluth=ones(size(alldata,3),size(cfg.model,2)); % Nstimuli X Nmodel
% 	bspm.clu95=zeros(size(alldata,3),size(cfg.model,2),length(cfg.th));
% 	bspm.clupvals=ones(size(alldata,3),size(cfg.model,2),length(cfg.th));
% 	
% 	% generate surrogate models
% 	surromodels=zeros(size(cfg.model,1),size(cfg.model,2),cfg.niter+1);
% 	for iter=0:cfg.niter
% 		if(iter==0)
% 			tempperms=1:size(cfg.model,1);
% 		else
% 			tempperms=randperm(size(cfg.model,1));
% 		end
% 		surromodels(:,:,iter+1)=cfg.model(tempperms,:);
% 	end
% 
% 	% compute cluster thresholds
% 	for stim = 1:size(alldata,3)
% 		tempdata=squeeze(alldata(:,:,stim));
% 		for mm=1:size(cfg.model,2)
% 			thismodel=cfg.model(:,mm);
% 			surr_cluster_size=zeros(cfg.niter+1,length(cfg.th));
% 			disp(['Running cluster correction for stim ' num2str(stim) ' and model ' num2str(mm)]);
% 			num=cfg.niter+1;
% 			if(cfg.grid == 1 && cfg.compute ==1)
% 				outfolder='/triton/becs/scratch/braindata/eglerean/ClinicalBodypaint/code/permutations/';
% 				outfolder=[cfg.outfolder '/permutations/'];
% 				mkdir(outfolder);
% 				outfile=[outfolder 'perm_s' num2str(stim) '_m' num2str(mm) '.mat'];
% 				filename=[outfolder 'perm_s' num2str(stim) '_m' num2str(mm) '_job'];
% 				logfile=[outfolder 'perm_s' num2str(stim) '_m' num2str(mm) '_log'];
% 
% 				% if result already exists, do not launch job or create files, unless ovewrite specified
% 
% 				% prepare slurm cluster scripts
% 				dlmwrite(filename, '#!/bin/sh', '');
% 				dlmwrite(filename, '#SBATCH -p short','-append','delimiter','');
% 				dlmwrite(filename, '#SBATCH -t 04:00:00','-append','delimiter','');
% 				dlmwrite(filename, '#SBATCH --qos=short','-append','delimiter','');
% 				dlmwrite(filename, ['#SBATCH -o "' logfile '"'],'-append','delimiter','');
% 				% Adjust memory requirement
% 				dlmwrite(filename, '#SBATCH --mem-per-cpu=8000','-append','delimiter','');
% 				dlmwrite(filename, 'module load matlab','-append','delimiter','');
% 
% 				dlmwrite(filename,sprintf('matlab -nosplash -nodisplay -nodesktop -r "addpath(genpath(''/triton/becs/scratch/braindata/eglerean/code/bodyspm/''));bodySPM_glm_processor(''%s'');exit"',outfile),'-append','delimiter','');
% 
% 
% 
% 				thissurromodels=squeeze(surromodels(:,mm,:));
% 				% save script and input file and launch job
% 				corrtype=cfg.corrtype;
% 				th=cfg.th;
% 				save(outfile,'stim','mm','tempdata','thissurromodels', 'corrtype', 'mask', 'bwmask', 'num','th');
% 				%submit job
% 				disp(['Submitting job for stimulus ' num2str(stim) ' and model ' num2str(mm)]);
% 				unix(['sbatch ' filename]);
% 				
% 
% 
% 			else
% 				parfor iter=1:num
% 					surromodel=surromodels(:,mm,iter);
% 					temp_surr_cluster_size = bodySPM_glm_helper(surromodel,tempdata,cfg.corrtype,mask,bwmask,cfg.th);
% 					surr_cluster_size(iter,:)=temp_surr_cluster_size;
% 				end		% close parfor iter
% 				disp(['Permutations completed']);
% 			end
% 
% 			if(cfg.grid==1 && cfg.compute == 0)
% 				% load variable surr_cluster_size
% 			end
% 
% 			for thID=1:length(cfg.th)
% 				clupval=1-length(find(surr_cluster_size(2:end,thID)<surr_cluster_size(1,thID)))/cfg.niter;
% 				bspm.clu95(stim,mm,thID)=prctile(surr_cluster_size(2:end,thID),95);
% 				if(surr_cluster_size(1,thID)==0) clupval=NaN; end
% 				bspm.clupvals(stim,mm,thID)=clupval;
% 			end
% 			mmm=min(squeeze(bspm.clupvals(stim,mm,:)));
% 			if(isnan(mmm(1))) continue; end
% 			minid=find(mmm==squeeze(bspm.clupvals(stim,mm,:)))
% 			if(length(minid)>1) disp(num2str(minid));end
% 			minid=minid(end); % take the last one, most conservative
% 			if(mmm<0.05)
% 				disp(['Found significant cluster of size ' num2str(surr_cluster_size(1,minid)) ' at threshold ' num2str(cfg.th(minid)) ' for stimulus ' num2str(stim) ' and model ' num2str(mm)]);
% 				bspm.cluth(stim,mm)=cfg.th(minid);
% 			end
% 			disp(num2str((squeeze(bspm.clupvals(stim,mm,:)))'))
% 		end
% 	end
end
