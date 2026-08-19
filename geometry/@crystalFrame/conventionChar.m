function c = conventionChar(cF,pC)
% the plotting convention expressed in crystal directions, e.g. '⊙c*→a'
%
% Overrides the generic @referenceFrame version, which writes the screen
% layout in the frame's axes names ('c↑→a'). That form does not fit a
% crystal: the crystal axes are in general not orthogonal, so the axis
% pointing north usually is none of them and the generic version falls
% back to the Cartesian form. Naming the axis out of the screen and the
% one to the east instead always has an answer, and it is how a
% crystallographer states the setting anyway.
%
% Both the direct and the reciprocal axes are candidates, so an X||a*
% setting reads '⊙c*→a' rather than falling back.
%
% Syntax
%   c = conventionChar(cF)      % the frame's own convention
%   c = conventionChar(cF,pC)   % a resolved convention, in crystal axes
%
% Input
%  cF - @crystalFrame
%  pC - @plottingConvention
%
% Output
%  c - char
%
% See also
% referenceFrame/conventionChar plottingConvention/char

if nargin < 2, pC = cF.how2plot; end
if isempty(pC), c = ''; return; end

dirs = normalize([cF.basis, basisDual(cF)]);
names = [cF.axesNames, strcat(cF.axesNames,'*')];

out = matchAxis(pC.outOfScreen,dirs,names);
east = matchAxis(pC.east,dirs,names);

if isempty(out) || isempty(east)
  c = char(pC);
else
  % {west, east, north, south, intoScreen, outOfScreen}, ASCII when UTF8
  % output is off
  a = plottingConvention.arrows;
  c = [a{6} out a{2} east];
end

end

% =========================================================================
function name = matchAxis(v,dirs,names)

name = '';
a = angle(v,dirs);
[m,i] = min(a);
if m < 1e-4
  name = names{i};
elseif pi - max(a) < 1e-4
  [~,i] = max(a);
  name = ['-' names{i}];
end

end
