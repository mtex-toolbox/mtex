function check_methodFiles
% verify the methods split out of classdef bodies into their own .m files
%
% These methods used to be implemented inline in the classdef body, which
% meant makeDoc emitted no reference page for them. Moving the bodies into
% @Class/name.m files must not change any behaviour.

% --- rotation
assert(isnan(rotation.nan.a),'rotation.nan')
assert(isequal(size(rotation.nan(5)),[5 5]),'rotation.nan(5) size')
assert(isequal(size(rotation.nan(2,3)),[2 3]),'rotation.nan(2,3) size')

assert(angle(rotation.id,rotation.byEuler(0,0,0))<1e-12,'rotation.id')
assert(isequal(size(rotation.id(4,2)),[4 2]),'rotation.id size')

r = rotation.rand(500);
assert(isequal(size(r),[500 1]),'rotation.rand size')
assert(~any(isnan(angle(r))),'rotation.rand NaN')
assert(max(angle(rotation.rand(200,'maxAngle',10*degree))) < 10*degree,'rotation.rand maxAngle')

inv = rotation.inversion;
assert(inv.isImproper,'rotation.inversion improper')
assert(isequal(round(double(inv*vector3d(1,2,3))),[-1;-2;-3]),'rotation.inversion action')

% subclasses still inherit / override correctly
cs = crystalSymmetry('432');
o = orientation.rand(10,cs);
assert(isa(o,'orientation') && isequal(size(o),[10 1]),'orientation.rand')
assert(isa(orientation.id(cs),'orientation'),'orientation.id')
assert(isa(orientation.nan(3,cs),'orientation'),'orientation.nan')

% --- tensor  (the recursion risk: rand(d) inside @tensor/rand.m)
T2 = tensor.rand('rank',2);
assert(isequal(size(T2.M),[3 3]),'tensor.rand rank 2')
assert(all(T2.M(:)>=0 & T2.M(:)<=1),'tensor.rand range')
T4 = tensor.rand('rank',4);
assert(isequal(size(T4.M),[3 3 3 3]),'tensor.rand rank 4')
T2b = tensor.rand(5,'rank',2);
assert(isequal(size(T2b.M),[3 3 5]),'tensor.rand array')
Tcs = tensor.rand('rank',2,cs);
assert(Tcs.CS == cs,'tensor.rand with CS')
% neighbours in the same static block must be untouched
assert(isequal(tensor.eye('rank',2).M,eye(3)),'tensor.eye')
assert(all(isnan(tensor.nan('rank',2).M(:))),'tensor.nan')
assert(all(tensor.zeros('rank',2).M(:)==0),'tensor.zeros')
assert(all(tensor.ones('rank',2).M(:)==1),'tensor.ones')

% --- EBSDhex
ebsd = mtexdata('titanium','silent');
ebsd = ebsd.gridify;
assert(isa(ebsd,'EBSDhex'),'expected a hex grid')
rows = [1 2 3 7 11]; cols = [1 5 2 9 4];
[x,y,z] = ebsd.hex2cube(rows,cols);
assert(all(abs(x+y+z)<1e-10),'cube coordinates must sum to zero')
[r2,c2] = ebsd.cube2hex(x,y,z);
assert(isequal(r2,rows) && isequal(c2,cols),'hex2cube/cube2hex roundtrip')
% linear-index call form
[xi,yi,zi] = ebsd.hex2cube(sub2ind(size(ebsd),rows,cols));
assert(isequal([xi;yi;zi],[x;y;z]),'hex2cube linear index form')
% single-output form returns linear indices
ind = ebsd.cube2hex(x,y,z);
assert(isequal(ind,sub2ind(size(ebsd),rows,cols)),'cube2hex single output')
% internal callers (subsind / plotting path)
assert(~isempty(ebsd(rows,cols)),'EBSDhex subsind')

% --- grainBoundary/length, a new overload replacing the builtin fallback
ebsd = mtexdata('twins','silent');
ebsd = ebsd('indexed');
grains = calcGrains(ebsd);
gB = grains.boundary;
gBmg = gB('Magnesium','Magnesium');
% previously measured, before @grainBoundary/length.m existed
assert(length(gBmg) == 3219, 'length(gB) changed: %d', length(gBmg))
assert(length(gBmg) == size(gBmg,1), 'length must agree with size')
assert(length(gBmg) == numel(gBmg.segLength), 'one segLength per segment')
assert(length(gB) == size(gB,1), 'length on the full boundary')
% empty and single-segment boundaries
assert(length(gB([])) == 0, 'empty boundary')
assert(length(gB(1)) == 1, 'single segment')
% the contrast the doc page draws: count vs summed geometric length
assert(sum(gBmg.segLength) > 0, 'segLength must be positive')
assert(abs(sum(gBmg.segLength) - length(gBmg)) > 1, ...
  'count and summed length must be distinct quantities')

disp('check_methodFiles passed')
end
