function check_ebsdLoadobj
% check that EBSD.loadobj recovers the positions of older .mat files
%
% Matlab hands a saved object to loadobj as a plain struct whenever it
% cannot assign all of its fields - which is exactly what happens to a file
% written before commit 859b62af0 ("EBSDsquare can now be rotated"), since
% that commit removed the dx / dy properties of @EBSDsquare. The struct
% branch of loadobj then has to carry the data over by hand, and every
% field it forgets is lost silently.
%
% Syntax
%   check_ebsdLoadobj
%
% See also
% EBSD/loadobj

checkPosIsKept;
checkPosFromStep;
checkPosFromPropXY;

disp('EBSD/loadobj: all checks passed');

end

% =========================================================================
function s = oldStyleStruct(ebsd)
% the fields an @EBSDsquare of the dx / dy era was saved with

s = struct();
s.id        = ebsd.id;
s.rotations = ebsd.rotations;
s.pos       = ebsd.pos;
s.unitCell  = ebsd.unitCell;
s.N         = ebsd.N;
s.phaseId   = ebsd.phaseId;
s.CSList    = ebsd.CSList;
s.phaseMap  = ebsd.phaseMap;
s.prop      = ebsd.prop;
s.opt       = ebsd.opt;
s.scanUnit  = ebsd.scanUnit;
s.A_D       = [];
s.dx        = norm(ebsd.d2);
s.dy        = norm(ebsd.d1);

end

% =========================================================================
function checkPosIsKept
% a struct that carries its positions keeps them
%
% Regression: the struct branch copied id, rotations, phaseId, CSList,
% prop, scanUnit, phaseMap, unitCell - and not pos. So every file that
% reached loadobj as a struct came back with an empty pos, whatever it had
% stored, and any later access to ebsd.pos / d1 / d2 threw "Index in
% position 1 exceeds array bounds". This is what happened to the published
% trueEbsdWCCo.mat.

ebsd = EBSD(mtexdata('twins','silent')).gridify;

e = EBSD.loadobj(oldStyleStruct(ebsd));

assert(isa(e,'EBSDsquare'), ...
  'check_ebsdLoadobj: a grid struct loaded as %s',class(e));

assert(~isempty(e.pos), ...
  'check_ebsdLoadobj: loadobj dropped the positions the file had stored');

assert(isequal(size(e.pos),size(ebsd.pos)) && ...
  max(norm(e.pos(:) - ebsd.pos(:))) < 1e-10 * ebsd.dPos, ...
  'check_ebsdLoadobj: the recovered positions are not the stored ones');

end

% =========================================================================
function checkPosFromStep
% a struct with no positions falls back to the stored grid spacing
%
% The dx / dy era stored the spacing as a property of its own. Matlab
% cannot assign those two fields any more - which is why such a file
% arrives as a struct in the first place - so they are still readable here
% and pos can be rebuilt, up to the origin that representation never had.

ebsd = EBSD(mtexdata('twins','silent')).gridify;

s = oldStyleStruct(ebsd);
s.pos = vector3d;

w = warning('off','MTEX:EBSD:loadobj:posFromStep');
e = EBSD.loadobj(s);
warning(w);

assert(isequal(size(e.pos),size(ebsd.pos)), ...
  'check_ebsdLoadobj: pos was rebuilt with size %s instead of %s',...
  mat2str(size(e.pos)),mat2str(size(ebsd.pos)));

% same grid, only shifted to the origin
d = e.pos - e.pos(1,1) - (ebsd.pos - ebsd.pos(1,1));
assert(max(norm(d(:))) < 1e-10 * ebsd.dPos, ...
  'check_ebsdLoadobj: the rebuilt grid does not match the stored spacing');

end

% =========================================================================
function checkPosFromPropXY
% the older prop.x / prop.y era still works

ebsd = EBSD(mtexdata('twins','silent'));

s = struct();
s.id        = ebsd.id;
s.rotations = ebsd.rotations;
s.unitCell  = ebsd.unitCell;
s.phaseId   = ebsd.phaseId;
s.CSList    = ebsd.CSList;
s.phaseMap  = ebsd.phaseMap;
s.prop      = ebsd.prop;
s.prop.x    = ebsd.pos.x;
s.prop.y    = ebsd.pos.y;
s.opt       = ebsd.opt;
s.scanUnit  = ebsd.scanUnit;

e = EBSD.loadobj(s);

assert(max(norm(e.pos - ebsd.pos)) < 1e-10 * ebsd.dPos, ...
  'check_ebsdLoadobj: the prop.x / prop.y era is no longer recovered');

assert(~isfield(e.prop,'x') && ~isfield(e.prop,'y'), ...
  'check_ebsdLoadobj: prop.x / prop.y were not removed after the rescue');

end
