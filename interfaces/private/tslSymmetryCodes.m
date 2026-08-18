function [laueCode,pgId] = tslSymmetryCodes(cs)
% the two symmetry codes an EDAX / TSL file states for a phase
%
% Description
%
% An .ang phase block describes the symmetry twice: "Symmetry" spells out
% the digits of the rotation group of one of the 11 Laue classes - 43 for
% cubic, 62 for hexagonal - and newer files add "PointGroupID", which
% counts the 32 point groups from 100. TSL2pointGroup reads both back.
%
% MTEX distinguishes more groups than either code does, because it keeps
% the alignment of a group with the crystal axes (12/m1 and 112/m are both
% 2/m here). Those variants fold onto the one code the format has - the
% lattice angles written next to it are what tells them apart again on
% import.
%
% Syntax
%   [laueCode,pgId] = tslSymmetryCodes(cs)
%
% Input
%  cs - @crystalSymmetry
%
% Output
%  laueCode - TSL symmetry code, 1 to 43
%  pgId     - EDAX point group id, 100 to 131
%
% See also
% TSL2pointGroup exportEBSD_ang

% the 32 point groups in the order EDAX numbers them
pgList = {'1','-1','2','m','2/m','222','mm2','mmm',...
  '4','-4','4/m','422','4mm','-42m','4/mmm',...
  '3','-3','32','3m','-3m',...
  '6','-6','6/m','622','6mm','-62m','6/mmm',...
  '23','m-3','432','-43m','m-3m'};

% the TSL code of every Laue class
laueList = {'-1',1; '2/m',20; 'mmm',22; '-3',3; '-3m',32; ...
  '4/m',4; '4/mmm',42; '6/m',6; '6/mmm',62; 'm-3',23; 'm-3m',43};

pg = foldAlignment(symmetry.pointGroups(cs.id).Inter);
laue = foldAlignment(symmetry.pointGroups(symmetry.pointGroups(cs.id).LaueId).Inter);

pgId = find(strcmp(pgList,pg),1);
if isempty(pgId), pgId = []; else, pgId = 99 + pgId; end

i = find(strcmp(laueList(:,1),laue),1);
if isempty(i)
  laueCode = 1;   % unknown, the least committal answer
else
  laueCode = laueList{i,2};
end

end

% ------------------------------------------------------------------------
function name = foldAlignment(name)
% the point group name without the alignment MTEX adds to it

name = char(name);

folded = { ...
  '211','2'; 'm11','m'; '2/m11','2/m'; ...
  '121','2'; '1m1','m'; '12/m1','2/m'; ...
  '112','2'; '11m','m'; '112/m','2/m'; ...
  '2mm','mm2'; 'm2m','mm2'; ...
  '321','32'; '312','32'; '3m1','3m'; '31m','3m'; '-3m1','-3m'; '-31m','-3m'; ...
  '-4m2','-42m'; '-6m2','-62m'};

i = find(strcmp(folded(:,1),name),1);
if ~isempty(i), name = folded{i,2}; end

end
