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
%


% --------------------- (1) Input is (nodes,values) -----------------------

if isa(f,'double')
  S1F = S1FunHarmonicAdjoint(f,varargin{:});
  return
end

% ------------------------- (2) Input is S1Fun ----------------------------

if isa(f,'S1Fun')
  g = @(x) f.eval(x);
  S1F = S1FunHarmonic.quadrature(g,'bandwidth',f.bandwidth,varargin{:});
  return
end

% ------ (3) Get nodes, values and weights in case of function handle -----

M = get_option(varargin,'bandwidth',getMTEXpref('maxS1Bandwidth'));
N = 2*(M+1);

x = 2*pi/N*(0:N-1).';
y =  f(x(:));

% S1F = S1FunHarmonicAdjoint(x,y,varargin{:},'weights',1/N,'bandwidth',N);
fhat = fftshift(ifft(y),1);
fhat(1,:) = [];
S1F = S1FunHarmonic(fhat);

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