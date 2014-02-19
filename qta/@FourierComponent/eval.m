function f = eval(odf,ori,varargin)
% evaluate odf using NSOFT
%
% Input
%  odf - @ODF
%  ori - @orientation
% 
% Output
%  f - double
%

if isempty(ori), f = []; return; end

% set parameter
L = dim2deg(length(odf.f_hat));
L = int32(min(L,get_option(varargin,'bandwidth',L)));
Ldim = deg2dim(double(L+1));

% export to Euler angle
g = Euler(ori,'nfft');
	
f_hat = [real(odf.f_hat(1:Ldim)),imag(odf.f_hat(1:Ldim))].';

% run NFSOFT
f = call_extern('fc2odf','intern',L,'EXTERN',g,f_hat);
