function bspm = make_raw_data_matrices(cfg)
% not the fastest kid on the block but gets things done!
% will combine each map as its own raw data matrix, size
% 522 x 342 x Nsubjects

subjects=textread(cfg.list,'%s');

for i=1:length(cfg.mapnames)
    mapfile = [cfg.outdata cfg.mapnames{i} '_raw_data_matrix.mat'];
    if exist(mapfile) && cfg.overwrite_raw == 0
        disp(['Already worked on ' cfg.mapnames{i} ', skipping']);
    else
        rawmat = NaN(522,342,length(subjects));
        for s=1:length(subjects)
            disp(['Working on ' num2str(i) ':' num2str(s)]);
            matname=[cfg.outdata subjects{s} '.mat'];
            load (matname) % 'resmat','resmat2','times'
            rawmat(:,:,s) = resmat(:,:,i);
        end
        save(mapfile, 'rawmat', '-v7.3');
    end
end
end