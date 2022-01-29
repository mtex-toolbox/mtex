function fhat = adjoint_compute_ghat_matlab(N,G,varargin)
% Matlab code of the adjoint representation based coefficient transform,
% that transforms a series of Wigner-D functions into a trivariate fourier series
%

% save some calculations by adding over half size in index j
ghat = zeros(2*N+1,N+1,2*N+1);
[~,k,l] = meshgrid(0:N,-N:N,-N:N);
ghat(:,1,:) = (-1).^(k(:,1,:)+l(:,1,:)) .*G(:,N+1,:);
ghat(:,2:end,:) = (-1).^(k(:,2:end,:)+l(:,2:end,:)) .* G(:,N+2:end,:) + G(:,N:-1:1,:);

% create output vektor and Wigner-d matrices by recurrence relation
fhat = zeros(deg2dim(N+1),1);
D = Wigner_d_recursion(N,pi/2);

% adjoint representation based coefficient transform
% use symmetry of fourier coefficient vector, if function is real valued
if ~check_option(varargin,'isReal')

  for n=0:N

    if n==0
      d = 1;
    else
      d = D{n};
    end
    fhat_n = sum(d(:,n+1:end).*permute(d(:,n+1:end),[3,2,1]).*ghat((-n:n)+N+1,1:n+1,(-n:n)+N+1),2);
    % normalize
    fhat_n = sqrt(2*n+1)*fhat_n;
    fhat(deg2dim(n)+1:deg2dim(n+1)) = reshape(fhat_n,2*n+1,2*n+1);
    
  end

else

  for n=0:N

    if n==0
      d = 1;
    else
      d = D{n};
    end
    fhat_n = sum(d(n+1:end,n+1:end).*permute(d(:,n+1:end),[3,2,1]).*ghat((0:n)+N+1,1:n+1,(-n:n)+N+1),2);
    % normalize
    fhat_n = sqrt(2*n+1)*fhat_n;
    fhat_n = permute(fhat_n,[1,3,2]);
    fhat(deg2dim(n)+1:deg2dim(n+1)) = [conj(flip(flip(fhat_n(2:end,:),1),2));fhat_n];
  end

end


end