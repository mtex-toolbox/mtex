function varargout = calcS2DF(v,varargin)
% calculates a densty function out of (weighted) unit vectors
%
% Input
% v - @vector3d
%
%% Options
% halfwidth - halfwidth of a kernel
% kernel    - specifies a kernel
% weights   - vector of weights, with same length as v
%
%% parse some input 

hw = get_option(varargin,'halfwidth',5*degree);
psi = get_option(varargin,'kernel',kernel('de la vallee','halfwidth',hw));
w = get_option(varargin,'weights',ones(numel(v),1));
w = w./sum(w);

if nargin > 1 && isa(varargin{1},'vector3d')
  out = varargin{1};
else
  out = S2Grid('plot',varargin{:});
end

%% calculate some fourier coefficients

A = getA(psi);
L = numel(A);
deg2dim = @(l) (l).^2;

n = numel(v);
p = zeros(1,deg2dim(L));

[theta,rho] = polar(v(:));
for l=0:L-1
  lhat = sphericalY(l,theta,rho).';  
  p(deg2dim(l)+1:deg2dim(l+1)) =  pi*sqrt(2)*A(l+1)/sqrt(2*l+1)*lhat*w(:);
end
P_hat = [real(p(:)),-imag(p(:))].';

%%

[out_theta,out_rho] = polar(out(:));
out_theta = fft_theta(out_theta);
out_rho   = fft_rho(out_rho);
r = [out_rho(:) out_theta(:)].';

%% eval density

Z = call_extern('pdf2pf','EXTERN',r,P_hat);
% Z(Z<0) =  0;

if nargin > 1 && isa(varargin{1},'vector3d')
  varargout{1} = Z;
else
  plot(out,'data',Z,'smooth',varargin{:});
end
