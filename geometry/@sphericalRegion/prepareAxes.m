function ax = prepareAxes(sR,varargin)
% prepare axes for plotting upper and lower hemisphere
%
% threre are three cases:
% 1: axis given -> no spherical region stored -> compute spherical region
% -> return handles
% 2: axis is hold and has spherical region -> return handles
% 3: new multiplot

% case 1: predefined axis
if check_option(varargin,'parent')

  % get axes to plot in
  ax = get_option(varargin,'parent');
  
  if ~isappdata(ax,'sphericalRegion')
        
    % if spherical region is on both hemispheres
    if ~sR.isHemisphere && ~check_option(varargin,'plain')
      
      % restrict to the northern hemisphere
      sR = sR.restrict(zvector,0);
    
      warning(['You can only plot one hemisphere in an axis. ' ...
        ' Consider restricting by using one of the options ''upper'', or, ''lower''!']);
      
    end
    setappdata(ax,'sphericalRegion',sR);
  end
  
% case 2: axis is hold and has spherical region
elseif ~newMTEXplot && isappdata(gca,'spherical region')
  
  ax = getappdata(gcf,'multiplotAxes');

% case 3: create new axes
elseif check_option(varargin,'plain')
  
  ax = newAxis(sR);
    
else
    
  % create axis for upper hemisphere
  if sR.hasUpperHemisphere    
    ax = newAxis(sR.restrict(zvector,0),'TR','upper');
  end
  
  % create axis for lower hemisphere
  if sR.hasLowerHemisphere  
    ax = newAxis(sR.restrict(-zvector,0),'TR','lower');
  end
end
