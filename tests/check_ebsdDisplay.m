function check_ebsdDisplay
% check that displaying an EBSD object never throws
%
% A diagnostic should not be the thing that breaks on the object one is
% trying to look at. Regression: display printed the map extent
% unconditionally, but extent is empty when there are no positions, so
% ext(1:2) threw "Index in position 1 exceeds array bounds" - which is how
% an old .mat file that lost its pos (see EBSD/loadobj) masked itself:
% ebsd = mtexdata('trueEbsdWCCo'); worked while mtexdata trueEbsdWCCo did
% not, the only difference being the display.
%
% Syntax
%   check_ebsdDisplay
%
% See also
% EBSD/display check_ebsdLoadobj

ebsd = EBSD(mtexdata('twins','silent'));

checkDisplays(ebsd,'a plain EBSD');
checkDisplays(ebsd.gridify,'a gridified EBSD');
checkDisplays(ebsd(1:5),'a five pixel EBSD');
checkDisplays(ebsd(false(length(ebsd),1)),'an empty EBSD');

% no positions at all - the damaged object of the regression above
noPos = ebsd;
noPos.pos = vector3d;
out = checkDisplays(noPos,'an EBSD without positions');
assert(contains(out,'no positions'), ...
  'check_ebsdDisplay: an EBSD without positions does not say so:\n%s',out);

% and with the unit cell gone as well
noCell = noPos;
noCell.unitCell = vector3d;
checkDisplays(noCell,'an EBSD without positions or unit cell');

disp('EBSD/display: all checks passed');

end

% =========================================================================
function out = checkDisplays(ebsd,name)
% both display and disp must survive - only the former is what the command
% form of an assignment calls

try
  out = evalc('display(ebsd)');
  evalc('disp(ebsd)');
catch ME
  error('check_ebsdDisplay: displaying %s failed with\n  %s',name,ME.message);
end

end
