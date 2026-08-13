function [h,mP] = plot(ebsd,varargin)
% spatial EBSD plot
%
% Syntax
%
%   % colorize according to phase
%   plot(ebsd)
%
%   % colorize according to arbitrary value - here MAD
%   plot(ebsd,ebsd.mad)
%
%   % colorize according to orientation
%   plot(ebsd('phaseName'),ebsd('phaseName').orientation)
%
%   % colorize according to custom color
%   oM = ipfColorKey(ebsd('phaseName'))
%   color = oM.orientation2color(ebsd('phaseName').orientations);
%   plot(ebsd('phaseName'),color)
%
%   % specify the color directly and show in Legend
%   badMAD = ebsd.mad > 1;
%   plot(ebsd(badMAD),'faceColor','black,'DisplayName','bad values')
%
%   % plot a subregion
%   plot(ebsd,ebsd.orientation,'region',[xmin, xmax, ymin, ymax])
%
% Input
%  ebsd  - @EBSD
%  color - length(ebsd) x 3 vector of RGB values
%
% Options
%  micronbar   - 'on'/'off'
%  refFrame    - 'on'/'off' - indicate the alignment of the specimen
%                 reference frame inside the scale bar box, see
%                 <scaleBar.html scaleBar>
%  refFrameDirs   - @vector3d, the directions to indicate
%                    (default xvector, yvector, zvector)
%  refFrameLabels - cell of char, their labels (default {'x','y','z'})
%  backend     - surf, patch, imagesc
%  DisplayName - add a legend entry
%  region      - [xmin, xmax, ymin, ymax] plotting region
%
% Flags
%  points   - plot dots instead of unitcells
%  exact    - plot exact unitcells, even for large maps
%
% Example
%
%   mtexdata forsterite
%   plot(ebsd)
%
%   % colorize according to orientations
%   plot(ebsd('Forsterite'),ebsd('Forsterite').orientations)
%
%   % colorize according to MAD
%   plot(ebsd,ebsd.mad,'micronbar','off')
%
% See also
% EBSDSpatialPlots

% ignore empty EBSD sets
if isempty(ebsd), return; end

% create a new plot
mtexFig = newMtexFigure('datacursormode',{@tooltip,ebsd},varargin{:});
[mP,isNew] = newMapPlot('scanUnit',ebsd.scanUnit,...
  'parent',mtexFig.gca,varargin{:},ebsd.how2plot);

% transform orientations to color
if nargin>1 && isa(varargin{1},'orientation')

  oM = ipfColorKey(varargin{1});
  oM.inversePoleFigureDirection = ...
    get_option(varargin,{'inversePoleFigureDirection','ipfd'},zvector);
  
  oM.precompute;
  varargin{1} = oM.orientation2color(varargin{1});
  
  if ~getMTEXpref('generatingHelpMode') && ~check_option(varargin,'inversePoleFigureDirection')
    disp('  I''m going to colorize the orientation data with the ');
    disp('  standard MTEX ipf-Z colorkey. To view the colorkey do:');
    disp(' ');
    disp('  colorKey = ipfColorKey(ori_variable_name)')
    disp('  plot(colorKey)')
  end
end

% translate logical into numerical data
if nargin>1 && islogical(varargin{1}), varargin{1} = double(varargin{1}); end

% numerical data are given
if nargin>1 && isnumeric(varargin{1})
  
  property = varargin{1};
    
  assert(any(numel(property) == length(ebsd) * [1,3]),...
    'The number of values should match the number of ebsd data!')
  
  h = plotUnitCells(ebsd, property, 'parent', mP.ax, varargin{:});
  
elseif nargin>1 && isa(varargin{1},'crystalShape')
  
  cS = varargin{1};

  % Lift the shapes off the map TOWARDS THE VIEWER. ebsd.N is the normal of
  % the map and may point either way - with the default convention, which
  % has z pointing into the screen, it points away, and the shapes were
  % drawn behind the map where the depth sorting hides them.
  % grain2d/plot corrects the sign the same way.
  s = sign(dot(ebsd.N,mP.how2plot.outOfScreen,'noAntipodal'));
  if s == 0, s = 1; end % the map is seen edge on - either side will do

  pos = ebsd.pos + s * cS.diameter * ebsd.N;
  plot(pos.x,pos.y,pos.z,ebsd.orientations * cS,varargin{2:end});
  
else % phase plot

  if ebsd.isSinglePhase && ~check_option(varargin,'faceColor')
    
    str = inputname(1);
    if isempty(str), str = "ebsd"; end
    
    if ~check_option(varargin,'wizard')
      warning("You asked me to make a phase plot of single phase map. " + ...
        "This might not what you are looking for. " + ...
        "In order to colorize the map according to the orientations you should do" + ...
        newline + newline + ...
        strong("plot(" + str + "," + str + ".orientations)") + newline);
    end
  end

  warning('off','MATLAB:legend:PlotEmpty');
  l = legend(mP.ax,'-DynamicLegend','location','NorthEast');
  warning('on','MATLAB:legend:PlotEmpty');

  if check_option(varargin,{'color','faceColor'})

    % a uniform user defined color - plot everything at once
    h = plotUnitCells(ebsd, 'none', 'parent', mP.ax, varargin{:});

  else

    % Compute the color of every pixel first and plot the entire map in a
    % single call - subsetting the EBSD data per phase is much more
    % expensive, since EBSD/subsref copies all property arrays. Pixels of
    % phases without a color keep NaN and are not drawn.
    color = NaN(length(ebsd),3);
    phaseColor = NaN(numel(ebsd.phaseMap),3);
    for k = 1:numel(ebsd.phaseMap)

      ind = ebsd.phaseId(:) == k;
      if ~any(ind), continue; end

      if check_option(varargin,'grayScale')
        c = 1 - (k-1)/(numel(ebsd.phaseMap)) * [1,1,1];
      else
        c = ebsd.CSList(k).color;
        if isnan(c), continue; end
      end

      color(ind,:) = repmat(c,nnz(ind),1);
      phaseColor(k,:) = c;

    end

    h = plotUnitCells(ebsd, color, 'parent', mP.ax, varargin{:});

    % keep the map object itself out of the legend - it would show up as
    % a meaningless 'dataN' entry
    try
      set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    catch
    end

    % the map is a single graphics object now, so the legend entries are
    % carried by one invisible proxy patch per plotted phase
    for k = reshape(find(~isnan(phaseColor(:,1))),1,[])
      if any(strcmp(ebsd.mineralList{k},l.String)), continue; end
      patch('parent',mP.ax,'XData',nan,'YData',nan, ...
        'FaceColor',phaseColor(k,:),'EdgeColor','none', ...
        'DisplayName',ebsd.mineralList{k});
    end

  end

  if ~check_option(varargin,'parent')
    set(gcf,'name','phase plot');
  end
  
end
  
% keep track of the extent of the graphics
% this is needed for the zoom: TODO maybe this can be done better
%if isNew, ; end % TODO set axis tight removes all the plot

mP.how2plot.setView(mP.ax);

try axis(mP.ax,'tight'); end %#ok<TRYNC>
%set(mP.ax,'zlim',[0,1.1]);

% the map is drawn as a cell around every measured position
ext = ebsd.extent;
uC = ebsd.unitCell;
if isempty(uC), dx = [0 0]; dy = [0 0]; else
  dx = [min(uC.x(:)) max(uC.x(:))]; dy = [min(uC.y(:)) max(uC.y(:))];
end

% note that ebsd.extent leaves out the padding a gridded map is completed
% with - the axis limits keep it out through the backends, which do not let
% a cell without a measurement count, see EBSD/private/plotSurf
mP.extent(1) = min(mP.extent(1),ext(1) + dx(1));
mP.extent(2) = max(mP.extent(2),ext(2) + dx(2));
mP.extent(3) = min(mP.extent(3),ext(3) + dy(1));
mP.extent(4) = max(mP.extent(4),ext(4) + dy(2));

if nargout==0, clear h; end

if isNew && ~isstruct(mtexFig)
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:});
end

% crystal shapes stick out of the map plane, which makes MATLAB sort the
% axes children by depth - tell the scale bar to move in front of them
mP.micronBar.setOnTop

if ~isstruct(mtexFig)  && isscalar(mtexFig.children)
  mtexFig.keepAspectRatio = false; 
end

end

% ----------------------------------------------------------------------
% Tooltip function
function txt = tooltip(empt,eventdata,ebsd) %#ok<INUSL>

[pos,~,value] = getDataCursorPos(gcm);

try
  id = findByLocation(ebsd,[pos(1) pos(2)]);
catch
  id = [];
end

if ~isempty(id)

  txt{1} = ['index = '  num2str(id)];
  txt{2} = ['Id = '  num2str(ebsd.id(id))];
  txt{3} = ['phase = ', ebsd.mineralList{ebsd.phaseId(id)}];
  txt{4} = ['(x,y) = (' xnum2str(pos(1:2),'delimiter',', ') ')'];
  if ebsd.isIndexed(id)
    txt{5} = ['Euler = ' char(ebsd.rotations(id),'nodegree')];
  end
  try %#ok<TRYNC>
    txt{end+1} = ['grainId = ' xnum2str(ebsd.grainId(id))];
  end
  if ~isempty(value)
    txt{end+1} = ['Value = ' xnum2str(value)];
  end
else
  txt = 'no data';
end

end

