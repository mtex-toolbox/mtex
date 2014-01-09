function S2G = regularS2Grid(varargin)

% extract options
bounds = getPolarRange(varargin{:});

% set up polar angles
theta = get_option(varargin,'theta',linspace(bounds.VR{1:2},bounds.points(2)));
theta = S1Grid(theta,bounds.FR{1:2});

% set up azimuth angles
steps = (bounds.VR{4}-bounds.VR{3}) / bounds.points(1);
rho = get_option(varargin,'rho',bounds.VR{3} + steps*(0:bounds.points(1)-1));
rho = repmat(...
  S1Grid(rho,bounds.FR{3:4},...
  'PERIODIC'),1,GridLength(theta));

% set up grid
S2G = S2Grid(theta,rho);

% set up options
%S2G = set_option(S2G,extract_option(varargin,{'INDEXED','PLOT','north','south','antipodal','lower','upper'}));


end

