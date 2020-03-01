function [sP, isNew] = newSphericalPlot(v,varargin)
% split plot in upper and lower hemisphere
%
% 1: axis given -> no sphericalRegion stored -> compute sphericalRegion -> finish
% 2: axis is hold and has sphericalRegion -> use multiplot
% 3: new multiplot

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
    sR = getPlotRegion(v,varargin{:});
    
    % extract projection
    proj = getProjection(sR,varargin{:});
    
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

  % get spherical region
  sR = getPlotRegion(v,varargin{:});
  
  % extract projection(s)
  % this might return two projections for upper and lower hemisphere
  proj = getProjection(sR,varargin{:});
  holdState = getHoldState(mtexFig.gca);
  
  for i = 1:numel(proj)
    
    % create a new axis
    if i>1, mtexFig.nextAxis; end
    hold(mtexFig.gca,holdState);
    
    % display upper/lower if needed
    if numel(proj)>1          
      if ~proj(i).sR.isUpper
        tr = {'TR','lower'};
      elseif ~proj(i).sR.isLower
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
          
elseif check_option(varargin,'add2all') % add to or overide existing axes
    
  for i = 1:numel(mtexFig.children)
    
    sP(i) = getappdata(mtexFig.children(i),'sphericalPlot'); %#ok<AGROW>
    
  end
  
else
  
  sP = getappdata(mtexFig.currentAxes,'sphericalPlot');
  
end

end

% ---------------------------------------------------------
function sR = getPlotRegion(varargin)
% returns spherical region to be plotted

% default values from the vectors to plot
if isa(varargin{1},'vector3d')
  sR = varargin{1}.region(varargin{2:end});
else
  sR = sphericalRegion;
end
sR = getClass(varargin,'sphericalRegion',sR);

% check for simple options
if check_option(varargin,'complete')
  sR = sphericalRegion;
end
if check_option(varargin,'upper')
  sR = sR.restrict2Upper;
elseif check_option(varargin,'lower')
  sR = sR.restrict2Lower;
end

% extract antipodal
sR.antipodal = check_option(varargin,'antipodal') || ...
  (isa(varargin{1},'vector3d') && varargin{1}.antipodal);

% for antipodal symmetry reduce to halfsphere
if sR.antipodal && sR.isUpper && sR.isLower &&...
    ~check_option(varargin,'complete')
  sR = sR.restrict2Upper;
end

end
% ---------------------------------------------------------
function proj = getProjection(sR,varargin)

proj = get_option(varargin,'projection','earea');

if ~isa(proj,'sphericalProjection')

  switch proj
    case 'plain', proj = plainProjection(sR);
    
    case {'stereo','eangle'}, proj = eangleProjection(sR); % equal angle
      
    case 'edist', proj = edistProjection(sR); % equal distance

    case {'earea','schmidt'}, proj = eareaProjection(sR); % equal area
        
    case 'orthographic',  proj = orthographicProjection(sR);
    
    case 'square',  proj = squareProjection(sR);
      
    case 'gnonomic', proj = gnonomicProjection(sR);
      
    otherwise
    
      error('%s\n%s','Unknown projection specified! Valid projections are:',...
        'plain, stereo, eangle, edist, earea, schmidt, orthographic','square')
  end
end

if ~isa(proj,'plainProjection') && sR.isUpper && sR.isLower  
  proj = [proj,proj];
  proj(1).sR = proj(1).sR.restrict2Upper;
  proj(2).sR = proj(2).sR.restrict2Lower;
end


end
