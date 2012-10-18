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

% which directions to plot
m = [Miller(1,0,0,s),Miller(0,1,0,s),...
     Miller(0,0,1,s),Miller(1,1,0,s),...
     Miller(0,1,1,s),Miller(1,0,1,s),...
     Miller(1,1,1,s)];

m = unique(m);

% plot them
plot(m,'symmetrised','labeled','MarkerEdgeColor','k','grid',varargin{:});

% postprocess figure
setappdata(gcf,'CS',s);
set(gcf,'tag','ipdf');
setappdata(gcf,'options',extract_option(varargin,'antipodal'));
