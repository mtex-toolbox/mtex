function [density,omega] = calcAngleDistribution(obj,varargin)
% calculate angle distribution
%
%
% Input
%  ebsd   - @EBSD
%  grains - @grainSet
%
% Flags
%
% Output
%  density - the density, such that 
%
%    $$\int f(\omega) d\omega = \pi$$
%
%  omega   - interval of density
%
% See also
% EBSD/calcMisorientation misorientationAnalysis/plotAngleDistribution

% compute the misorientation distribution to get a smooth angle
% distribution
if check_option(varargin,'smooth')
  
  odf1 = calcFourierODF(obj,'halfwidth',10*degree);
  
  obj2 = getClass(varargin,'misorientationAnaylsis',[]);
  if isempty(obj2) || length(obj) == length(obj2)
    odf2 = odf1;
  else
    odf2 = calcFourierODF(obj2,'halfwidth',10*degree);
  end
    
  mdf = calcMDF(odf1,odf2);
  
  [density,omega] = calcAngleDistribution(mdf,varargin{:});
  
else
  m = calcMisorientation(obj,varargin{:});

  [dns,omega] = angleDistribution(m.CS);
  omega = linspace(0,max(omega),min(50,max(5,length(m)/20)));
  omega = get_option(varargin,'omega',omega);

  density = histc(angle(m),omega);
  %density = pi*density./mean(density);
  density = 100*density./sum(density);
end
