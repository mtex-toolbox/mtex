function pf = rotate(pf,rot,varargin)
% rotates pole figures by a certain rotation
%
% Syntax  
%   pf = rotate(pf,rot)
% 
% Input
%  pf  - @PoleFigure
%  rot - @rotation
%
% Output
%  pf - rotated @PoleFigure
%
% See also
% rotation_index ODF/rotate

ss = pf.SS.Laue;
if length(ss)>2 && ~any(rot == ss(:))
  warning('Rotating pole figures with specimen symmetry will remove the specimen symmetry')
  pf.SS = specimenSymmetry;
end

for ipf = 1:pf.numPF
	pf.allR{ipf} =  pf.allR{ipf}.rotate(rot);
end
