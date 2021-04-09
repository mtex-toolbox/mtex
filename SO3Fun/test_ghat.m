clear all

%%
mex -R2018a calculate_ghat.c
mex -R2018a calculate_ghat_longwig.c

for k = 11:15
N = 20*k;
for i=1:2

%rot = orientation.rand(1000);
%SO3F = calcDensity(rot,'harmonic','bandwidth',N,'halfwidth',2.5*degree);
%SO3F = SO3FunHarmonic(SO3F.components{1}.f_hat)
%fhat = SO3F.fhat;

SO3F2 = SO3FunHarmonic(rand(deg2dim(N+1),1)*1i+rand(deg2dim(N+1),1));
SO3F2.isReal=0;
fhat = SO3F2.fhat;


tic
B=calculate_ghat_longwig(N,fhat,'makeeven');
time(k,1,j) = time(k,1,j) + toc/2;
tic
B=calculate_ghat_longwig(N,fhat,'makeeven','isReal');
%C=calculate_ghat(fhat,N);
time(k,2,j) = time(k,2,j) + toc/2;
tic
%D = calghat(N,fhat,'makeeven');
%toc
%lsg = max(max(abs(D-C)))+max(max(abs(B-C)));

%NANS = sum(sum(sum(isnan(C))))+sum(sum(sum(isnan(B))))
%max(lsg)

end
end

%A=isnan(C);
%sum(sum(sum(A)))
%spy(A(2:end,2:end,1))

%%
mex -R2018a calculate_ghat.c
lsg=0;
for N=0:6
  SO3F2 = SO3FunHarmonic(rand(deg2dim(N+1),1)*1i+rand(deg2dim(N+1),1));
  SO3F2.isReal=0;
  fhat = SO3F2.fhat;
%   rot = orientation.rand(1000);
%   SO3F = calcDensity(rot,'harmonic','bandwidth',N,'halfwidth',2.5*degree);
%   SO3F = SO3FunHarmonic(SO3F.components{1}.f_hat)
%   fhat = SO3F.fhat;

  % (2N+2,2N+2,2N+2)
  B1 = calculate_ghat(N,fhat,'makeeven');
  C1 = calghat(N,fhat,'makeeven');
  lsg = lsg + max(max(max(abs(B1-C1))));
  
  % (2N+1,2N+1,2N+1)
  B2 = calculate_ghat(N,fhat);
  C2 = calghat(N,fhat);
  lsg = lsg + max(max(max(abs(B2-C2))));

  % (2N+2,N+1+ind,2N+2)
  B3 =  calculate_ghat(N,fhat,'makeeven','isReal');
  C3 = calghat(N,fhat,'makeeven','isReal');
  lsg = lsg + max(max(max(abs(B3-C3))));

 
  % (2N+2,N+1+ind,2N+2)
  B4 = calculate_ghat(N,fhat,'isReal');
  C4 = calghat(N,fhat,'isReal');
  lsg = lsg + max(max(max(abs(B4-C4))));

end

lsg
% 
% B1(N+2:end,2:N+2,1)
% d= Wigner_D(N,pi/2); d(N+1:end,1:N+1)
% 