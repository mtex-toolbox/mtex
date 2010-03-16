function scatter(grains,varargin)

[phase,uphase] = get(grains,'phase');
grains = grains(phase == uphase(1));
o = get(grains,'orientation');

varargin = set_option_property(grains,varargin{:});

scatter(o,...
  'FigureTitle',[inputname(1) ' (' get(grains(1),'comment') ')'],varargin{:});

