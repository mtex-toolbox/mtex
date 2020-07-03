function psi = calcKernel(ori,varargin)
% compute an optimal kernel function for ODF estimation
%
% Syntax
%
%   psi = calcKernel(ori)
%   psi = calcKernel(ori,'method','ruleOfThumb')
%
% Input
%  ori - @orientation
%
% Output
%  psi    - @kernel
%
% Flags
%  magicrule   - 
%  RuleOfThumb - 
%  LSCV        - least squares cross valiadation
%  KLCV        - Kullback Leibler cross validation (default)
%  BCV         - biased cross validation
%
% See also
% EBSD/calcODF orientation/BCV orientation/KLCV orientation/LSCV


% if there are to many orientations -> subsampling
numOri = length(ori);

maxSample = 5000;
if length(ori) > maxSample
  fak = (numOri/maxSample).^(1/7); % true is 2/7 but let us stay on the save side
  
  ind = discretesample(length(ori),maxSample);
  ori = subSet(ori,ind);
    
else
  fak = 1;
end

% first the simple methods
method = get_option(varargin,'method','KLCV');

switch lower(method)
  
  case 'magicrule'
    
    kappa = (numProper(ori.CS) * numProper(ori.SS) * numOri)^(2/7) * 3; % magic rule
    psi = deLaValleePoussinKernel(kappa,varargin{:});
    return
    
  case 'ruleofthumb'

    % compute resolution of the orientations
    if isempty(ori)
      res = 2*pi;
    else
      d = angle_outer(ori,ori);
      d(d<0.005) = pi;
      res = quantile(min(d,[],2),0.9);
    end

    hw = max((res * 3)/2,2*degree);
    psi = deLaValleePoussinKernel('halfwidth',hw);
    psi = deLaValleePoussinKernel(fak*psi.kappa);

    return 
end

% now prepare kernels for cross validation methods
for k = 1:10
  psi{k} = deLaValleePoussinKernel('halfwidth',30*degree/2^(k/3)); %#ok<AGROW>
end
psi = get_option(varargin,'kernel',psi);

switch method

  case 'LSCV'
    c = -LSCV(ori,psi,varargin{:});
  case 'KLCV'
    c = KLCV(ori,psi,varargin{:});
  case 'BCV'
    c = -BCV(ori,psi,varargin{:});
  otherwise
    error('Unknown kernel selection method.');
end

[~,i] = max(c);
psi = deLaValleePoussinKernel(fak*psi{i(1)}.kappa);
