function plot(s,varargin)
% plot symmetry

m = [Miller(1,0,0,s),Miller(0,0,1,s),Miller(0,1,1,s),Miller(1,1,0,s)];

if symeq(m(2),m(3)), m = m(1:2);end
if symeq(m(1),m(2)), m = m(2:end);end

plot(m,'All','north','south','labeled','MarkerEdgeColor','k','grid',varargin{:});
%setappdata(gcf,'r',S2Grid());
setappdata(gcf,'CS',s);
set(gcf,'tag','ipdf');
setappdata(gcf,'options',extract_option(varargin,'axial'));
