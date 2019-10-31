function init(zrm,varargin)

zrm.pf = getClass(varargin,'PoleFigure',zrm.pf);

% if no pole figures are specified abbort
if isempty(zrm.pf), return; end

zrm.psi = getClass(varargin,'S2Kernel', S2DeLaValleePoussin('halfwidth',...
  get_option(varargin,'halfwidth',2*zrm.pf.allR{1}.resolution)));

zrm.threshold = get_option(varargin,'threshold',0.1 * zrm.psi.eval(1));

zrm.delta = get_option(varargin,'delta',zrm.delta,'double');
zrm.bg = get_option(varargin,'bg',zrm.delta * max(zrm.pf));
zrm.alpha = get_option(varargin,'alpha',zrm.alpha,'double');

% spherical functions approximating the pole figures
[zrm.density, zrm.pdf] = deal(S2FunHarmonic);
for i = 1:zrm.pf.numPF
  % normalization
  zrm.density(i) = calcDensity(zrm.pf.allR{i},'kernel',zrm.psi,'noNormalization');
  
  w = (zrm.alpha * (zrm.pf.allI{i} > zrm.bg(i))-1);
  zrm.pdf(i) = calcDensity(zrm.pf.allR{i},'weights',w,'kernel',zrm.psi,'noNormalization');
  
end
