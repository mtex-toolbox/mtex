function check_NFSOFT
%
% checks for Y_l(g h) = T_l(g) Y_l(h)
%

%% input data
L = 16;

%q = axis2quat(xvector+yvector,25*degree);
%q = axis2quat(zvector,90*degree);
%h = [xvector,-xvector,yvector];

qq = quaternion(SO3Grid(10));
h = equispacedS2Grid('points',20,'antipodal');

progress(0,length(qq));

for iq = 1:length(qq)

  progress(iq,length(qq));
  
  q = qq(iq);
  
  %% convert to export parameters
  g = Euler(q,'nfft');
%   alpha = fft_rho(alpha); %-->z
%   beta  = fft_theta(beta);
%   gamma = fft_rho(gamma); %-->z
%   g = 2*pi*[alpha;beta;gamma];
  %g = [0;pi/2;0];
      
  %% set parameters
  c = 1;
  A = ones(1,L+1);

  %% run NFSOFT
  T = call_extern('odf2fc','EXTERN',g,c,A); % conjugate(D)

  % extract result
  T = complex(T(1:2:end),T(2:2:end));


  %% check result

  for l = 0:L
  
    Y = sphericalY(l,h).'; % -> Y
    gY = sphericalY(l,q*h).'; % -> Y
    Tl = reshape(T(deg2dim(l)+1:deg2dim(l+1)),2*l+1,2*l+1);
    %    TY = flipud(Tl * flipud(Y));
    %    TY = flipud(fliplr(Tl) * Y);
    TY = Tl * Y;
    er(l+1,iq) = sqrt(norm(TY(:) - gY(:)));
    %TY = conj(Tl) * Y;norm(TY(:) - gY(:))
    %TY = Tl' * Y;norm(TY(:) - gY(:))
    %TY = Tl.' * Y;norm(TY(:) - gY(:))
    
  end

end

%plot(mean(er,2));
if mean(er(:)) > 0.001
  error('Error in NFSOFT');
else
  disp('checking NFSOFT: ok')
  disp(mean(er(:)))
end

pcolor(er)

function d = deg2dim(l)
% dimension of the harmonic space up to order l

d = l*(2*l-1)*(2*l+1)/3;

