function check_mtexPref
% checks that every setMTEXpref has a getMTEXpref that reads it back
%
% Most preferences live in the appdata group and round trip trivially, but
% setMTEXpref translates three of them into a call on the object that
% actually holds the setting - the plotting convention. getMTEXpref knew
% nothing about that, so those three were settable and not gettable: it
% looked them up in the appdata group, found nothing, and returned [] while
% the setting was in effect.
%
% See also
% setMTEXpref getMTEXpref plottingConvention

pC0 = plottingConvention.default;
cleanup = onCleanup(@() pC0.makeDefault); %#ok<NASGU>

checkOrdinaryPref;
checkConventionPrefs;
checkNotAxisAligned;

disp('check_mtexPref: passed');

end

% =========================================================================
function checkOrdinaryPref
% an appdata backed preference is unaffected, and an unknown one still []

old = getMTEXpref('FontSize');
setMTEXpref('FontSize',13);
assert(isequal(getMTEXpref('FontSize'),13), ...
  'check_mtexPref: FontSize came back as %s', mat2str(getMTEXpref('FontSize')));
setMTEXpref('FontSize',old);

assert(isempty(getMTEXpref('noSuchPreference')), ...
  'check_mtexPref: an unknown preference no longer returns []');
assert(isequal(getMTEXpref('noSuchPreference','fallback'),'fallback'), ...
  'check_mtexPref: an unknown preference ignores its default argument');

end

% =========================================================================
function checkConventionPrefs
% the three preferences held by the plotting convention read back

plottingConvention.ij.makeDefault;

pC = getMTEXpref('xyzPlotting');
assert(isa(pC,'plottingConvention'), ...
  'check_mtexPref: getMTEXpref(''xyzPlotting'') returned a %s', class(pC));
assert(pC == plottingConvention.default, ...
  'check_mtexPref: getMTEXpref(''xyzPlotting'') is not the default convention');

% setting a whole convention is read back as that convention
wanted = plottingConvention(zvector,xvector);
setMTEXpref('xyzPlotting',wanted);
assert(getMTEXpref('xyzPlotting') == wanted, ...
  'check_mtexPref: the convention set through xyzPlotting is not the one reported back');

for d = {'east','west','north','south'}
  setMTEXpref('xAxisDirection',d{1});
  assert(strcmp(getMTEXpref('xAxisDirection'),d{1}), ...
    'check_mtexPref: xAxisDirection set to %s reads back as ''%s''', ...
    d{1}, getMTEXpref('xAxisDirection'));
end

for d = {'intoPlane','outOfPlane'}
  setMTEXpref('zAxisDirection',d{1});
  assert(strcmp(getMTEXpref('zAxisDirection'),d{1}), ...
    'check_mtexPref: zAxisDirection set to %s reads back as ''%s''', ...
    d{1}, getMTEXpref('zAxisDirection'));
end

end

% =========================================================================
function checkNotAxisAligned
% a tilted convention has no axis direction to report, and says so

pC = plottingConvention;
pC.outOfScreen = vector3d(0.4,0.3,1);
pC.makeDefault;

for p = {'xAxisDirection','zAxisDirection'}
  v = getMTEXpref(p{1});
  assert(ischar(v) && isempty(v), ...
    'check_mtexPref: %s of a tilted convention is %s, expected an empty char', ...
    p{1}, mat2str(v));
end

% the convention itself is still reported in full
assert(isa(getMTEXpref('xyzPlotting'),'plottingConvention'), ...
  'check_mtexPref: a tilted convention is not reported by xyzPlotting');

end
