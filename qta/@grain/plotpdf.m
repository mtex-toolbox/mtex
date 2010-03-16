function plotpdf(grains,h,varargin)


[phase,uphase] = get(grains,'phase');
grains = grains(phase == uphase(1));
o = get(grains,'orientation');

varargin = set_option_property(grains,varargin{:});

plotpdf(o,h,...
  'FigureTitle',[inputname(1) ' (' get(grains(1),'comment') ')'],varargin{:});

