function Z = fourier2pdf(odf,h,r,varargin)
% calculate pole figure from Fourier coefficients

%% get input
h = vector3d(h);
r = vector3d(r);
if length(h) == 1
  in = h;
  out = r;
elseif length(r) == 1
  out = h;
  in = r;
else
  error('Either h or r should be a single direction!');
end


%% calculate Fourier coefficients of the pole figure

% 
[in_theta,in_rho] = vec2sph(in(:));

% bandwidth
L = get_option(varargin,'bandwidth',bandwidth(odf));
L = min(L,bandwidth(odf));

ipdf_hat = cumsum([0,2*(0:L)+1]);
for l = 0:L
 
  P_hat(1+ipdf_hat(l+1):ipdf_hat(l+2)) = reshape(...
    odf.c_hat(1+deg2dim(l):deg2dim(l+1)),2*l+1,2*l+1) ./sqrt(2*l+1) ...
    * 2*sqrt(pi)*sphericalY(l,in_theta,in_rho).';
    
end

%% evaluate Fourier coefficients

[out_theta,out_rho] = vec2sph(out(:));
out_theta = fft_theta(out_theta); 
out_rho   = fft_rho(out_rho); 
r = [reshape(out_rho,1,[]);reshape(out_theta,1,[])];

P_hat = [real(P_hat(:)),-imag(P_hat(:))].';
%P_hat = ones(size(P_hat));

Z = call_extern([mtex_path,'/c/bin/pdf2pf'],'EXTERN',r,P_hat);
