function f = doEval(odf,g,varargin)
% evaluate odf using NSOFT
%
%% Input
%  odf - @ODF
%  g   - @quaternion
% 
%% Output
%  f - double
%

% set parameter
L = dim2deg(length(odf.f_hat));
L = int32(min(L,get_option(varargin,'bandwidth',L)));
Ldim = deg2dim(double(L+1));

% export to Euler angle
g = Euler(g,'nfft');
	
f_hat = [real(odf.f_hat(1:Ldim)),imag(odf.f_hat(1:Ldim))].';

% run NFSOFT
f = call_extern('fc2odf','intern',L,'EXTERN',g,f_hat);
    
