function c = conventionChar(rf,pC)
% the plotting convention expressed in the axes names of the frame
%
% For a frame with custom axes names the screen layout is written in
% those names, e.g. 'TD←RD↑' for a rolling frame with RD pointing north
% and TD west. The canonical X, Y, Z frame keeps the classic lowercase
% form 'y↑→x' of plottingConvention/char. Empty when the frame carries
% no convention and none is passed in.
%
% Syntax
%   c = conventionChar(rf)      % the frame's own convention
%   c = conventionChar(rf,pC)   % a resolved convention, in frame labels
%
% Input
%  rf - @referenceFrame
%  pC - @plottingConvention
%
% Output
%  c - char
%
% See also
% plottingConvention

if nargin < 2, pC = rf.how2plot; end
if isempty(pC), c = ''; return; end

% the canonical frame reads best in the classic lowercase form
if isequal(rf.axesNames,{'X','Y','Z'})
  c = char(pC);
  return
end

dirs = normalize(rf.basis);

[ud,iN] = find(pC.north == [1;-1] .* dirs,1);
[lr,iE] = find(pC.east  == [1;-1] .* dirs,1);

% no named frame axis on the screen axes - fall back to the Cartesian form
if isempty(iN) || isempty(iE) || max(iN,iE) > numel(rf.axesNames)
  c = char(pC);
  return
end

% {west, east, north, south, ...}, ASCII when UTF8 output is off
a = plottingConvention.arrows;
northPart = [rf.axesNames{iN} a{ud+2}];

if lr == 1
  c = [northPart a{2} rf.axesNames{iE}];
else
  c = [rf.axesNames{iE} a{1} northPart];
end
