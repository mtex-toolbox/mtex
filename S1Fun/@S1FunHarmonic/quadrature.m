function S1F = quadrature(x,y,varargin)

N = get_option(varargin,'bandwidth',128);

plan = nfft(1,2*N+2,length(x));
%if check_option(varargin,'antipodal')
%  plan.x = x(:)/pi;
%else
  plan.x = x(:)/2/pi;
%end
plan.f = y(:);

plan.nfft_adjoint;

S1F = S1FunHarmonic(plan.fhat,varargin{:});

S1F.antipodal = check_option(varargin,'antipodal');

end