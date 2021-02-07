clear all
%% Overview of evaluations of real valued rotational functions
%
%% NFFT
% 
% The idea of variables of type @SO3FunHarmonic is to calculate with 
% rotational functions by using harmonic sums. In order to evaluate this 
% harmonics we consider the following real valued rotational function

rng(11)
rot = orientation.rand(1000);
SO3F = calcDensity(rot,'harmonic','bandwidth',64,'halfwidth',2.5*degree);
SO3F = SO3FunHarmonic(SO3F.components{1}.f_hat)
N = SO3F.bandwidth;

fprintf('\n \n <strong> NFFT: </strong>\n')

% The goal is to evaluate a rotational function fast in some given
% orientations and to use some symmetriy properties to make the algorithm
% faster.
% To study speed of this algorithms one has to choose between a few and 
% lots of evaluation points. Hence we construct two vectors of rotations. 

ori1 = rotation.rand(10);
ori2 = rotation.rand(1000000);

%% Comparison of the different implementations of eval functions
% Now we want to campare between different implementations and want to show
% there speed and accuracy for approximate solutions.
% Hence we save the running time in a variable
implementation = zeros(2,7);
error = zeros(2,7);

%% eval.m
% First we study the function eval.m which is using NFSOFT.
fprintf('\neval.m \n  This function uses NFSOFT. \n')
tic
f1 = eval(SO3F,ori1);
implementation(1,1) = toc;

tic
f2 = eval(SO3F,ori2);
implementation(2,1) = toc;

%%
% Now we implemented some slightly different methods for this problem. The
% main idea is to transform the harmonic sum of Wigner-D functions with
% rotational input to an 3 dimensional fourier sum, following the script.
% This can be structured in 3 steps:
%   (a) calculate the matrix of fourier coefficents (following script)
%   (b) transform the evaluation points (following script)
%   (c) using 3 dimensional nfft 

%%
% First we have to do (a) efficiently. Therefore we verify different 
% implementations. 

%% eval_NoSymStraightforward.m
% We start with a straightforward implementation of (a) following the 
% script.
fprintf('\neval_NoSymStraightforward.m \n')
tic

% Code from eval_NoSymStraightforward.m
d = zeros(N+1,2*N+1,2*N+1);
for n = 0:N
    d(n+1,N+1+(-n:n),N+1+(-n:n)) = Wigner_D(n,pi/2);
end
fhat = zeros(N+1,2*N+1,2*N+1);
for n = 0:N
    fhat(n+1,N+1+(-n:n),N+1+(-n:n)) = ...
        reshape(SO3F.fhat(deg2dim(n)+1:deg2dim(n+1)),1,2*n+1,2*n+1);
end
ghat = zeros(2*N+2,2*N+2,2*N+2);
for j = -N:N
  dj = d(:,:,N+1+j);
  gj = fhat .* dj .* permute(dj,[1,3,2]);
  ghat(2:end,2:end,N+2+j) = sum(gj);
end
%

t = toc;
fprintf('  time to compute fourier matrix = %.3f s\n',t)
GHAT = ghat;           % Save ghat to compare later with the other algorithms

%% eval_NoSym4dimHypermatrix.m
% Here we tried to omit loops and do it by a 4 dimensional Hypermatrix. 
% This Hypermatrix gets very big and so it needs a lot of storage space. 
% Hence the storage explodes for large bandwidth N.
% The solution ghat is the same as before, but this implementation is very
% slow.
fprintf('\neval_NoSym4dimHypermatrix.m \n')
tic

% Code from eval_NoSym4dimHypermatrix.m
d = zeros(N+1,2*N+1,2*N+1);
fhat = d;
for n = 0:N
    d(n+1,N+1+(-n:n),N+1+(-n:n)) = Wigner_D(n,pi/2);
    fhat(n+1,N+1+(-n:n),N+1+(-n:n)) = ...
        reshape(SO3F.fhat(deg2dim(n)+1:deg2dim(n+1)),1,2*n+1,2*n+1);
end
ghat = zeros(2*N+2,2*N+2,2*N+2);
G = ones(N+1,2*N+1,2*N+1,2*N+1).*fhat ...
    .*permute(d,[1,2,4,3]).*permute(d,[1,4,2,3]);
ghat(2:end,2:end,2:end) = sum(G);
%

t = toc;
fprintf('  time to compute fourier matrix = %.3f s\n',t)
fprintf('  l_{\\infty} error of fourier matrix = %.1d \n',...
    max(max(max(abs(GHAT-ghat)))));

%% eval_NoSymFast.m
% This is a better implementation of (a). We have less loop iterations and
% we do not construct fhat completely. We parallelize the first
% straightforward implementation by sum over another index in the script.
fprintf('\neval_NoSymFast.m \n')
tic

% Code from eval_NoSymFast.m
ghat = zeros(2*N+2,2*N+2,2*N+2);
for n = 0:N
    Fhat = reshape(SO3F.fhat(deg2dim(n)+1:deg2dim(n+1)),2*n+1,2*n+1);
    d = Wigner_D(n,pi/2);
    D = permute(d,[1,3,2]) .* permute(d,[3,1,2]) .* Fhat;
    ghat(N+2+(-n:n),N+2+(-n:n),N+2+(-n:n)) = ...
        ghat(N+2+(-n:n),N+2+(-n:n),N+2+(-n:n)) + D;
end
%

t = toc;
fprintf('  time to compute fourier matrix = %.3f s\n',t)
fprintf('  l_{\\infty} error of fourier matrix = %.1d \n',...
    max(max(max(abs(GHAT-ghat)))));

%% 
% Save the running times and errors for this 3 implementations
tic
ftest1 = eval_NoSymStraightforward(SO3F,ori1);
implementation(1,2) = toc;

tic
ftest2 = eval_NoSymStraightforward(SO3F,ori2);
implementation(2,2) = toc;

error(1,2) = max(abs(ftest1-f1));
error(2,2) = max(abs(ftest2-f2));

tic
ftest1 = eval_NoSym4dimHypermatrix(SO3F,ori1);
implementation(1,3) = toc;

tic
ftest2 = eval_NoSym4dimHypermatrix(SO3F,ori2);
implementation(2,3) = toc;

error(1,3) = max(abs(ftest1-f1));
error(2,3) = max(abs(ftest2-f2));

tic
ftest1 = eval_NoSymFast(SO3F,ori1);
implementation(1,4) = toc;

tic
ftest2 = eval_NoSymFast(SO3F,ori2);
implementation(2,4) = toc;

error(1,4) = max(abs(ftest1-f1));
error(2,4) = max(abs(ftest2-f2));

%% eval_SymReconstrct.m
% Now we want to investigate the symmetry properties of the fourier matrix
% ghat by using a real valued function SO3F.
% First we calculate only half of ghat and get the remaining part by the
% symmetry property.
fprintf('\neval_SymReconstrct.m \n')
tic

% Code from eval_SymReconstrct.m
ghat = zeros(2*N+2,2*N+2,2*N+2);
for n = 0:N
    Fhat = reshape(SO3F.fhat(deg2dim(n)+1:deg2dim(n+1)),2*n+1,2*n+1); 
    Fhat = Fhat(:,1:n+1);
    d = Wigner_D(n,pi/2); d = d(:,1:n+1);
    D = permute(d,[1,3,2]) .* permute(d(1:n+1,:),[3,1,2]) .* Fhat;
    ghat(N+2+(-n:n),N+2+(-n:0),N+2+(-n:0)) = ...
        ghat(N+2+(-n:n),N+2+(-n:0),N+2+(-n:0)) + D;
end
pm = -reshape((-1).^(1:(2*N+1)*(N+1)),[2*N+1,N+1]);
ghat(2:end,2:N+2,N+2+(1:N)) = flip(ghat(2:end,2:N+2,N+2+(-N:-1)),3) .*pm;
ghat(2:end,N+2+(1:N),2:end) = ...
    conj(flip(flip(flip(ghat(2:end,N+2+(-N:-1),2:end),1),2),3));
%

t = toc;
fprintf('  time to compute fourier matrix = %.3f s\n',t)
fprintf('  l_{\\infty} error of fourier matrix = %.1d \n',...
    max(max(max(abs(GHAT-ghat)))));

%% eval_SymHalfsize.m
% Now we want to use the symmetry property to reduce the size of NFFT
% following the script. Hence the fourier matrix ghat is only half the size
% it was before. And we have to change two lines in part (c). First we have
% one lower dimension in NFFT and second we have to modify the solution a
% little bit.
fprintf('\neval_SymHalfsize.m \n')
tic

% Code from eval_SymHalfsize.m
ind = mod(N+1,2);
ghat = zeros(2*N+2,N+1+ind,2*N+2);
for n = 0:N
    Fhat = reshape(SO3F.fhat(deg2dim(n)+1:deg2dim(n+1)),2*n+1,2*n+1); 
    Fhat = Fhat(:,n+1:end);
    d = Wigner_D(n,pi/2); d = d(:,1:n+1);
    D = permute(d,[1,3,2]) .* permute(d(n+1:end,:),[3,1,2]) .* Fhat;  
    ghat(N+2+(-n:n),ind+(1:n+1),N+2+(-n:0)) = ...
        ghat(N+2+(-n:n),ind+(1:n+1),N+2+(-n:0)) + D;
end
pm = (-1)^(ind)*reshape((-1).^(1:(2*N+1)*(N+1)),[2*N+1,N+1]);
ghat(2:end,1+ind:end,N+2+(1:N)) = ...
    flip(ghat(2:end,1+ind:end,N+2+(-N:-1)),3) .* pm;
ghat(:,1+ind,:)=ghat(:,1+ind,:)/2;
%

t = toc;
fprintf('  time to compute fourier matrix = %.3f s\n',t)

%% 
% Save the running times and errors for this 2 implementations
tic
ftest1 = eval_SymReconstrct(SO3F,ori1);
implementation(1,5) = toc;

tic
ftest2 = eval_SymReconstrct(SO3F,ori2);
implementation(2,5) = toc;

error(1,5) = max(abs(ftest1-f1));
error(2,5) = max(abs(ftest2-f2));

tic
ftest1 = eval_SymHalfsize(SO3F,ori1);
implementation(1,6) = toc;

tic
ftest2 = eval_SymHalfsize(SO3F,ori2);
implementation(2,6) = toc;

error(1,6) = max(abs(ftest1-f1));
error(2,6) = max(abs(ftest2-f2));

%% eval_SymNFFTDecompose.m
% Now we also want to use the second symmetry property to reduce the size
% of the fourier matrix and NFFT again by an half. We cant summarize the 
% formulas similar as before. So we decompose the NFFT in 5 smaller ones
% following the script.
% That is not a realy good idea.
fprintf('\neval_SymNFFTDecompose.m\n  The fourier matrix is decomposed.\n')

tic
ftest1 = eval_SymNFFTDecompose(SO3F,ori1);
implementation(1,7) = toc;

tic
ftest2 = eval_SymNFFTDecompose(SO3F,ori2);
implementation(2,7) = toc;

error(1,7) = max(abs(ftest1-f1));
error(2,7) = max(abs(ftest2-f2));

%% 
% Now we compare the running time of the different implementations
fprintf(['\nComparison of the running times (seconds) of the above \n',...
    'algorithms evaluated in %.0f and %1.1e orientations:\n'],...
    size(ori1,1),size(ori2,1))
disp(implementation)

% and the errors
fprintf(['\nComparison of the l_{\\infty} errors to eval() of the \n' ...
    'above algorithms for %.0f and %1.1e orientations:\n'],...
    size(ori1,1),size(ori2,1))
disp(error)

fprintf('head of the tables:')
fprintf(['\n[ eval | NoSymStraightforward | NoSym4dimHypermatrix | ', ...
    'NoSymFast | SymReconstrct | SymHalfsize | SymNFFTDecompose ] \n'])



% We observe: eval_SymReconstrct.m and eval_SymHalfsize.m are possible 
% alternatives for  eval.m
% It remains to investigate this more precisely:

% for k = 1:10
   bd = 10:10:80;
   bd(1) = 1;
%   new_time = zeros(length(bd),7,3);
% 
%   for j = 1:7
%     rot = rotation.rand(10^j,1);
% 
%     for N = 1:length(bd)
%       F = SO3FunHarmonic(rand(deg2dim(bd(N)+1),1));
%       tic
%       eval(F,rot);
%       new_time(N,j,1) = new_time(N,j,1)+toc;
%       fprintf('[return, log_points 7, bd %.0f] = [%.0f,%.0f,%.0f] \n',...
%           length(bd),k,j,N)
%     end
% 
%     for N = 1:length(bd)
%       F = SO3FunHarmonic(rand(deg2dim(bd(N)+1),1));
%       tic
%       eval_SymHalfsize(F,rot);
%       new_time(N,j,2) = new_time(N,j,2)+toc;
%       fprintf('[return, log_points 7, bd %.0f] = [%.0f,%.0f,%.0f] \n',...
%           length(bd),k,j,N)
%     end
% 
%     for N = 1:length(bd)
%       F = SO3FunHarmonic(rand(deg2dim(bd(N)+1),1));
%       tic
%       eval_SymReconstrct(F,rot);
%       new_time(N,j,3) = new_time(N,j,3)+toc;
%       fprintf('[return, log_points 7, bd %.0f] = [%.0f,%.0f,%.0f] \n',...
%           length(bd),k,j,N)
%     end
%   end
%   
%   load('time.mat')
%   time(k) = {new_time};
%   save('time.mat','time')
% end

% The above Code creates the variable time saved in time.mat.
load('time.mat')
for j=1:7
    subplot(2,4,j)
    plot(bd,time(:,j,1),'g','LineWidth',1,'DisplayName','eval')
    hold on
    plot(bd,time(:,j,2),'b','LineWidth',1,'DisplayName','eval_SymHalfsize')
    hold on
    plot(bd,time(:,j,3),'m','LineWidth',1,'DisplayName','eval_SymReconstrct')
    grid on
    xlim([bd(1) bd(end)])
    xlabel('bandwidth')
    ylabel('time in sec')
    title(['10^',num2str(j),' evaluation points'])
end
subplot(2,4,8)
plot(1,1,'g')
hold on
plot(1,1,'b')
hold on
plot(1,1,'m')
set(gca,'visible','off')
legend({'eval_{NFSOFT}','eval_{SymHalfsize}','eval_{SymReconstrct}'},'Location','best')

sgtitle('running time of different eval functions')

% Thus we use eval_SymHalfsize.m as best implementation.
% Therefore we construct a function eval2 using this implementation in the
% case of real valued functions and eval_NoSymFast.m otherwise.

%% eval2.m
fprintf('\neval2.m \n')
tic
ftest1 = eval2(SO3F,ori1);
t1 = toc;
tic
ftest2 = eval2(SO3F,ori2);
t2 = toc;
fprintf('  running time of [ori1,ori2]  = [%.3f,%.3f] s\n',t1,t2)
fprintf('  l_{\\infty} error of [ori1,ori2] = [%.1d,%.1d] \n',...
    max(abs(ftest1-f1)),max(abs(ftest2-f2)));
fprintf('  It is the same like eval_SymHalfsize.m.\n')













%% FFT
%
% The complexity of 3 dimensional NFFT is strongly corelated to the number
% of evaluation points. Now we want to consider the above idea for FFT.
fprintf('\n \n <strong> FFT: </strong>\n')

%create equidistant Grid (alpha,beta,gamma) c [0,2*pi)x[0,pi)x[0,2*pi)
fprintf('Grid to control FFT: ')
clear Grid
Grid(:,[3,2,1]) = combvec(0:2*N,0:2*N,0:2*N)'*2*pi/(2*N+1);
Grid = Grid(Grid(:,2)<pi,:);
Gridori = rotation.byEuler(Grid,'nfft')

f_grid = eval(SO3F,Gridori);

%% eval_fftNoSymStraightforward.m
% Therefore we construct an FFT from eval_NoSymStraightforward.m without 
% using the symmetry property.
fprintf('eval_fftNoSymStraightforward.m \n')

tic
fft = eval_fftNoSymStraightforward(SO3F);
t = toc;

fprintf('  running time of algorithm = %.3f s\n',t)
fprintf('  l_{\\infty} error to eval(SO3F,Gridori) = %.1d \n', ...
    max(abs(fft-f_grid)));

%% eval_fftNoSymFast.m
% We simply speed up this by using the faster function eval_NoSymFast
fprintf('\neval_fftNoSymFast.m \n')

tic
fft = eval_fftNoSymFast(SO3F);
t = toc;

fprintf('  running time of algorithm = %.3f s\n',t)
fprintf('  l_{\\infty} error to eval(SO3F,Gridori) = %.1d \n', ...
    max(abs(fft-f_grid)));

%% eval_fftSymReconstrct.m
% Now we speed up the algorithm by using the symmetry property to
% reconstruct half of fourier matrix from the other half, like before.
fprintf('\neval_fftSymReconstrct.m \n')

tic
fft = eval_fftSymReconstrct(SO3F);
t = toc;

fprintf('  running time of algorithm = %.3f s\n',t)
fprintf('  l_{\\infty} error to eval(SO3F,Gridori) = %.1d \n', ...
    max(abs(fft(:)-f_grid)));

%% eval_fftSym.m
% Now we speed up the algorithm by using the symmetry property. 
fprintf('\neval_fftSym.m \n')

tic
fft = eval_fftSym(SO3F);
t = toc;

fprintf('  running time of algorithm = %.3f s\n',t)
fprintf('  l_{\\infty} error to eval(SO3F,Gridori) = %.1d \n', ...
    max(abs(fft(:)-f_grid)));

%% evalfft.m

%
fprintf('\nevalfft.m (dft)\n')
tic
dft=evalfft(SO3F)
t=toc;

fprintf('  running time of algorithm = %.3f s\n',t)
fprintf('  l_{\\infty} error to eval(SO3F,dft.grid) = %.1d \n', ...
    max(max(max(abs(eval(SO3F,dft.grid)-dft.value)))))

% Now we want to do FFT and approximate the evaluation of ori by the
% received grid.
% First we use a special construction to get an orientation for testing
% evalfft. The first point is a random orientation and the second point is
% the nearest grid point of the first point.

%lines from evalfft
H = 64;
h = pi/(H+1);

ori3 = rotation.byEuler(2.28,34*h,0.93);

%lines from evalfft to get next gridpoint
abg = Euler(ori3,'nfft');
abg = mod(mod(abg+[-pi/2,0,pi/2],2*pi)/h,2*H+2);
basic = round(abg);

% add ori3 at next gridpoint (for ori3(2) yields abg == basic)
ori3(2) = rotation.byEuler(basic*h-[-pi/2,0,pi/2],'ZYZ');

ori3

fprintf('\nevalfft.m (interpolation)\n')
tic
f1 = SO3F.evalfft(ori3,'nearest')';
t = toc;

fprintf('  running time of algorithm = %.3f s\n',t)
fprintf('  eval of ori3 = [ %.4f , %.4f ] \n', eval(SO3F,ori3))
fprintf('  evalfft of ori3 = [ %.4f , %.4f ] \n', f1)

% ori3(2) has the same value as ori3(1) because they are rounded to the
% same nearest gridpoint.
% ori3(2) is very close to this gridpoint. Hence it is mapped to the right
% function value. ori3(1) is a little bit away from this gridpoint. The
% function is locally very steep, hence the function values between two 
% closely spaced points are very different.


% Now we want to plot SO3F with fix beta.
% The plot shows all points that are 'nearest' ori3(2) for fixed beta.
% Hence every point in the plot is mapped by evalfft(SO3F,'nearest') to the
% same function value.
[A,G] = meshgrid(basic(1)-0.5:0.1:basic(1)+0.5,basic(3)-0.5:0.1:basic(3)+0.5);
A = (A*h+pi/2)/degree;
G = (G*h-pi/2)/degree;
rot = rotation.byEuler(A*degree,basic(2)*h,G*degree,'ZYZ');
Z = eval(SO3F,rot);
s = surf(A,G,Z);
s.EdgeColor = 'none';
xlabel('alpha')
ylabel('gamma')
zlabel('value')
title('SO3F at grid for alpha and gamma with fix beta')
colorbar

%plot ori3(1) and ori3(2)
hold on
abg = Euler(ori3,'nfft')/degree;
plot3(abg(:,1),abg(:,3),eval(SO3F,ori3)', 'ro')

view(-221,32)
