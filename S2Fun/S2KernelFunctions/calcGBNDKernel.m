function [Psi,psi] = calcGBNDKernel(varargin)
% optimal kernel function for GBND estimation
%
% Syntax
%   [Psi,psi] = calcGBNDKernel('halfwidth',10*degree)
%
% Output
%  Psi - @S1Kernel
%  psi - @S2FunHarmonic
%
% Options
%  halfwidth - 
%  nonneg    - nonnegativ kernel 
%  bump      - bump kernel
%

% extract halfwidth
if nargin > 0 && isnumeric(varargin{1})
  hw = varargin{1};
else
  hw = get_option(varargin,'halfwidth',10*degree);
end

if check_option(varargin,"nonneg")
  
  gd = @(t,sigma) 1/sqrt(2*pi)/sigma .* exp(-1/2* (t/sigma).^2) / 0.5437;
  
  s = cos(pi/2-hw);
  Psi = S2KernelHandle(@(t) 2*(gd(t,s)));
  
elseif check_option(varargin,"bump")

  Psi = S2KernelHandle(@(t) (abs(t) < asin(hw)));
  fak = Psi.A(1) * 0.5437;
  Psi = S2KernelHandle(@(t) (abs(t) < asin(hw)) / fak);
  
else % we define the kernel by inverting the integral equation

  % extract the target kernel
  if nargin > 0 && isa(varargin{1},"S2Kernel")
    Kappa = varargin{1};
  else
    Kappa = S2DeLaValleePoussinKernel('halfwidth',hw);
  end

  % discretization at chebyshev nodes
  N = 1000;                         % # unknowns (Chebyshev nodes in t)
  [t,~] = chebpts(N,[0 1]);         % t-grid for unknown f(u) and data g(t)
  u = t;                            % same grid for u

  % --- barycentric weights (Cheb2) & helper for interpolation rows
  wbar = baryWeightsCheb2(N);
  baryRow = @(y) baryRowCheb2(y, u, wbar);

  % --- Gauss–Legendre in theta on [0,pi/2]
  nTheta = 120;
  [theta, wth] = legpts(nTheta, [0 pi/2]);   % Gauss–Legendre nodes/weights

  % --- kernel k(theta,t) = I01(a,b) (vectorized); uses m=b/a and the m<0 map
  k_theta_t = @(th,tv) I01_point( 1 - tv.^2 + tv.^2.*sin(th).^2, ...
    1 - 2*tv.^2 + tv.^2.*sin(th).^2 );

  % --- assemble Nyström matrix A so that g ≈ A*fvals
  A = zeros(N,N);
  for i = 1:N

    ti = t(i);
    ue = ti.*sin(theta);                   % eval locations for f
    ke = k_theta_t(theta, ti);             % k(θ, t_i)
    row = zeros(1,N);
    for ell = 1:nTheta
      v = baryRow(ue(ell));                % length-N interpolation row
      row = row + 4 * ke(ell) * wth(ell) * v;
    end
    A(i,:) = row;
  end

  g_vals = Kappa.eval(sqrt(1-t.^2));

  % inverse transform
  f_rec_vals = A \ g_vals;

  f_rec  = chebfun.interp1(u, f_rec_vals / 0.32,  [0 1]);

  F_even = chebfun(@(x) f_rec(abs(x)), [-1 1], 'vectorize', 'splitting','on'); % even extension
  
  N = 128;
  c_leg  = legcoeffs(F_even, N);               % Legendre coeffs on [-1,1]
  c_leg(2:2:end) = 0;

  Psi = S2Kernel(c_leg);
end

% normalization
Psi = (pi / 2 / integral(@(t) I(t,Psi),0,1)) * Psi;

if nargout>1

  if check_option(varargin,'directional')
    s = @(omega) sin(omega) .* (omega > 0) .* (omega<=pi);

    psi = S2FunHandle(@(v) Psi.eval(v) .* ...
      s(angle(v,xvector,zvector)));
  else
    psi = S2FunHandle(@(v) Psi.eval(v) .* sin(angle(v,xvector)));    
  end

  if check_option(varargin,'harmonic')
    bw = 62;%min(getMTEXpref('maxS2Bandwidth'),psi.bandwidth);
    psi = S2FunHarmonic.quadrature(psi,'bandwidth', bw,'antipodal');
  end

end

end

%%

% === helpers ===
function [K,E] = ellipKE_param(m)

K = zeros(size(m)); E = K;
mask0 = (m>=0 & m<=1);                      % MATLAB numeric ellipke domain
if any(mask0), [K(mask0),E(mask0)] = ellipke(m(mask0)); end
maskN = (m<0);                              % imaginary-modulus map (DLMF §19.7)
if any(maskN)
  mu = m(maskN)./(m(maskN)-1);
  [Kmu,Emu] = ellipke(mu);
  fac = sqrt(1 - m(maskN));
  K(maskN) = Kmu ./ fac;                  % K(m)=K(μ)/√(1-m)
  E(maskN) = Emu .* fac;                  % E(m)=√(1-m) E(μ)
end
if any(m>1), error('Encountered m>1; ensure T ≤ 1.'); end

end

function val = I01_point(a,b)

m = b./a;  [K,E] = ellipKE_param(m);
val = sqrt(a) .* ((m+1).*E + (m-1).*K) ./ (3*m);      % stable combo
small = abs(m) < 1e-12; if any(small), val(small) = sqrt(a(small))*(pi/4); end
one = (m==1);        if any(one),   val(one)   = (2/3)*sqrt(a(one)); end

end

function w = baryWeightsCheb2(N)
k = 0:N-1; w = (-1).^k; w(1)=w(1)/2; w(end)=w(end)/2;
end

function v = baryRowCheb2(y, x, w)
d = y - x(:).'; idx = find(abs(d) < 1e-14, 1);
if ~isempty(idx), v = zeros(1,length(x)); v(idx)=1; return, end
tmp = w ./ d; v = tmp / sum(tmp);
end


function v = I(t,psi)

[~,e] = ellip2ke(1-t.^2);
v = psi.eval(t).*e;

end
