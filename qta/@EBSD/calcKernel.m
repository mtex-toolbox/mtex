function psi = calcKernel(ebsd,varargin)
% compute an optimal kernel function ODF estimation
%
%% Input
%  ebsd - @EBSD
%
%% Output
%  psi    - @kernel
%
%% Options
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
%% See also
% EBSD/calcODF EBSD/BCV EBSD/KLCV EBSD/LSCV

% ensure single phase
if numel(unique(ebsd.phase)) > 1

  error('MTEX:MultiplePhases',['This operatorion is only permitted for a single phase!' ...
    'See ' doclink('xx','xx')  ...
    ' for how to restrict EBSD data to a single phase.']);
end

% ensure spatial independence
if isfield(ebsd.options,'x')
  warning('MTEX:calcKernel',['Measurements seem to be spatially dependend.' ...
    ' Usually this results in to sharp kernel functions. You may want to'...
    ' restore grains first and then estimate the kernel from the grains.' ...
    ' See also: ' doclink('EBSD2odf','automatic optimal kernel detection'),'.\n ']);
end

% prepare kernels for testing
for k = 1:10
  psi(k) = kernel('de la Vallee Poussin','halfwidth',30*degree/2^(k/3)); %#ok<AGROW>
end
psi = get_option(varargin,'kernel',psi);

% if there are to many orientations -> subsampling
maxSample = 5000;
if numel(ebsd) > maxSample
  fak = (numel(ebsd)/maxSample).^(1/7); % true is 2/7 but let us stay on the save side
  ebsd = subsample(ebsd,maxSample);
else
  fak = 1;
end

method = get_option(varargin,'method','KLCV');
switch method

  case 'RuleOfThumb'

    % compute resolution of the orientations
    ori = get(ebsd,'orientations');
    if numel(ori) == 0
      res = 2*pi;
    else
      d = angle_outer(ori,ori);
      d(d<0.005) = pi;
      res = quantile(min(d,[],2),0.9);
    end

    hw = max((res * 3)/2,2*degree);
    psi = kernel('de la Vallee Poussin','halfwidth',hw);
    psi = kernel('de la Vallee Poussin',fak*get(psi,'kappa'));

    return
  case 'LSCV'

    c = -LSCV(ebsd,psi);

  case 'KLCV'

    c = KLCV(ebsd,psi);

  case 'BCV'

    c = -BCV(ebsd,psi);

  otherwise

    error('Unknown kernel selection method.');

end

[cc,i] = max(c);
psi = kernel('de la Vallee Poussin',fak*get(psi(i(1)),'kappa'));

