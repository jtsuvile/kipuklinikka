clear all
close all
addpath('/m/nbe/scratch/braindata/eglerean/emoworld/external/tsne')
addpath(genpath('/m/nbe/scratch/braindata/anikins1/EmoWorld/code/')); % toolbox folder
addpath(genpath('/m/nbe/scratch/braindata/shared/toolboxes/bramila'));
% get avg emotion per country based on t maps.
% we scale t values by num of subj to have eff size but it shouldn't affect the
% similarity measure since we use Spearman corr
% names of the groups: countries civilizations general_lan_families
% language_families 1st_language genders hands n_pixels
files=dir('/m/nbe/scratch/braindata/anikins1/EmoWorld/pictures_HS/countries/cfgs/*.mat');
NC=length(files);
mask=uint8(imread('bodySPM_base3.png'));
newmask=mask/255;
inmask=mask>128;
NE=14;
allTvals=zeros(sum(inmask(:)),NC*NE);

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
      allTvals(:,(n-1)*NE+e)=temp(inmask)/sqrt(Nsubj(n));
      classID((n-1)*NE+e,:)=[e n];
   end
end

labels=cfg.labels;


save countries_labels_etc countries labels Nsubj classID inmask mask
%error('stop')

D=squareform(pdist(allTvals','spearman'));
D=squareform(pdist(allTvals','cosine'));
D=squareform(pdist(allTvals','euclidean'));

%% run tsne for distance matrix
close all
for perpx=30%[2 5 30 50 100]
figure(perpx)    
rng(0)
%[tsne_out]=tsne_d(D,classID(:,1));

%tsne_out=tsne(allTvals',classID(:,1),2,perpx);
[tsne_out tsne_D]=tsne(allTvals',classID(:,1))%,2,perpx);

% plot the MDS for all emotions
hexcolors=[
    'a8da43' % netural = greenish
    '878787' %fear = grey
    'da000e' %anger = red
    '946400' % disgust = brown
    '5a9dd1' % sadness = light blue
    'ffff00' %joy = yellow
    'fc6b00' % surprise = orange    
    '954514' % anxiety 
    'f167b5' %love 
    '1a5bad' % depression
    'f9b8b4' % contempt     
    'ffffb7' %pride
    'b291c6' % shame     
    '853598' % envy
];

otherColors=zeros(14,3);
for i=1:size(hexcolors,1)
    RR=hex2dec(hexcolors(i,1:2))/255;
    GG=hex2dec(hexcolors(i,3:4))/255;
    BB=hex2dec(hexcolors(i,5:6))/255;
    %otherColors(shuffother(i),:)=[RR GG BB];
    otherColors(i,:)=[RR GG BB];
end
for n =1:size(tsne_out,1)
   figure(100+perpx)
   hold on
   plot(tsne_out(n,1),tsne_out(n,2),'o','MarkerSize',10,'MarkerFaceColor',otherColors(classID(n,1),:),'MarkerEdgeColor',otherColors(classID(n,1),:)/2)
   temp=countries{classID(n,2)};
   text(tsne_out(n,1)+.1,tsne_out(n,2),temp(1:2))
end

for e=1:NE
   ids=find(classID(:,1)==e);
   xyM=mean(tsne_out(ids,:));
   text(xyM(1)-.01,xyM(2),labels{e},'FontSize',20,'FontWeight','bold','Color',[0 0 0]);
   text(xyM(1)+.01,xyM(2),labels{e},'FontSize',20,'FontWeight','bold','Color',[0 0 0]);
   text(xyM(1),xyM(2)-.01,labels{e},'FontSize',20,'FontWeight','bold','Color',[0 0 0]);
   text(xyM(1),xyM(2)+.01,labels{e},'FontSize',20,'FontWeight','bold','Color',[0 0 0]);
   text(xyM(1),xyM(2),labels{e},'FontSize',20,'FontWeight','bold','Color',otherColors(e,:));
end

end


% repeat for basic emotions only

%% similarity of emotion pattern across countries
% given the distance matrix, extract two countries and compare patter with
% mantel test
% i.e. how similar are the "fingerprints" of all countries?
tsne_D=(tsne_D+tsne_D')/2;
tsne_D(1:(size(tsne_D,1)+1):end)=0;
for c1=1:NC
    id1=find(classID(:,2)==c1);
    temp1=tsne_D(id1,id1); % here is the "figerprint" of country 1, 
    % which tells how much differently guys from this country painted any
    % given pair of emotions (e.g. how big was the difference between despression and love for them?)
    c1
    for c2=(c1+1):NC
        id2=find(classID(:,2)==c2);
        temp2=D(id2,id2); % here is the "figerprint" of country 2
        [r p]=bramila_mantel(temp1, temp2,5000,'spearman');
        allR(c1,c2)=r;
        allR(c2,c1)=r;
        allP(c1,c2)=p;
        allP(c2,c1)=p;
    end
end
figure
imagesc(allR)
colormap(cbrewer('seq','Blues',11)); % adjust colors
colorbar;

% figure
% imagesc(temp1)
% colormap(cbrewer('seq','Blues',11)); % adjust colors
% % colorbar;

set(gcf, 'Units', 'Pixels', 'Position', [0, 0, 1300, 1600], 'PaperUnits', 'Points', 'PaperSize', [1300, 1600]) % set the size of the final plot
export_fig(['/m/nbe/scratch/braindata/anikins1/EmoWorld/figures/fingerprints_allCB.png'],'-png', '-m2', '-nocrop');

%% given the emotion, compare if they are similar different between countries
for e1=1:14
    id1=find(classID(:,1)==e1);
    temp1=tsne_D(id1,id1);
    e1
    for e2=(e1+1):14
        id2=find(classID(:,1)==e1);
        temp2=D(id2,id2);
        [r p]=bramila_mantel(temp1, temp2,5000,'spearman');
        allR_emo(e1,e2)=r;
        allR_emo(e2,e1)=r;
        allP_emo(e1,e2)=p;
        allP_emo(e2,e1)=p;
    end
end
figure
imagesc(allR_emo)

%% plot of all data and dendrogram

z=linkage(squareform(tsne_D),'complete');
z(:,3)=sqrt(z(:,3));
figure
[H,T,OUTPERM] =dendrogram(z,0)
axis off
for c=1:length(OUTPERM)
    cID=classID(OUTPERM(c),2);
    eID=classID(OUTPERM(c),1);
    ctext=countries{cID};
    hold on
    t=text(c,0,ctext(1:2),'Rotation',90,'Color',[0 0 0],'BackgroundColor',otherColors(eID,:),'FontSize',3,'HorizontalAlignment','right')
    hold on
end
