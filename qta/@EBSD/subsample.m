function nebsd = subsample(ebsd,points)
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

nebsd = ebsd;

ss = sampleSize(ebsd);

if points >= sum(ss), return;end

for i = 1:length(nebsd)
  
  ip = round(points * ss(i) / sum(ss(:)));
  nebsd(i).orientations = ...
    subGrid(nebsd(i).orientations,randsample(ss(i),ip));
  
end
