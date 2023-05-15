%% Test approximation-method
clear 
rng(0)

G = SO3Fun.dubna;% G.CS=specimenSymmetry;
figure(1)
plot(G)
q = orientation.rand(1e5,G.CS);
% q = G.discreteSample(6e4);
f = G.eval(q);

F2 = SO3FunHarmonic.approximation(q,f,'tol',1e-6,'maxit',50,'bandwidth',25)
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



%% More Penrose Pseudo Inverse of Representationbased Wigner Transform
clear

N=3;

G = sparse((2*N+1)^3,deg2dim(N+1));
dd={};
for n=0:N

  d = Wigner_D(n,pi/2);
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






