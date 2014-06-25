function h = scatter3d(v,data,varargin)
% plot spherical data
%
% Syntax
%   scatter3d(v,data)
%
% Input
%
% See also
% savefigure

% where to plot
if check_option(varargin,'parent')
  ax = get_option(varargin,'parent');
else
  ax = gca;
end

% plot
v = 1.02 .* v ./ norm(v);
v = [reshape(v,[],1);-reshape(v,[],1)];

h = scatter3(v.x(:),v.y(:),v.z(:),30,...
  [reshape(data,length(v)/2,[]);reshape(data,length(v)/2,[])],'filled');

axis(ax,'equal','vis3d','off');

set(ax,'XDir','rev','YDir','rev',...
'XLim',[-1.02,1.02],'YLim',[-1.02,1.02],'ZLim',[-1.02,1.02]);

if nargout == 0, clear h;end
