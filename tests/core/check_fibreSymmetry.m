function check_fibreSymmetry
% a fibre h||r is that of every pair of an image of h under the crystal
% point group and of r under the specimen point group, the improper
% elements included: in a centrosymmetric crystal, or with a specimen
% symmetry holding the inversion, -h||r too
%
% fibre/angle vanishes at every such pair, fibre/symmetrise turns an arc
% onto every equivalent fibre keeping its length, and the distinct
% fibres are the pairs up to (h,r) = (-h,-r).
%
% See also
% fibre/angle fibre/symmetrise fibre/multiplicity

pairs = {{'m-3m','1',48},{'m-3m','mmm',192},{'432','mmm',192}, ...
  {'mm2','222',16},{'-43m','1',24},{'-1','2/m',4}};

for k = 1:numel(pairs)
  cs = crystalSymmetry(pairs{k}{1}); ss = specimenSymmetry(pairs{k}{2});
  name = [pairs{k}{1} '/' pairs{k}{2}];
  h = Miller(1,2,4,cs,'uvw'); r = vector3d(1,2,3);
  f = fibre(h,r,ss);

  hs = symmetrise(h); rs = ss.rot * r;
  [I,J] = meshgrid(1:length(hs),1:length(rs));
  ori = orientation(rotation.map(vector3d(hs(I(:))),rs(J(:))),cs,ss);
  assert(max(angle(f,ori)) < 1e-7,'check_fibreSymmetry:angle', ...
    '%s: an equivalent pair is off the fibre',name);

  o1 = orientation.byEuler(10*degree,20*degree,30*degree,cs,ss);
  arc = fibre(o1,o1*orientation.byAxisAngle(h,40*degree));
  S = symmetrise(arc);
  assert(max([angle(fibre(o1,h),S.o1(:)); angle(fibre(o1,h),S.o2(:))]) < 1e-7 && ...
    max(abs(angle(S.o1(:),S.o2(:),'noSymmetry') - 40*degree)) < 1e-7, ...
    'check_fibreSymmetry:symmetrise','%s: an equivalent arc is off the fibre',name);

  assert(multiplicity(f) == pairs{k}{3},'check_fibreSymmetry:multiplicity', ...
    '%s: %d distinct fibres for %d',name,multiplicity(f),pairs{k}{3});
end

end
