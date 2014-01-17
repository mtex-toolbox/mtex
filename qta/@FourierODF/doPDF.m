function Z = doPDF(odf,h,r,varargin)
% calculate pole figure from Fourier coefficients

% use only even Fourier coefficients?
even = 1 + (check_option(varargin,'antipodal') || r.antipodal);

if length(h) == 1  % pole figures
  in = h;
  out = r;
elseif length(r) == 1 % inverse pole figures
  out = h;
  in = r;
else
  error('Either h or r should be a single direction!');
end

% calculate Fourier coefficients of the pole figure
[in_theta,in_rho] = polar(in(:));

% bandwidth
L = get_option(varargin,'bandwidth',bandwidth(odf));
L = min(L,bandwidth(odf));

ipdf_hat = cumsum([0,2*(0:L)+1]);

for l = 0:even:L
  if length(h) == 1  % pole figures
    P_hat(1+ipdf_hat(l+1):ipdf_hat(l+2)) = reshape(...
      odf.f_hat(1+deg2dim(l):deg2dim(l+1)),2*l+1,2*l+1) ./sqrt(2*l+1) ...
      * 2*sqrt(pi)*sphericalY(l,in_theta,in_rho).';
  else               % inverse pole figures
    P_hat(1+ipdf_hat(l+1):ipdf_hat(l+2)) = reshape(...
      odf.f_hat(1+deg2dim(l):deg2dim(l+1)),2*l+1,2*l+1)' ./sqrt(2*l+1) ...
      * 2*sqrt(pi)*sphericalY(l,in_theta,in_rho).';
  end
end

% evaluate Fourier coefficients
[out_theta,out_rho] = polar(out(:));
out_theta = fft_theta(out_theta); 
out_rho   = fft_rho(out_rho); 
r = [reshape(out_rho,1,[]);reshape(out_theta,1,[])];

P_hat = [real(P_hat(:)),-imag(P_hat(:))].';

Z = call_extern('pdf2pf','EXTERN',r,P_hat);
