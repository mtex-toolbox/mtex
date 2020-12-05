function [lp, omega] = surfor(gb,varargin)
% Returns the projection function of grain boundary segments based 
% on Panozzo R (1984) "Two-dimensional strain from the
% orientation of lines in a plane." J Struct Geol 6:215–221
% 
% Surfor makes only sense for sufficiently smooth grain boundaries.
%
% Input:
%  gb         - @grainBoundary
%
% Output:
%  lp         - cummulative projection length
%  omega      - list of angles used for the projection
%
% Options:
%  stepwidth  - width of interval for angles 0:pi (default: 1 degree) 
%
%

%proj. angle
if nargin > 1 && isnumeric(varargin{1})
  omega = varargin{1};
else
  sw = get_option(varargin,'stepwidth',1*degree);
  omega=linspace(0,pi,round(pi/sw));
end

% direction
rho = mod(gb.direction.rho,pi);
omat = repmat(omega,length(rho),1);

% sum of projection lengths
lp = sum(gb.segLength .* abs(cos(mod(omat-rho,pi))));
lp = lp./max(lp);


end