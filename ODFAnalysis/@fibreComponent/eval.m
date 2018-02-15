function f = eval(component,g,varargin)
% evaluate an odf at orientation g
%

f = reshape(component.psi.RK_symmetrised(g, component.h, component.r, ...
  component.weights,component.CS,component.SS,1),size(g));
