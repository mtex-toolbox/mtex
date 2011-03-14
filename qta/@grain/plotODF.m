function plotodf(grains,varargin)


[o ind] = get(grains,'orientations','CheckPhase',varargin{:});

varargin = set_option_property(grains(ind),varargin{:});

plotodf(o,...
  'FigureTitle',[inputname(1) ' (' get(grains(1),'comment') ')'],varargin{:});

