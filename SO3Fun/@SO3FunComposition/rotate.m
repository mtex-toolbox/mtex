function odf = rotate(odf,rot,varargin)
% rotate ODF
%
% Input
%  odf - @SO3Fun
%  q   - @rotation
%
% Output
%  rotated odf - @SO3Fun

ss = odf.SS.Laue;
if length(ss)>2 && ~any(rot == ss(:))
  warning('Rotating an ODF with specimen symmetry will remove the specimen symmetry')
  odf.SS = specimenSymmetry;
end

for i = 1:length(odf.components)
  odf.components{i} = odf.components{i}.rotate(rot,varargin{:});  
end
