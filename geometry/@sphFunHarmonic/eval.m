function f =  eval(sF,v)
%
% syntax
%  f = eval(sF,v)
%
% Input
%  v - @vector3d interpolation nodes 
%
% Output
%  f - function values

[out_theta,out_rho] = polar(v(:));
out_theta = fft_theta(out_theta); 
out_rho   = fft_rho(out_rho);

r = [reshape(out_rho,1,[]);reshape(out_theta,1,[])];

P_hat = [real(sF.fhat(:)),-imag(sF.fhat(:))].';

f = call_extern('pdf2pf','EXTERN',r,P_hat);

end