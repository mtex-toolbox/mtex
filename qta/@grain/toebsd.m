function ebsd = toebsd(grains)
% convert an grain object with orientation to ebsd data
%
%% Input
%  grains   - @grain
%
%% Output
%  ebsd  - @EBSD
%
%% See also
% ebsd/calcODF

cxy = centroid(grains);
ar = area(grains);

phase = get(grains,'phase');
uphase = unique(phase);

for k=1:length(uphase)
  sel = uphase(k) == phase;
  o = get(grains(sel),'orientation');
  
  options.weights = ar( sel );
  ebsd(k) = EBSD( o,...
    'xy',cxy( sel,: ),'phase',uphase(k),'options',options);
end
