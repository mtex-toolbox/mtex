function [density,omega] = calcAngleDistribution(ebsd,varargin)
% calculate angle distribution
%
%% Input
% ebsd - @EBSD
%
%% Flags
%
%% Output
% density - the density, such that 
%
%    $$\int f(\omega) d\omega = \pi$$
%
% omega  - intervals of density
%
% in the discrete case density sums up to 100
%
%% See also
% EBSD/calcMisorientation EBSD/plotAngleDistribution

if check_option(varargin,'smooth')
  
  odf1 = calcODF(ebsd,'Fourier','halfwidth',10*degree);
  
  ebsd2 = getClass(varargin,'EBSD',[]);
  if isempty(ebsd2) || numel(ebsd) == numel(ebsd2)
    odf2 = odf1;
  else
    odf2 = calcODF(ebsd2,'halfwidth',10*degree,'Fourier');
  end
    
  mdf = calcMDF(odf1,odf2);
  
  [density,omega] = calcAngleDistribution(mdf,varargin{:});
  
else
  m = calcMisorientation(ebsd,varargin{:});

  [dns,omega] = angleDistribution(get(m,'CS'));
  omega = linspace(0,max(omega),min(50,max(5,numel(m)/20)));
  omega = get_option(varargin,'omega',omega);

  density = histc(angle(m),omega);
  %density = pi*density./mean(density);
  density = 100*density./sum(density);
end
