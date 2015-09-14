function psi = calcKernel(ori,varargin)
% compute an optimal kernel function for ODF estimation
%
% Input
%  ori - @orientation
%
% Output
%  psi    - @kernel
%
% Options
% method  - select a halfwidth by
%
%    * |'RuleOfThumb'| 
%
%    or via cross valiadation method:
%
%    * |'LSCV'| -- least squares cross valiadation
%    * |'KLCV'| -- Kullback Leibler cross validation
%    * |'BCV'| -- biased cross validation
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
    
    kappa = (length(ori.CS) * length(ori.SS) * numOri)^(2/7) * 3; % magic rule
    psi = deLaValeePoussinKernel(kappa,varargin{:});
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
    psi = deLaValeePoussinKernel('halfwidth',hw);
    psi = deLaValeePoussinKernel(fak*psi.kappa);

    return 
end

% now prepare kernels for cross validation methods
for k = 1:10
  psi{k} = deLaValeePoussinKernel('halfwidth',30*degree/2^(k/3)); %#ok<AGROW>
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
psi = deLaValeePoussinKernel(fak*psi{i(1)}.kappa);
