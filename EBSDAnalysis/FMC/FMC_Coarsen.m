function fmc = FMC_Coarsen(fmc)
%Performs one coarsening step.

fmc.sizeW = fmc.sizeWnext;

fmc = part0EdgeDilution(fmc);
fmc = part1CoarseSeeds(fmc);
fmc = part2CreateP(fmc);
fmc = part3NormalizeP(fmc);
fmc = part5CoarseWeightsUpdate(fmc);
fmc = part6InterpWeights(fmc);
fmc = part7BiasWeights(fmc);
fmc = part8Salieciens(fmc);

fmc.v     = fmc.vcoarse;


end

%% part 0: Edge dilution procedure in Kushnir 2006
function fmc = part0EdgeDilution(fmc)

[i,j,w] = find(fmc.W);
sumW    = sum(fmc.W,2)-diag(fmc.W);                  %Total weights of each entry to its neighbors, not counting itself
n       = sum(fmc.W>0)';  %Total numer of neighbors each entry has

%If the weight between two nodes, (e.g. a to b) is less than the total
%weights of a to all its neighbors normalized by the total number of a's
%neighbors, set that weight to zero. Same for b.
w( w < (sumW(i)./(fmc.gammaW*n(i)))  &...
  w < (sumW(j)./(fmc.gammaW*n(j))) ) = 0;

fmc.W = sparse(i,j,w,fmc.sizeW,fmc.sizeW);

end


%% part 1: Select Coarse Seeds
function fmc = part1CoarseSeeds(fmc)
%F represents whether the nodes are Coarse nodes or not.
%0 means they are, 1 means they aren't

%Celements is the list of nodes that are coarse nodes.
%The nodes are considered in order of descending size
alphaSumV = full(fmc.alpha*(sum(fmc.W,2)-diag(fmc.W)));

% if s == 1 sort by weights
% else sort by size
if fmc.sLevel == 1
  [tmp,iorder] = sort(sum(fmc.W),'descend');
else
  [tmp,iorder] = sort(fmc.v, 'descend');
  iorder = iorder';
end

[i,tmp,w] = find(fmc.W);
cs   = [0 cumsum(full(sum(fmc.W>0,1)))];
Finv = false(fmc.sizeW,1);
% traverse all rows of W and find the indices of all nonzero elements
% that are in F. ind1 is the vector of indices of NZ entries of the rowI'th row
%ind2 contains the indices of ind1 that are coarse nodes
%sum of the weights between I'th pixel and nodes that are coarse

% add most weighted adjacent node if degree of weights less than alphasum
for k = iorder
  s    = cs(k)+1:cs(k+1);
  wsub = w(s); % weights of row
  Finv(k) = sum(wsub(Finv(i(s)))) < alphaSumV(k);
end

fmc.sizeWnext = nnz(Finv);
fmc.Celements = find(Finv)';
fmc.F         = ~Finv;

end

%% part 2: Create P
function fmc = part2CreateP(fmc)

% if F(i)==1, P(i,:)=W(i,Celements);
%populate the rows of P that correspond to fine nodes with weights between themselves and the coarse nods
Pfine = sparse(fmc.sizeW, fmc.sizeWnext);
Pfine(fmc.F,:) = fmc.W(fmc.F,fmc.Celements);

% if F(i)==0, P(i, Celements == i )=1;
%coarse nodes are fully weighted with their seeds
Pcoarse = sparse(fmc.Celements, 1:fmc.sizeWnext, 1, fmc.sizeW, fmc.sizeWnext);

fmc.P = Pfine + Pcoarse;

end

%% part 3: Normalize P
function fmc = part3NormalizeP(fmc)

% if sum(P(i,:))>0, P(i,:)=P(i,:)/sum(P(i,:));
Psum = sum(fmc.P,2);
[i,j,p] = find(fmc.P);
fmc.P = sparse(i,j,p./Psum(i),fmc.sizeW,fmc.sizeWnext);

i = find(Psum <= 0);
fmc.Celements = [fmc.Celements i'];
fmc.sizeWnext = numel(fmc.Celements);

[tmp,j] = ismember(i,fmc.Celements);
fmc.P = sparseConcat(fmc.P,i,j,ones(numel(i),1), [fmc.sizeW, fmc.sizeWnext]);

end


%% part 5:
function fmc = part5CoarseWeightsUpdate(fmc)

P = fmc.P;
%Calculate the new W and links
fmc.W   = P'*fmc.W*P;
fmc.A_D = P'*fmc.A_D*P;
%calculate the number of data points in each new node
fmc.vcoarse=P'*fmc.v;

end

%% part 6: Interpolate weights
function fmc = part6InterpWeights(fmc)

Celements = fmc.Celements(:);

%Qvar is the variance of each new node

[ii,jj,pp] = find(fmc.P);
t = pp > .05 & ii ~= Celements(jj);
i = ii(t); j = jj(t); p = pp(t);

O  = fmc.O(i);
Oc = fmc.O(Celements);

% project to fundamental region of Ocoarse_j
O = project2FundamentalRegion(quaternion(O),fmc.CS,quaternion(Oc(j)));

O     = reshape(squeeze(double(O)),[],4);
Oc    = reshape(squeeze(double(Oc)),[],4);

QVari = fmc.Qvar(i);
Qvar  = fmc.Qvar(Celements);

vi    = fmc.v(i).*p;
vc    = fmc.v(Celements);

% % Calculate the new quaternion variances and averages using
% % the online variance updating algorithm
for k=1:size(O,1)
  jk = j(k);
  
  oi = O(k,:);
  oc = Oc(jk,:);
  
  d = abs(oi*oc');
  if d > fmc.quatmax2
    del = 2*real(acosd(d));
    
    vt=vc(jk)+vi(k);
    
    w = [vc(jk); vi(k)]./vt;
    Q = [oc;oi];
    
    [ev,ew] = eig(Q'*diag(w)*Q);
    Oc(jk,:) = ev(:,diag(ew)>.5);
    
    Qvar(jk)=vc(jk)*Qvar(jk)+vi(k)*QVari(k)+(del^2*(vc(jk)*vi(k))/vt);       %Single-pass Variance
    Qvar(jk)=Qvar(jk)/vt;
    vc(jk)=vt;
    
  else
    p(k) = 0;
  end
end

P = sparse(i,j,p,fmc.sizeW,fmc.sizeWnext) + ...
  sparse(ii(~t),jj(~t),pp(~t),fmc.sizeW,fmc.sizeWnext);
% P(sub2ind(size(P),i,j)) = p; % slow for large

fmc.Qvar = Qvar;
fmc.O = quaternion(Oc.').';
fmc.P = P;

end

%% part 7: Bias weights
function fmc = part7BiasWeights(fmc)
%Use the Qvar and misorientation to find the Mahalanobis distance, then use
%that to reweight the nodes.

[i,j] = find(triu(fmc.W));

misorientation = angle(orientation(fmc.O(i),fmc.CS),orientation(fmc.O(j),fmc.CS));
misorientation = misorientation/degree;

Wthreshold = 1e-3;
smallMis = abs(misorientation) <= Wthreshold;

i1 = i(~smallMis); j1 = j(~smallMis);
i2 = i(smallMis);  j2 = j(smallMis);
misorientation = misorientation(~smallMis);

sqrtstuff = sqrt(min(fmc.Qvar(i1),fmc.Qvar(j1)));

bias = exp(-fmc.cmaha*(abs(misorientation)-1.*sqrtstuff)./sqrtstuff);
bias = sparse(i1, j1, bias, fmc.sizeWnext, fmc.sizeWnext) +...
  sparse(i2, j2, 1,fmc.sizeWnext, fmc.sizeWnext);

bias = bias + triu(bias,1)';

fmc.W = fmc.W.*bias;


end

%% part 8: Calculate saliencies
function fmc = part8Salieciens(fmc)

fmc.Sal = 2*((sum(fmc.W)' - diag(fmc.W)).*diag(fmc.A_D))./ ...
  (diag(fmc.W).*(sum(fmc.A_D,2)-diag(fmc.A_D)));

end

