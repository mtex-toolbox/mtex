function varargout = scatter(o,varargin)
% plots ebsd data as scatter plot
%
% Syntax
%   scatter(ori)
%
% Input
%  ori - @orientation
%
% Options
%  axisAngle - axis angle projection
%  Rodrigues - rodrigues parameterization
%  Euler     - 3d Bunge Euler plot
%  points    - number of orientations to be plotted
%  center    - orientation center
%
% See also
% vector3d/text orientation/plot

if nargin > 1 && isnumeric(varargin{1})
  data = varargin{1};
  varargin(1) = [];
else
  data = [];
end

% subsample to reduce size
if length(o) > 2000 || check_option(varargin,'points')
  points = fix(get_option(varargin,'points',2000));
  disp(['plot ', int2str(points) ,' random orientations out of ', ...
    int2str(length(o)),' given orientations']);
  [o,ind] = discreteSample(o,fix(points),'withoutReplacement');
  if ~isempty(data), data = data(ind); end
else
  
end

[mtexFig,isNew] = newMtexFigure(varargin{:});

% plot
[varargout{1:nargout}]= scatter@rotation(rotation(o),data,'parent',mtexFig.gca,varargin{:});

if isNew
  set(mtexFig.parent,'Name',['Scatter plot of "',get_option(varargin,'FigureTitle',inputname(1)),'"']);
  fcw
end
