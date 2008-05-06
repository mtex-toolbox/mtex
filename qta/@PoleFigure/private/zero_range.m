function NS3G = zero_range(pf,S3G,varargin)
% implements the zero range method
%
%% Input
%  pf  - @PoleFigure
%  S3G - initial @SO3Grid
%
%% Output
%  NS3G - reduced @SO3Grid
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


global mtex_path;

g = quaternion(S3G);
cs = pf(1).CS; ss = pf(1).SS;

% calculate symmetrically equivalent orientations
g = ss*reshape(g,1,[]);               % SS x S3G
g = reshape(g.',[],1);                % S3G x SS
g = reshape(g*cs,GridLength(S3G),[]); % S3G x SS x CS

% start with complete grid
ind = true(GridLength(S3G),1);

% which pole figures to check
ipf = get_option(varargin,'zero_range',1:length(pf),'double');

  
% loop over pole figures
for ip = ipf

  fprintf('applying zero range method to %s',char(getMiller(pf(ip))));
  
  % kernel used for calculation
  k = kernel('de la Vallee Poussin','halfwidth',...
    get_option(varargin,'zr_halfwidth',...
    max([1.5*degree,2*getResolution(S3G),2*getResolution(pf(ip))])));
  
  % legendre coefficents
  Al = getA(k); Al(2:2:end) = 0;
  bw = min(200,length(Al));
  Al = Al(1:bw);
    
  % in - nodes to become r
  [in_theta,in_rho] = polar(pf(ip).r);
  in_theta = fft_theta(in_theta);
  in_rho   = fft_rho(in_rho);
  gh = [reshape(in_rho,1,[]);reshape(in_theta,1,[])];
  
  % normalization
  r = gh;
  c = ones(size(pf(ip).data));
  c = reshape(run_linux([mtex_path,'/c/bin/odf2pf'],'EXTERN',gh,r,c,Al),size(c));
    
  % c - coefficients
  delta = get_option(varargin,'zr_delta',0.01,'double');
  bg = get_option(varargin,'zr_bg',delta * max(pf(ip).data(:)));
  if length(bg)>1, bg = bg(ip);end
  c = (get_option(varargin,'zr_factor',10)*(pf(ip).data > bg)-1)./c;

  % approximation grid
  r = S2Grid('regular','resolution',1*degree,'reduced');
  size_r = GridSize(r);
  [r_theta,r_rho] = polar(r);
  r_theta = fft_theta(r_theta);
  r_rho   = fft_rho(r_rho);
  r = [reshape(r_rho,1,[]);reshape(r_theta,1,[])];

  % evaluate zero ranges at approximation grid
  f = run_linux([mtex_path,'/c/bin/odf2pf'],'EXTERN',gh,r,c,Al);
  
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
    ir = 1+round(theta * 4 * (size_r(2)-1))*size_r(1) + ...
      round(rho * size_r(1));
    ir(ir>prod(size_r)) = prod(size_r);
    
    % ignore all orientations that are close to a pole figure value that is
    % zero
    ind(ind) = all(f(ir) >= -0.1,2);
    assert(any(ind),'Zero range methods has canceled out all orientations. Chose better parameters');
  
  end
  fprintf(' - reduction: %d / %d\n',sum(ind),length(ind));
end

NS3G = subGrid(S3G,ind);
