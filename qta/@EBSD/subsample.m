function ebsd = subsample(ebsd,points)
% subsample of ebsd data
%
%% Syntax
% subsample(ebsd,points)
%
%% Input
%  ebsd - @EBSD
%  points  - number of random subsamples 
%
%% See also
% EBSD/delete EBSD/subGrid 

ss = length(ebsd);
sl = size(ebsd,2);

if points >= sl, return;end

for i = 1:numel(ebsd)
  ip = fix(points * ss(i) / sl);
  S1 = substruct('()', {i,mtexrandsample(ss(i),ip)});
  S2 = substruct('()', {i});
  ebsd = subsasgn(ebsd,S2, subsref(ebsd,S1));
end