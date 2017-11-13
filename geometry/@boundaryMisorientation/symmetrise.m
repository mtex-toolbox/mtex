function bM = symmetrise(bM,varargin)
% 
%
% Syntax
%   bM = symmetrise(bM)
%
% Input
%  bM - @boundaryMisorientation
%
% Output
%  bM - @boundaryMisorientation
%

bM.mori = bM.CS2 * (bM.mori * bM.CS1).';
bM.N1 = repmat(bM.CS1 * bM.N1,numel(bM.CS2),1);

% in the presense of the grain exchange symmetry
if bM.antipodal
  % we have to add the inverse as well
  bM = [bM;inv(bM)];
end

end
