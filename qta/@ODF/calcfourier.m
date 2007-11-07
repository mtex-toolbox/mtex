function nodf = calcfourier(odf,L)
% compute Fourier coefficients of odf
%
% Compute the Fourier coefficients of the ODF and store them in the
% returned ODF. In order to get the Fourier coefficients of an ODF use
% [[ODF_fourier.html,fourier]].
%
%% usage:  
% nodf = fourier(odf,L)
%
%% Input
%  odf  - @ODF
%  L    - order up to which Fourier coefficients are calculated
%
%% Output
%  nodf - @ODF where Fourier coefficients are stored for further use 
%
%% See also
% ODF/fourier ODF/textureindex ODF/entropy ODF/eval
%

error(nargchk(2, 2, nargin))

global mtex_path;

for i = 1:length(odf)
  
  % no precomputation
  if check_option(odf(i),'UNIFORM') || ...
      dim2deg(length(odf(i).c_hat)) <= min(L,length(getA(odf(i).psi))-1) 
    
    if check_option(odf(i),'UNIFORM') % **** uniform portion *****
    
      odf(i).c_hat = odf(i).c;
    
    elseif check_option(odf(i),'FIBRE') % ***** fibre symmetric portion *****
    
      A = getA(odf(i).psi);
            
      % symmetrize
      h = odf(i).CS * vector3d(odf(i).center{1});
      h = repmat(h,1,length(odf(i).SS));
      r = odf(i).SS * odf(i).center{2};
      r = repmat(r,length(odf(i).CS),1);
      [theta_h,rho_h] = vec2sph(h(:));
      [theta_r,rho_r] = vec2sph(r(:));
    
      for l = 0:min(L,length(A)-1)
        hat = odf(i).c * 4*pi / (2*l+1) * A(l+1) *...
          sphericalY(l,theta_h,rho_h).' * conj(sphericalY(l,theta_r,rho_r));
        
        hat = hat';
        
        odf(i).c_hat(deg2dim(l)+1:deg2dim(l+1)) = hat(:) / ...
          length(odf(i).CS) / length(odf(i).SS);
              
      end
        
    else                           % **** radially symmetric portion ****

      % export center in Euler angle
      g = odf(i).SS*reshape(quaternion(odf(i).center),1,[]); % SS x S3G
      g = reshape(g.',[],1);                                 % S3G x SS
      g = reshape(g*odf(i).CS,1,[]);                         % S3G x SS x CS
      [alpha,beta,gamma] = quat2euler(g);
      alpha = fft_rho(alpha);
      beta  = fft_theta(beta);
      gamma = fft_rho(gamma);
      g = 2*pi*[alpha;beta;gamma];
      
      % set parameter
      c = odf(i).c / length(odf(i).SS) / length(odf(i).CS);
      A = getA(odf(i).psi);
      A = A(1:min(max(4,L+1),length(A)));
      
      % run NFSOFT
      unimodal_hat = run_linux([mtex_path,'/c/bin/odf2fc'],'EXTERN',g,c,A);
      
      % extract result
      odf(i).c_hat = complex(unimodal_hat(1:2:end),unimodal_hat(2:2:end));
      
    end
    
    if ~isempty(inputname(1)) && nargout == 1
      assignin('caller',inputname(1),odf);
    end
    
  end
  
end
nodf = odf;
end

