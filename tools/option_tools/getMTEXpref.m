function value = getMTEXpref(pref,default)

% Preferences that setMTEXpref does not keep in the appdata group, because
% they are held by the object they belong to - see setMTEXpref, which
% translates each of these into a call on that object. Without this a
% settable preference was not gettable: getMTEXpref('xyzPlotting') returned
% [] rather than the convention actually in effect.
if nargin >= 1 && (ischar(pref) || isstring(pref)) && ~isempty(pref)

  pC = [];
  switch lower(pref)
    case 'xyzplotting'
      value = plottingConvention.default;
      return
    case 'xaxisdirection'
      pC = plottingConvention.default;
      screen = {'east',pC.east; 'west',-pC.east; 'north',pC.north; 'south',-pC.north};
    case 'zaxisdirection'
      pC = plottingConvention.default;
      screen = {'outOfPlane',pC.outOfScreen; 'intoPlane',-pC.outOfScreen};
  end

  if ~isempty(pC)
    % '' whenever the axis is not aligned with a screen direction - there
    % is no such setting to report back for a tilted convention
    value = '';
    ax = xvector; if strcmpi(pref,'zaxisdirection'), ax = zvector; end
    for k = 1:size(screen,1)
      if angle(ax,screen{k,2}) < 1e-6, value = screen{k,1}; break; end
    end
    return
  end

end

group = getappdata(0,'mtex');

if nargin == 0

  value = group;

elseif isfield(group,pref)

  value = group.(pref);

elseif nargin == 2

  value = default;

else

  value = [];

end

end
