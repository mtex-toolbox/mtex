function rmallappdata(fig,varargin)
% removes all figure appdata

d = getappdata(fig);
f = fields(d);

for i = 1:length(f)
  rmappdata(fig,f{i});
end
