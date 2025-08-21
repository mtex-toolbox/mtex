function A = calcFourier(psi,M,varargin)
% Compute the Chebychev coefficients by gaussian quadrature rule.
%
%
% *Extended explanation of the FFT-Based Quadrature Method:*
%
% Note that an SO3Kernel is a series of Chebychev polynomials of 2nd kind
% with even degree, i.e.
%
% $$  \psi(x) = \sum_{m=0}^M  a_{m} \cdot U_{2m}(x)  $$
%
% for $x\in [-1,1]$. Moreover we have $\psi \in L^2([-1,1],\,\sqrt{1-t^2})$.
% Often we substitute $x=\cos\frac{\theta}{2}$ to obtain a kernel function 
% that depends on the rotational angle $\theta$.
%
% In the following, we will deal not only with even degrees, but also with 
% Chebyshev polynomials with odd degrees. Ultimately, however, the 
% coefficients for the odd degrees will vanish.
% Therefore, for the moment, we will consider series of the form
% 
% $$  \psi(x) = \sum_{m=0}^{M-1}  a_{m} \cdot U_{m}(x).  $$
%
% Since the Chebychev polynomials build an orthogonal basis w.r.t. the 
% above scalar product, we obtain the coefficients $a_m$ for 
% $m=0,\dots,M-1$ using
%
% $$  a_m = \int_{-1}^1 \psi(x) \cdot U_{m}(x) \mathrm{d}x.  $$
%
% Substituting $x=\cos\frac{\theta}{2}$ yields
%
% $$  a_m = \int_0^{2\pi} \psi(\cos\frac{\theta}{2}) \cdot \sin\frac{\theta}{2} \cdot \sin\frac{(m+1)\theta}{2}  $$
%
% since $U_{m}(\cos\frac{\theta}{2}) \, \sin\frac{\theta}{2} = \sin\frac{(m+1)\theta}{2}$.
%
% Note that the gaussian quadrature rule with quadrature weights $\omega_j = \frac{2}{M}$ 
% and quadrature notes $\theta_j = \frac{(2j+1)\pi}{M}$ allows us to 
% exactly integrate
%
% $$  \int_0^{2\pi} \sin\frac{(m+1)\theta}{2} \cdot \sin\frac{(n+1)\theta}{2} \mathrm{d}\theta = \delta_{m,n} $$
%
% for $0 \leq n,m \leq M-1$.
% 
% Hence, if $\psi(x)$ is bandlimited with bandwidth $M-1$, then we can
% compute the coefficients $a_m$ by gaussian quadrature formula, i.e.
%
% $$  a_m =  \sum_{j=0}^{M-1} \left( \frac{2}{M} \cdot \psi(\cos\frac{\theta_j}{2}) \cdot \sin\frac{\theta_j}{2} \right) \cdot \sin\frac{(m+1)\theta_j}{2}.  $$
% 
% We precompute the coefficients $c_j = \sqrt{\frac{2}{M}} \cdot \psi(\cos\frac{\theta_j}{2}) \cdot \sin\frac{\theta_j}{2}$.  
% Then the above linear system reads as 
%
% $$ a_m = \sqrt{\frac{2}{M}} \sum_{j=0}^{M-1} c_j \cdot \sin\frac{(m+1)(2j+1)\pi}{2M},$$
%
% which is the discrete sine transform DST-II. This can be computed
% efficiently by an FFT-based algorithm, see [1].
%
% [1] - G.Plonka, D.Potts, G.Steidl, M.Tasche: Numerical Fourier Analysis, Birkhäuser (Cham), 2018
%
%
% Syntax
%   A = calcFourier(psi,L)
%   A = calcFourier(psi,L,'GaussKronrod')
%   A = calcFourier(psi,L,maxAngle,'GaussKronrod')
%
% Input
%  psi - @SO3Kernel
%  L - bandwidth
%  maxAngle - double
%
% Output
%  A - double (Chebychev coefficient vector)
%
% Option
%  'GaussKronrod' - Use Gauss-Kronrod quadrature
%

M = 2*M+2;

if check_option(varargin,'GaussKronrod')
  A = calcFourierGK(psi,M,varargin);
  return
end

% compute quadrature weights and notes
weights = 2/M;
nodes = (1:2:2*M-1)*pi/(M);

% precompute coefficients for DST-II
c = (sqrt(weights) * psi.eval(cos(nodes/2)) .* sin(nodes/2)).';

% % Direct DST-II
% % Note: With maxAngle we can make the size of S and c smaller.
% S = sqrt(weights) * sin( (1:M-1)'.*(1:2:2*M-1)*pi/(2*M) );
% A = S*c;

% Fast DST (transform and expand coefficient vector -> FFT -> transform and cut coefficent vector)
y = [- c .* exp(-pi*1i*(0:M-1)'/M) ; flip(c) .* exp(-pi*1i*(M:2*M-1)'/M) ];
yhat = fft(y);
A = 1/sqrt(2*M) * real(-1i* exp(-pi*1i*(1:M)'/(2*M)) .* yhat(1:M));

% Omit every second coefficient, since we only need the Chebyshev 
% coefficients with even degrees (the others are 0 for symmetry reasons).
A = A(1:2:end);

end




function A = calcFourierGK(psi,L,varargin)

if isnumeric(varargin{1})
  maxAngle = varargin{1};
else
  maxAngle = pi;
end

epsilon = getMTEXpref('FFTAccuracy',1E-2);
small = 0;
warning off;

for l = 0:L
  fun = @(omega) psi.eval(cos(omega/2)).*sin((2*l+1)*omega./2).*sin(omega./2);
  A(l+1) = 2/pi*quadgk(fun ,0,maxAngle,'MaxIntervalCount',2000); %#ok<AGROW>

  if abs(A(l+1)) < epsilon
    small = small + 1;
  else
    small = 0;
  end

  if small == 10, break;end
end

end