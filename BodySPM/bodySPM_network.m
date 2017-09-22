function bspm = bodySPM_network(cfg)

% bodySPM_network(cfg)
%
%   Compute within subject networks between stimuli
%
%   Usage
%       bspm = bodySPM_glm(cfg)
%
%   Input:
%       cfg.datapath = path to your preprocessed data subjects subfolder (mandatory)
%       cfg.list = txt file with the list of subjects to process
%	Output:
%		bspm.nets = correlations between maps and models



base=uint8(imread('bodySPM_base2.png'));
mask=uint8(imread('bodySPM_base3.png'));
mask=mask*.85;
base2=base(10:531,33:203,:);


bwmask=double(mask>127);
inmask=find(bwmask>0);



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
		alldata=zeros(size(tempdata,1),size(tempdata,2),Nsubj);
	end
	alldata(:,:,ns)=tempdata;
    tempdata=tempdata+eps*randn(size(tempdata));
    tempnet=corr(tempdata(inmask,:),'type','spearman');
    netids=find(triu(ones(size(tempnet)),1));
    allnets(:,ns)=tempnet(netids);
    
   
end

bspm.allnets=allnets;