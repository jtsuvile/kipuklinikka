function bspm = bodySPM_simmat(cfg)

% bodySPM_simmat(cfg)
%
%   Preprocess a list of parsed subjects 
%
%   Usage
%       bspm = bodySPM_glm(cfg)
%
%   Input:
%       cfg.datapath = path to your preprocessed data subjects subfolder (mandatory)
%       cfg.list = txt file with the list of subjects to process
%	Output:
%		bspm.tpp = total painted pixels


base=uint8(imread('bodySPM_base2.png'));
mask=uint8(imread('bodySPM_base3.png'));
mask=mask*.85;
base2=base(10:531,33:203,:);

% todo: add input checks

subjects=textread(cfg.list,'%8c');
Nsubj=size(subjects,1);
tocheck=zeros(Nsubj,1);
inmask=find(mask>127);
for ns=1:Nsubj;
    disp(['Processing subject ' subjects(ns,:) ' which is number ' num2str(ns) ' out of ' num2str(Nsubj)]);
    matname=[cfg.datapath '/' subjects(ns,:) '.mat'];
    load (matname) % 'resmat','resmat2','times'
	tempdata=reshape(resmat2,[],size(resmat2,3));
	tempdata=tempdata(inmask,:);
	if(ns==1)
		ids=find(triu(ones(size(tempdata,2)),1));
		ids
		simmats=zeros(length(ids),Nsubj);
	end
	cc=corr(tempdata+eps*randn(size(tempdata)),'type','Spearman');
	simmats(:,ns)=cc(ids);
end
bspm=cfg;
bspm.simmats=simmats;


