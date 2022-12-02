clear all 

% Build mex function
mex -R2018a Wigner_d_fast.c



%% Compare different Wigner-d methods
N = 512
beta =rand*pi;

% past method 
tic
a = Wigner_D(N,beta);
toc

% new faster method
tic
b = Wigner_d_fast(N,beta);
toc

% create cell array of all Wigner-ds with harmonic degree smaller then L
tic
c = Wigner_d_recursion(N,beta);
toc

% get new Wigner-d from previous two
tic
d = Wigner_d_recursion(c{end-1},c{end-2},beta);
toc

% get new Wigner-d from previous two (faster)
tic
e = Wigner_d_fast(c{end-1},c{end-2},beta);
toc


  
max(max(abs(a-b)))

max(max(abs(d-e)))