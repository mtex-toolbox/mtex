function check_NFSOFT
%
% checks for Y_l(g h) = T_l(g) Y_l(h)
%

global mtex_path

%% input data
L = 16;

%q = axis2quat(xvector+yvector,25*degree);
%q = axis2quat(zvector,90*degree);
%h = [xvector,-xvector,yvector];

qq = quaternion(SO3Grid(50));
h = vector3d(S2Grid('equispaced','points',20,'reduced'));

progress(0,length(qq));

for iq = 1:length(qq)

  progress(iq,length(qq));
  
  q = qq(iq);
  
  %% convert to export parameters
  [alpha,beta,gamma] = quat2euler(q);
  alpha = fft_rho(alpha); %-->z
  beta  = fft_theta(beta);
  gamma = fft_rho(gamma); %-->z
  g = 2*pi*[alpha;beta;gamma];
  %g = [0;pi/2;0];
      
  %% set parameters
  c = 1;
  A = ones(1,L+1);

  %% run NFSOFT
  T = call_extern([mtex_path,'/c/bin/odf2fc'],'EXTERN',g,c,A);

  % extract result
  T = complex(T(1:2:end),T(2:2:end));


  %% check result

  for l = 0:L
  
    Y = sphericalY(l,h).';
    gY = sphericalY(l,q*h).';
    Tl = reshape(T(deg2dim(l)+1:deg2dim(l+1)),2*l+1,2*l+1);
    %    TY = flipud(Tl * flipud(Y));
    %    TY = flipud(fliplr(Tl) * Y);
    TY = Tl * Y;
    error(l+1,iq) = sqrt(norm(TY(:) - gY(:)));
    %TY = conj(Tl) * Y;norm(TY(:) - gY(:))
    %TY = Tl' * Y;norm(TY(:) - gY(:))
    %TY = Tl.' * Y;norm(TY(:) - gY(:))
    
  end

end

%plot(mean(error,2));
if mean(error(:)) > 0.001
  error('Error in NFSOFT');
else
  disp('checking NFSOFT: ok')
  disp(mean(error(:)))
end

function d = deg2dim(l)
% dimension of the harmonic space up to order l

d = l*(2*l-1)*(2*l+1)/3;

