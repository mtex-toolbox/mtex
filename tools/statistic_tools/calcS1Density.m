function S1F = calcS1Density(x,varargin)
% compute periodic density on [0,2 pi] 
%
% Syntax
%
%   S1F = calcS1Density(x) 
%
% Input
%  x - double 
%
% Output
%  S1F - @S1FunHarmonic
%  
% Options
%  halfwidth - width of the kernel function
%  antipodal - ensures f(x+pi) = f(x)
%  even      - ensures f(x) = f(-x)

if ~check_option(varargin,{'sigma','halfwidth'})
  % automatic bandwidth selection
  k = ((280*pi^0.5)/729)^0.2/2/pi;
  s = min(std(x), iqr(x)/1.349);
  sigma = k*s*length(x)^-0.2;
else
  sigma = get_option(varargin,{'sigma','halfwidth'});
end

% compute bandwidth dependent from sigma
N = round(4/sigma);

y = get_option(varargin,'weights',ones(size(x)));
S1F = S1FunHarmonic.quadrature(x,y,'bandwidth',N,varargin{:});

% convolution
S1F.fhat = S1F.fhat .* exp(- 0.5*sigma.^2 * (-N:N).^2).';

% normalize
S1F.fhat = S1F.fhat ./ S1F.fhat(N+1);

% make antipodal if needed
%fun.antipodal = check_option(varargin,'antipodal');


end

function test %#ok<DEFNU>

x = gB.direction.rho; %#ok<NASGU>
norm(gB.direction)


out = linspace(-pi,pi,1000);

plot(out,abs(plan2.f))

%plan.fhat 
figure(2)
histogram(omega)



% make Gaussian kernel
ti = 1:length(Tp);
mu = length(ti)/2 + 1;
G = (exp( -((ti - mu).^2)./ (2*sigma^2) ))';
% convolve kernel with data
pdf = ifft(fft(Tp).*fft(G));
% remove padding
pdf = pdf(tn-t2+1:tn-t2+tn);
% normalize values
pdf = pdf./sum(pdf); %#ok<NASGU>

end