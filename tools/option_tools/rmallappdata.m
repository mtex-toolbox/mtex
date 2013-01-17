function rmallappdata(fig,varargin)
% removes all figure appdata

if nargin == 0, fig = gcf;end
d = getappdata(fig);
f = fields(d);

for i = 1:length(f)
  rmappdata(fig,f{i});
end
