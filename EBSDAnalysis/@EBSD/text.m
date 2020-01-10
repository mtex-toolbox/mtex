function h = text(ebsd,txt,varargin)
% plot text at pixel centers
%
% Syntax
%   text(text(29),'A')
%
%   % plot grains with grainId
%   text(grains,arrayfun(@num2str,grains.id,'uniformOutput',false))
%
% Input
%  grains - @EBSD
%


if isnumeric(txt), txt = xnum2str(txt,'cell'); end

fs = getMTEXpref('FontSize');

h = optiondraw(text(ebsd.prop.x(:),ebsd.prop.y(:),txt,...
  'HorizontalAlignment','center','VerticalAlignment','middle','fontSize',fs),varargin{:});

if nargout == 0, clear h; end

end
