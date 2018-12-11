function s = calcQuat(s,axes)
% calculate quaternions for Laue groups

if s.id==0, return; end

if nargin == 1, axes = [xvector,yvector,zvector]; end

a = axes(1);
b = axes(2);
c = axes(3);

a1 = axes(1);
a2 = axes(2);
m = a1 - a2;

ll0axis = a+b;
lllaxis = a+b+c;

pg = pointGroupList;
pg = pg(s.id);

% compute rotations
switch pg.LaueId
  case 2 % 1
    rot = {rotation.byEuler(0,0,0)};
  case 5 % 211
    rot = {symAxis(a,2)};
  case 8 % 121
    rot = {symAxis(b,2)};
  case 11 % 112
    rot = {symAxis(c,2)};
  case 16 % 222
    rot = {symAxis(a,2),symAxis(c,2)};
  case 18 % 3
    rot = {symAxis(c,3)};
  case 21 % 321
    rot = {symAxis(a1,2),symAxis(c,3)};
  case 24 % 312
    rot = {symAxis(m,2),symAxis(c,3)};
  case 27 % 4
    rot = {symAxis(c,4)};
  case 32 % 4/mmm
    rot = {symAxis(a,2),symAxis(c,4)};
  case 35 % 6
    rot = {symAxis(c,6)};
  case 40 % 622
    rot = {symAxis(a,2),symAxis(c,6)};
  case 42 % 23
    rot = {symAxis(lllaxis,3),symAxis(a,2),symAxis(c,2)};
  case 45 % 432
    rot = {symAxis(lllaxis,3),symAxis(ll0axis,2),symAxis(c,4)};
end

% apply inversion
if size(pg.Inversion ,1) == 2
  rot = [rot,{[1,-1] .* rotation.id}];
else
  rot = arrayfun(@(i) rot{i} .* pg.Inversion(i).^(0:length(rot{i})-1) ,...
    1:length(rot),'uniformOutput',false);

end

% store symmetries
rot = prod(rot{:});
[s.a, s.b, s.c, s.d] = double(rot);
s.i = isImproper(rot);

end
