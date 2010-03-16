function plotipdf(grains,r,varargin)


[o ind] = get(grains,'orientations','CheckPhase',varargin{:});

varargin = set_option_property(grains(ind),varargin{:});

plotipdf(o,r,...
  'FigureTitle',[inputname(1) ' (' get(grains(1),'comment') ')'],varargin{:});

