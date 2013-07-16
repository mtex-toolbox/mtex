function f = RK(kk,g,h,r,c,CS,SS,varargin)
% sum Radon trasformed kernel
%
%% Syntax
%  f = RK(kk,g,h,r,c,CS,SS,varargin) - 
%
%% Input
%  kk   - @kernel
%  g    - @quaternion(s)
%  h    - list of crystal directions
%  r    - list of ein specimen directions
%  c    - coefficients
%  CS,SS- crystal, specimen @symmetry
%
%% Options
%  antipodal - antipodal Radon transform $P(h,r) = (\mathcal{R}f(h,r) + \mathcal{R}f(--h,r))/2$
%  BANDWIDTH - bandwidth of ansatz functions
%
%% Output
% matrix - 1. dim --> g, 2.dim --> r
%
%% Remarks
% formulae
% 
% $$ f_j = \sum_i c_i \mathcal{R}K(g_i,h,r_j)$$
%
% $$ \mathcal{R}K((h,r);g) = \sum_l A_l P_l(gh, r)$$
%
%% See also
% kernel/k kernel/rkk

g = quaternion(g);
ng = numel(g);

if length(h)>1 || isa(h,'S2Grid')   % inverse pole figure
	r = r./norm(r);
  in = reshape(inverse(symmetrise(g,CS,SS)).' * r,[ng,length(CS),length(SS)]);
	out = h; lh = length(CS);
else % pole figure
  h = vector3d(h);
	h = reshape(h./norm(h),1,[]);
	[h,lh] = symmetrise(h,CS,varargin{:});
	%lh = length(CS);
	g = reshape(reshape((SS * reshape(g,1,[])).',[],1),[],1);
	in = reshape(g*h,[ng,length(SS),lh]);
	out = r;
end
clear g;


% NFSFT-based algorithm
if check_option(varargin,'fourier') || (numel(in) > 50 && numel(out) > 50 && ~isempty(c) && ...
    ~isempty(getA(kk)) && ~check_option(varargin,'exact'))
		
	% transform in polar coordinates
	[in_theta,in_rho] = polar(in);
	[out_theta,out_rho] = polar(out);
	
	in_theta = fft_theta(in_theta); 
	in_rho   = fft_rho(in_rho);   
	out_theta= fft_theta(out_theta);
	out_rho  = fft_rho(out_rho);  
	
	gh = [reshape(in_rho,1,[]);reshape(in_theta,1,[])];
	r = [reshape(out_rho,1,[]);reshape(out_theta,1,[])];
	
	% extract legendre coefficents
	Al = getA(kk);
	if check_option(varargin,'antipodal'), Al(2:2:end) = 0;end
  bw = get_option(varargin,'bandwidth',length(Al));
  Al = Al(1:min(bw,length(Al)));
  
  f = call_extern('odf2pf','EXTERN',gh,r,c,Al);
	
else % calculate matrix

  out = vector3d(out); out = out./norm(out);
  if numel(in)*numel(out)>50000000
    qwarning(['possible to large Matrix: ',int2str(numel(in)*numel(out))]);
  end
  f = zeros(numel(out),size(in,1));
    
  % take mean along all symmetries
  for is = 1:length(SS)*lh
		dmatrix = dot_outer(out,in(:,is));    
    f = f + kk.RK(dmatrix);
		if check_option(varargin,'antipodal'), f = f + kk.RK(-dmatrix);end		
  end
  
  %dmatrix = reshape(dot_outer(out,in),numel(out),size(in,1),[]);    
  %f = f + sum(kk.RK(dmatrix),3);
  %if check_option(varargin,'antipodal')
  %  f = f + sum(kk.RK(-dmatrix),3);
  %end
	
	if ~isempty(c), f = f * reshape(c,[],1);end
	if check_option(varargin,'antipodal'), f = f/2;end
end
f = f / length(SS) / lh;
