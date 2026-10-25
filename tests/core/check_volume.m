function check_volume
% volume and fibreVolume integrate the function over every orientation within
% the radius of the center or the fibre
%
% The region is the union of the symmetric copies of the ball or the tube.
% They coincide where a symmetry fixes the center (cube with specimen
% symmetry mmm: four times) and overlap for a large radius; the union counts
% once. A lean selection of tests/lib/checkVolumeCases, which
% slow/check_volumeFull runs over more frame pairs, centers and fibres, and
% that the grid about a center is not reused for another.
%
% See also
% SO3Fun/volume SO3Fun/fibreVolume

checkVolumeCases({{'m-3m','mmm'}},'centers',2:3,'fibres',[],'radii',[15 45]*degree);
checkVolumeCases({{'m-3m','mmm'}},'centers',[],'fibres',3,'radii',15*degree);
checkVolumeCases({{'m-3m','exchange'}},'centers',3,'radii',15*degree);
checkGridCenter;

end


% volume integrates over the grid about its center; equispacedSO3Grid reuses
% its last grid, which must not hand out the ball about another center
function checkGridCenter

cs = crystalSymmetry('m-3m'); ss = specimenSymmetry('mmm');
c1 = orientation.id(cs,ss);
c2 = orientation.byEuler(40*degree,25*degree,10*degree,cs,ss);
equispacedSO3Grid(cs,ss,'maxAngle',45*degree,'center',c1,'resolution',2*degree);
S3G = equispacedSO3Grid(cs,ss,'maxAngle',45*degree,'center',c2,'resolution',2*degree);
assert(max(angle(S3G(:),c2)) < 45*degree + 1e-6, ...
  'check_volume:gridCenter','the grid about a center is that about another');

end
