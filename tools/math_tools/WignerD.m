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

psi = get_option(varargin,'kernel',[],'SO3Kernel');
if ~isempty(psi)
    L = psi.bandwidth;
else
    L = 4;
end
L = get_option(varargin,{'L','bandwidth'},L);
l = get_option(varargin,{'order','degree'},0:L);

if isa(ori,'orientation')
    [cs,ss] = deal(ori.CS.properGroup,ori.SS.properGroup);
    Tcs = wignerDmatrixSum(cs.rot,l)./numSym(cs); % cs.WignerD(L)
    Tss = wignerDmatrixSum(ss.rot,l)./numSym(ss); % ss.WignerD(L)
    Psi = wignerDmatrix(ori,l,Tcs,Tss);
else
    Psi = wignerDmatrix(ori,l);
end

if isa(psi,'SO3Kernel')
    % convolve with kernel
    Psi = expandPsi(psi,l).*Psi;
end

if check_option(varargin,{'order','degree'}) && isscalar(l)
    Psi = reshape(Psi,2*l+1,2*l+1,[]);
end

% %% test correctness
% tic
% C1 = Fourier(calcFourier(unimodalODF(ori,psi),'bandwidth',L));
% toc
% norm(sum(Psi./size(Psi,2),2)-C1)
%

end


function J = Jy(L)
v = sqrt(cumsum((L:-1:1)./2));
v = [v fliplr(v)];
J = diag(v,1)+diag(-v,-1);
end

function C = wignerDmatrixSum(q,L)

d = dim(L);
cs = [0 cumsum(d)];
C = zeros(cs(end),1);

[alpha,beta,gamma] = Euler(quaternion(q),'abg');
[ubeta,~,ub] = unique(round(beta*1e12)*1e-12);

for l=1:numel(L)
    m = -L(l):L(l);
    n = 2*L(l)+1;
    sign = L(l)+2:2:n;

    Jalpha = exp(1i*alpha(:)*m);
    Jgamma = exp(1i*m.'*gamma(:).');
    Jalpha(:,sign) = -Jalpha(:,sign);
    Jgamma(sign,:) = -Jgamma(sign,:);

    Jy_l = Jy(L(l));

    ndx = cs(l)+1:cs(l+1);
    for k=1:numel(ubeta)
        Jbeta = expm(-ubeta(k)*Jy_l).*sqrt(n);

        for kk = find(ub(:).'==k)
            A = Jgamma(:,kk).*Jbeta.*Jalpha(kk,:);
            C(ndx) = C(ndx) + A(:);
        end
    end
end

end

function C = wignerDmatrix(q,L,Tcs,Tss)

d = dim(L);
cs = [0 cumsum(d)];
Nc = cs(end);
C = zeros(Nc,length(q));

[alpha,beta,gamma] = Euler(quaternion(q),'abg');
[ubeta,~,ub] = unique(round(beta*1e12)*1e-12);

do_conv = nargin > 3;

for l=1:numel(L)
    m = -L(l):L(l);
    n = 2*L(l)+1;
    sign = L(l)+2:2:n;

    Jalpha = exp(1i*alpha(:)*m);
    Jgamma = exp(1i*m.'*gamma(:).');
    Jalpha(:,sign) = -Jalpha(:,sign);
    Jgamma(sign,:) = -Jgamma(sign,:);

    Jy_l = Jy(L(l));

    ndx = cs(l)+1:cs(l+1);
    if do_conv
        Tc = reshape(Tcs(ndx),n,n);
        Ts = reshape(Tss(ndx),n,n);
    end

    for k=1:numel(ubeta)
        Jbeta = expm(-ubeta(k)*Jy_l)./sqrt(n);

        if do_conv
            % convolve, see also SO3FunHarmonic\conv
            for kk = find(ub==k).'
                % new matlab supports vectorization, othersize kk*o, where o = ones(n,1);
                C(ndx+(kk-1)*Nc) = (Tc * (Jgamma(:,kk).*Jbeta.*Jalpha(kk,:)) * Ts)./n;
            end
        else
            for kk = find(ub==k).'
                C(ndx+(kk-1)*Nc) = Jgamma(:,kk).*Jbeta.*Jalpha(kk,:);
            end
        end
    end
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
% see also deg2dim
d = (2*l+1).^2;
end
