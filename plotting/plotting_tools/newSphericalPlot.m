function [sP, isNew] = newSphericalPlot(v,varargin)
% split plot in upper and lower hemisphere
%
% 1: axis given -> no sphericalRegion stored -> compute sphericalRegion -> finish
% 2: axis is hold and has sphericalRegion -> use multiplot
% 3: new multiplot

% get plotting convention
try
  how2plot = v.how2plot;
catch ME
  how2plot = plottingConvention.default;
end
% plottingConvention is a value class - this is already a private copy
how2plot = plottingConvention.fromOption(varargin,how2plot);

% case 1: predefined axis
% -----------------------
if check_option(varargin,'parent')

  ax = get_option(varargin,'parent');
  
  % axis is already a spherical plot
  if isappdata(ax(end),'sphericalPlot') && ishold(ax(end))
  
    for i = 1:length(ax)
      sP(i) = getappdata(ax(i),'sphericalPlot');
    end
    isNew = false;
    
  else % set up a new spherical axes if required
    
    % extract spherical region
    % TODO: it might happen that the spherical region needs two axes
    sR = getPlotRegion(v,how2plot,varargin{:});
    
    % extract projection
    proj = getProjection(sR,how2plot,varargin{:});
    
    % create a new spherical plot
    sP = sphericalPlot(ax,proj(1),varargin{:});
    isNew = true;
            
  end    
  return;
end
  
% create a new mtexFigure or get a reference to it
[mtexFig,isNew] = newMtexFigure(varargin{:});

%~check_option(varargin,'add2all') ||

if isNew || ~isappdata(mtexFig.currentAxes,'sphericalPlot')

  % maybe the spherical projection is already given - it must not share its
  % plotting convention with the data, see ownConvention
  proj = ownConvention(getClass(varargin,'sphericalProjection'));

  if isempty(proj)
    % get spherical region
    sR = getPlotRegion(v,how2plot,varargin{:});
  
    % extract projection(s)
    % this might return two projections for upper and lower hemisphere
    proj = getProjection(sR,how2plot,varargin{:});
  end
  
  % the axes created below have to start out in the same hold state as the
  % current one - this is a baseline, not a temporary hold, so it must
  % survive this function
  srcAx = mtexFig.gca;

  for i = 1:numel(proj)

    % create a new axis
    if i>1, mtexFig.nextAxis; end
    copyHoldState(srcAx,mtexFig.gca);

    % display upper/lower if needed
    if numel(proj)>1          
      if ~proj(i).isUpper
        tr = {'TR','lower'};
      elseif ~proj(i).isLower
        tr = {'TR','upper'};
      else
        tr = {};
      end
    else
      tr = {};
    end
    
    % create a new spherical plot
    sP(i) = sphericalPlot(mtexFig.gca,proj(i),tr{:},varargin{:});         %#ok<AGROW>
    
  end
  mtexFig.drawNow(varargin{:});
  isNew = true;
          
elseif check_option(varargin,'add2all') % add to or override existing axes
    
  for i = 1:numel(mtexFig.children)
    
    sP(i) = getappdata(mtexFig.children(i),'sphericalPlot'); %#ok<AGROW>
    
  end
  
else
  
  sP = getappdata(mtexFig.currentAxes,'sphericalPlot');
  
end

end

% ---------------------------------------------------------
function sR = getPlotRegion(sR,how2plot,varargin)
% returns spherical region to be plotted

% default values from the vectors to plot
if isa(sR,'vector3d')
  sR = getClass(varargin,'sphericalRegion',sR.region(varargin{:}));
elseif ~isa(sR,'sphericalRegion')
  sR = getClass(varargin,'sphericalRegion',sphericalRegion);
end

% check for simple options
if check_option(varargin,'complete')
  sR = sphericalRegion;
end
if check_option(varargin,'upper')
  sR = sR.restrict2Upper(how2plot);
elseif check_option(varargin,'lower')
  sR = sR.restrict2Lower(how2plot);
end

% extract antipodal
sR.antipodal = sR.antipodal || check_option(varargin,'antipodal');

% for antipodal symmetry reduce to halfsphere
if sR.antipodal && sR.isUpper(how2plot) && sR.isLower(how2plot) &&...
    ~check_option(varargin,'complete')
  sR = sR.restrict2Upper(how2plot);
end

end
% ---------------------------------------------------------
function proj = getProjection(sR,pC,varargin)

proj = get_option(varargin,'projection','earea');

if isa(proj,'sphericalProjection')

  proj = ownConvention(proj);

else

  switch proj
    case 'plain', proj = plainProjection(sR);
    
    case {'stereo','eangle'}, proj = eangleProjection(sR,pC); % equal angle
      
    case 'edist', proj = edistProjection(sR,pC); % equal distance

    case {'earea','schmidt'}, proj = eareaProjection(sR,pC); % equal area
        
    case 'orthographic',  proj = orthographicProjection(sR,pC);
    
    case 'square',  proj = squareProjection(sR,pC);
      
    case 'gnonomic', proj = gnonomicProjection(sR,pC);
      
    otherwise
    
      error('%s\n%s','Unknown projection specified! Valid projections are:',...
        'plain, stereo, eangle, edist, earea, schmidt, orthographic','square')
  end
end

if ~isa(proj,'plainProjection') && sR.isUpper(pC) && sR.isLower(pC)  
  proj = [proj,proj];
  proj(1).sR = proj(1).sR.restrict2Upper(pC);
  proj(2).sR = proj(2).sR.restrict2Lower(pC);
end


end
% ---------------------------------------------------------
function proj = ownConvention(proj)
% let the axis own the plotting convention of a projection handed in

% Since plottingConvention became a value class the freezing this
% function used to do - copying the convention so that a later
% plotx2east does not reproject an already drawn axis - happens by
% itself on every assignment; what remains is aligning all projections
% on the value of the first one.

if isempty(proj), return; end

pC = proj(1).pC;
for i = 2:numel(proj), proj(i).pC = pC; end

end
