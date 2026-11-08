function runFeatures(names,maps,out,r0)
% small-alpha segmentation and part features for every map, saved to out/<name>.mat
for k = 1:numel(names)
  t = tic;
  [gr,eg] = calcGrains(maps{k},'angle',10*degree,'alpha',1.1);
  tSeg = toc(t); t = tic;
  [T,P,info] = niParts(maps{k},eg.grainId,gr,r0);
  tParts = toc(t);
  fprintf('%s: %d grains, %d parts, segmentation %.1f s, parts %.1f s\n', ...
    names{k},length(gr),height(T),tSeg,tParts);
  save(fullfile(out,[names{k} '.mat']),'T','P','info','tSeg','tParts');
end
