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

% the angles of the point groups are multiples of pi/2, whose Wigner-d
% matrices are powers of the one at pi/2, all others come from it by
% d(beta) = (-1)^floor((r-c)/2) d(pi/2)' diag(cos(m beta)+sin(m beta)) d(pi/2)
k = round(ubeta/(pi/2));
onGrid = abs(ubeta - k*pi/2) < 1e-10;
dHalf = wignerdHalfPi(max(L));

for l=1:numel(L)
    m = -L(l):L(l);
    n = 2*L(l)+1;
    sign = L(l)+2:2:n;

    Jalpha = exp(1i*alpha(:)*m);
    Jgamma = exp(1i*m.'*gamma(:).');
    Jalpha(:,sign) = -Jalpha(:,sign);
    Jgamma(sign,:) = -Jgamma(sign,:);

    D = dHalf{L(l)+1};
    sgn = (-1).^floor((m.'-m)/2);

    ndx = cs(l)+1:cs(l+1);
    for kb=1:numel(ubeta)
        if onGrid(kb)
          Jbeta = D^k(kb) .* sqrt(n);
        else
          Jbeta = sgn .* (D.' * ((cos(m.'*ubeta(kb))+sin(m.'*ubeta(kb))) .* D)) .* sqrt(n);
        end

        % the rotations with this beta at once: their outer products summed
        kk = ub(:).'==kb;
        A = Jbeta .* (Jgamma(:,kk) * Jalpha(kk,:));
        C(ndx) = C(ndx) + A(:);
    end
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
