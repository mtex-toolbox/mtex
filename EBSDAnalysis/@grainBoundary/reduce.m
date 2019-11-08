function gB = reduce(gB,factor)
% reduce a list of grain boundary segments by taking only every second
% 
% Syntax
%   gB_red = reduce(gB)
%   gB_red = reduce(gB,n)
%
% Input
%  gB - @grainBoundary
%  n  - factor by which the segments are reduced (default 2)
%
% Output
%  gB_red - @grainBoundary
%
% See also
% EBSD/reduce


if nargin == 1, factor = 2; end

% computed Euler cycles
%[~,Fid] = EulerCycles2(gB.F);

%Fid(isnan(Fid)) = [];
%gB = gB.subSet(Fid(1:factor:end));

gB = gB.reorder;
gB = gB.subSet(1:factor:length(gB));

end