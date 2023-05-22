function y = eval(S1F,x,varargin)


plan = nfft(1,length(S1F.fhat),length(x));
if check_option(varargin,'antipodal')
  plan.x = x(:)/pi;
else
  plan.x = x(:)/2/pi;
end
plan.fhat = S1F.fhat;

plan.nfft_trafo;

y = plan.f;

if isalmostreal(y), y = real(y); end

end