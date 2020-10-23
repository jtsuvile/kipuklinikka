function bspm = bodySPM_global(cfg)

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
for ns=1:Nsubj;
    disp(['Processing subject ' subjects(ns,:) ' which is number ' num2str(ns) ' out of ' num2str(Nsubj)]);
    matname=[cfg.datapath '/' subjects(ns,:) '.mat'];
    load (matname) % 'resmat','resmat2','times'
	tempdata=reshape(resmat2,[],size(resmat2,3));
	if(ns==1)
		alldata=zeros(size(tempdata,1),size(tempdata,2),Nsubj);
	end
	alldata(:,:,ns)=tempdata;
end
inmask=find(mask>127);
disp('Computing global properties')
Nstim=size(alldata,2);

tpp=zeros(Nstim,Nsubj); % total painted pixels
for stim=1:size(alldata,2)
	tempdata=sign(squeeze(alldata(inmask,stim,:)));
	tpp(stim,:)=sum(abs(tempdata),1);

	tempdataPOS=zeros(size(tempdata));
	tempdataPOS(find(tempdata>0))=1;
	tempdataNEG=zeros(size(tempdata));
	tempdataNEG(find(tempdata<0))=1;

	tppPOS(stim,:)=sum(tempdataPOS,1);
	tppNEG(stim,:)=sum(tempdataNEG,1);

end
bspm=cfg;
bspm.tpp=tpp;
bspm.tppPOS=tppPOS;
bspm.tppNEG=tppNEG


