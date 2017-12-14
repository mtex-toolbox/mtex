function pdf = calcPDF(component,h,r,varargin)
% compute the pole density function for a given unimodal component

if nargin > 2 && min(length(h),length(r)) > 0 && ...
    (check_option(varargin,'old') || max(length(h),length(r)) < 1000)
  
  pdf = component.psi.RK_symmetrised(...
    component.center,h,r,component.weights,...
    component.CS,component.SS,varargin{:});
  return
  
end

if length(h) == 1

  sh = symmetrise(h,'unique');
  pdf = sphFunHarmonic.quadrature(...
    repmat(component.weights(:),1,length(sh)),component.center*sh);
  
  pdf = 4 * pi * conv(pdf,component.psi)./ length(sh);

  % symmetrise with respect to specimen symmetry
  pdf = pdf.symmetrise(component.SS);
  
  % maybe we should evaluate
  if nargin > 2 && isa(r,'vector3d'), pdf = pdf.eval(r); end
  
else

  sr = symmetrise(r,component.SS,'unique');
  pdf = sphFunHarmonic.quadrature(...
    repmat(component.weights(:),1,length(sr)),inv(component.center)*sr);
  
  pdf = 4 * pi * conv(pdf,component.psi) ./ length(sr);

  % symmetrise with respect to crystal symmetry
  pdf = pdf.symmetrise(component.CS);
  
  % maybe we should evaluate
  if isa(h,'vector3d'), pdf = pdf.eval(h); end
  
end