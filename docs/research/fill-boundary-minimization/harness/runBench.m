function T = runBench(names,variants,opt)
% the benchmark maps: total boundary length, grains, time of the straightening for every variant
global SIF SIFALL SIFIN
sp = fileparts(mfilename('fullpath'));
addpath(fullfile(sp,'bench'));
for i = 1:numel(names)
  [ebsd,o] = loadBenchMap(names{i});
  o = [o opt]; %#ok<AGROW>
  SIF = 'sif_dump'; [g,e] = calcGrains(ebsd,o{:}); SIF = [];
  fld = matlab.lang.makeValidName(names{i});
  if isempty(SIFIN), fprintf('%-28s no fill\n',names{i}); continue; end
  SIFALL.(fld) = SIFIN; SIFIN = [];
  fprintf('%-28s %d px, %4.1f %% notIndexed, %4d grains, %5.1f %% of the pixels outside all grains\n',names{i},length(ebsd),100*mean(~ebsd.isIndexed(:)),length(g),100*mean(e.grainId(:) == 0));
  R = sifEval(fld,variants);
  for k = 1:numel(R), T(i,k) = struct('map',names{i},'variant',R(k).name,'L',R(k).L,'L0',R(k).L0,'t',R(k).t,'nX',R(k).nX,'nOut',R(k).nOut); end %#ok<AGROW>
end
end
