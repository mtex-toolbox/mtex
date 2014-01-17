function pdf = calcPDF(component,h,r,varargin)


pdf = component.psi.RK_symmetrised(...
  component.center,h,r,component.weights,...
  component.CS,component.SS,varargin{:});

