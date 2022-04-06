function odf = rotate(odf,rot,varargin)
% rotate ODF
%
% Input
%  odf - @ODF
%  q   - @rotation
%
% Output
%  rotated odf - @ODF

ss = odf.SS.Laue;
if length(ss)>2 && ~any(rot == ss(:))
  warning('Rotating an ODF with specimen symmetry will remove the specimen symmetry')
  odf.SS = specimenSymmetry;
end

for i = 1:length(odf.components)
  odf.components{i} = odf.components{i}.rotate(rot,varargin{:});  
end
