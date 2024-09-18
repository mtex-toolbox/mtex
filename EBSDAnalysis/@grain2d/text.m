function h = text(grains,txt,varargin)
% plot directions at grain centers
%
% Syntax
%   text(grains(29),'A')
%
%   % plot grains with grainId
%   text(grains,arrayfun(@num2str,grains.id,'uniformOutput',false))
%
% Input
%  grains - @grain2d
%



pos = grains.centroid;

if isnumeric(txt), txt = xnum2str(txt,'cell'); end

fs = getMTEXpref('FontSize');

h = optiondraw(text(pos.x, pos.y, pos.z,txt,...
  'HorizontalAlignment','center','VerticalAlignment','middle','fontSize',fs),varargin{:});

if nargout == 0, clear h; end

end
