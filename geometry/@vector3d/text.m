function text(v,varargin)
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
% Output
%
% See also

% initialize spherical plot
sP = newSphericalPlot(v,varargin{:},'hold');

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
    s = strings{i};
    if ~ischar(s), s = char(s,getMTEXpref('textInterpreter'));end
    mtex_text(x(i),y(i),s,'parent',sP(j).ax,...
      'HorizontalAlignment','center','VerticalAlignment','middle',...
      'tag','addMarkerSpacing','UserData',[x(i),y(i)],...
      'margin',0.001,varargin{2:end});
  end
end
