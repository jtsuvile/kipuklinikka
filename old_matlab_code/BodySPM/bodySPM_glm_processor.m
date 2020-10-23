function surr_cluster_size = bodySPM_glm_processor(filename)
	disp(['loading ' filename])
	load(filename) % variables from save(outfile,'stim','mm','tempdata','thissurromodels', 'corrtype', 'mask', 'bwmask', 'num','th');
	surr_cluster_size=zeros(num,length(th));
	for iter=1:num
		surromodel=thissurromodels(:,iter);
		temp_surr_cluster_size = bodySPM_glm_helper(surromodel,tempdata,corrtype,mask,bwmask,th);
		surr_cluster_size(iter,:)=temp_surr_cluster_size;
	end     % close parfor iter
	save(['perm_s' num2str(stim) '_m' num2str(mm) '_results.mat'],'surr_cluster_size');
	disp(['Permutations completed']);

