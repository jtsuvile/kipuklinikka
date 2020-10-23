close all
clear all

addpath('./external/tsne/')
% get avg emotion per country based on t maps.
% we scale t values by num of subj to have eff size but it shouldn't affect the
% similarity measure since we use Spearman corr

% group names:  civilizations countries genders hands general_lan_families
% language_families 1st_language n_pixels

files=dir('/m/nbe/scratch/braindata/anikins1/EmoWorld/pictures_HS/countries/cfgs/*.mat');
current_type = 'countries';
NC=length(files);
mask=uint8(imread('bodySPM_base3.png'));
newmask=mask/255;
inmask=mask>128;
NE=14;
allESvals=zeros(sum(inmask(:)),NC*NE);

for n=1:NC
   temp=strsplit(strrep(files(n).name,'.mat',''),'_');
   countries{n,1}=temp{1};
   Nsubj(n,1)=str2num(temp{3});
   % load cfg file
   load(['/m/nbe/scratch/braindata/anikins1/EmoWorld/pictures_HS/countries/cfgs/' files(n).name]) % we have a variable called cfg
   disp(files(n).name);
   %ttests(n,1)=cfg.bspm.ttest;
   for e=1:NE
      temp=cfg.bspm.ttest.tval(:,:,e); 
      allESvals(:,(n-1)*NE+e)=temp(inmask)/sqrt(Nsubj(n));
      classID((n-1)*NE+e,:)=[e n];
   end
end

labels=cfg.labels;


save countries_labels_etc countries labels Nsubj classID inmask mask
load countries_labels_etc
temp=squareform(pdist(allESvals'));
iscmat=1-temp/max(temp(:));
classID=classID(1:14*NC,:);
iscmat=iscmat(1:14*NC,1:14*NC);
[aaa emo_order]=sort(classID(:,1));

iscmat=iscmat(emo_order,emo_order);
%iscmat=iscmat(1:7*NC,1:7*NC);
% sort them by emotions

NITER=5000;
p=0;
isc_val=0;
for e=1:14
    model=zeros(size(iscmat));
    model((1:NC)+(e-1)*NC,(1:NC)+(e-1)*NC)=triu(ones(NC),1);
    surro=zeros(size(iscmat));
    surro((1:NC)+(e-1)*NC,:)=1;
    surro((1:NC)+(e-1)*NC,(1:NC)+(e-1)*NC)=0;
    NM=length(find(model>0));
    tempsurr=iscmat(find(surro>0));
    isc_val(e)=mean(iscmat(find(model>0)));
    for iter=1:NITER
        %disp(num2str(iter));
        temp=tempsurr(randperm(length(tempsurr))); % shuffle tempsurr
        temp=temp(1:NM); % take first NM points
        isc_surr(iter)=mean(temp); % do average
    end
  	[fi xi]=ksdensity(isc_surr,'function','cdf','npoints',200);

    pval_left=interp1([0 xi 1],[0 fi 1],isc_val(e));    % trick to avoid NaNs
    p(e)=1-pval_left
end
figure
imagesc(iscmat,[0 1]);
% colormap(cbrewer('div','RdBu',11));
colormap(cbrewer('seq','Blues',100)); % adjust colors
colorbar;
set(gcf, 'Units', 'Pixels', 'Position', [0, 0, 1300, 1600], 'PaperUnits', 'Points', 'PaperSize', [1300, 1600]) % set the size of the final plot
export_fig(['/m/nbe/scratch/braindata/anikins1/EmoWorld/clustering/emoISC/by_' current_type '2CB.png'],'-png', '-m2', '-nocrop');

