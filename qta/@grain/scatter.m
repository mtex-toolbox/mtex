function scatter(grains,varargin)

o = get(grains,'orientations');

varargin = set_option_property(grains(ind),varargin{:});

scatter(o,...
  'FigureTitle',[inputname(1) ' (' get(grains(1),'comment') ')'],varargin{:});

