clear all
close all
addpath(genpath('/triton/becs/scratch/braindata/eglerean/code/bodyspm/'))

% plot of ttest values
load alllabels
load bspm_ttest
cfg=[];
cfg.bspm=bspm;
cfg.labels=labels;
cfg.type='ttest';
cfg.NumCol=32;

bodySPM_plot(cfg);

set(gcf,'units','normalized','outerposition',[0 0 1 1])
set(gcf,'Color',[1 1 1])
axis off
box off
set(gcf,'paperunits','normalized')
set(gcf,'paperposition',[0 0 1 1])
set(gcf,'paperorientation','landscape')
% saving
tightfig
saveas(gcf,'pdf/tstats.pdf','pdf');
export_fig('png/tstats.png');


%% glm
load bspm_clucorr_pearson

map=cbrewer('div','RdBu',21);
map=flipud(map);
map(((size(map,1)-1)/2)+1,:)=[1 1 1]*1;

ids=find(abs(bspm.glm)>0);
M=round(20*prctile(abs(bspm.glm(ids)),99.99))/20;
NumCol=32;
th=0.02;
 non_sig=round(th/M*NumCol); % proportion of non significant colors
    hotmap=hot(NumCol-non_sig);
    coldmap=flipud([hotmap(:,3) hotmap(:,2) hotmap(:,1) ]);
    map=[
        coldmap
        zeros(2*non_sig,3);
        hotmap
        ];


base=uint8(imread('bodySPM_base2.png'));
base2=base(10:531,33:203,:); % single image base

mask=uint8(imread('bodySPM_base3.png'));
mask=mask*1; %was .85
if(0)
% for viz purposes
base2inv=255-base2;
base2inv=uint8(mean(base2inv,3));
base2inv(find(base2inv<128))=0;
mask=mask-base2inv;
inmask=(mask>254);
temp=bwlabel(inmask,4);

newmask=zeros(size(mask));
newmask(find(temp==5))=1; % hardcoded!!
inmask=newmask>0;
else
    newmask=mask/255;
    inmask=mask>128;
end

if(0)
    % first, find the smallest of the largest cluster size across all models/stimuli
    largest_clusters=zeros(length(model_labels),length(labels));
    for modelID=1:length(model_labels);
        for stimulus=1:length(labels);
            tempdataC=bspm.glm(:,modelID,stimulus);
            tempdataC(find(isnan(tempdataC)))=0;
            tempmaskIN=double(abs(tempdataC(inmask))>=bspm.cluth(stimulus,modelID));
            tempmask=zeros(size(mask));
            tempmask(inmask)=tempmaskIN;
            tempclusters=bwlabel(tempmask,4);
            vals=unique(tempclusters);
            vals(1)=[];
            ccount=histc(tempclusters(:),vals);
            if(length(ccount)>0)
                largest_clusters(modelID,stimulus)=max(ccount);
            end
        end
    end
    
    temp=sort(largest_clusters(:));
    %temp(find(temp<=100))=[];
    temp(find(temp<=0))=[];
    min_clu_size=temp(1)
end

winnercount=0;
% the absolute min cluster size
h=fspecial('gaussian',[15 15],5);
mmm_clusize=length(find(h(:)>max(h(:))/2));

for modelID=1:length(model_labels);
    figure(modelID)
    for stimulus=1:length(labels);
        
        tempdataC=bspm.glm(:,modelID,stimulus);
        tempdataC(find(isnan(tempdataC)))=0;
        
        tempmaskIN=double(abs(tempdataC(inmask))>=bspm.cluth(stimulus,modelID));
        
        
        tempmask=zeros(size(mask));
        tempmask(inmask)=tempmaskIN;
        tempclusters=bwlabel(tempmask,4);
        vals=unique(tempclusters);
        ccount=histc(tempclusters(:),vals);
        
        thID=find(bspm.th==bspm.cluth(stimulus,modelID));
        if(isempty(thID))
            min_clu_size=0;
        else
            min_clu_size=bspm.clu95(stimulus,modelID,thID);
            
        end
        
        ids=find(ccount<=min_clu_size);
        for n = 1:length(ids)
            tempclusters(find(tempclusters==vals(ids(n))))=0;
        end
        tempmask=sign(tempclusters);
        out(modelID,stimulus)=sum(tempmask(:));
        tempdataout=zeros(size(tempdataC));
        tempdataout(inmask)=tempmask(inmask).*tempdataC(inmask);
        outfig=reshape(tempdataout,size(mask,1),size(mask,2));
        %min(outfig(:))
        %max(outfig(:))
        subplot(2,5,stimulus);
        imagesc(base2);
        hold on
        h=imagesc(outfig,[-M M]);
        colormap(map);
        thismask=255*sign(abs(outfig));
        set(h,'AlphaData',255*newmask)
        axis equal
        title([model_labels{modelID} ' vs ' labels{stimulus}]);
        
        axis off
        box off
        
        if(any(thismask(:)) && modelID>3) % we skip the first 3 models
            if(length(find(thismask>0)) < mmm_clusize) continue; end
            
            disp(['we have a winner for ' model_labels{modelID} ' vs ' labels{stimulus}])
            winnercount=winnercount+1;
            if(winnercount==1)
                winners=outfig;
            else
                winners(:,:,winnercount)=outfig;
            end
            winnerlabels{winnercount}=[model_labels{modelID} ' vs ' labels{stimulus}];
            winpval(winnercount)=bspm.clupvals(stimulus,modelID,thID)
            wincluTH(winnercount)=bspm.cluth(stimulus,modelID);
            
        end
            
        
        
        
        % saveas(gcf,['pngs/model ' model_labels{modelID} ' - ' labels{stimulus} '_clucorr.png']);
    end
    subplot(2,5,stimulus+1);

    fh=imagesc(ones(size(base2)),[-(M+eps),(M+eps)]);
    axis('off');
    colorbar
    title('Colorbar')
    
    
    
    box off
    axis off
    %error('stop')
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    set(gcf,'Color',[1 1 1])
    
    set(gcf,'paperunits','normalized')
    set(gcf,'paperposition',[0 0 1 1])
    set(gcf,'paperorientation','landscape')
    
    % saving
    
    export_fig(['png/model ' model_labels{modelID} '_clucorr.png']);
 
    
end


for w=1:size(winners,3)
   figure(100)
   subplot(2,7,w)
        imagesc(base2);
        hold on
        h=imagesc(winners(:,:,w),[-M M]);
        colormap(map);
        set(h,'AlphaData',255*newmask)
        axis equal
        title(winnerlabels{w});
        
        axis off
        box off
        text(0, size(base2,1)+20,['q < ' num2str(winpval(w),3) '; TH = ±' num2str(wincluTH(w))])
        
end
   subplot(2,7,w+1)
   
fh=imagesc(zeros(size(base2)),[-(M+eps),(M+eps)]);
    axis('off');
    colorbar
    title('Colorbar')
    box off
    axis off
    %error('stop')
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    set(gcf,'Color',[1 1 1])
    
    set(gcf,'paperunits','normalized')
    set(gcf,'paperposition',[0 0 1 1])
    set(gcf,'paperorientation','landscape')

   % saving
   tightfig
    saveas(gcf,'pdf/significant_models_pearson.pdf','pdf');
    export_fig(['png/significant_models_pearson']);
 
