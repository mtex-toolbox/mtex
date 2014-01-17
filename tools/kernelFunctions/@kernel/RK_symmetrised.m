function M = RK_symmetrised(psi,g,h,r,c,CS,SS,varargin)
% sum Radon trasformed kernel
%
% Syntax
%   f = RK_symmetrised(psi,g,h,r,c,CS,SS,varargin) - 
%
% Input
%  psi   - @kernel
%  g    - @quaternion(s)
%  h    - list of crystal directions
%  r    - list of ein specimen directions
%  c    - coefficients
%  CS,SS- crystal, specimen @symmetry
%
% Options
%  antipodal - antipodal Radon transform $P(h,r) = (\mathcal{R}f(h,r) + \mathcal{R}f(--h,r))/2$
%  BANDWIDTH - bandwidth of ansatz functions
%
% Output
%  matrix - 1. dim --> g, 2.dim --> r
%
% Description
% formulae
% 
% $$ f_j = \sum_i c_i \mathcal{R}K(g_i,h,r_j)$$
%
% $$ \mathcal{R}K((h,r);g) = \sum_l A_l P_l(gh, r)$$
%
% See also
% kernel/k kernel/rkk


if length(h)==1                        % pole figure
  
  [h,lh] = symmetrise(h,varargin{:});
  in = reshape((SS * g).' * h, [length(g),length(SS),lh]);
	out = r;

else                                   % inverse pole figure
  
  in = reshape(inv(symmetrise(g)).' * r, ...
    [length(g),length(CS),length(SS)]);
  out = h; 
  lh = length(CS);
  
end

% NFSFT-based algorithm
if check_option(varargin,'fourier') || (length(in) > 50 && length(out) > 50 && ~isempty(c) && ...
    ~isempty(psi.A) && ~check_option(varargin,'exact'))
		
  % transform in polar coordinates
  in_theta = fft_theta(in.theta);
	in_rho   = fft_rho(in.rho);   
	out_theta= fft_theta(out.theta);
	out_rho  = fft_rho(out.rho);  
	
	gh = [in_rho(:),in_theta(:)].';
	r = [out_rho(:),out_theta(:)].';
	
	% extract legendre coefficents
	Al = psi.A;
	if check_option(varargin,'antipodal'), Al(2:2:end) = 0;end
  bw = get_option(varargin,'bandwidth',length(Al));
  Al = Al(1:min(bw,length(Al)));
  
  M = call_extern('odf2pf','EXTERN',gh,r,c,Al);
	
else % calculate matrix

  if length(in)*length(out)>50000000
    qwarning(['possible to large Matrix: ',int2str(length(in)*length(out))]);
  end
  M = zeros(length(out),size(in,1));
    
  % take mean along all symmetries
  for is = 1:length(SS)*lh
		dmatrix = dot_outer(out.normalize,in(:,is).normalize);
    M = M + psi.RK(dmatrix);
		if check_option(varargin,'antipodal'), M = M + psi.RK(-dmatrix);end		
  end

	if ~isempty(c), M = M * c(:); end
	if check_option(varargin,'antipodal'), M = M/2;end
end
M = M / length(SS) / lh;
