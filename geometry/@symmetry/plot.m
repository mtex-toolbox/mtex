function plot(s,varargin)
% plot symmetry
%
%% Input
%  s - symmetry
%
%% Output
%
%% Options
%  antipodal      - include [[AxialDirectional.html,antipodal symmetry]]

m = [Miller(1,0,0,s),Miller(0,0,1,s),Miller(0,1,1,s),Miller(1,1,0,s)];

if m(2) == m(3), m = m(1:2);end
if m(1) == m(2), m = m(2:end);end

plot(m,'All','north','south','labeled','MarkerEdgeColor','k','grid',varargin{:});

setappdata(gcf,'CS',s);
set(gcf,'tag','ipdf');
setappdata(gcf,'options',extract_option(varargin,'antipodal'));
