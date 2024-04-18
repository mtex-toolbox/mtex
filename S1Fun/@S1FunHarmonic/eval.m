function y = eval(S1F,x,varargin)

% make fhat even for nfft
fhat = [zeros([1,size(S1F)]) ; S1F.fhat];

sz = size(x);
x = x(:);

plan = nfft(1,length(fhat),length(x));
if check_option(varargin,'antipodal')
  plan.x = x(:)/pi;
else
  plan.x = x(:)/2/pi;
end

fhat = fhat(:,:);
y = zeros(length(x),length(S1F));
for k=1:numel(S1F)
  plan.fhat = fhat(:,k);
  plan.nfft_trafo;
  y(:,k) = plan.f;
end

if isscalar(S1F)
  y = reshape(y,sz);
end

if isalmostreal(y), y = real(y); end

end