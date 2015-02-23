function plotPDF(o,h,varargin)
% plot orientations into pole figures
%
% Syntax
%   plotPDF(ori,[h1,..,hN],<options>)
%
% Input
%  ori - @orientation
%  h   - @Miller crystallographic directions
%
% Options
%  superposition - plot superposed pole figures
%  points        - number of points to be plotted
%
% Flags
%  antipodal - include <AxialDirectional.html antipodal symmetry>
%  complete  - plot entire (hemi)--sphere
%
% See also
% orientation/plotIPDF S2Grid/plot savefigure
% Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

[mtexFig,isNew] = newMtexFigure('ensureTag','pdf',...
  'ensureAppdata',{{'SS',o.SS}},...
  'datacursormode',@tooltip,varargin{:});

if isNew % for a new plot 
  
  if ~iscell(h), h = vec2cell(h);end 
  argin_check([h{:}],{'Miller'});  
  for i = 1:length(h)
    h{i} = o.CS.ensureCS(h{i});
  end    
  setappdata(gcf,'h',h);
  set(gcf,'Name',['Pole figures of "',get_option(varargin,'FigureTitle',inputname(1)),'"']);
  
else
  h = getappdata(gcf,'h');
end

% colorcoding 1 TODO this should be done differently
data = get_option(varargin,'property',[]);

% ------------------ subsample if needed --------------------------
if ~check_option(varargin,{'all','contour','contourf','smooth'}) && ...
    (sum(length(o))*length(o.CS)*length(o.SS) > 10000 || check_option(varargin,'points'))

  points = fix(get_option(varargin,'points',10000/length(o.CS)/length(o.SS)));
  disp(['  I''m plotting ', int2str(points) ,' random orientations out of ', int2str(length(o)),' given orientations']);
  disp('  You can specify the the number points by the option "points".'); 
  disp('  The option "all" ensures that all data are plotted');
  
  samples = discretesample(length(o),points);
  o= o.subSet(samples);
  if ~isempty(data), data = data(samples); end
end

% colorcoding 2 TODO: remove this
if check_option(varargin,'colorcoding')
  colorcoding = lower(get_option(varargin,'colorcoding','angle'));
  data = orientation2color(o,colorcoding,varargin{:});
  
  % convert RGB to ind
  if numel(data) == 3*length(o)  
    [data, map] = rgb2ind(reshape(data,[],1,3), 0.03,'nodither');
    set(gcf,'colormap',map);    
  end
  
end

% plot
for i = 1:length(h)

  if i>1, mtexFig.nextAxis; end

  % compute specimen directions
  sh = symmetrise(h{i});
  r = reshape(o.SS * o * sh,[],1);
     
  r.plot(repmat(data(:).',[length(o.SS) length(sh)]),'fundamentalRegion',...
    'parent',mtexFig.gca,'doNotDraw',varargin{:});
  mtexTitle(mtexFig.gca,char(h{i},'LaTeX'));

  % TODO: unifyMarkerSize

end

if isNew || check_option(varargin,'figSize')
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); 
end

% ----------- Tooltip function ------------------------
function txt = tooltip(varargin)

[r_local,id] = getDataCursorPos(mtexFig);

txt = ['id ' xnum2str(id) ' at (' int2str(r_local.theta/degree) ',' int2str(r_local.rho/degree) ')'];

end

end


