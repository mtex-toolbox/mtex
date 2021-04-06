function out = radon(odf,h,varargin)
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
% SO3Fun/radon

% cycle through components
out = radon(odf.components{1},h,varargin{:});
for i = 2:length(odf.components)
  out = out + radon(odf.components{i},h,varargin{:});
end

end
