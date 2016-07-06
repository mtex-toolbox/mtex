function S3G = zeroRange(pf,S3G,varargin)
% implements the zero range method
%
% Input
%  pf  - @PoleFigure
%  S3G - initial @SO3Grid
%
% Output
%  NS3G - antipodal @SO3Grid
%
% Options
%  zero_range   - which pole figures to be included [0.1]
%  zr_bg        - intensity to be considered as background
%  zr_factor    - backgound = pf_max_value / zr_factor
%  zr_halfwidth - halfwidth of the kernel used for estimation
%  zr_delta     - height of a positive kernel
%
% See also
% PoleFigure/calcODF


% symmetrically equivalent orientations
g = S3G.symmetrise.';

% start with complete grid
ind = true(length(S3G),1);

% which pole figures to check
ipf = get_option(varargin,'zero_range',1:pf.numPF,'double');
  
% approximation grid
S2G = regularS2Grid('resolution',1*degree,'antipodal');

% loop over pole figures
for ip = ipf

  fprintf('applying zero range method to %s',char(pf.allH{ip}));
  
  % compute zero ranges at approximation grid
  zr = calcZeroRange(pf.select(ip),S2G,varargin{:});
  
  % loop over symmetries
  for is = 1:size(g,2)

    fprintf('.');
    
    % calculate specimen directions corresponding to grid
    ggh = g(ind,is) * pf.allH{ip};
    
    % transform in polar coordinates -> output nodes
    theta= fft_theta(ggh.theta);
    rho  = fft_rho(ggh.rho);          

    % project to upper hemisphere
    rho(theta>0.25) = 0.5 + rho(theta>0.25);
    rho(rho<0) = rho(rho<0) + 1;
    theta(theta>0.25) = 0.5-theta(theta>0.25);
    
    % calculate indece
    ir = 1+round(theta * 4 * (size(S2G,2)-1))*size(S2G,1) + ...
      round(rho * size(S2G,1));
    ir(ir>length(S2G)) = length(S2G);
    
    % ignore all orientations that are close to the zero range
    ind(ind) = all(zr(ir),2);
    assert(any(ind),'Zero range methods has canceled out all orientations. Chose better parameters');
  
  end
  fprintf(' - reduction: %d / %d\n',sum(ind),length(ind));
end

S3G = subGrid(S3G,ind);
