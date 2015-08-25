function h = text(v,varargin)
% display a text in a spherical plot
%
% Syntax
%   text(v,s)  %
%
% Input
%  v  - @vector3d
%  s  - string
%
% Options
%
% See also

% initialize spherical plot
sP = newSphericalPlot(v,varargin{:},'hold');
h = [];
interpreter = getMTEXpref('textInterpreter');
fs = getMTEXpref('FontSize');

if check_option(varargin,'textAboveMarker')
  aboveBelow = -5;
elseif check_option(varargin,'autoAlignText')
  aboveBelow = 0;
else % textBelowMarker
  aboveBelow = 5;
end

for j = 1:numel(sP)

  % project data
  [x,y] = project(sP(j).proj,v,varargin{:});

  % special option -> labeled
  if check_option(varargin,'labeled')

    strings = cell(1,length(v));
    for i = 1:length(v), strings{i} = char(v.subSet(i),getMTEXpref('textInterpreter')); end

  else % ensure cell as input

    strings = ensurecell(varargin{1});
    if length(v)>1 && length(strings)==1
      strings = repmat(strings,length(v),1);
    end

  end
  
  % print labels  
  for i = 1:length(strings)
    
    if isnan(x(i)), continue; end
    
    s = strings{i};
    if ~ischar(s), s = char(s,interpreter);end

    if strcmpi(interpreter,'LaTeX') && ~isempty(regexp(s,'[\\\^_]','ONCE'))
      s = ['$' s '$']; %#ok<AGROW>
    end

    if check_option(varargin,'addMarkerSpacing'),
      tag = {'UserData',[x(i),y(i)],'tag'};
      
      if y(i) > mean(sP(j).bounds([2 4])) + 0.1 + aboveBelow
        tag = [tag,'setAboveMarker'];
      else        
        tag = [tag,'setBelowMarker'];
      end
    else
      tag = {};
    end
    
    h = [h,optiondraw(text(x(i),y(i),s,'interpreter',interpreter,...
      'HorizontalAlignment','center','VerticalAlignment','middle',...
      tag{:},'margin',0.001,'parent',sP(j).ax),'FontSize',fs,varargin{2:end})]; %#ok<AGROW>
    
  end

  % finish plot
  if isappdata(sP(1).parent,'mtexFig')
    mtexFig = getappdata(sP(1).parent,'mtexFig');
    mtexFig.drawNow(varargin{:});
  end
end

if nargout == 0, clear h;end

end

