function [sP, isNew] = newSphericalPlot(v,varargin)
% split plot in upper and lower hemisphere
%
% 1: axis given -> no sphericalRegion stored -> compute sphericalRegion -> finish
% 2: axis is hold and has sphericalRegion -> use multiplot
% 3: new multiplot

% the frame of the data names the axes of the annotation, see annotateFrame
frameArg = {};
if ~isempty(v.frame), frameArg = {'dataFrame',v.frame}; end

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
    
    % TODO: it might happen that the spherical region needs two axes
    proj = makeSphericalProjection(v,varargin{:});

    % create a new spherical plot
    sP = sphericalPlot(ax,proj(1),varargin{:},frameArg{:});
    isNew = true;
            
  end    
  return;
end
  
% create a new mtexFigure or get a reference to it
[mtexFig,isNew] = newMtexFigure(varargin{:});

%~check_option(varargin,'add2all') ||

if isNew || ~isappdata(mtexFig.currentAxes,'sphericalPlot')

  % one projection, or two for the upper and the lower hemisphere
  proj = makeSphericalProjection(v,varargin{:});

  % the new axes start out in the hold state of the current one, as a baseline
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
    sP(i) = sphericalPlot(mtexFig.gca,proj(i),tr{:},varargin{:},frameArg{:}); %#ok<AGROW>

  end

  % an upper and a lower hemisphere are two axes, but one plot
  registerHemispheres([sP.ax]);

  mtexFig.drawNow(varargin{:});
  isNew = true;
          
elseif check_option(varargin,'add2all') % add to or override existing axes
    
  for i = 1:numel(mtexFig.children)
    
    sP(i) = getappdata(mtexFig.children(i),'sphericalPlot'); %#ok<AGROW>
    
  end
  
else

  sP = getappdata(mtexFig.currentAxes,'sphericalPlot');

  % a plot covering both hemispheres is spread over two axes, an annotation over both (#330)
  if isempty(getClass(varargin,'sphericalProjection'))
    sP = sP.allHemispheres;
  end

end

end
