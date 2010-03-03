function odf = calcFourier(odf,L,varargin)
% compute Fourier coefficients of odf
%
% Compute the Fourier coefficients of the ODF and store them in the
% returned ODF. In order to get the Fourier coefficients of an ODF use
% [[ODF_Fourier.html,Fourier]].
%
%% Syntax  
% odf = calcFourier(odf,L)
%
%% Input
%  odf  - @ODF
%  L    - order up to which Fourier coefficients are calculated
%
%% Output
%  nodf - @ODF where Fourier coefficients are stored for further use 
%
%% See also
% ODF/plotFourier ODF/Fourier WiegnerD FourierODF ODF/textureindex ODF/entropy ODF/eval 
%

error(nargchk(2, 2, nargin));
L = max(L,4);

for i = 1:length(odf)
  
  % no precomputation
  if check_option(odf(i),'Bingham') || ~check_option(odf(i),'Fourier')  && (check_option(odf(i),'UNIFORM') || ...
      dim2deg(length(odf(i).c_hat)) < min(L,length(getA(odf(i).psi))-1))
    
    if check_option(odf(i),'UNIFORM') % **** uniform portion *****
    
      odf(i).c_hat = odf(i).c;
    
    elseif check_option(odf(i),'FIBRE') % ***** fibre symmetric portion *****
    
      A = getA(odf(i).psi);
      A = A(1:min(max(4,L+1),length(A)));
            
      % symmetrize
      h = odf(i).CS * vector3d(odf(i).center{1});
      h = repmat(h,1,length(odf(i).SS));
      r = odf(i).SS * odf(i).center{2};
      r = repmat(r,length(odf(i).CS),1);
      [theta_h,rho_h] = vec2sph(h(:));
      [theta_r,rho_r] = vec2sph(r(:));
    
      odf(i).c_hat = zeros(deg2dim(length(A)),1);
      for l = 0:min(L,length(A)-1)
        hat = odf(i).c * 4*pi / (2*l+1) * A(l+1) *...
          sphericalY(l,theta_h,rho_h).' * conj(sphericalY(l,theta_r,rho_r));
        
        hat = hat';
        odf(i).c_hat(deg2dim(l)+1:deg2dim(l+1)) = hat(:) / ...
          length(odf(i).CS) / length(odf(i).SS);
              
      end
      
    elseif check_option(odf(i),'BINGHAM') % ***** Bingham portion *****
      
      error('Computing the Fourier coefficients of Bingham ODFs is not yet supportet!');
      
    else
      % **** radially symmetric portion ****
      % set parameter
      c = odf(i).c / numel(odf(i).SS) / numel(odf(i).CS);
      
      %% TODO
      % symmetrization for a few center
      if 10*numel(odf(i).center)*numel(odf(i).SS)*numel(odf(i).CS)...
          < max(L^3,100)
        g = odf(i).SS * reshape(quaternion(odf(i).center),1,[]); % SS x S3G
        g = reshape(g.',[],1);                                 % S3G x SS
        g = reshape(g*odf(i).CS,1,[]);                         % S3G x SS x CS        
        % g = quaternion(symmetrise(odf(i).center));
        
        c = repmat(c,1,numel(odf(i).CS)*numel(odf(i).SS));         
      else
        g = quaternion(odf(i).center);        
      end      
      
      % export center in Euler angle
      abg = Euler(g,'nfft');
      
      % export Chebyshev coefficients
      A = getA(odf(i).psi);
      A = A(1:min(max(4,L+1),length(A)));
        
      % init Fourier coefficients
      odf(i).c_hat = zeros(deg2dim(length(A)),1);

      % iterate due to memory restrictions?
      maxiter = ceil(numel(c)/25000);
      if maxiter > 1, progress(0,maxiter);end

      for iter = 1:maxiter
   
        % current iteration region
        if maxiter > 1, progress(iter,maxiter); end   
        dind = ceil(numel(c) / maxiter);
        ind = 1+(iter-1)*dind:min(numel(c),iter*dind);
        
        % calculate Fourier coefficients
        odf(i).c_hat = odf(i).c_hat + gcA2fourier(abg(:,ind),c(ind),A);             
      end
    
      % symmetrization for a many center      
      if 10*numel(odf(i).center)*numel(odf(i).SS)*numel(odf(i).CS)...
          >= L^3        
      
        if numel(odf(i).CS) ~= 1
          % symmetrize crystal symmetry
          abg = Euler(odf(i).CS,'nfft');
          A(1:end) = 1;
          c = ones(1,numel(odf(i).CS));
          odf(i).c_hat = multiply(odf(i).c_hat,gcA2fourier(abg,c,A),length(A)-1);
        end
      
        if numel(odf(i).SS) ~= 1
          % symmetrize specimen symmetry
          abg = Euler(odf(i).SS,'nfft');
          A(1:end) = 1;
          c = ones(1,numel(odf(i).SS));
          odf(i).c_hat = multiply(gcA2fourier(abg,c,A),odf(i).c_hat,length(A)-1);
        end
      end
    end
    
    if ~isempty(inputname(1)) && nargout == 1
      assignin('caller',inputname(1),odf);
    end
    
  end
  
end

end

function f = gcA2fourier(g,c,A)

% run NFSOFT
f = call_extern('odf2fc','EXTERN',g,c,A);
      
% extract result
f = complex(f(1:2:end),f(2:2:end));


end

% multiply Fourier matrixes
function f = multiply(f1,f2,lA)

f = zeros(numel(f1),1);
for l = 0:lA  
  ind = deg2dim(l)+1:deg2dim(l+1);  
  f(ind) = reshape(f1(ind),2*l+1,2*l+1) ...
    * reshape(f2(ind),2*l+1,2*l+1);
end

end
