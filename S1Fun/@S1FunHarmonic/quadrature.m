function S1F = quadrature(f,varargin)
%
% Syntax
%   S1F = S1FunHarmonic.quadrature(nodes,values,'weights',w)
%   S1F = S1FunHarmonic.quadrature(f)
%   S1F = S1FunHarmonic.quadrature(f, 'bandwidth', bandwidth)
%
% Input
%  values - double (first dimension has to be the evaluations)
%  nodes - double
%  f - function handle (first dimension has to be the evaluations)
%
% Output
%  S1F - @S1FunHarmonic
%
% Options
%  bandwidth - minimal degree of the complex exponentials
%  S1Grid - quadrature grid
%  weights - quadrature weights


% --------------------- (1) Input is (nodes,values) -----------------------

if isa(f,'double')
  S1F = S1FunHarmonicAdjoint(f,varargin{:});
  return
end

% ---------- (2) Get nodes, values and weights in case of S1Fun -----------

if isa(f,'function_handle')
  f = S1FunHandle(f);
end

bw = get_option(varargin,'bandwidth', min(getMTEXpref('maxS1Bandwidth'),f.bandwidth));

S1G = get_option(varargin,'S1Grid',[]); S1G = S1G(:);
weights = get_option(varargin,'weights',[]); weights = weights(:);
if isempty(S1G)
  % Gaussian Quadrature Grid as default
  N = 2*(bw+1);
  S1G = 2*pi/N*(0:N-1).';
  weights = 1/N;
  varargin = [varargin,'Gaussian'];
elseif isempty(w)
  % use Voronoi volumes as weights
  S1G = sort(S1G);
  dist = (S1G(2:end)-S1G(1:end-1)); 
  distEnd = 2*pi+S1G(1)-S1G(end);
  weights = 0.5*([distEnd;dist]+[dist;distEnd]);
end

values =  f.eval(S1G(:));

% ------------------------ (3) Do adjoint NFFT ----------------------------

S1F = S1FunHarmonic.adjoint(S1G,values,varargin{:},'weights',weights,'bandwidth',bw);


end







function S1F = S1FunHarmonicAdjoint(nodes,values,varargin)
  
N = get_option(varargin,'bandwidth',getMTEXpref('maxS1Bandwidth'));

w = get_option(varargin,'weights',1);
values = w.*values;

plan = nfft(1,2*N+2,length(nodes));
%if check_option(varargin,'antipodal')
%  plan.x = x(:)/pi;
%else
plan.x = nodes(:)/(2*pi);
%end

sz = size(values);
fhat = zeros([2*N+1,sz(2:end)]);

for k=1:prod(sz(2:end))
  plan.f = values(:,k);
  plan.nfft_adjoint;
  fhat(:,k) = plan.fhat(2:end);
end

fhat = reshape(fhat,[2*N+1,sz(2:end)]);
S1F = S1FunHarmonic(fhat,varargin{:});

end