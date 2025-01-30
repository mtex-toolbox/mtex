function Psi = WignerD(ori,varargin)
% Evaluation of Wigner-D functions or Wigner-d functions of specific
% degrees.
%
% Syntax
%   Dl = WignerD(g,l)
%   Dl = WignerD(g,l,'normalize')
%   Dl = WignerD(g,'degree',l)
%   D  = WignerD(g,'bandwidth',l)
%   dl = WignerD(beta,l)
%   dl = WignerD(beta,'degree',l)
%   d  = WignerD(beta,'bandwidth',l)
%
% Input
%  g - @quaternion / @rotation / @orientation / @symmetry
%  beta - second Euler angle
%
% Output
%  Dl - Wigner-D matrix D_l^(m,n) ($(2l+1) \times (2l+1)$)
%  D - all evaluated Wigner-D functions up to bandwidth L ($(l(2*l--1)(2*l+1)/3) \times n$ where n is the number of rotations)
%  dl - Wigner-d matrix d_l^(m,n)
%  d - all evaluated Wigner-d functions up to bandwidth L
%
% Options
%  bandwidth - harmonic degree of series expansion
%  degree    - number or array, single degree reshapes result
%
% Flags
%  normalize - l2 normalized Wigner-D functions (multiply by \sqrt(2n+1))
%
% See also
% sphericalY symmetry/WignerD

if nargin<2
  varargin={2};
end
if isa(varargin{1},'rotation')
  r = varargin{1}; varargin{1} = ori; ori = r;
end
if isa(varargin{1},'double')
  varargin = ['degree',varargin];
end

L = get_option(varargin,'bandwidth',getMTEXpref('maxSO3Bandwidth'));
l = get_option(varargin,{'order','degree'},0:L);

% Wigner-d functions
if isa(ori,'double')
  ori = rotation.byAxisAngle(yvector,ori);
end


if check_option(varargin,'sphericalHarmonics') && isscalar(ori) % define by spherical harmonics

  %  $$ D_n^{k,l}(R) = \int_{S^2} Y_n^k(\xi) \, \overline{Y_n^l(R\cdot\xi)} d{\xi} $$
  Psi = wignerDmatrixSphericalHarm(ori,l,varargin{:});

elseif check_option(varargin,'fastMethod') && isscalar(ori) % use wigner-d recursion
  
  Psi = wignerDmatrixRecursion(ori,l,varargin{:});
  % TODO: wigner trafo trick is not faster

else % use matrix exponential

  Psi = wignerDmatrix(ori,l,varargin{:});

end

% reshape
if check_option(varargin,{'order','degree'}) && isscalar(l)
    Psi = reshape(Psi,2*l+1,2*l+1,[]);
end

end






function Psi = wignerDmatrixSphericalHarm(ori,l,varargin)

res = get_option(varargin,'resolution',1.5*degree);
r = equispacedS2Grid('resolution',res);

Psi = [];

for i=l
  Y1 = sphericalY(i,r);
  Y2 = sphericalY(i,rotation(ori)*r);
  D = Y1.' * conj(Y2)./length(r)*pi*4;
  
  if isa(ori,'orientation')
    [cs,ss] = deal(ori.CS.properGroup,ori.SS.properGroup);
    Tcs = reshape(WignerD(cs,'degree',i),2*i+1,2*i+1);
    Tss = reshape(WignerD(ss,'degree',i),2*i+1,2*i+1);
    D = Tcs * D * Tss /(2*i+1);
  end
  if check_option(varargin,'normalize')
    D = sqrt(2*i+1) * D;
  end
 
  Psi = [Psi;D(:)];
end

end


function Psi = wignerDmatrixRecursion(ori,l,varargin)

Psi=[];
[alpha,beta,gamma] = Euler(ori,'abg');

for i=l
  D = exp(-1i*gamma*(-i:i)') .* Wigner_d_fast(beta,i) .* exp(-1i*alpha*(-i:i));

  if isa(ori,'orientation')
    [cs,ss] = deal(ori.CS.properGroup,ori.SS.properGroup);
    Tcs = reshape(WignerD(cs,'degree',i),2*i+1,2*i+1);
    Tss = reshape(WignerD(ss,'degree',i),2*i+1,2*i+1);
    D = Tcs * D * Tss /(2*i+1);
  end
  if check_option(varargin,'normalize')
    D = sqrt(2*i+1) * D;
  end

  Psi = [Psi;D(:)];
end

end


function C = wignerDmatrix(ori,L,varargin)

if isa(ori,'orientation')
  [cs,ss] = deal(ori.CS.properGroup,ori.SS.properGroup);
  Tcs = WignerD(cs,'degree',L);
  Tss = WignerD(ss,'degree',L);
  do_conv = true;
else
  Tc = 1;
  Ts = 1;
  do_conv = false;
end


d = (2*L+1).^2;
cs = [0 cumsum(d)];
Nc = cs(end);
C = zeros(Nc,length(ori));

[alpha,beta,gamma] = Euler(ori,'abg');
[ubeta,~,ub] = unique(round(beta*1e12)*1e-12);

for l=1:numel(L)
  m = -L(l):L(l);
  n = 2*L(l)+1;
  sign = L(l)+2:2:n;

  Jalpha = exp(-1i*alpha(:)*m);
  Jgamma = exp(-1i*m.'*gamma(:).');
  Jalpha(:,sign) = -Jalpha(:,sign);
  Jgamma(sign,:) = -Jgamma(sign,:);

  v = sqrt(cumsum((L(l):-1:1)./2));
  v = [v fliplr(v)];
  Jy_l = diag(v,1)+diag(-v,-1);

  ndx = cs(l)+1:cs(l+1);
  if do_conv
    Tc = reshape(Tcs(ndx),n,n)/sqrt(2*L(l)+1);
    Ts = reshape(Tss(ndx),n,n)/sqrt(2*L(l)+1);
  end

  if check_option(varargin,'normalize')
    normalize = sqrt(2*L(l)+1);
  else
    normalize=1;
  end

  for k=1:numel(ubeta)
    Jbeta = expm(-ubeta(k)*Jy_l);

    % convolve, see also SO3FunHarmonic\conv
    for kk = find(ub==k).'
      % new matlab supports vectorization, othersize kk*o, where o = ones(n,1);
      C(ndx+(kk-1)*Nc) = normalize*(Tc * (Jgamma(:,kk).*Jbeta.*Jalpha(kk,:)) * Ts);
    end
  end
end

end



function Test

%% Construction of Wigner-d functions
n = 3;
beta = rand;

D = zeros(2*n+1);
for k=-n:n
  for l=-n:n
    a = abs(k-l);
    b = abs(k+l);
    s = n-(a+b)/2;    
    P = jacobiP(s,a,b,cos(beta));
    B = sqrt(nchoosek(2*n-s,s+a)/nchoosek(s+b,b))*((1-cos(beta))/2)^(a/2)*((1+cos(beta))/2)^(b/2)*P;
    ind = min(k,0)+min(l,0) + (k+l)*(l<k);
    D(k+n+1,l+n+1) = (-1)^ind  *B;
  end
end

WignerD(n,beta)-D

%% Wigner-D functions
F = SO3FunHarmonic([zeros(1,9);eye(9)])
reshape(F.eval(rotation.byEuler(pi/5,pi/3,pi/7)),3,3)
sqrt(2*1+1) * WignerD(1,pi/3) .* exp(-1i*(-1:1)*pi/5) .* exp(-1i*(-1:1)'*pi/7)

end