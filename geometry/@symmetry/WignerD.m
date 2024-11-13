function fhat = WignerD(cs,varargin)
% Wigner-D functions w.r.t. symmetry
%
% Syntax
%   D = WignerD(cs,'bandwidth',L)
%   Dl = WignerD(cs,'degree',l)
%
% Input
%  cs - @symmetry
%
% Options
%  bandwidth - harmonic degree of series expansion
%  degree    - number or array, single degree reshapes result
%
% Flags
%  quadrature - use quadrature (nfsoft) based method
%
% See also
% sphericalY WignerD

assert(nargin>2,'Not enough input arguments.')
% if nargin<2
%   varargin={2};
% end
% if isa(varargin{1},'double')
%   varargin = ['degree',varargin];
% end

L = get_option(varargin,'bandwidth',getMTEXpref('maxSO3Bandwidth'));
l = get_option(varargin,{'order','degree'},0:L);
L = max(l);

% check storage
if isfield(cs.opt,'fhat') && length(cs.opt.fhat)>=deg2dim(L+1)

  ind = [];
  for i=l
    ind = [ind,deg2dim(i)+1:deg2dim(i+1)];
  end
  fhat = cs.opt.fhat(ind);
  return

end

% symmetry
CS = cs.properGroup;

if check_option(varargin,'quadrature') % use quadrature

  fhat = wignerDquadrature(CS,L);
  
  fhat(abs(fhat)<1e-5) = 0;
  fhat = sparse(fhat);

  % write to storage
  cs.opt.fhat = fhat;
  
  if length(l)~=L+1 || any(l~=0:L)
    for i=l
      ind = [ind,deg2dim(i)+1:deg2dim(i+1)];
    end
    fhat = fhat(ind);
  end

else % direct computation by matrix exponential
  
  fhat = wignerDmatrixSum(CS.rot,l)./numSym(CS);
  fhat(abs(fhat)<1e-5) = 0;
  fhat = sparse(fhat);

  % write to storage
  if length(l)==L+1 && all(l==0:L)
    cs.opt.fhat = fhat;
  end

end

end


function fhat = wignerDquadrature(CS,L)

c = ones(1,numSym(CS))/numSym(CS);
if L<200
  SO3F = SO3FunHarmonic.quadrature(CS.rot,c,'bandwidth',L,'nfsoft');
else
  ori = orientation(CS.rot,CS);
  SO3F = SO3FunHarmonic.quadrature(ori,c,'bandwidth',L,'directComputation','skipSymmetrise');
end
fhat = SO3F.fhat;

end



function C = wignerDmatrixSum(q,L)

d = (2*L+1).^2;
cs = [0 cumsum(d)];
C = zeros(cs(end),1);

[alpha,beta,gamma] = Euler(q,'abg');
[ubeta,~,ub] = unique(round(beta*1e12)*1e-12);

for l=1:numel(L)
    m = -L(l):L(l);
    n = 2*L(l)+1;
    sign = L(l)+2:2:n;

    Jalpha = exp(1i*alpha(:)*m);
    Jgamma = exp(1i*m.'*gamma(:).');
    Jalpha(:,sign) = -Jalpha(:,sign);
    Jgamma(sign,:) = -Jgamma(sign,:);

    v = sqrt(cumsum((L(l):-1:1)./2));
    v = [v fliplr(v)];
    Jy_l = diag(v,1)+diag(-v,-1);

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
