function ebsd = subsample(ebsd,points)
% subsample of ebsd data
%
%% Syntax
% subsample(ebsd,points)
%
%% Input
%  ebsd    - @EBSD
%  points  - number of random subsamples 
%
%% Output
%  ebsd    - @EBSD
%
%% See also
% EBSD/delete 

if points >= numel(ebsd), return;end

ind = discretesample(numel(ebsd),points);

ebsd = subsref(ebsd,ind);
