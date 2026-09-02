function varargout = TSL2pointGroup(sym,pointGroup)
% translate the symmetry entries of an EDAX / TSL file into a point group, and back
%
% EDAX files describe the symmetry of a phase twice. The "Symmetry" code is
% the one every EDAX format has, but it only distinguishes the 11 Laue
% groups - it spells out the digits of the corresponding rotation group,
% e.g. 43 for cubic and 62 for hexagonal. Newer files state in addition the
% actual point group, either as the numeric id "PointGroupID" / "PGsymID"
% or as a string like "Hexagonal (D6h) [6/mmm]".
%
% The point group is used whenever it is available and consistent with the
% Laue group, otherwise the Laue group is returned.
%
% Given a crystal symmetry, the two codes an .ang states for it come back:
% the Laue code, and the point group id where the group is one of the 32.
%
% Syntax
%   pointGroup = TSL2pointGroup(43)
%   pointGroup = TSL2pointGroup(62,126)
%   pointGroup = TSL2pointGroup(22,'Orthorhombic (D2h) [mmm]')
%   [laueCode,pgId] = TSL2pointGroup(cs)
%
% Input
%  sym        - TSL symmetry code, numeric or char, or a @crystalSymmetry
%  pointGroup - EDAX point group id (>= 100) or name, optional
%
% Output
%  pointGroup - point group name as understood by @crystalSymmetry
%  laueCode   - TSL symmetry code, 1 to 43
%  pgId       - EDAX point group id, 100 to 131, empty for a group EDAX does
%               not number
%
% See also
% loadEBSD_ang loadEBSD_osc loadEBSD_h5 exportEBSD_ang laueGroups

if isa(sym,'symmetry')
  [varargout{1:2}] = codesOf(sym);
  return
end

laueGroup = TSL2laueGroup(sym);

if nargin == 1, varargout{1} = laueGroup; return; end

pointGroup = pointGroupName(pointGroup);

% no point group stated - the Laue group is all we know
if isempty(pointGroup), varargout{1} = laueGroup; return; end

% both should describe the same Laue class, if they do not the point group
% was not understood and the Laue group is the safer choice
try
  idPG = symmetry.extractPointId(pointGroup);
  idLaue = symmetry.extractPointId(laueGroup);
  if symmetry.pointGroups(idPG).LaueId ~= symmetry.pointGroups(idLaue).LaueId
    pointGroup = laueGroup;
  end
catch
  pointGroup = laueGroup;
end

varargout{1} = pointGroup;

end

function [laueCode,pgId] = codesOf(cs)
% the codes an .ang states for cs

pg = symmetry.pointGroups(cs.id);
laue = foldAlignment(symmetry.pointGroups(pg.LaueId).Inter);

t = laueGroups;
i = find(strcmp(t(:,1),laue),1);
laueCode = 1;   % unknown, the least committal answer
if ~isempty(i), laueCode = t{i,2}; end

pgId = 99 + find(strcmp(pointGroupList,foldAlignment(pg.Inter)),1);

end

function laueGroup = TSL2laueGroup(sym)
% the 11 Laue groups behind the TSL symmetry codes

if iscell(sym), sym = sym{1}; end
laueGroup = strtrim(char(string(sym)));

% an older file writes 2 for 2/m; crystalSymmetry then decides from the
% lattice angles whether that means 12/m1, 112/m or 2/m11
code = str2double(laueGroup);
if code == 2, code = 20; end

t = laueGroups;
i = find([t{:,2}] == code,1);
if ~isempty(i), laueGroup = t{i,1}; return; end

% .osc files store the point group id in the very same field
pg = pointGroupName(laueGroup);
if ~isempty(pg), laueGroup = pg; end

end

function name = pointGroupName(pointGroup)
% the point group as an id, as an EDAX name or already as a plain name

name = '';
if isempty(pointGroup), return; end
if iscell(pointGroup), pointGroup = pointGroup{1}; end
pointGroup = strtrim(char(string(pointGroup)));

% EDAX writes names like "Hexagonal (D6h) [6/mmm]"
inBrackets = regexp(pointGroup,'\[([^\]]+)\]','tokens','once');
if ~isempty(inBrackets), name = strtrim(inBrackets{1}); return; end

% the numeric id counts the 32 point groups, starting with 100 for triclinic 1
id = str2double(pointGroup);
if ~isnan(id) && id >= 100 && id <= 100 + numel(pointGroupList) - 1
  list = pointGroupList;
  name = list{id - 99};
  return
end

% anything else is passed on unchanged, crystalSymmetry may know it
if isnan(id), name = pointGroup; end

end

function list = pointGroupList
% the 32 crystallographic point groups in the order EDAX numbers them,
% i.e. PointGroupID = 100 + position in this list - 1
%
% Verified for 126 -> 6/mmm and 131 -> m-3m against the SpaceGroupHall
% entries of the very same phases.

list = {'1','-1','2','m','2/m','222','mm2','mmm',...
  '4','-4','4/m','422','4mm','-42m','4/mmm',...
  '3','-3','32','3m','-3m',...
  '6','-6','6/m','622','6mm','-62m','6/mmm',...
  '23','m-3','432','-43m','m-3m'};

end
