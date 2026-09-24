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
%  rotations - average these rotations instead of the proper group
%
% Flags
%  quadrature - use quadrature (nfsoft) based method
%
% See also
% sphericalY WignerD

assert(nargin>2,'Not enough input arguments.')
persistent store
% if nargin<2
%   varargin={2};
% end
% if isa(varargin{1},'double')
%   varargin = ['degree',varargin];
% end

L = get_option(varargin,'bandwidth',getMTEXpref('maxSO3Bandwidth'));
l = get_option(varargin,{'order','degree'},0:L);
L = max(l);

% the rotations whose Wigner-D matrices are averaged, by default those of
% the proper group
rot = get_option(varargin,'rotations',[]);
own = isempty(rot);
if own, rot = cs.properGroup.rot; end

% check storage
if own && isfield(cs.opt,'fhat') && length(cs.opt.fhat)>=deg2dim(L+1)
  fhat = degrees(cs.opt.fhat,l);
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
  
  fhat = degrees(fhat,l);

else % direct computation

  % symmetry objects are created anew all the time, so the sums are also
  % stored by the rotations of the group
  if isempty(store), store = containers.Map; end
  key = groupKey(rot);
  if isKey(store,key) && length(store(key)) >= deg2dim(L+1)
    fhat = store(key);
  else
    fhat = wignerDmatrixSum(rot,0:L)./length(rot);
    fhat(abs(fhat)<1e-12) = 0;
    fhat = sparse(fhat);
    if store.Count >= 32, remove(store,keys(store)); end
    store(key) = fhat;
  end

  % write to storage
  if own, cs.opt.fhat = fhat; end
  fhat = degrees(fhat,l);

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
% sum of the L2-normalized Wigner-D matrices of the rotations q for the degrees L

d = (2*L+1).^2;
cs = [0 cumsum(d)];
C = zeros(cs(end),1);

[alpha,beta,gamma] = Euler(q,'abg');
[ubeta,~,ub] = unique(round(beta*1e12)*1e-12);

% the angles of the point groups are multiples of pi/2, for which the
% Wigner-d matrices come exactly from the recursion at pi/2
k = round(ubeta/(pi/2));
onGrid = abs(ubeta - k*pi/2) < 1e-10;
if any(onGrid), dHalf = wignerdHalfPi(max(L)); end

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
    for kb=1:numel(ubeta)
        if onGrid(kb)
          Jbeta = dHalf{L(l)+1}^k(kb) .* sqrt(n);
        else
          Jbeta = expm(-ubeta(kb)*Jy_l).*sqrt(n);
        end

        % the rotations with this beta at once: their outer products summed
        kk = ub(:).'==kb;
        A = Jbeta .* (Jgamma(:,kk) * Jalpha(kk,:));
        C(ndx) = C(ndx) + A(:);
    end
end

end


function d = wignerdHalfPi(L)
% the Wigner-d matrices expm(-pi/2*Jy_l) of the degrees l = 0..L from the
% three term recursion of the quadrant S(a,b) = d_l(-a,-b), a,b >= 0, see
% SO3Fun/@SO3FunHarmonic/private/wigner_d_quadrant_at_pi_half.cpp

Q = cell(1,L+1);
Q{1} = 1;
if L >= 1, Q{2} = [0, sqrt(0.5); -sqrt(0.5), 0.5]; end
for l = 2:L
  a = (0:l-1).';
  inv = 1./(l^2 - a.^2);
  p = -a.*sqrt(inv);
  q = sqrt(((l-1)^2 - a.^2).*inv);
  S1 = Q{l}(1:l,1:l);
  S2 = zeros(l); S2(1:l-1,1:l-1) = Q{l-1};
  S = zeros(l+1);
  S(1:l,1:l) = (-(2*l-1)/(l-1))*(p*p.').*S1 + (-l/(l-1))*(q*q.').*S2;
  % frame: column l is sqrt(binom(2l,l-a)) 2^-l, kept as mantissa and exponent
  S(l+1,l+1) = pow2(1,-l);
  mant = 1; ex = 0;
  for it = 1:l
    [mant,e] = log2(mant*sqrt((2*l+1-it)/it));
    ex = ex + e;
    S(l+1-it,l+1) = pow2(mant,ex-l);
  end
  S(l+1,1:l) = (1-2*mod(l+(0:l-1),2)) .* S(1:l,l+1).';
  Q{l+1} = S;
end

% the whole matrix from d(-r,c) = (-1)^(l+r+c) d(r,c) in both indices, and
% the sign (-1)^x of every positive row and column index x of expm(-pi/2*Jy_l)
d = cell(1,L+1);
for l = 0:L
  r = (-l:l).'; c = -l:l;
  D = zeros(2*l+1);
  D(1:l+1,1:l+1) = rot90(Q{l+1},2);
  D(l+2:end,1:l+1) = (1-2*mod(l+r(l+2:end)+c(1:l+1),2)) .* D(l:-1:1,1:l+1);
  D(:,l+2:end) = (1-2*mod(l+r+c(l+2:end),2)) .* D(:,l:-1:1);
  sigma = 1 - 2*(r > 0 & mod(r,2)==1);
  d{l+1} = (sigma*sigma.') .* D;
end

end


function key = groupKey(rot)
% the rotations as a string, independent of their order and of the sign of
% the quaternions

Q = [rot.a(:) rot.b(:) rot.c(:) rot.d(:)];
[~,j] = max(abs(Q) > 1e-9,[],2);
Q = Q .* sign(Q(sub2ind(size(Q),(1:size(Q,1))',j)));
key = sprintf('%d,',sortrows(round(Q*1e9)));

end


function fhat = degrees(fhat,l)
% the coefficients of the degrees l, a leading block 0:L without indexing

if isequal(l(:)',0:max(l))
  fhat = fhat(1:deg2dim(max(l)+1));
else
  fhat = fhat(cell2mat(arrayfun(@(i) deg2dim(i)+1:deg2dim(i+1),l(:)','UniformOutput',false)));
end

end
