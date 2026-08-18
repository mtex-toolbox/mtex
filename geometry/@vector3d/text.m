function h = text(v,varargin)
% display a text in a spherical plot
%
% Syntax
%   text(v,s)
%   text(v,s,'fontSize',16)
%   text(v,s,'textAboveMarker')
%   text(v,s,'textColor','blue')
%   text(v,s,'textBackgroundColor','white')
%
% Input
%  v  - @vector3d
%  s  - string
%
% Options
%  textColor - rgb or color name
%  textAboveMarker - display the text above the marker
%
% See also

if check_option(varargin,'add2all')

  ax = get_option(varargin,'parent');
  if isempty(ax)
    mtexFig = gcm;
    if isempty(gcm)
      ax = gca;
    else
      ax = mtexFig.children;
    end
  end
  varargin = delete_option(varargin,'parent',1);
  varargin = delete_option(varargin,'add2all');

  h = [];
  for i = 1:length(ax)
    h = [h, text(v,varargin{:},'parent',ax(i))]; %#ok<AGROW>
  end

  if nargout == 0, clear h; end
  return
end

if check_option(varargin,'parent')
  ax = get_option(varargin,'parent');
else
  ax = gca;
end

% a three dimensional spherical plot, e.g. plot(...,'3d') - it does not go
% through a sphericalPlot at all, and a flat label would end up pinned to
% the z = 0 plane, i.e. inside the sphere. Place the label in space
% instead, with an arrow pointing along the direction it names.
if is3dPlot(ax)

  hG = holdOn(ax); %#ok<NASGU>
  h = [reshape(arrow3d(v,varargin{:},'parent',ax),1,[]),...
    reshape(text3(v,varargin{:},'parent',ax),1,[])];
  clear hG

  if nargout == 0, clear h; end
  return
end

% initialize spherical plot
sP = newSphericalPlot(v,varargin{:},'hold');
h = [];
interpreter = get_option(varargin,'interpreter',getMTEXpref('textInterpreter'));
fs = getMTEXpref('FontSize');
varargin = delete_option(varargin,'parent',1);

if check_option(varargin,'textAboveMarker')
  aboveBelow = -1;
elseif check_option(varargin,'autoAlignText')
  aboveBelow = 0;
else % textBelowMarker
  aboveBelow = 1;
end

for j = 1:numel(sP)

  % project data
  [x,y] = project(sP(j).proj,v,varargin{:});

  % special option -> labeled
  if check_option(varargin,'labeled')

    strings = cell(1,length(v));
    for i = 1:length(v), strings{i} = char(v.subSet(i),getMTEXpref('textInterpreter')); end

  elseif isnumeric(varargin{1})  % ensure cell as input
    
    strings = ensurecell(xnum2str(varargin{1},'cell'));
    
  else
    strings = ensurecell(varargin{1});
  end

  if length(v)>1 && isscalar(strings), strings = repmat(strings,length(v),1); end
  
  % print labels  
  for i = 1:length(strings)
    
    if isnan(x(i)), continue; end
    
    s = strings{i};
    if ~ischar(s) && ~isstring(s), s = char(s,interpreter);end

    % A string enclosed in $..$ is LaTeX math - Miller/char(m,'LaTeX')
    % returns exactly that, and so do hand written labels. The tex
    % interpreter has no math mode, hence it would print the dollars and
    % every backslash literally, so render those with LaTeX no matter what
    % textInterpreter says. They must not be wrapped a second time either.
    if isMathMode(s)
      sInterpreter = 'LaTeX';
    else
      sInterpreter = interpreter;
      if strcmpi(interpreter,'LaTeX') && ~isempty(regexp(s,'[\\\^_]','ONCE'))
        s = ['$' s '$']; %#ok<AGROW>
      end
    end

    if check_option(varargin,'addMarkerSpacing')
      
      xy = [x(i),y(i)];
            
      if aboveBelow == -1 || (aboveBelow == 0 && ...
          xor(sP(j).ax=="reverse",...
          xy(2) > mean(sP(j).bounds([2 4])) + 0.1))
        tag = {'UserData',xy,'tag','setAboveMarker'};
      else
        tag = {'UserData',xy,'tag','setBelowMarker'}; 
      end
    else
      tag = {};
    end
    
    h = [h,optiondraw(text(x(i),y(i),s,'interpreter',sInterpreter,...
      'HorizontalAlignment','center','VerticalAlignment','middle',...
      tag{:},'margin',0.001,'parent',sP(j).ax),'FontSize',fs,varargin{2:end})]; %#ok<AGROW>
    
  end

  if check_option(varargin,'textcolor')
    [h.Color] = deal(str2rgb(get_option(varargin,'textcolor')));
  end

  % finish plot
  if isappdata(sP(1).parent,'mtexFig')
    mtexFig = getappdata(sP(1).parent,'mtexFig');
    mtexFig.drawNow(varargin{:});
  end
end

if nargout == 0, clear h;end

end

% -------------------------------------------------------------------------
function tf = isMathMode(s)
% true if s is enclosed in $..$, i.e. it is LaTeX math already

s = strtrim(char(s));
tf = numel(s) >= 2 && s(1) == '$' && s(end) == '$';

end

% -------------------------------------------------------------------------
function tf = is3dPlot(ax)
% true if ax holds a three dimensional spherical plot
%
% vector3d/plot3d, vector3d/scatter3d and plotEmptySphere - the three ways
% such an axis comes into being - all end with axis(ax,'equal','vis3d'),
% which is what pins the plot box aspect ratio; a two dimensional spherical
% plot only ever pins the data aspect ratio. An EBSD map pins it as well,
% but it announces itself by its appdata, and so does a sphericalPlot.

tf = isscalar(ax) && isgraphics(ax,'axes') && ...
  strcmpi(ax.PlotBoxAspectRatioMode,'manual') && ...
  ~isappdata(ax,'mapPlot') && ~isappdata(ax,'sphericalPlot');

end

