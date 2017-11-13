function bM = project2FundamentalRegion(bM,varargin)
% 
%
% Syntax
%   bM = project2FundamentalRegion(bM)
%
% Input
%  bM - @boundaryMisorientation
%
% Output
%  bM - @boundaryMisorientation
%

% step 1: project misorientation to the fundamental zone
% I guess the best would be if orientation.project2FundamentalRegion would
% return symmetry elements S1, S2 such that the projected misorientation
% is S2*mori*S1

[bM.mori,S1,S2] = project2FundamentalRegion(bM.mori);

bM.N1 = bM.N1 * S1;

end

