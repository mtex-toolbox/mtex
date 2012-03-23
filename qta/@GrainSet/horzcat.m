function grains = horzcat(varargin)
% concatenation of grains from the same GrainSet
%
%% Syntax
% g = [grains_1, grains_2, ..., grains_n]
%% Example
%  g = [grains('fe') grains('mg')]
%  g = [grains(1:100) grains(500:end)]
%
%% See also
% GrainSet/vertcat

grains = varargin{1};

for k = 2:numel(varargin)
  g = varargin{k};
  
  gOld = find(any(grains.I_DG,1));
  gNew = find(any(g.I_DG,1));
  dOld = find(any(grains.I_DG,2));
  dNew = find(any(g.I_DG,2));
  
  % intersection of sets and indexes
  [a,gndx] = unique([gOld(:);gNew(:)]);
  [a,dndx] = unique([dOld(:);dNew(:)]);
  
  grains.A_D  = max(grains.A_D,g.A_D);
  grains.I_DG = max(grains.I_DG,g.I_DG);
  grains.A_G  = max(grains.A_G,g.A_G);
  
  grains.meanRotation = [grains.meanRotation;g.meanRotation];
  grains.meanRotation = grains.meanRotation(gndx);
  
  grains.phase = [grains.phase;g.phase];
  grains.phase = grains.phase(gndx);
  
  grains.I_FDext = max(grains.I_FDext,g.I_FDext);
  grains.I_FDsub = max(grains.I_FDsub,g.I_FDsub);
  
  grains.F = max(grains.F,g.F);
  grains.V = max(grains.V,g.V);
  
  for fn = fieldnames(grains.options)'
    cfn = char(fn);
    newoption = vertcat(grains.options.(cfn),g.options.(cfn));
    grains.options.(cfn) = newoption(gndx);
  end
  
  grains.EBSD = [grains.EBSD g.EBSD];
  grains.EBSD = grains.EBSD('sort',dndx);
  
end

