function plotPDF(o,varargin)
% plot orientations into pole figures
%
% Syntax
%   plotPDF(ori,[h1,h2,h3])
%   plotPDF(ori,[h1,h2,h3],'points',100)
%   plotPDF(ori,[h1,h2,h3],'points','all')
%   plotPDF(ori,[h1,h2,h3],'contourf')
%   plotPDF(ori,[h1,h2,h3],'antipodal')
%   plotPDF(ori,[h1,h2,h3],'superposition',{1,[1.5 0.5]})
%   plotPDF(ori,data,[h1,h2,h3])
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
%  noSymmetry - ignore symmetricaly equivalent points
%
% See also
% orientation/plotIPDF S2Grid/plot savefigure
% Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

[mtexFig,isNew] = newMtexFigure('datacursormode',@tooltip,varargin{:});

% extract data
if check_option(varargin,'property')
  data = get_option(varargin,'property');
  data = reshape(data,[1,length(o) numel(data)/length(o)]);
elseif (nargin > 1 && ~(isa(varargin{1},'Miller')) || ...
    (nargin > 2 && iscell(varargin{2}) && isa(varargin{2}{1},'Miller')))
  [data,varargin] = extract_data(length(o),varargin);
  data = reshape(data,[1,length(o) numel(data)/length(o)]);
else
  data = [];
end

% find crystal directions
h = [];
try h = getappdata(mtexFig.currentAxes,'h'); end %#ok<TRYNC>

if isempty(h) % for a new plot 
  h = varargin{1};
  varargin(1) = [];
  if ~iscell(h), h = vec2cell(h);end 
else
  h = {h};
end

% all h should by Miller and have the right symmetry
argin_check([h{:}],{'Miller'});
for i = 1:length(h), h{i} = o.CS.ensureCS(h{i}); end

if isNew
  if isa(o.SS,'specimenSymmetry')
    pfAnnotations = getMTEXpref('pfAnnotations');
  else
    pfAnnotations = @(varargin) 1;
  end
  set(mtexFig.parent,'Name',['Pole figures of "',get_option(varargin,'FigureTitle',inputname(1)),'"']);
else
  pfAnnotations = @(varargin) 1;
end


% ------------------ subsample if needed --------------------------
if ~check_option(varargin,{'all','contour','contourf','smooth'}) && ...
    (sum(length(o))*length(o.CS)*length(o.SS) > 10000 || check_option(varargin,'points'))

  points = fix(get_option(varargin,'points',10000/length(o.CS)/length(o.SS)));
  disp(['  I''m plotting ', int2str(points) ,' random orientations out of ', int2str(length(o)),' given orientations']);
  disp('  You can specify the the number points by the option "points".'); 
  disp('  The option "all" ensures that all data are plotted');
  
  samples = discretesample(length(o),points);
  o= o.subSet(samples);
  if ~isempty(data), data = data(:,samples,:); end
    
end

% plot
for i = 1:length(h)

  if i>1, mtexFig.nextAxis; end

  % compute specimen directions
  if check_option(varargin,'noSymmetry')
    sh = h{i};
  else
    sh = symmetrise(h{i});
  end
  r = reshape(o.SS * o * sh,[],1);
  opt = replicateMarkerSize(varargin,length(o.SS)*length(sh));
  
  % maybe we can restric ourselfs to the upper hemisphere
  if all(angle(h{i},-h{i})<1e-2) && ~check_option(varargin,{'lower','complete','3d'})
    opt = [opt,'upper'];
  end
  
  
  [~,cax] = r.plot(repmat(data,[length(o.SS) length(sh)]),...
    o.SS.fundamentalSector(varargin{:}),'doNotDraw',opt{:});
  
  if ~check_option(varargin,'noTitle'), mtexTitle(cax(1),char(h{i},'LaTeX')); end
  
  % plot annotations
  pfAnnotations('parent',cax,'doNotDraw','add2all');
  setappdata(cax,'h',h{i});
  set(cax,'tag','pdf');
  setappdata(cax,'SS',o.SS);
  
  % TODO: unifyMarkerSize

end

if isNew || check_option(varargin,'figSize')
  mtexFig.drawNow('figSize',getMTEXpref('figSize'),varargin{:}); 
end

if check_option(varargin,'3d')  
  datacursormode off
  fcw(mtexFig.parent,'-link'); 
end

% ----------- Tooltip function ------------------------
function txt = tooltip(varargin)

[r_local,id] = getDataCursorPos(mtexFig);

txt = ['id ' xnum2str(id) ' at (' int2str(r_local.theta/degree) ',' int2str(r_local.rho/degree) ')'];

end

end

function opt = replicateMarkerSize(opt,n)

ms = get_option(opt,'MarkerSize');
if length(ms)>1 && n > 1
  ms = repmat(ms(:).',n,1);
  opt = set_option(opt,'MarkerSize',ms);
end
  
end

