function plotpdf(grains,h,varargin)


o = get(grains,'orientations');

varargin = set_option_property(grains(ind),varargin{:});

plotpdf(o,h,...
  'FigureTitle',[inputname(1) ' (' get(grains(1),'comment') ')'],varargin{:});

