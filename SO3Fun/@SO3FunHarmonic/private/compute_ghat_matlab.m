function ghat = compute_ghat_matlab(N,fhat,varargin)
% This function contains the matlab code which is used to compute the
% fourier coefficients ghat in eval_v2 and evalfft by a faster C++ program.

normalizedfhat=zeros(deg2dim(N+1),1);
  for l=0:N
    normalizedfhat(deg2dim(l)+1:deg2dim(l+1)) = fhat(deg2dim(l)+1:deg2dim(l+1))*sqrt(2*l+1);
  end
fhat=normalizedfhat;
  
halfsize = get_flag(varargin,'isReal','notReal');
even = get_flag(varargin,'makeeven','notmake');

% (2N+2,2N+2,2N+2)     -->     if ~SO3F.isReal in eval_v2
if strcmpi(even,'makeeven') && ~strcmpi(halfsize,'isReal')
  
  ghat = zeros(2*N+2,2*N+2,2*N+2);

  for n = 0:N

    Fhat = reshape(fhat(deg2dim(n)+1:deg2dim(n+1)),2*n+1,2*n+1);
  
    d = Wigner_D(n,pi/2); d = d(:,1:n+1);

%     % probabply use recursions formula for Wigner-d matrices
%     if n==0
%       dlmin2 = 1;
%       d = dlmin2;
%     elseif n==1
%       dlmin1 = Wigner_D(1,pi/2); dlmin1 = dlmin1(:,1:2);
%       d = dlmin1;
%     else
%       d =  Wigner_d_recursion(dlmin1,dlmin2,pi/2,'half');
%       dlmin2 = dlmin1;
%       dlmin1 =d;
%     end

  
    D = permute(d,[1,3,2]) .* permute(d,[3,1,2]).* Fhat;

    ghat(N+2+(-n:n),N+2+(-n:n),N+2+(-n:0)) = ...
        ghat(N+2+(-n:n),N+2+(-n:n),N+2+(-n:0)) + D;

  end
  
  pm = -reshape((-1).^(1:(2*N+1)*(2*N+1)),[2*N+1,2*N+1]);
  ghat(2:end,2:end,N+2+(1:N)) = ...
      flip(ghat(2:end,2:end,N+2+(-N:-1)),3) .* pm;
  
end

% (2N+2,N+1+ind,2N+2)     -->     if SO3F.isReal in eval_v2
if strcmpi(even,'makeeven') && strcmpi(halfsize,'isReal')
  
  ind = mod(N+1,2);

  ghat = zeros(2*N+2,N+1+ind,2*N+2);

  for n = 0:N

    Fhat = reshape(fhat(deg2dim(n)+1+n*(2*n+1):deg2dim(n+1)),2*n+1,n+1);

    d = Wigner_D(n,pi/2); d = d(:,1:n+1);
    
%     % probabply use recursions formula for Wigner-d matrices
%     if n==0
%       dlmin2 = 1;
%       d = dlmin2;
%     elseif n==1
%       dlmin1 = Wigner_D(1,pi/2); dlmin1 = dlmin1(:,1:2);
%       d = dlmin1;
%     else
%       d =  Wigner_d_recursion(dlmin1,dlmin2,pi/2,'half');
%       dlmin2 = dlmin1;
%       dlmin1 =d;
%     end
    
    D = permute(d,[1,3,2]) .* permute(d(n+1:end,:),[3,1,2]) .* Fhat;

    ghat(N+2+(-n:n),ind+(1:n+1),N+2+(-n:0)) = ...
        ghat(N+2+(-n:n),ind+(1:n+1),N+2+(-n:0)) + D;

  end

  pm = (-1)^(ind)*reshape((-1).^(1:(2*N+1)*(N+1)),[2*N+1,N+1]);
  ghat(2:end,1+ind:end,N+2+(1:N)) = ...
      flip(ghat(2:end,1+ind:end,N+2+(-N:-1)),3) .* pm;

  ghat(:,1+ind,:) = ghat(:,1+ind,:)/2;
  
end

%(2N+1,2N+1,2N+1)     -->     if ~SO3F.isReal in evalfft
if ~strcmpi(even,'makeeven') && ~strcmpi(halfsize,'isReal')

  ghat = zeros(2*N+1,2*N+1,2*N+1);

  for n = 0:N

    Fhat = reshape(fhat(deg2dim(n)+1:deg2dim(n+1)),2*n+1,2*n+1);

    d = Wigner_D(n,pi/2); d = d(:,1:n+1);
    
%     % probabply use recursions formula for Wigner-d matrices
%     if n==0
%       dlmin2 = 1;
%       d = dlmin2;
%     elseif n==1
%       dlmin1 = Wigner_D(1,pi/2); dlmin1 = dlmin1(:,1:2);
%       d = dlmin1;
%     else
%       d =  Wigner_d_recursion(dlmin1,dlmin2,pi/2,'half');
%       dlmin2 = dlmin1;
%       dlmin1 =d;
%     end
    
    D = permute(d,[1,3,2]) .* permute(d,[3,1,2]) .* Fhat;

    ghat(N+1+(-n:n),N+1+(-n:n),N+1+(-n:0)) = ...
        ghat(N+1+(-n:n),N+1+(-n:n),N+1+(-n:0)) + D;

  end

  pm = -reshape((-1).^(1:(2*N+1)*(2*N+1)),[2*N+1,2*N+1]);
  ghat(:,:,N+1+(1:N)) = flip(ghat(:,:,N+1+(-N:-1)),3) .* pm;
  
end



%(2N+1,N+1,2N+1)     -->     if SO3F.isReal in evalfft
if ~strcmpi(even,'makeeven') && strcmpi(halfsize,'isReal')
  
  ghat = zeros(2*N+1,N+1,2*N+1);

  for n = 0:N

    Fhat = reshape(fhat(deg2dim(n)+1+n*(2*n+1):deg2dim(n+1)),2*n+1,n+1);

    d = Wigner_D(n,pi/2); d = d(:,1:n+1);
    
%     % probabply use recursions formula for Wigner-d matrices
%     if n==0
%       dlmin2 = 1;
%       d = dlmin2;
%     elseif n==1
%       dlmin1 = Wigner_D(1,pi/2); dlmin1 = dlmin1(:,1:2);
%       d = dlmin1;
%     else
%       d =  Wigner_d_recursion(dlmin1,dlmin2,pi/2,'half');
%       dlmin2 = dlmin1;
%       dlmin1 =d;
%     end
    
    D = permute(d,[1,3,2]) .* permute(d(n+1:end,:),[3,1,2]) .* Fhat;

    ghat(N+1+(-n:n),1:n+1,N+1+(-n:0)) =ghat(N+1+(-n:n),1:n+1,N+1+(-n:0))+D;

  end
  pm = (-1)^(N-1)*reshape((-1).^(1:(2*N+1)*(N+1)),[2*N+1,N+1]);
  ghat(:,:,N+1+(1:N)) = flip(ghat(:,:,N+1+(-N:-1)),3) .* pm;

  ghat(:,1,:) = ghat(:,1,:)/2;

end

end