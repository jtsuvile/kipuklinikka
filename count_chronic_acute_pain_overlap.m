clear all;
close all;
addpath(genpath('/Users/jtsuvile/Documents/projects/kipupotilaat/code/BodySPM/'));
%%
cfg=[];
cfg.datapath = '/Users/jtsuvile/Documents/projects/kipupotilaat/data/mat-files/';
cfg.subinfopath = '/Users/jtsuvile/Documents/projects/kipupotilaat/data/';
bgdata = csvread([cfg.subinfopath '/subs_bg_info_numeric.csv'], 1, 1);
cfg.niter=0; % do not run cluster correction
cfg.doaverage = 0;
cfg.uncorrected = 0;
cfg.mapnames = {'pain_0','pain_1'};
Nsubs = length(bgdata);
%%
fi = fopen([cfg.subinfopath '/subs_bg_info_numeric.csv']);
variable_names_raw = textscan(fi,'%s',46,'Delimiter',',');
fclose(fi);
variable_names = variable_names_raw{1};
variable_names(1) = [];
variable_names = regexprep(variable_names,'[^a-zA-Z]','');

mask_fb=uint8(imread('bodySPM_frontback_mask.png'));
mask_fb = [mask_fb mask_fb];
mask_fb=mask_fb(:,:,1);
mask_fb=mask_fb*.85;
in_mask_fb=find(mask_fb>128);

%%
for i=1:length(cfg.mapnames)
    disp(['Starting map ' num2str(i)]);
    cfg.condition = i;
    cfg.rawdatafile = [cfg.datapath cfg.mapnames{i} '_raw_data_matrix.mat'];
    load(cfg.rawdatafile)
    if(i==1)
        rawmat_acute = rawmat;
    end
    if(i==2)
        rawmat_chronic = rawmat;
    end
end
%%
rawmat_chronic(rawmat_chronic>0) = 1;
rawmat_acute(rawmat_acute>0) = 1;
%%
pains_overlap = zeros(Nsubs,3);
for j=1:Nsubs
    disp(['Sub ' num2str(j)]);
    temp_chronic = rawmat_chronic(:,:,j);
    temp_acute = rawmat_acute(:,:,j);
    if(sum(sum(temp_chronic))==0)
        pains_overlap(j,4) = 0;
    else
        pains_overlap(j,4) = 1;
    end
    if(sum(sum(temp_acute))==0)
        pains_overlap(j,3) = 0;
    else
        pains_overlap(j,3) = 1;
    end
    temp = temp_chronic + temp_acute;
    overlap = sum(sum(temp==2));
    prop_overlap = overlap/length(in_mask_fb); % how much of the body area is chronic & acute
    prop_pain = overlap/sum(sum(temp>0)); % how much of the extent of pain is chronic & acute
    pains_overlap(j,1) = prop_overlap;
    pains_overlap(j,2) = prop_pain;
    
end

%%
%write header to file
textHeader = ['overlap_prop_body, overlap_prop_all_pain, acute_present, chronic_present'];
fid = fopen([cfg.subinfopath 'pains_overlap.csv'],'w'); 
fprintf(fid,'%s\n',textHeader)
fclose(fid)
%write data to end of file
dlmwrite([cfg.subinfopath 'pains_overlap.csv'],pains_overlap,'-append','precision', 16);
