function c = char(component,varargin)
% called by standard output

c = strvcat('  Radially symmetric portion:',...
  ['    kernel: ',char(component.psi)],...
  ['    center: ',char(component.center)]);

end
