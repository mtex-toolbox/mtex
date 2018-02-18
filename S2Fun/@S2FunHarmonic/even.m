function sF = even(sF, varargin)
% even or antipodal part of a spherical function
%
% Syntax
%   sF = sF.even
%

sF = sF.conv(repmat([1;0],ceil(sF.bandwidth/2)+1,1));

end
