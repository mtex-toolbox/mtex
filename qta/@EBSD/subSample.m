function ebsd = subSample(ebsd,points)
% subsample of ebsd data
%
% Syntax
%   subSample(ebsd,points)
%
% Input
%  ebsd    - @EBSD
%  points  - number of random subsamples 
%
% Output
%  ebsd    - @EBSD
%
% See also
% EBSD/delete 

if points >= length(ebsd), return;end

ind = discretesample(length(ebsd),points);

ebsd = subSet(ebsd,ind);
