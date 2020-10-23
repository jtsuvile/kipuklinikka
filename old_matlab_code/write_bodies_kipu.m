function [k] = write_bodies_kipu(root, bodyspm);
% write_bodies(experiment)
% writes raw body data into matrix format
% assumes list of good subjects (subs.txt) residing in the data folder
% input = words / faces / movie / story

%% Basic definitions for the experiment
%root='/Users/jtsuvile/Documents/projects/scantouch/beh_results';
%bodyspmdir=('/scratch/socbrain/soctouch/BodySPM/');
%root='/Volumes/SCRATCH_socbrain/soctouch';
%root='/Users/jtsuvile/Documents/projects/Touch';
%bodyspm=('/Users/jtsuvile/Documents/projects/touch/data/BodySPM/');
addpath(bodyspm)
base=uint8(imread(sprintf('%sbase2.png',bodyspm)));
mask=uint8(imread(sprintf('%sbase3.png',bodyspm)));
mask=mask*.85;
base2=base(10:531,33:203,:);
cfg.onesided = [1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0]; % does the final data have one or two shapes

%% Hey ho, let's go ...

% anadir=strcat('/triton/becs/scratch/socbrain/soctouch/word_data_',str(experiment),'/subjects/');
anadir= '';

subdir=sprintf('%s/%s',root,anadir);
cd (subdir);
D = dir(subdir);
subjects=textread('subs.txt');
k=size(subjects,1);
cd(subdir);

%% Loop through the subjects & emotion conditions
for ns=1:k;
    sub=sprintf('%s/%s',subdir,num2str(subjects(ns)));
    list=csvread([sub '/presentation.txt']);
    N=length(list);
    a=load_subj(sub,2);
    S=20;
    disp(['Processing subject ' num2str(subjects(ns)) ' which is number ' num2str(ns) ' out of ' num2str(k)]);
    resmat=zeros(522,171*2,21);
    
    for n=1:S;
        if(n==1 && list(n)~=0);
            over=nan(size(base,1),size(base,2));
            over2=[over(10:531,33:203,:) over(10:531,696:866,:)];
            resmat(:,:,n)=over2;
        elseif(n~=1 && isempty(find(list==n-1)));
            over=nan(size(base,1),size(base,2));
            over2=[over(10:531,33:203,:) over(10:531,696:866,:)];
            resmat(:,:,n)=over2;
        else
            if (n==1)
                T = length(a(1).paint(:,2));
                over=zeros(size(base,1),size(base,2));
                for t=1:T
                    y=ceil(a(1).paint(t,3)+1);
                    x=ceil(a(1).paint(t,2)+1);
                    if(x<=0) x=1; end
                    if(y<=0) y=1; end
                    if(x>=900) x=900; end
                    if(y>=600) y=600; end
                    over(y,x)=over(y,x)+1;
                end
            else
                T=length(a(find(list==n-1)).paint(:,2));
                over=zeros(size(base,1),size(base,2));
                for t=1:T
                    y=ceil(a(find(list==n-1)).paint(t,3)+1);
                    x=ceil(a(find(list==n-1)).paint(t,2)+1);
                    if(x<=0) x=1; end
                    if(y<=0) y=1; end
                    if(x>=900) x=900; end
                    if(y>=600) y=600; end
                    over(y,x)=over(y,x)+1;
                end
            end
            h=fspecial('gaussian',[25 25],8.5);
            over=imfilter(over,h);
            M1=1;
            M2=1;
            
            if(cfg.onesided(n)==1)
                over2=[M1*over(10:531,33:203,:), M2*over(10:531,696:866,:)];
                %resmat(:,1:171,n)=over2;
                resmat(:,:,n)=over2;
            else
                over2=[over(10:531,35:205,:), over(10:531, 700:870,:)];
                resmat(:,:,n)=over2;
            end
        end
    end
    
    %% Finally reshuffle the order of the order of the emotions
    subname=sprintf('%s',num2str(subjects(ns)));
    %for jo=1:length(shuffle);
    %    bresmat(:,:,jo)=resmat(:,:,(shuffle(jo)));
    %end
    %resmat=bresmat;
    matname=fullfile(root, 'mat-files', sprintf('subject_%s.mat',subname));
    %mkdir(pwd, 'mat-files');
    save (matname, 'resmat');
    %%
    %     for i=1:n;
    %         subplot(2,10,i);
    %         imagesc(base2);
    %         axis('off');
    %         set(gcf,'Color',[1 1 1]);
    %         hold on;
    %         over2=resmat(:,:,i);
    %
    %         min=-1;
    %         max=1;
    %         fh=imagesc(over2,[min max]);
    %         axis('off');
    %         colormap(lines);
    %         %mask=ones(size(over2))*.7; old
    %         set(fh,'AlphaData',mask)
    %         %title(labels(i),'FontSize',10)
    %     end
    %
    %     fname1=sprintf('%s.tiff',subname);
    %
    %     export_fig(fname1, '-m1.5');
    %     close all
end

