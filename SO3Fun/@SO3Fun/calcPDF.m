function pdf = calcPDF(SO3F,h,varargin)
% calcPDF computed the PDF corresponding to an ODF
%
% Syntax
%   pdf = calcPDF(SO3F,h)
%   pdf = calcPDF(SO3F,h,'superposition',c)
%   value = calcPDF(SO3F,h,r)
%   ipdf = calcPDF(SO3F,[],r)
%
% Input
%  SO3F - @SO3Fun
%  h   - @Miller / @vector3d crystal directions
%  r   - @vector3d specimen directions
%
% Output
%  pdf   - pole density function @S2FunHarmonicSym
%  ipdf  - inverse pole density function @S2FunHarmonicSym
%  value - double
%
% Options
%  superposition - calculate superposed pdf
%
% Flags
%  antipodal - include <VectorsAxes.html antipodal symmetry>
%
% See also
% SO3Fun/plotPDF SO3Fun/plotIPDF SO3Fun/calcPoleFigure

% check crystal symmetry
if isa(h,'Miller')
  h = SO3F.CS.ensureCS(h); 
elseif ~isempty(h)
  h = Miller(h,SO3F.CS);
end

% superposed pole figures
sp = get_option(varargin,'superposition',1);
assert(isscalar(sp) || length(sp) == length(h),...
  'Number of superposition coefficients must coinside with the number of pole figures');

% compute pole density functions and average over superposition
pdf = SO3F.radon(h,varargin{:}).' * sp(:);

end
