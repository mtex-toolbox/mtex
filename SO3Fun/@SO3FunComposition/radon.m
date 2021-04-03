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
%  pdf - pole density function @S2FunHarmonicSym
%  ipdf - inverse pole density function @S2FunHarmonicSym
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
if length(sp) > 1
  assert(length(sp) == length(h),'Number of superposition coefficients must coinside with the number of pole figures');
  varargin = delete_option(varargin,'superposition');
  pdf = sp(1) * calcPDF(odf,h(1),varargin{:});
  for i = 2:length(sp)
    pdf = sp(i) * calcPDF(odf,h(i),varargin{:});
  end
  return
end

% cycle through components
pdf = odf.weights(1) * calcPDF(odf.components{1},h,varargin{:});
for i = 2:length(odf.components)
  pdf = pdf + reshape(odf.weights(i) * calcPDF(odf.components{i},h,varargin{:}),size(pdf));
end

end
