function Psi = WignerD(ori,varargin)
% Wigner-D function
%
% Syntax
%
%   Dl = WignerD(g,'degree',l)
%   D  = WignerD(g,'bandwidth',l)
%   D  = W
%
% Input
%  g - @quaternion / @rotation / @orientation / @symmetry
%
% Options
%  bandwidth - harmonic degree of series expansion
%  degree    - number or array, single degree reshapes result
%  kernel    - multiply wigner coefficients by kernel 
%
% Output
%  Dl - $(2l+1) \times (2l+1)$
%  D  - $(l(2*l--1)(2*l+1)/3) \times n$ where n is the number of rotations
%
% See also
% sphericalY

psi = get_option(varargin,'kernel',[],'kernel');
if ~isempty(psi)
  L = psi.bandwidth;
else
  L = 4;
end
L = get_option(varargin,{'L','bandwidth'},L);
l = get_option(varargin,{'order','degree'},0:L);

if isa(ori,'orientation')
  N = numSym(ori.CS) * numSym(ori.SS);
  
  Tcs = wignerDmatrixSum(ori.CS,l);
  Tss = wignerDmatrixSum(ori.SS,l);
  Psi = wignerDmatrix(ori,l,Tcs,Tss);
else
  N = 1; % normalization 
  
  Psi = wignerDmatrix(ori,l);  
end

if isa(psi,'kernel')
  Psi = bsxfun(@times,expandPsi(psi,l)./N,Psi);
else
  Psi = Psi./N;
end

if check_option(varargin,{'order','degree'}) && numel(l) == 1  
  Psi = reshape(Psi,2*l+1,2*l+1,[]);
end

% %% test correctness
% tic 
% C1 = Fourier(calcFourier(unimodalODF(ori,psi),L));
% toc
% norm(sum(Psi./size(Psi,2),2)-C1)
%

end


function J = Jy(L)
%v = sqrt(cumsum(2*(L:-1:1)))/2;
v = sqrt(cumsum((L:-1:1)./2));
v = [v fliplr(v)];
J = diag(v,1)+diag(-v,-1);
end
% function dmm = wignerd_mm(L,beta)
% dmm = expm(beta*Jy(L));
% end

function C = wignerDmatrixSum(q,L)

d = dim(L);
cs = [0 cumsum(d)];
C = zeros(cs(end),1);
 
[alpha,beta,gamma] = Euler(quaternion(q),'abg');
[ubeta,~,ub] = unique(round(beta*1e12)*1e-12);

for l=1:numel(L)
  m = -L(l):L(l);
  sign = L(l)+2:2:2*L(l)+1;
  Jalpha = exp(1i*m.'*alpha(:).');
  Jgamma = exp(1i*gamma(:)*m);
%   Jalpha
  Jalpha(sign,:) = -Jalpha(sign,:);
  Jgamma(:,sign) = -Jgamma(:,sign);
  
  Jy_l = Jy(L(l));
  
  ndx = cs(l)+1:cs(l+1);
  o = ones(2*L(l)+1,1);
  for k=1:numel(ubeta)
    Jbeta = expm(ubeta(k)*Jy_l);
    
    for kk = find(ub(:).'==k)
      A = Jalpha(:,kk*o).*Jbeta.*Jgamma(kk*o,:);
      C(ndx) = C(ndx) + A(:);
    end
  end
end
end


function C = wignerDmatrix(q,L,Tcs,Tss)

d = dim(L);
cs = [0 cumsum(d)];
Nc = cs(end);
C = zeros(Nc,numel(q));

[alpha,beta,gamma] = Euler(quaternion(q),'abg');

[ubeta,~,ub] = unique(round(beta*1e12)*1e-12);

for l=1:numel(L)
  m = -L(l):L(l);
  ll = 2*L(l)+1;
  sign = L(l)+2:2:ll;

  Jalpha = exp(1i*m.'*alpha(:).');
  Jgamma = exp(1i*gamma(:)*m);
  Jalpha(sign,:) = -Jalpha(sign,:);
  Jgamma(:,sign) = -Jgamma(:,sign);
  
  Jy_l = Jy(L(l));
  
  ndx = cs(l)+1:cs(l+1);  
  o = ones(2*L(l)+1,1);
  for k=1:numel(ubeta)
    Jbeta = expm(ubeta(k)*Jy_l);
    
    if nargin>3
      Tc = reshape(Tcs(ndx),ll,ll);
      Ts = reshape(Tss(ndx),ll,ll);
      for kk = find(ub(:).'==k)
        C(ndx+(kk-1)*Nc) = Ts * (Jalpha(:,kk*o).*Jbeta.*Jgamma(kk*o,:)) * Tc;
      end
    else
      for kk = find(ub(:).'==k)
        C(ndx+(kk-1)*Nc) = Jalpha(:,kk*o).*Jbeta.*Jgamma(kk*o,:);
      end
    end
  end
  
%   for k = 1:numel(alpha)
%     dmm = wignerd_mm(l,beta(k));
%     A = Jalpha(:,k*o).*Jbeta.*Jgamma(k*o,:);
%     C(deg2dim(l)+1:deg2dim(l+1),k) = A(:);
%   end
end
end


function Ahat = expandPsi(psi,L)

d = dim(L);
cs = [0 cumsum(d)];

Ahat = zeros(cs(end),1);
A = zeros(1,max(L)+1);
A(1:psi.bandwidth+1) = psi.A;
for l=1:numel(L)
  Ahat(cs(l)+1:cs(l+1)) = A(L(l)+1);
end
end

function d = dim(l)
  d = (2*l+1).^2;
end
