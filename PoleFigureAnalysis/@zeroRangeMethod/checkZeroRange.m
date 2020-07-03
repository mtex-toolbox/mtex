function isZero = checkZeroRange(zrm,ori,i,varargin)
% check for zero regions in experiementl pole figures
%
% Syntax
%
%   isZero = checkZeroRange(zrm,ori) % check at orientation in all pole figures
%   isZero = checkZeroRange(zrm,v,i) % check at position in the i-th pole figure
%
% Input
%  zrm - @zeroRangeMethod
%  ori - @orientation
%  v   - @vector3d
%  i   - check in the i~th pole figure
%
% Output
%  isZero - boolean vector of length(ori)

if isa(ori,'orientation')
  
  % start with complete grid
  isZero = false(size(ori));
  
  % loop over pole figures
  for i = 1:zrm.pf.numPF

    h = symmetrise(zrm.pf.allH{i},'antipodal','unique');
        
    % loop over all symmetrically equivalent pole figure positions
    for ih = 1:length(h)
      v = ori(~isZero) * h(ih);
      isZero(~isZero) = checkZeroRange(zrm,v,i);
    end    
    
  end
else % check the i-th pole figure at position ori
  d = zrm.density(i).eval(ori);
  pdf = zrm.pdf(i).eval(ori);
  isZero = d > zrm.threshold & pdf./d < -0.1;
end
end