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
cfg.onesided = [1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0]; % does the final data have one or two shapes
cfg.mapnames = {'emotions_0','emotions_1','emotions_2','emotions_3','emotions_4','emotions_5','emotions_6','pain_0','pain_1','sensitivity_0','sensitivity_1', 'sensitivity_2'};
Nsubs = length(bgdata);
%%
fi = fopen([cfg.subinfopath '/subs_bg_info_numeric.csv']);
variable_names_raw = textscan(fi,'%s',46,'Delimiter',',');
fclose(fi);
variable_names = variable_names_raw{1};
variable_names(1) = [];
variable_names = regexprep(variable_names,'[^a-zA-Z]','');

mask=uint8(imread('bodySPM_base3.png'));
mask = [mask zeros(size(mask))];
mask=mask*.85;
in_mask=find(mask>128);

mask_fb=uint8(imread('bodySPM_frontback_mask.png'));
mask_fb = [mask_fb mask_fb];
mask_fb=mask_fb(:,:,1);
mask_fb=mask_fb*.85;
in_mask_fb=find(mask_fb>128);

%%
activs = zeros(Nsubs,3*length(cfg.mapnames));
activations_header = {};
%%
for i=1:length(cfg.mapnames)
    disp(['Starting map ' num2str(i)]);
    cfg.condition = i;
    cfg.rawdatafile = [cfg.datapath cfg.mapnames{i} '_raw_data_matrix.mat'];
    load(cfg.rawdatafile)
    startind = (i-1)*3;
    header_names = {[cfg.mapnames{i} '_pos'], [cfg.mapnames{i} '_neg'], [cfg.mapnames{i} '_total']};
    activations_header = [activations_header, header_names];
    for j=1:Nsubs
        disp(['Map ' num2str(i) ' sub ' num2str(j)]);
        temp_unmasked = rawmat(:,:,j);
        if cfg.onesided(cfg.condition)==1
            temp = temp_unmasked(in_mask);
            mask_size = length(in_mask);
        else
            temp = temp_unmasked(in_mask_fb);
            mask_size = length(in_mask_fb);
        end
        activs(j,startind+1) = size(find(temp>0),1)/mask_size; % activations
        activs(j,startind+2) = size(find(temp<0),1)/mask_size; % deactivations
        activs(j,startind+3) = size(find(temp~=0),1)/mask_size;
    end
end
%%
activations = [bgdata, activs];
header = [variable_names; activations_header']';
textHeader = strjoin(header, ',');
%%
%write header to file
fid = fopen([cfg.subinfopath 'subs_bg_info_with_masked_activations.csv'],'w'); 
fprintf(fid,'%s\n',textHeader)
fclose(fid)
%write data to end of file
dlmwrite([cfg.subinfopath 'subs_bg_info_with_masked_activations.csv'],activations,'-append','precision', 16);
