function bspm = get_good_subjects_kipu(cfg)
%%
%	Initially parse the 'subjects' subfolder to determine how many subjects
%	fully completed the task and other diagnostics. Adapted for pain
%	questionnaire by J.S. 11/09/2017
%
%	Usage
%		bspm = bodySPM_parseSubjects(cfg)
%	
%	Input:
%		cfg.outdata = path to output folder for writing (mandatory)
% 		cfg.datapath= path to your data subjects subfolder (mandatory)
%		cfg.Nstimuli = number of tasks/conditions/stimuli (mandatory)
%		cfg.Nempty = how many are allowed to be empty (default 1, e.g. neutral)
%		cfg.phenodata = 0; % amount of data asked to the subjects regarding age etc stored in data.txt. Default 0 (= there is no data.txt)
%% testing values
cfg.datapath = '/Users/jtsuvile/Documents/projects/kipupotilaat/data/subjects';
cfg.outdata = cfg.datapath;
cfg.Nstimuli = 12;
cfg.phenodata = 1;
cfg.Nempty = 3;
%%
bg_files = {'data.txt','pain_info.txt','current_feelings.txt',};
Nempty=1;	% we allow at least Nempty to be empty.
if(~isempty(cfg.Nempty))
	Nempty = cfg.Nempty;
end
Nstimuli=cfg.Nstimuli;

subjects=dir([cfg.datapath '/*']);
blacklist=[];
%%
for s=1:length(subjects)
	if(subjects(s).isdir==0)
		disp(subjects(s).name);
		blacklist=[blacklist;s];
		continue;
	end
	if(strcmp(subjects(s).name,'.') || strcmp(subjects(s).name,'..'))
		disp(subjects(s).name);
		blacklist=[blacklist;s];
                continue;
        end
	%% advanced feature that use regexp, excluded for now
	%if(length(regexp(subjects(s).name,'[A-Za-z]')) >0 )
	%	disp(subjects(s).name);
	%	blacklist=[blacklist;s];
	%	continue
	%end
end
%%
subjects(blacklist)=[];

Nsubj=length(subjects); % all the folders available

data_filter=zeros(Nsubj,3+cfg.phenodata); % 13 columns per subject: how many files in folder, how many empty, is it a good or bad subjects, 

emptymat=[
     0     0     0
    -1    -1    -1
     0     0     0
    -1    -1    -1
     0     0     0
    -1    -1    -1
     0     0     0
];
%%
for s=1:Nsubj
	disp(['Screening subject ' subjects(s).name ' (' num2str(s) '/' num2str(Nsubj) ')']); 
	filesindir=dir([cfg.datapath '/' subjects(s).name '/*.csv']);
	data_filter(s,1)=length(filesindir);
	Nemptyfiles=0;
	for f=1:length(filesindir)
		try
			temp=csvread([cfg.datapath '/' subjects(s).name '/' filesindir(f).name]);
		catch 
			warning(['CSV data corrupted for subject ' subjects(s).name])
			temp=emptymat;
		end
		if(isequal(temp,emptymat)) Nemptyfiles=Nemptyfiles+1; end
	end
	data_filter(s,2)=Nemptyfiles;

	if(cfg.phenodata > 0)
        txtfiles=dir([cfg.datapath '/' subjects(s).name '/*.txt']);
        celltxtfiles = struct2cell(txtfiles);
        %% make sure we have all background files included in the .txt files
        if(isempty(setdiff(bg_files, celltxtfiles(1,:))))
            data_filter(s,3) = 1;
        else
            data_filter(s,3) = 0;
        end
    end
    data_filter(s,4)=1;
    % assign as bad subjects those, who haven't done all tasks, whose data
    % is corrupted or who haven't provided all background info
    if(data_filter(s,1) < Nstimuli || data_filter(s,2) > Nempty || data_filter(s,3)==0)
		data_filter(s,4)=0;
	end
end

bspm=cfg;
bspm.data_filter=data_filter;
bspm.subjects=subjects;

end
