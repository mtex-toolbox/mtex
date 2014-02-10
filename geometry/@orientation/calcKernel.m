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

% prepare kernels for testing
for k = 1:10
  psi{k} = deLaValeePoussinKernel('halfwidth',30*degree/2^(k/3)); %#ok<AGROW>
end
psi = get_option(varargin,'kernel',psi);

% if there are to many orientations -> subsampling
maxSample = 5000;
if length(ori) > maxSample
  fak = (length(ori)/maxSample).^(1/7); % true is 2/7 but let us stay on the save side
  
  ind = discretesample(length(ori),maxSample);
  ori = subSet(ori,ind);
%  weights = weights(ind);
  
else
  fak = 1;
end

method = get_option(varargin,'method','KLCV');
switch method

  case 'RuleOfThumb'

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
  case 'LSCV'

    c = -LSCV(ori,psi);

  case 'KLCV'

    c = KLCV(ori,psi);

  case 'BCV'

    c = -BCV(ori,psi);

  otherwise

    error('Unknown kernel selection method.');

end

[cc,i] = max(c);
psi = deLaValeePoussinKernel(fak*psi{i(1)}.kappa);

