function odf = rotate(odf,q,varargin)
% rotate ODF
%
% Input
%  odf - @ODF
%  q   - @rotation
%
% Output
%  rotated odf - @ODF

for i = 1:length(odf)
  odf(i) = odf(i).doRotate(q,varargin{:});  
end
