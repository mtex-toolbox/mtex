function odf = rotate(odf,rot,varargin)
% rotate ODF
%
% Input
%  odf - @ODF
%  q   - @rotation
%
% Output
%  rotated odf - @ODF

for i = 1:length(odf.components)
  odf.components{i} = odf.components{i}.rotate(rot,varargin{:});  
end
