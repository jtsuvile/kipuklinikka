function bodySPM_plot(cfg)
% Input parameter contains ttest OR ttest2 OR glm results
% cfg.bspm
% cfg.type = ttest ttest2 glm
% cfg.M = optional max tvalue
mask=uint8(imread('bodySPM_base3.png'));
in_mask=find(mask>128); % list of pixels inside the mask
base=uint8(imread('bodySPM_base2.png'));
base2=base(10:531,33:203,:); % single image base
labels=cfg.labels;

if (strcmp(cfg.type,'ttest'))
	NC=size(cfg.bspm.ttest.tval,3); % number of conditions
	
    if(isfield(cfg,'M')) 
        M=cfg.M;
    else
        M=max(abs(cfg.bspm.ttest.tval(:)));
        M=round(prctile(abs(cfg.bspm.ttest.tval(:)),99.9)/5)*5;
    end
    
    
	NumCol=cfg.NumCol;
	th=cfg.bspm.ttest.tTH(2);
	if(isempty(th)) 
		% using uncorrected T-value threshold
		th=3; 
	end

	non_sig=round(th/M*NumCol); % proportion of non significant colors
	hotmap=hot(NumCol-non_sig);
	coldmap=flipud([hotmap(:,3) hotmap(:,2) hotmap(:,1) ]);
	hotcoldmap=[
		coldmap
		zeros(2*non_sig,3);
		hotmap
		];
	if(0)
	% reshaping the tvalues into images
	tvals_for_plot=zeros(size(mask,1),size(mask,2),NC);
	for condit=1:NC
		temp=zeros(size(mask));
		temp(in_mask)=tdata(:,condit);
		temp(find(~isfinite(temp)))=0; % we set nans and infs to 0 for display
		max(temp(:))
		tvals_for_plot(:,:,condit)=temp;
	end
	end
	% plotting
	plotcols = ceil((NC+1)/2); %set as desired
	plotrows = ceil((NC+1)/plotcols); % number of rows is equal to number of conditions+1 (for the colorbar)
	for n=1:NC
		figure(1100)
		subplot(plotrows,plotcols,n)
		imagesc(base2);
		axis('off');
		set(gcf,'Color',[1 1 1]);
		hold on;
		%over2=tvals_for_ploat(:,:,n);
		over2=cfg.bspm.ttest.tval(:,:,n);
		fh=imagesc(over2,[-M,M]);
		axis('off');
		axis equal
		colormap(hotcoldmap);
		set(fh,'AlphaData',mask)
		title(labels(n),'FontSize',10)
		if(n==NC)
			subplot(plotrows,plotcols,n+1)
			title('Colorbar')
			fh=imagesc(zeros(size(base2)),[-M-eps,M+eps]);
			axis('off');
			colorbar;
		end
	end
else
	error('not yet implemented')
end

if(0)

% old code


map=cbrewer('div','RdBu',21);
map=flipud(map);
map(11,:)=[.3 .3 .3];
load bspm_cluster % bspm model_labels labels


base=uint8(imread('bodySPM_base2.png'));
mask=uint8(imread('bodySPM_base3.png'));
mask=mask*.85;
inmask=find(mask>128);


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
		vals'
        vals(1)=[];
		vals' 
		ccount=histc(tempclusters(:),vals);
        ids=find(ccount<=min_clu_size);
		for n = 1:length(ids)
			tempclusters(find(tempclusters==vals(ids(n))))=0;
		end
		tempmask=sign(tempclusters);
		out(modelID,stimulus)=sum(tempmask(:));
		tempdataout=zeros(size(tempdataC));
		tempdataout(inmask)=tempmask(inmask).*tempdataC(inmask);
		outfig=reshape(tempdataout,size(mask,1),size(mask,2));
		min(outfig(:))
		max(outfig(:))
		subplot(2,5,stimulus);
		h=imagesc(outfig,[-.2 .2]);
		colormap(map);
		set(h,'AlphaData',mask)
		axis equal
		title([model_labels{modelID} ' vs ' labels{stimulus}]);
		box off
		axis off
        %error('stop')
		% saveas(gcf,['pngs/model ' model_labels{modelID} ' - ' labels{stimulus} '_clucorr.png']);
	end
	colorbar
	%subplot(2,5,stimulus+1);
	%[h b]=hist(model(:,modelID),50);
	%plot(b,h,'o-');
	%title(model_labels{modelID})
	saveas(gcf,['pngs/model ' model_labels{modelID} '_clucorr.png']);
end


end
