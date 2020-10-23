function bspm = bodySPM_ttest_kipu(cfg)

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

load(cfg.rawdatafile) %rawmat
%%
tempdata=reshape(rawmat,[],size(rawmat,3));
%alldata =tempdata;
if(cfg.onesided(cfg.condition))
    mask=uint8(imread('bodySPM_base3.png'));
    mask = [mask zeros(size(mask))];
    mask=mask*.85;
    in_mask=find(mask>128);
    %in_mask = 1:178524;
    alldata = tempdata(in_mask,:);
else
    mask=uint8(imread('bodySPM_frontback_mask.png'));
    mask = [mask mask];
    mask=mask(:,:,1);
    mask=mask*.85;
    in_mask=find(mask>128);
    alldata = tempdata(in_mask,:);
end
% 
% todo: add input checks
debug = [];
%%
tdata=zeros(length(in_mask),1);
%tdata = zeros(size(tempdata,1),1);

[H,P1,CI,STATS] = ttest(alldata');
debug.ttest.H = H;
debug.ttest.P = P1;
debug.ttest.CI = CI;
debug.ttest.STATS = STATS;

tdata(:)=STATS.tstat;
%reshaped = reshape(tdata, size(rawmat,1), size(rawmat,2));
% img_H = zeros(size(mask));
% img_H(in_mask) = H ;
%% multiple comparisons correction across this figure
alltdata=tdata(:);
alltdata(find(~isfinite(alltdata))) = 0;%[];   % getting rid of anomalies due to low number of demo subjects (ie no variance)

df       = STATS.df(1);    % degrees of freedom
P        = 1-cdf('T',alltdata,df);  % p values
[pID pN] = FDR(P,0.05);     % BH FDRr

if(isempty(pID)&&isempty(pN))
    pID = 0;
    pN = 0;
end
tID      = icdf('T',1-pID,df);      % T threshold, indep or pos. correl.
tN       = icdf('T',1-pN,df) ;      % T threshold, no correl. assumptions
%%
temp=zeros(size(mask));
temp(in_mask)=tdata(:);
%temp=zeros(size(rawmat,1), size(rawmat,2));
%temp(:)=tdata(:);
temp(find(~isfinite(temp)))=0; % we set nans and infs to 0 for display
%max(temp(:))
tvals=temp;
p_temp = ones(size(mask));
p_temp(in_mask) = P;

bspm=cfg;
bspm.ttest.tval=tvals;
bspm.ttest.qval=[pID pN];
bspm.ttest.tTH=[tID tN];
bspm.ttest.pval = p_temp;
%%
% bwmask=double(mask>127);
% %if(0) % cluster correction for ttest not yet implemented
% if(cfg.niter > 0) % if we do clu corr
% 	bspm.cluth=ones(size(alldata,2),size(cfg.model,2)); % Nstimuli X Nmodel
% 	surromodels=zeros(size(cfg.model,1),size(cfg.model,2),cfg.niter+1);
% 	bspm.clupvals=ones(size(alldata,2),size(cfg.model,2),length(cfg.th));
% 	for iter=0:cfg.niter
% 		if(iter==0)
% 			tempperms=1:size(cfg.model,1);
% 		else
% 			tempperms=randperm(size(cfg.model,1));
% 		end
% 		surromodels(:,:,iter+1)=cfg.model(tempperms,:);
% 	end
% 
% 	for stim = 1:size(alldata,2)
% 		tempdata=squeeze(alldata(:,stim,:));
% 		for mm=1:size(cfg.model,2)
% 			thismodel=cfg.model(:,mm);
% 			surr_cluster_size=zeros(cfg.niter+1,length(cfg.th));
% 			disp(['Running cluster correction for stim ' num2str(stim) ' and model ' num2str(mm)]);
% 			num=cfg.niter+1;
% 			parfor iter=1:num
% 				%surromodel=thismodel;
% 				%size(surromodel)
% 				surromodel=surromodels(:,mm,iter);
% 				%size(surromodel)
% 				%save debug
% 				surrocorr=abs(reshape(corr(tempdata',surromodel),size(mask)));
% 				surrocorr=surrocorr.*bwmask;
% 				temp_surr_cluster_size=zeros(1,length(cfg.th));
% 				for thID=1:length(cfg.th)
% 					tempclusters=bwlabel(surrocorr>cfg.th(thID),4);
% 					if(max(tempclusters(:))>0)
% 						vals=unique(tempclusters);
% 						vals(1)=[];
% 						ccount=histc(tempclusters(:),vals);
% 						temp_surr_cluster_size(thID)=max(ccount);
% 					end
% 				end
% 				surr_cluster_size(iter,:)=temp_surr_cluster_size;
% 			end		% close parfor iter
% 			disp(['Permutations completed']);
% 			for thID=1:length(cfg.th)
% 				clupval=1-length(find(surr_cluster_size(2:end,thID)<surr_cluster_size(1,thID)))/cfg.niter;
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
% end
end
