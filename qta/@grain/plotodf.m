function plotodf(grains,varargin)


o = get(grains,'orientations');

varargin = set_option_property(grains,varargin{:});

plotodf(o,...
  'FigureTitle',[inputname(1) ' (' get(grains(1),'comment') ')'],varargin{:});
