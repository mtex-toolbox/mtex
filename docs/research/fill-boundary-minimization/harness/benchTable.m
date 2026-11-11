function benchTable(opt,tag)
% all twelve benchmark maps with the options opt added, one table row per map
names = {'T0_07_clusters','T1_clean_clusters','T1_noisy_clusters','T1_clean_cracks','T1_noisy_cracks','T1_deformed_cracks','T1_clean_boundaryNotIndexed','T1_clean_patchy','T1_noisy_patchy','T1_patchyD21','T1_clean_matrix','T1_noisy_matrix'};
v = {'sif_dev','sif_ts','sif_comp','sif_ref','sif_new'};
out = evalc('T = runBench(names,v,opt);');
fid = fopen(fullfile(fileparts(mfilename('fullpath')),['bench_' tag '.log']),'w'); fwrite(fid,out); fclose(fid);
fprintf('| map | bisector | develop | taut string | component | exact (loops) | new | crossing/leaving (ts, new) |\n|---|---:|---:|---:|---:|---:|---:|---|\n');
for i = 1:size(T,1)
  if isempty(T(i,1).L), continue; end
  fprintf('| %s | %.1f |',T(i,1).map,T(i,1).L0);
  for k = 1:numel(v), fprintf(' %+.2f %% (%.2f s) |',100*(T(i,k).L/T(i,k).L0-1),T(i,k).t); end
  fprintf(' %d/%d, %d/%d |\n',T(i,2).nX,T(i,2).nOut,T(i,5).nX,T(i,5).nOut);
end
save(fullfile(fileparts(mfilename('fullpath')),['bench_' tag '.mat']),'T');
end
