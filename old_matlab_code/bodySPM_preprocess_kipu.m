function bspm = bodySPM_preprocess_kipu(cfg)

% bodySPM_preprocess(cfg)
%
%   Preprocess a list of parsed subjects 
%
%   Usage
%       bspm = bodySPM_preprocess(cfg)
%
%   Input:
%       cfg.outdata = path to output folder for writing (mandatory)
%       cfg.datapath = path to your data subjects subfolder (mandatory)
%       cfg.Nstimuli = number of tasks/conditions/stimuli (mandatory)
%       cfg.list = txt file with the list of subjects to process
%       cfg.listformat = e.g. '%8c' or '%s'
%       cfg.doaverage = 1
%       cfg.averageMatrix = one line per average, one col per story to average
%       cfg.shuffleAverage = vector of shuffled ids e.g. [2 1 3 5 7 6 4]
%       cfg.hasBaseline = 0 (adds an extra condition)
% NB 12.9.2017 JS
% pain study has both pos/neg data and sensitivity data (positive from two
% sides of the body), so cfg.posneg should be a vector the length of
% Nstimuli with info for each stimulus separately
%		cfg.posneg=[0, 1]; % 1 for pos, -1 for neg, 0 for both
%		cfg.overwrite=0
%
%%
base=uint8(imread('bodySPM_base2.png'));
mask=uint8(imread('bodySPM_base3.png'));
mask=mask*.85;
base2=base(10:531,33:203,:);

% todo: add input checks

subjects=textread(cfg.list,'%s');
Nsubj=size(subjects,1);
allTimes=zeros(cfg.Nstimuli,2,Nsubj);
tocheck=zeros(Nsubj,1);
for ns=1:Nsubj;
	subjID=subjects{ns,:};
    disp(['Processing subject ' subjID ' which is number ' num2str(ns) ' out of ' num2str(Nsubj)]);
	if(cfg.overwrite==0)
		matname=[cfg.outdata '/' subjID '.mat'];
		if(exist(matname)==2)
			a=load(matname);
			allTimes(:,:,ns)=a.times;
			disp(['Already preprocessed, no overwrite'])
			continue;
		end
    end
%%    

    a=bodySPM_load_kipu([cfg.datapath '/' subjID '/'],2, cfg.mapnames);
    S=length(a);
    if( S ~= cfg.Nstimuli)
        disp('Mismatch between expected number of trials and loaded trials')
    end
   
    resmat=zeros(522,342,cfg.Nstimuli);
    times=zeros(S,2);
    % go through each stimulus
    for n=1:S;
        T=length(a(n).paint(:,2));
        over=zeros(size(base,1),size(base,2));
        for t=1:T
            y=ceil(a(n).paint(t,3)+1);
            x=ceil(a(n).paint(t,2)+1);
            if(x<=0) x=1; end
            if(y<=0) y=1; end
            if(x>=900) x=900; end
            if(y>=600) y=600; end
            over(y,x)=over(y,x)+1;
        end
        h=fspecial('gaussian',[25 25],8.5);
        over=imfilter(over,h);
		M1=1;
		M2=1;
        
        % NB: the one-sided and two-sided images are slightly differently
        % located on the matrix, so indices in the below clauses are
        % different on purpose /JS
        if(cfg.onesided(n)==1) %if onesided, populate only the left side of the matrix
            over2=M1*over(10:531,33:203,:)-M2*over(10:531,698:868,:);
            resmat(:,1:171,n)=over2;
        else 
            over2=[over(10:531,35:205,:), over(10:531, 700:870,:)];
            resmat(:,:,n)=over2;
        end
        
        % times vector, the first one is the amount of time in milliseconds, the second one is the total number of pixels painted
        if(size(a(n).paint,1)>0 && size(a(n).mouse,1)>0)
            times(n,1)=a(n).mouse(end,1)-a(n).mouse(1,1);
        else
			tocheck(ns)=tocheck(ns)+1;
			times(n,1)=0;
		end
        times(n,2)=T;
    end
%%
    %do average
    if(cfg.doaverage)
		if(size(cfg.averageMatrix,1)==1)
			resmat2=resmat;
		else
			for rm=1:size(cfg.averageMatrix,1);
				resmat2(:,:,rm)=mean(resmat(:,:,cfg.averageMatrix(rm,:)),3);
			end
		end

        if(cfg.hasBaseline)    
            resmat2(:,:,size(cfg.averageMatrix,1)+1)=resmat(:,:,cfg.Nstimuli);
        end
        
        % reshuffle average
        bresmat=zeros(size(resmat2));
		save debug
        for jo=1:length(cfg.shuffleAverage);
            bresmat(:,:,jo)=resmat2(:,:,(cfg.shuffleAverage(jo)));
        end
        if(cfg.hasBaseline) 
            bresmat(:,:,size(cfg.averageMatrix,1)+1)=resmat2(:,:,size(cfg.averageMatrix,1)+1);
        end
        
        resmat2=bresmat;
        
    end

    matname=[cfg.outdata '/' subjID '.mat'];
    save (matname, 'resmat','times');

    
    % store all times for diagnostic purposes
    allTimes(:,:,ns)=times;
end
bspm=cfg;
bspm.allTimes=allTimes;
bspm.tocheck=tocheck;
