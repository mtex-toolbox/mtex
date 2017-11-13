function bM = inv(bM)
% change a grain A to grain B boundary misorientation to a grain B to grain A boundary misorientation
%
% Syntax
%   bM = inv(bM)
%
% Input
%  bM - @boundaryMisorientation
%
% Output
%  bM - @boundaryMisorientation
%

bM.N1 = bM.N2;
bM.mori = inv(bM.mori);

end

