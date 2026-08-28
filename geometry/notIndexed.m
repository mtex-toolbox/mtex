function fr = notIndexed(name,color)
% the phase of measurements that could not be indexed
%
% A not indexed phase is a <notIndexedFrame.notIndexedFrame.html
% notIndexedFrame>: a reference frame without a lattice, which is what lets
% the CSList of a @phaseList hold it beside the crystal frames of the
% indexed phases.
%
% Syntax
%   ni = notIndexed
%   ni = notIndexed(name)
%   ni = notIndexed(name,color)
%
% Input
%  name  - name shown instead of a mineral, 'notIndexed' by default
%  color - RGB triplet, NaN by default
%
% Output
%  ni - @notIndexedFrame
%
% See also
% notIndexedFrame phaseList crystalSymmetry

switch nargin
  case 0
    fr = notIndexedFrame;
  case 1
    fr = notIndexedFrame(name);
  otherwise
    fr = notIndexedFrame(name,color);
end

end
