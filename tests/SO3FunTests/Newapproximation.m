%% Test approximation-method
clear 
rng(0)

G = SO3Fun.dubna;% G.CS=specimenSymmetry;
figure(1)
plot(G)
q = orientation.rand(1e5,G.CS);
%q = equispacedSO3Grid(G.CS,'resolution',5*degree); q=q(:);
% q = G.discreteSample(6e4);
f = G.eval(q);

F2 = SO3FunHarmonic.approximate(q,f,'tol',1e-6,'maxit',50,'bandwidth',25)
figure(2)
plot(F2)


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Alternative Computations
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% show Voronoi cells
clear
rng(0)
ori=orientation.rand(1e2);
[V,C,E] = calcVoronoi(ori);
for i=[1,82,5,7,16,20]
plot(ori(i))
hold on
plot(V(C{i}))
Z = E(any(E(:,1)==C{i},2) & any(E(:,2)==C{i},2),:);
% Z = E(C{i},C{i});
for k=1:length(Z)
  g = geodesic(V(Z(k,1)),V(Z(k,2)),0:0.01:1);
  % g = geodesic(V(C{i}(k)),V(C{i}(Z(k,:)==1)),0:0.01:1);
  plot(g,'Marker','.')
end
pause(0.5)
end
hold off

%%

clear
rng(0)
rot = orientation.rand(5);
[V,C] = calcVoronoi(rot);

w = calcVoronoiVolume(rot)

%% Clenshaw Curtis quadrature weights

clear

N=10

n=2*N+1;
c = zeros(n,2);
c(1:2:n,1) = (2./[1 1-(2:2:n-1).^2 ])';
c(2,2)=1;
f = real(ifft([c(1:n,:);c(n-1:-1:2,:)]));
w = 2*([f(1,1); 2*f(2:n-1,1); f(n,1)])/2;


b=sum(exp(-1i*pi*(-N:N).*(0:2*N)'/N).*w',2);
real(b)

 ( (-1).^(0:N) * 2./(1-(4*(0:N).^2)) )'


%% More Penrose Pseudo Inverse of Representationbased Wigner Transform
clear

N=3;

G = sparse((2*N+1)^3,deg2dim(N+1));
dd={};
for n=0:N

  d = WignerD(pi/2,n);
  dd{n+1} = sqrt(2*n+1)*d.*reshape(d,2*n+1,1,2*n+1);
  dim(n+1)=deg2dim(n);
end

g=1;
b=1;

for k=-N:N
  for l=-N:N
    for j=-N:N
      ind = g;
      for n = N:-1:max(abs(k),max(abs(l),abs(j)))
%         ind = dim(n+1)+1 + n*(2*n+2) + (2*n+1)*k + l;
        G( (2*N+1)^2*(k+N) + (2*N+1)*(l+N) + (j+N+1),ind) = dd{n+1}(j+n+1,k+n+1,l+n+1);
        ind = ind+1;
      end
    end
    g = g+(N+1-max(abs(k),abs(l)));
  end
end


%%
S=G'*G;
i=inv(S);
(S~=0) ~= (i~=0);
if N>=2
  i(1,6) = 0;
  i(6,1) = 0;
end
if N>=3
  i(1,60) = 0;
  i(60,1) = 0;
end

figure(1)
subplot(1,3,1)
spy(G)

%rank(full(G))
subplot(1,3,2)
spy(S)

subplot(1,3,3)
spy(i)


S2={};
iter=1;
line=1;
for k=-N:N
  for l=-N:N
    
    len = N+1-max(abs(k),abs(l));
    A = S(line-1+(1:len),line-1+(1:len));

    S2{iter} = full(A);
    iter=iter+1;
    line = line+len;
  end
end

min(cellfun(@det,S2))



%%
rng(0)
N=10;

G = sparse((2*N+1)^3,deg2dim(N+1));
dd={};
for n=0:N
  d = WignerD(pi/2,n);
  dd{n+1} = sqrt(2*n+1)*d.*reshape(d,2*n+1,1,2*n+1);%.*(1i.^(reshape(-n:n,1,1,[])-(-n:n)));
  dim(n+1)=deg2dim(n);
end

g=1;
b=1;

for k=-N:N
  for l=-N:N
    for j=-N:N
      ind = g;
      for n = N:-1:max(abs(k),max(abs(l),abs(j)))
%         ind = dim(n+1)+1 + n*(2*n+2) + (2*n+1)*k + l;
        G( (2*N+1)^2*(k+N) + (2*N+1)*(l+N) + (j+N+1),ind) = dd{n+1}(j+n+1,k+n+1,l+n+1);
        ind = ind+1;
      end
    end
    g = g+(N+1-max(abs(k),abs(l)));
  end
end


S = G.' * G;

fhat = rand(deg2dim(N+1),1);
a=wignerTrafomex(N,fhat,2^0);


b=G*fhat;

a = permute(real(a),[2,1,3])

b = reshape(b,size(a))

%a = permute(a,[2,1,3]);
%a=real(a)
%b=reshape(b,size(a))
%max(abs(real(a(:)-b)))


%% represente inv(G'*G)

clear


rng(0)
N=5;
fhat = rand(deg2dim(N+1),1);


dd={};
for n=0:N
  d = WignerD(pi/2,n);
  dd{n+1} = sqrt(2*n+1)*d.*reshape(d,2*n+1,1,2*n+1);%.*(1i.^(reshape(-n:n,1,1,[])-(-n:n)));
end

g=1;
ghat = zeros(2*N+1,2*N+1,2*N+1);
G = sparse((2*N+1)^3,deg2dim(N+1));
G2 = sparse((2*N+1)^3,deg2dim(N+1));

for k=-N:N
  for l=-N:N
    for j=-N:N
      for n = max(abs(k),max(abs(l),abs(j))):N
        ghat(k+N+1,j+N+1,l+N+1) = ghat(k+N+1,j+N+1,l+N+1) + dd{n+1}(j+n+1,k+n+1,l+n+1) * fhat(deg2dim(n)+(l+n)*(2*n+1)+(k+n+1));
        G( (k+N)*(2*N+1)^2 + (l+N)*(2*N+1) + (j+N+1), deg2dim(n)+(l+n)*(2*n+1)+(k+n+1) ) = dd{n+1}(j+n+1,k+n+1,l+n+1);
      end
    end
  end
end



a = wignerTrafomex(N,fhat,2^0);


fhat2 = fhat;
ind = 0;
for k=-N:N
  for l=-N:N
    for n = max(abs(k),abs(l)):N
      ind = ind+1;
      fhat2(ind) = fhat(deg2dim(n)+(l+n)*(2*n+1)+(k+n+1));
      G2(:,ind) = G(:,deg2dim(n)+(l+n)*(2*n+1)+(k+n+1));
    end
  end
end

b = G2*fhat2;
b = permute(reshape(b,2*N+1,2*N+1,2*N+1),[3,1,2]);


max(abs(b(:)-a(:)))



S = G2.'*G2;





%% S2 contains the blockmatrices of S


N=5;

dd={};
for n=0:N
  d = WignerD(pi/2,n);
  dd{n+1} = sqrt(2*n+1)*d.*reshape(d,2*n+1,1,2*n+1);%.*(1i.^(reshape(-n:n,1,1,[])-(-n:n)));
end


S2 = cell(2*N+1,2*N+1);

for k=-N:N
  for l=-N:N
    M=zeros(N-max(abs(k),abs(l))+1);
    ind = 1;
    for n = max(abs(k),abs(l)):N
      for m = max(abs(k),abs(l)):N
        
        M(ind) =  M(ind) + dd{n+1}(n+1,k+n+1,l+n+1)*dd{m+1}(m+1,k+m+1,l+m+1);
        for j=1:min(n,m)
          M(ind) =  M(ind) + 2*dd{n+1}(j+n+1,k+n+1,l+n+1)*dd{m+1}(j+m+1,k+m+1,l+m+1);
        end
        
        ind = ind+1;
      end
    end
    S2{k+N+1,l+N+1} = reshape(M,sqrt(ind-1),[]);
  end
end


% B=blkdiag(S2{:});
% B = B-full(S);
% max(abs(B(:)))


i=cellfun(@inv,S2,'UniformOutput',false);




%% compute pseudo inverse

clear 
rng(0)

N=64;

tic

dd={};    % 285MB for N=64
for n=0:N
  d = WignerD(pi/2,n);
  dd{n+1} = sqrt(2*n+1)*d.*reshape(d,2*n+1,1,2*n+1);%.*(1i.^(reshape(-n:n,1,1,[])-(-n:n)));
end

u = rand(deg2dim(N+1),1);

S = cell(2*N+1,2*N+1);
L = cell((2*N+1)^2,1);
ind = 1;

for k=-N:N
  for l=-N:N
    
    i = max(abs(k),abs(l));
    M = zeros(N+1,N+1-i);

    for n = i:N
      a = squeeze(dd{n+1}((0:n)+n+1,k+n+1,l+n+1));
      M(1:n+1,n+1-i) = a;
    end
    
    M(1,:) = sqrt(0.5)*M(1,:);
    S3 = 2*(M'*M);
    S{k+N+1,l+N+1} = S3;
 
    bds = max(abs(k),abs(l)):N;
    index = bds.*(2*bds-1).*(2*bds+1)/3 + (l+bds).*(2*bds+1) + (k+bds+1);
    u2 = u(index);

    A = S3\u2;
%     A = inv(S3)*u2;

    L{ind} = A;
    ind = ind+1;

  end
end

L = cell2mat(L);

toc



%%

clear 
rng(0)

N=40;

tic

dd={};    % 285MB for N=64
for n=0:N
  d = WignerD(pi/2,n);
  dd{n+1} = sqrt(2*n+1)*d.*reshape(d,2*n+1,1,2*n+1);%.*(1i.^(reshape(-n:n,1,1,[])-(-n:n)));
end

u = rand(deg2dim(N+1),1);

S = sparse(deg2dim(N+1),deg2dim(N+1));
ind = 0;

for k=-N:N
  for l=-N:N
    
    i = max(abs(k),abs(l));
    M = zeros(N+1,N+1-i);

    for n = i:N
      a = squeeze(dd{n+1}((0:n)+n+1,k+n+1,l+n+1));
      M(1:n+1,n+1-i) = a;
    end
    
    M(1,:) = sqrt(0.5)*M(1,:);
    S3 = 2*(M'*M);
    len = size(S3,1);
    S(ind+(1:len),ind+(1:len)) = S3;
    ind = ind + len;
%     bds = max(abs(k),abs(l)):N;
%     index = bds.*(2*bds-1).*(2*bds+1)/3 + (l+bds).*(2*bds+1) + (k+bds+1);
%     u2 = u(index);
% 
% %     A = S3\u2;
%     A = inv(S3)*u2;
%     L=[L;A];

  end
end
clear dd

toc

spy(S)


%%  D = F*G

clear 
rng(0)
N=1;
M=10;


D = zeros(M,deg2dim(N+1));

for m=1:M
  rot = rotation.rand;
  b=[];
  for k=0:N
    a = WignerD(rot,k);
    b = [b;a(:)];
  end
  D(m,:) = b.';
end


size(D)

rank(D)


spy(D'*D)
























