function pointGroup = TSL2pointGroup(sym)
% translate an EDAX / TSL symmetry code into a MTEX point group name
%
% EDAX files (.ang, .osc, EDAX flavoured *.h5) do not store the point group
% by name but as a numeric code which spells out the digits of the proper
% rotation group, e.g. 43 for 432 and 62 for 622. The 11 codes below are
% exactly the 11 proper rotation groups. Everything that is not part of the
% table - in particular a symmetry given by its name - is passed through
% unchanged so that it can be resolved by crystalSymmetry itself.
%
% Syntax
%   pointGroup = TSL2pointGroup(43)
%   pointGroup = TSL2pointGroup('62')
%
% Input
%  sym - TSL symmetry code, numeric or char
%
% Output
%  pointGroup - point group name as understood by @crystalSymmetry
%
% See also
% loadEBSD_ang loadEBSD_osc loadEBSD_h5

if iscell(sym), sym = sym{1}; end
pointGroup = strtrim(char(string(sym)));

% the monoclinic code 2 is kept as '2' - crystalSymmetry decides from the
% lattice angles whether this is 121, 112 or 211
switch pointGroup
  case '1',   pointGroup = '1';    % C1  triclinic
  case '2',   pointGroup = '2';    % C2  monoclinic
  case '20',  pointGroup = '2';    % C2  monoclinic
  case '22',  pointGroup = '222';  % D2  orthorhombic
  case '3',   pointGroup = '3';    % C3  trigonal
  case '32',  pointGroup = '321';  % D3  trigonal
  case '4',   pointGroup = '4';    % C4  tetragonal
  case '42',  pointGroup = '422';  % D4  tetragonal
  case '6',   pointGroup = '6';    % C6  hexagonal
  case '62',  pointGroup = '622';  % D6  hexagonal
  case '23',  pointGroup = '23';   % T   cubic
  case '43',  pointGroup = '432';  % O   cubic

  % codes seen in .osc files only
  case '126', pointGroup = '622';
  case '131', pointGroup = '432';
end

end
