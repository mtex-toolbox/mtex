function pdf = calcPDF(component,h,r,varargin)
% compute the pole density function for a given unimodal component

if nargin > 2 && min(length(h),length(r)) > 0 && ...
    (check_option(varargin,'old') || max(length(h),length(r)) < 10)
  
  pdf = component.psi.RK_symmetrised(...
    component.center,h,r,component.weights,...
    component.CS,component.SS,varargin{:});
  return
  
end

% pole figure will be antipodal?
antipodalFlag = {[],'antipodal'};

isAnti = component.SS.isLaue || component.CS.isLaue || ...
  check_option(varargin,'antipodal') ;

if length(h) == 1 % pole figure

  % maybe only this particular pole figure is antipodal
  hIsAnti = isAnti || (angle(h,-h) < 1e-6);
  
  % take unique symmetrically equivalent 
  sh = symmetrise(h,'unique',antipodalFlag{1+hIsAnti});
  
  pdf = S2FunHarmonicSym.quadrature(component.center*sh,...
    repmat(component.weights(:),1,length(sh)),component.SS,antipodalFlag{1+hIsAnti},...
    'symmetrise','bandwidth',component.psi.bandwidth);

  % convolve with kernel function
  pdf = 4 * pi * conv(pdf,component.psi)./ length(sh);

  % maybe we should evaluate
  if nargin > 2 && isa(r,'vector3d'), pdf = pdf.eval(r); end
  
else % inverse pole figure

  sr = symmetrise(r,component.SS,'unique');
  pdf = S2FunHarmonicSym.quadrature(inv(component.center)*sr,...
    repmat(component.weights(:),1,length(sr)),component.CS,antipodalFlag{1+isAnti},...
    'symmetrise','bandwidth',component.psi.bandwidth);

  % convolve with kernel function
  pdf = 4 * pi * conv(pdf,component.psi) ./ length(sr);

  % maybe we should evaluate
  if isa(h,'vector3d'), pdf = pdf.eval(h); end
  
end
