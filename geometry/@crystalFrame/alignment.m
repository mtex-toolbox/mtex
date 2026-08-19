function str = alignment(cF)
% the alignment of the Cartesian axes as strings, e.g. {'X||a','Z||c*'}
%
% Where a direct and a reciprocal axis coincide - c and c* in a hexagonal
% lattice, every pair in an orthogonal one - the direct axis is reported,
% so the result does not depend on rounding noise in the basis. For a
% frame with mutually orthogonal axes nothing is worth reporting and the
% result is empty - the same rule crystalSymmetry/alignment always used.

abc = normalize(cF.basis);

% orthogonal basis - nothing to report
if all(isappr(abs(dot_outer(abc,abc)),eye(3)),'all')
  str = {};
  return
end

dirs = [abc, normalize(basisDual(cF))];
labels = [cF.axesNames, strcat(cF.axesNames,'*')];
xyzLabel = {'X','Y','Z'};
xyz = [xvector,yvector,zvector];

str = {};
for x = 1:3
  m = find(isappr(abs(dot_outer(dirs,xyz(x))),1),1);
  if ~isempty(m), str{end+1} = [xyzLabel{x} '||' labels{m}]; end %#ok<AGROW>
end
