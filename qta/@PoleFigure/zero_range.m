function NS3G = zero_range(pf,S3G,varargin)
% implements the zero range method
%
%% Input
%  pf  - @PoleFigure
%  S3G - initial @SO3Grid
%
%% Output
%  NS3G - antipodal @SO3Grid
%
%% Options
%  zero_range   - which pole figures to be included
%  zr_bg        - intensity to be considered as background
%  zr_factor    - backgound = pf_max_value / zr_factor
%  zr_halfwidth - halfwidth of the kernel used for estimation
%  zr_delta     - height of a positive kernel
%
%% See also
% PoleFigure/calcODF


%% calculate symmetrically equivalent orientations
%% TODO
g = quaternion(S3G);
cs = pf(1).CS; ss = pf(1).SS;
g = ss*reshape(g,1,[]);               % SS x S3G
g = reshape(g.',[],1);                % S3G x SS
g = reshape(g*cs,numel(S3G),[]); % S3G x SS x CS

% start with complete grid
ind = true(numel(S3G),1);

% which pole figures to check
ipf = get_option(varargin,'zero_range',1:length(pf),'double');

  
%% approximation grid
S2G = S2Grid('regular','resolution',1*degree,'antipodal');

% loop over pole figures
for ip = ipf

  fprintf('applying zero range method to %s',char(getMiller(pf(ip))));
  
  % compute zero ranges at approximation grid
  zr = calcZeroRange(pf(ip),S2G,varargin{:});
  
  % loop over symmetries
  for is = 1:size(g,2)

    fprintf('.');
    
    % calculate specimen directions corresponding to grid
    ggh = g(ind,is) * pf(ip).h;
    
    % transform in polar coordinates -> output nodes
    [theta,rho] = polar(ggh);
    theta= fft_theta(theta);
    rho  = fft_rho(rho);          

    % project to northern hemisphere
    rho(theta>0.25) = 0.5 + rho(theta>0.25);
    rho(rho<0) = rho(rho<0) + 1;
    theta(theta>0.25) = 0.5-theta(theta>0.25);
    
    % calculate indece
    ir = 1+round(theta * 4 * (size(S2G,2)-1))*size(S2G,1) + ...
      round(rho * size(S2G,1));
    ir(ir>numel(S2G)) = numel(S2G);
    
    % ignore all orientations that are close to the zero range
    ind(ind) = all(zr(ir),2);
    assert(any(ind),'Zero range methods has canceled out all orientations. Chose better parameters');
  
  end
  fprintf(' - reduction: %d / %d\n',sum(ind),length(ind));
end

NS3G = subGrid(S3G,ind);
