function [psi,c] = calcKernel(ebsd,varargin)
% compute an optimal kernel function ODF estimation
%
%% Input
%  ebsd - @EBSD
%
%% Output
%  psi    - @kernel
%
%% Options
%  phase   - specifies the phase (default is the first one)
%
%% See also
% EBSD/calcODF

if ~isempty(ebsd.xy)
  warning('');
end

% prepare kernels for testing
for k = 1:10
  psi(k) = kernel('de la Vallee Poussin','halfwidth',40*degree/2^(k/3)); %#ok<AGROW>
end
psi = get_option(varargin,'kernel',psi);

%

method = get_option(varargin,'method','LSCV');
switch method
  
  case 'LSCV'
    
    c = LSCV(ebsd,psi);
    
  case 'KLCV'
    
    c = KLCV(ebsd,psi);
    
  case 'BCV'
    
    c = BCV(ebsd,psi);
    
  otherwise
    
    error('Unknown kernel selection method.');
    
end

[cc,i] = max(c);
psi = psi(i);

