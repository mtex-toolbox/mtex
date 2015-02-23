function varargout = scatter(o,varargin)
% plots ebsd data as scatter plot
%
% Syntax
%   scatter(ebsd,<options>)
%
% Input
%  ebsd - @EBSD
%
% Options
%  axisAngle - axis angle projection
%  Rodrigues - rodrigues parameterization
%  points    - number of orientations to be plotted
%  center    - orientation center
%
% See also
% EBSD/plotPDF savefigure

% subsample to reduce size
if length(o) > 2000 || check_option(varargin,'points')
  points = fix(get_option(varargin,'points',2000));
  disp(['plot ', int2str(points) ,' random orientations out of ', ...
    int2str(length(o)),' given orientations']);
  o = o.discreteSample(fix(points));
end

[mtexFig,isNew] = newMtexFigure('ensureTag','quaternionScatter',...
  'ensureAppdata',{{'CS',o.CS},{'SS',o.SS}},varargin{:});

if isNew
  
  % reference orientation for fundamental region
  if check_option(varargin,'center')
    center = get_option(varargin,'center');    
  else
    center = mean(o);
  end  
  setappdata(mtexFig.parent,'center',center);

  setappdata(mtexFig.parent,'CS',o.CS);
  setappdata(mtexFig.parent,'SS',o.SS);  
  
else
  center = getappdata(mtexFig.parent,'center');    
end

varargin = delete_option(varargin,'center');
q = rotation(project2FundamentalRegion(o,center));
  
% plot
[varargout{1:nargout}]= scatter@rotation(q,'parent',mtexFig.gca,varargin{:});

set(mtexFig.parent,'Name',['Scatter plot of "',get_option(varargin,'FigureTitle',inputname(1)),'"']);
