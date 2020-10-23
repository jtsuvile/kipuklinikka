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
cfg.onesided = [1, 1, 1, 1, 1, 1, 1, 0, 0, 0]; % does the final data have one or two shapes
cfg.mapnames = {'emotions_0','emotions_1','emotions_2','emotions_3','emotions_4','emotions_5','emotions_6','sensitivity_0','sensitivity_1', 'sensitivity_2'};

%%
fi = fopen([cfg.subinfopath '/subs_bg_info_numeric.csv']);
variable_names_raw = textscan(fi,'%s',46,'Delimiter',',');
fclose(fi);
variable_names = variable_names_raw{1};
variable_names(1) = [];
variable_names = regexprep(variable_names,'[^a-zA-Z]','');
%% one sample t-test
for i=1:length(cfg.mapnames)
    cfg.condition = i;
    cfg.condition_name = cfg.mapnames{i};
    cfg.rawdatafile = [cfg.datapath cfg.mapnames{i} '_raw_data_matrix.mat'];
    bspm = bodySPM_ttest_kipu(cfg);
    save([cfg.datapath 'bspm_ttest_' cfg.mapnames{i}], 'bspm');
end
%error('stop');
%% percentages for pain maps
cfg.mapnames = {'pain_0','pain_1'};
%%
for j=1:length(cfg.mapnames)
    clear rawmat;
    cfg.rawdatafile = [cfg.datapath cfg.mapnames{j} '_raw_data_matrix.mat'];
    cfg.condition_name = cfg.mapnames{j};
    load(cfg.rawdatafile)
    rawmat(rawmat~=0) = 1;
    summa = sum(rawmat,3);
    ratio = summa./size(rawmat,3);
    perc = ratio*100;
    bspm=cfg;
    bspm.perc = perc;
    bspm.Nsubs = size(rawmat,3);
    save([cfg.datapath 'bspm_percentages_' cfg.mapnames{j}], 'bspm');
end

%% FDR over all, onesided
clear bspm;
cfg.mapnames = {'emotions_0','emotions_1','emotions_2','emotions_3','emotions_4','emotions_5','emotions_6','pain_0','pain_1','sensitivity_0','sensitivity_1', 'sensitivity_2'};

for vv=1:2
    p_all = [];
    if vv==1
        mask=uint8(imread('bodySPM_base3.png'));
        mask = [mask zeros(size(mask))];
        thing = 1:7;
        thingname = 'emotions';
    else
        mask=uint8(imread('bodySPM_frontback_mask.png'));
        mask = [mask mask];
        mask = mask(:,:,1);
        if vv==3
            thing = 8:9;
            thingname = 'pains';
        elseif vv==2
            thing = 10:12;
            thingname = 'sensitivity';
        else
            error('not valid');
        end
    end
    mask=mask*.85;
    in_mask=find(mask>128);
    for g=1:length(thing)
        e = thing(g);
        ttestfile = [cfg.datapath 'bspm_ttest_' cfg.mapnames{e}];
        load(ttestfile)
        p_relevant = bspm.ttest.pval(in_mask);
        p_all = [p_all; p_relevant];
    end
    df=size(bgdata,1)-1; %degrees of freedom
    [pID, pN] = FDR(p_all, 0.05);
    tID      = icdf('T',1-pID,df);      % T threshold, indep or pos. correl.
    tN       = icdf('T',1-pN,df) ;      % T threshold, no correl. assumptions
    limits= [];
    limits.pval = [pID pN];
    limits.tval = [tID tN];
    save([cfg.datapath 'limits_ttest_' thingname '_joint_FDR'], 'limits');
end

%% 2 sample t-test
Nsubj=size(bgdata,1);
G=round(Nsubj/3);
allttest2={};
%cfg.mapnames = {'emotions_0','emotions_1','emotions_2','emotions_3','emotions_4','emotions_5','emotions_6'};
%cfg.onesided = [1, 1, 1, 1, 1, 1, 1]; % does the final data have one or two shapes
cfg.onesided = [1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0]; % does the final data have one or two shapes
cfg.mapnames = {'emotions_0','emotions_1','emotions_2','emotions_3','emotions_4','emotions_5','emotions_6','pain_0','pain_1','sensitivity_0','sensitivity_1', 'sensitivity_2'};
cfg.comparemaps = 0;
%% two sample t-test by background data
look_at = [13, 14, 15];%[2, 6, 13, 14, 15];
variable_names(look_at);
for j=1:length(cfg.mapnames)
    cfg.condition = j;
    cfg.rawdatafile = [cfg.datapath cfg.mapnames{j} '_raw_data_matrix.mat'];
    for m=1:length(look_at);
        disp(['running two sample t-test of ' cfg.mapnames{j} ' with groups by ' variable_names{look_at(m)}]);
        bg=bgdata(:,look_at(m));
        %[aa bb]=sort(temp,1,'descend');
        %g1=bb(1:G);
        %g2=bb((end-G+1):end);
        vals = unique(bg);
        if length(vals)<3
            cfg.g1=find(bg==vals(1));
            cfg.g2=find(bg==vals(2));
        else
            error('not implemented yet');
        end
        cfg.niter=0;
        cfg.uncorrected=1;
        bspm = bodySPM_ttest2_kipu(cfg);
        save([cfg.datapath 'bspm_ttest2_' cfg.mapnames{j} '_group_' variable_names{look_at(m)}], 'bspm');
    end
end
disp('done!');
%% FDR over all, twosided
clear bspm;
look_at = [13, 14, 15];
for n=1:length(look_at)
    for vv=1:1
        p_all = [];
        if vv==1
            mask=uint8(imread('bodySPM_base3.png'));
            mask = [mask zeros(size(mask))];
            thing = 1:7;
            thingname = 'emotions';
        else
            mask=uint8(imread('bodySPM_frontback_mask.png'));
            mask = [mask mask];
            mask = mask(:,:,1);
            if vv==2
                thing = 8:9;
                thingname = 'pains';
            elseif vv==3
                thing = 10:12;
                thingname = 'sensitivity';
            else
                error('not valid');
            end
        end
        mask=mask*.85;
        in_mask=find(mask>128);
        for g=1:length(thing)
            e = thing(g);
            ttestfile = [cfg.datapath 'bspm_ttest2_' cfg.mapnames{e} '_group_' variable_names{look_at(n)}];
            load(ttestfile)
            p_relevant = bspm.ttest2.pvals(in_mask);
            p_all = [p_all; p_relevant];
        end
        df=size(bgdata,1)-1; %degrees of freedom
        [pID, pN] = FDR(p_all, 0.05);
        tID      = icdf('T',1-pID,df);      % T threshold, indep or pos. correl.
        tN       = icdf('T',1-pN,df) ;      % T threshold, no correl. assumptions
        limits= [];
        limits.pval = [pID pN];
        limits.tval = [tID tN];
        save([cfg.datapath 'limits_ttest2_' thingname '_'  variable_names{look_at(n)} '_joint_FDR'], 'limits');
    end
end

