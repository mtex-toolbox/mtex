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

m = [Miller(1,0,0,s),Miller(0,1,0,s),...
     Miller(0,0,1,s),Miller(1,1,0,s),...
     Miller(0,1,1,s),Miller(1,0,1,s),...
     Miller(1,1,1,s)];

%m = [Miller(1,0,0,s),Miller(0,0,1,s),Miller(0,1,1,s),Miller(1,1,0,s)];

m = unique(m);

plot(m,'All','north','south','labeled','MarkerEdgeColor','k','grid',varargin{:});

setappdata(gcf,'CS',s);
set(gcf,'tag','ipdf');
setappdata(gcf,'options',extract_option(varargin,'antipodal'));
