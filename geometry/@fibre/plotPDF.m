function plotPDF(f,varargin)
% plot a fibre into pole figures
%
% Syntax
%   plotPDF(ori,[h1,h2,h3])
%   plotPDF(ori,[h1,h2,h3],'antipodal')
%   plotPDF(ori,[h1,h2,h3],'superposition',{1,[1.5 0.5]})
%   plotPDF(ori,data,[h1,h2,h3])
%
% Input
%  f - @orientation
%  h   - @Miller crystallographic directions
%
% Options
%  superposition - plot superposed pole figures
%  points        - number of points to be plotted
%
% Flags
%  antipodal - include <VectorsAxes.html antipodal symmetry>
%  complete  - plot entire (hemi)--sphere
%
% See also
% orientation/plotIPDF S2Grid/plot savefigure
% Plotting Annotations_demo ColorCoding_demo PlotTypes_demo
% SphericalProjection_demo

% generate a new figure
[mtexFig,isNew] = newMtexFigure('datacursormode',@tooltip,varargin{:});

% extract crystal directions
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
for i = 1:length(h), h{i} = f.CS.ensureCS(h{i}); end

if isNew
  pfAnnotations = getMTEXpref('pfAnnotations');
  set(mtexFig.parent,'Name',['Pole figures of "',get_option(varargin,'FigureTitle',inputname(1)),'"']);
else
  pfAnnotations = @(varargin) 1;
end

% plot
for i = 1:length(h)

  if i>1, mtexFig.nextAxis; end

  % compute specimen directions
  r = f.orientation * h{i};

  [~,cax] = r.line('fundamentalRegion','parent',mtexFig.gca,'doNotDraw',varargin{:});
  if ~check_option(varargin,'noTitle')
    mtexTitle(mtexFig.gca,char(h{i},'LaTeX'));
  end

  if isa(f.SS,'specimenSymmetry')
    pfAnnotations('parent',mtexFig.gca,'doNotDraw');
  end
  setappdata(cax,'h',h{i});
  set(cax,'tag','pdf');
  setappdata(cax,'SS',f.SS);

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

r_local = getDataCursorPos(mtexFig);

txt = ['(' int2str(r_local.theta/degree) ',' int2str(r_local.rho/degree) ')'];

end

end
