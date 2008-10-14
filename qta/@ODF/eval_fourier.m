function f = eval_fourier(odf,g,varargin)
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
L = dim2deg(length(odf.c_hat));
L = int32(min(L,get_option(varargin,'bandwidth',L)));
Ldim = deg2dim(double(L+1));

s = size(g);
% export to Euler angle
g = quat2euler(g,'nfft');
	
f_hat = [real(odf.c_hat(1:Ldim)),imag(odf.c_hat(1:Ldim))].';

% run NFSOFT
f = reshape(call_extern([mtex_path,'/c/bin/fc2odf'],'intern',L,'EXTERN',g,f_hat),...
  s);
    
