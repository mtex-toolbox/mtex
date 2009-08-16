function ebsd = toebsd(grains)
% convert an grain object with orientation to ebsd data
%
%% Input
%  grains   - @grain
%
%% Output
%  ebsd  - @ebsd
%
%% See also
% ebsd/calcODF

cxy = centroid(grains);
ar = area(grains);

mean = get(grains,'orientation');
phase = get(grains,'phase');
CS = get(grains,'CS');
SS = get(grains,'SS');

uphase = unique(phase);
for k=1:length(uphase)
  sel = uphase(k) == phase;
  sel1 = find(sel,1,'first');
  
  options.weights = ar( sel );
  ebsd(k) = EBSD( mean( sel ),CS{sel1},SS{sel1},...
                  'xy',cxy( sel,: ),'phase',uphase(k),'options',options);
end