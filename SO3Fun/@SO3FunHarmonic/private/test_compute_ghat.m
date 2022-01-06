clear all

% Build mex fuction for matlab
mex -R2018a representationbased_coefficient_transform.c
mex -R2018a compute_ghat_syminghat.c

  
%% Test this functions

% Create a random SO3FunHarmonic function
N=128
SO3F2 = SO3FunHarmonic(rand(deg2dim(N+1),1)*1i+rand(deg2dim(N+1),1));
SO3F2.isReal=0;
fhat = SO3F2.fhat;

% compute ghat fast
tic; 
A1 = representationbased_coefficient_transform(N,fhat,2^1); %makeeven
toc

% compute ghat with slower symetry method
tic; 
B1 = compute_ghat_syminghat(N,fhat,'makeeven');
toc

% compute ghat with matlab method
tic; 
C = compute_ghat_matlab(N,fhat,'makeeven');
toc

  
tic; A2 = representationbased_coefficient_transform(N,fhat); toc
tic; B2 = compute_ghat_syminghat(N,fhat); toc

tic; A3 = representationbased_coefficient_transform(N,fhat,2^0); toc %'isReal'
tic; B3 = compute_ghat_syminghat(N,fhat,'isReal'); toc

tic; A4 = representationbased_coefficient_transform(N,fhat,2^0+2^1); toc %'makeeven','isReal'
tic; B4 = compute_ghat_syminghat(N,fhat,'makeeven','isReal'); toc


%A=isnan(C);
%sum(sum(sum(A)))
%spy(A(2:end,2:end,1))

%% Look on accuracy


lsg=0;

for N=0:6
  
  SO3F2 = SO3FunHarmonic(rand(deg2dim(N+1),1)*1i+rand(deg2dim(N+1),1));
  SO3F2.isReal=0;
  fhat = SO3F2.fhat;

  % (2N+2,2N+2,2N+2)
  A1 = representationbased_coefficient_transform(N,fhat,2^1); %'makeeven'
  B1 = compute_ghat_syminghat(N,fhat,'makeeven');
  C1 = compute_ghat_matlab(N,fhat,'makeeven');
  lsg = max( [lsg, max(max(max(abs(B1-C1)))), max(max(max(abs(A1-C1))))] );
  
  
  % (2N+1,2N+1,2N+1)
  A2 = representationbased_coefficient_transform(N,fhat);
  B2 = compute_ghat_syminghat(N,fhat);
  C2 = compute_ghat_matlab(N,fhat);
  lsg = max( [lsg, max(max(max(abs(B2-C2)))), max(max(max(abs(A2-C2))))] );

  % (2N+2,N+1+ind,2N+2)
  A3 = representationbased_coefficient_transform(N,fhat,2^0+2^1); %'makeeven','isReal'
  B3 = compute_ghat_syminghat(N,fhat,'makeeven','isReal');
  C3 = compute_ghat_matlab(N,fhat,'makeeven','isReal');
  lsg = max( [lsg, max(max(max(abs(B3-C3)))), max(max(max(abs(A3-C3))))] );

 
  % (2N+2,N+1+ind,2N+2)
  A4 = representationbased_coefficient_transform(N,fhat,2^0); %'isReal'
  B4 = compute_ghat_syminghat(N,fhat,'isReal');
  C4 = compute_ghat_matlab(N,fhat,'isReal');
  lsg = max( [lsg, max(max(max(abs(B4-C4)))), max(max(max(abs(A4-C4))))] );

end

lsg

