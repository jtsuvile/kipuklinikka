clear all
close all

model = load('pheno_filtered.csv');
sex = load('pheno_sex.csv'); % females =1;
sex = 2*(sex-1.5); % now it's with zero mean.

model=[sex model];
model_labels={'sex','age','edu','EDPS1','SCL1','TAS1','TAS2','TAS3','TAStotal'};

cfg.datapath='/scratch/braindata/eglerean/ClinicalBodypaint/outdata/';
cfg.list='pheno_filtered_list.csv';
cfg.niter=0;

bspm=bodySPM_global(cfg);
TAScols=6:9;
NC=8;

cases={'tpp','tppPOS','tppNEG'};
for c=1:3

	[cc pp]=corr(bspm.(cases{c})',model,'type','pearson');
	sum(pp<0.05/NC)
	for n=1:length(TAScols)
		if(ismember(TAScols(n),find(sum(pp<0.05/NC))))
			figure
			plot(bspm.(cases{c})(TAScols(n),:),model(:,TAScols(n)),'.');
			xlabel(['Total painted pixels (' cases{c} ')'])
			ylabel(model_labels{TAScols(n)})
			disp('storing figure')
			saveas(gcf,['pngs/' cases{c} '_' model_labels{TAScols(n)} '.png']); 
		end
	end
end
                      


bspm=bodySPM_simmat(cfg);
[cc pp]=corr(bspm.simmats',model,'type','spearman');

sum(pp<0.05/((NC*NC-NC)/2))
    for n=1:length(TAScols)
        if(ismember(TAScols(n),find(sum(pp<0.05/((NC*NC-NC)/2)))))
            figure
            plot(bspm.simmats(TAScols(n),:),model(:,TAScols(n)),'.');
            xlabel(['Similarity (' cases{c} ')'])
            ylabel(model_labels{TAScols(n)})
            disp('storing figure')
            saveas(gcf,['pngs/' 'simmat_' model_labels{TAScols(n)} '.png']);
        end
    end

