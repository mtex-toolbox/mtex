function pdf = calcPDF(odf,h,varargin)
% calcPDF computed the PDF corresponding to an ODF
%
% Syntax
%   pdf = calcPDF(odf,h)
%   pdf = calcPDF(odf,h,'superposition',c)
%   value = calcPDF(odf,h,r)
%   ipdf = calcPDF(odf,[],r)
%
% Input
%  odf - @ODF
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
% ODF/plotPDF ODF/plotIPDF ODF/calcPoleFigure

% check crystal symmetry
if isa(h,'Miller'), h = odf.CS.ensureCS(h); end

% superposed pole figures
sp = get_option(varargin,'superposition',1);
assert(length(sp)== 1 || length(sp) == length(h),...
  'Number of superposition coefficients must coinside with the number of pole figures');

% compute pole densitsy functions and average over superposition
pdf = odf.radon(h,varargin{:}).' * sp(:);

% maybe we should evaluate them
if nargin > 0 && isa(varargin{1},'vector3d') && ~isempty(h)
  if length(h) > length(varargin{1})
    pdf = pdf.eval(h);
  else
    pdf = pdf.eval(varargin{1});
  end
end

end
