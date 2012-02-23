function varargout = calcS2DF(v,varargin)
% calculates a density function out of (weighted) unit vectors
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

hw = get_option(varargin,'halfwidth',10*degree);
psi = get_option(varargin,'kernel',kernel('de la vallee','halfwidth',hw));
c = get_option(varargin,'weights',ones(numel(v),1));
c = c./sum(c);

if nargin > 1 && isa(varargin{1},'vector3d')
  out = varargin{1};
else
  out = S2Grid('plot',varargin{:});
end

%% evaluate density

[in_theta,in_rho] = polar(v);
[out_theta,out_rho] = polar(out);

in_theta = fft_theta(in_theta);
in_rho   = fft_rho(in_rho);
out_theta= fft_theta(out_theta);
out_rho  = fft_rho(out_rho);

gh = [reshape(in_rho,1,[]);reshape(in_theta,1,[])];
r = [reshape(out_rho,1,[]);reshape(out_theta,1,[])];
	
% extract legendre coefficents
Al = getA(psi);
if check_option(varargin,'antipodal'), Al(2:2:end) = 0;end
bw = get_option(varargin,'bandwidth',length(Al));
Al = Al(1:min(bw,length(Al)));
  
Z = call_extern('odf2pf','EXTERN',gh,r,c,Al);

%% collect output

if nargin > 1 && isa(varargin{1},'vector3d')
  varargout{1} = Z;
else
  plot(out,'data',Z,'smooth',varargin{:});
end
