function [bandwidth,density,xmesh,cdf] = kde(data,n,MIN,MAX,varargin)
% Reliable and extremely fast kernel density estimator for one-dimensional data;
%        Gaussian kernel is assumed and the bandwidth is chosen automatically;
%        Unlike many other implementations, this one is immune to problems
%        caused by multimodal densities with widely separated modes (see example). The
%        estimation does not deteriorate for multimodal densities, because we never assume
%        a parametric model for the data.
% INPUTS:
%     data    - a vector of data from which the density estimate is constructed;
%          n  - the number of mesh points used in the uniform discretization of the
%               interval [MIN, MAX]; n has to be a power of two; if n is not a power of two, then
%               n is rounded up to the next power of two, i.e., n is set to n=2^ceil(log2(n));
%               the default value of n is n=2^12;
%   MIN, MAX  - defines the interval [MIN,MAX] on which the density estimate is constructed;
%               the default values of MIN and MAX are:
%               MIN=min(data)-Range/10 and MAX=max(data)+Range/10, where Range=max(data)-min(data);
% OUTPUTS:
%   bandwidth - the optimal bandwidth (Gaussian kernel assumed);
%     density - column vector of length 'n' with the values of the density
%               estimate at the grid points;
%     xmesh   - the grid over which the density estimate is computed;
%             - If no output is requested, then the code automatically plots a graph of
%               the density estimate.
%        cdf  - column vector of length 'n' with the values of the cdf
%  Reference:
% Kernel density estimation via diffusion
% Z. I. Botev, J. F. Grotowski, and D. P. Kroese (2010)
% Annals of Statistics, Volume 38, Number 5, pages 2916-2957.

%
%  Example:
%           data=[randn(100,1);randn(100,1)*2+35 ;randn(100,1)+55];
%              kde(data,2^14,min(data)-5,max(data)+5);

data=data(:); %make data a column vector

% if n is not supplied switch to the default
if nargin<2, n=2^14; end
n=2^ceil(log2(n)); % round up n to the next power of 2;

%define the default  interval [MIN,MAX]
if nargin<4 
  minimum=min(data); maximum=max(data);
  Range=maximum-minimum;
  MIN=minimum-Range/2; MAX=maximum+Range/2;
end

% set up the grid over which the density estimate is computed;
R=MAX-MIN; 
dx=R / n; 
edges = MIN+(0:dx:R);
xmesh = (edges(1:end-1) + edges(2:end))./2;
N=length(unique(data));

%bin the data uniformly using the grid defined above;
initial_data = histcounts(data,edges)/N;
initial_data = initial_data/sum(initial_data);
a=dct1d(initial_data); % discrete cosine transform of initial data

if check_option(varargin,'bandwidth')
  t_star = get_option(varargin,'bandwidth');
elseif check_option(varargin,'magicNumber')
  % rule of thumb
  t_star = get_option(varargin,'magicNumber',.28,'double')*N^(2);
else
  % now compute the optimal bandwidth^2 using the referenced method
  I = (1:n).^2; 
      
  % use  fzero to solve the equation t=zeta*gamma^[5](t)
  t_star=root(@(t)fixed_point(t,N,I,a.^2 ./ 4),N);
end

% smooth the discrete cosine transform of initial data using t_star
a_t = a .* exp(-(0:n-1).^2 * pi^2 * t_star/2);

% now apply the inverse discrete cosine transform
density = idct1d(a_t) / R;

% take the rescaling of the data into account
bandwidth = sqrt(t_star) * R;

% remove negatives due to round-off error
density = max(density,eps);

end
%
function  out=fixed_point(t,N,I,a2)
% this implements the function t-zeta*gamma^[l](t)
l=7;
f=2*pi^(2*l)*sum(I.^l .* a2 .* exp(-I*pi^2*t));

for s=l-1:-1:2
  K0=prod([1:2:2*s-1])/sqrt(2*pi);  const=(1+(1/2)^(s+1/2))/3;
  time=(2*const*K0/N/f)^(2/(3+2*s));
  f=2*pi^(2*s) * sum(I.^s.*a2.*exp(-I*pi^2*time));
end
out=t-(2*N*sqrt(pi)*f)^(-2/5);
end



% ##############################################################
function out = idct1d(data)
% computes the inverse discrete cosine transform

n = length(data);
% Compute weights
weights = n * exp(1i*(0:n-1) * pi/(2*n));

% Compute x tilde using equation (5.93) in Jain
data = real(ifft(weights.*data));
% Re-order elements of each column according to equations (5.93) and
% (5.94) in Jain
out = zeros(1,n);
out(1:2:n) = data(1:n/2);
out(2:2:n) = data(n:-1:n/2+1);
%   Reference:
%      A. K. Jain, "Fundamentals of Digital Image
%      Processing", pp. 150-153.
end
% ##############################################################

function data=dct1d(data)
% computes the discrete cosine transform of the column vector data
n = length(data);

% Compute weights to multiply DFT coefficients
weight = [1,2*(exp(-1i*(1:n-1)*pi/(2*n)))];
% Re-order the elements of the columns of x
data = [ data(1:2:end), data(end:-2:2) ];
% Multiply FFT by weights:
data= real(weight.* fft(data));
end

function t=root(f,N)
% try to find smallest root whenever there is more than one
N=50*(N<=50)+1050*(N>=1050)+N*((N<1050)&(N>50));
tol=10^-12+0.01*(N-50)/1000;
flag=0;
while flag==0
    try
        t=fzero(f,[0,tol]);
        flag=1;
    catch
        tol=min(tol*2,.1); % double search interval
    end
    if tol==.1 % if all else fails
        t=fminbnd(@(x)abs(f(x)),0,.1); flag=1;
    end
end
end
