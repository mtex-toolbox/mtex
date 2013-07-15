function fmc = FMC_Coarsen(fmc)
%Performs one coarsening step.


fmc = part0EdgeDilution(fmc);
fmc = part1CoarseSeeds(fmc);
fmc = part2CreateP(fmc);
fmc = part3NormalizeP(fmc);
fmc = part6InterpWeights(fmc);
fmc = part7BiasWeights(fmc);
fmc = part8Salieciens(fmc);

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
alphaSumV = fmc.alpha*(sum(fmc.W,2)-diag(fmc.W));

% if s == 1 sort by weights
% else sort by size
if fmc.s == 1
  [~,iorder] = sort(sum(fmc.W),'descend');
else
  [~,iorder] = sort(fmc.v, 'descend');
  iorder = iorder';
end

[i,~,w] = find(fmc.W);
cs   = [0 cumsum(full(sum(fmc.W>0,1)))];
Finv = false(fmc.sizeW,1);
% traverse all rows of W and find the indices of all nonzero elements
% that are in F. ind1 is the vector of indices of NZ entries of the rowI'th row
%ind2 contains the indices of ind1 that are coarse nodes
%sum of the weights between I'th pixel and nodes that are coarse
for k = iorder
  s    = cs(k)+1:cs(k+1);
  fsub = Finv(i(s)); %elements of row
  wsub = w(s); % weights of row
  Finv(k) = sum(wsub(fsub)) < alphaSumV(k);
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
ind  = find(Psum > 0);
i = find(Psum <= 0); 

fmc.P(ind,:) = bsxfun(@rdivide,fmc.P(ind,:),Psum(ind));

% i = find(fmc.F);
fmc.Celements = [fmc.Celements i'];
fmc.sizeWnext = numel(fmc.Celements);

[~,j] = ismember(i,fmc.Celements);
fmc.P = sparseConcat(fmc.P,i,j,ones(numel(i),1), [fmc.sizeW, fmc.sizeWnext]);

end

%% part 6: Interpolate weights
function fmc = part6InterpWeights(fmc)

P = fmc.P;
Celements = fmc.Celements;

%Calculate the new W and links
fmc.Wcoarse   = P'*fmc.W*P;
fmc.A_Dcoarse = P'*fmc.A_D*P;
%calculate the number of data points in each new node
fmc.vcoarse=P'*fmc.v;


%Initialize the new cluster averages
Ocoarse = fmc.O(Celements);


%Qvar is the variance of each new node
Qvar=zeros(fmc.sizeWnext,1);

%Calculate the new quaternion variances and averages using
%the online variance updating algorithm
for i=1:fmc.sizeWnext
  elelist=find(P(:,i)>.05)';
  elelist(elelist==Celements(i))=[];
  Qvar(i)=fmc.Varin(Celements(i));
  vcum=fmc.v(Celements(i));
  fmc.O(elelist) = project2FundamentalRegion(fmc.O(elelist),fmc.CS,fmc.CS,Ocoarse(i));
  for j=elelist
    q = Ocoarse(i)'.*fmc.O(j);
    del =  real(2*acosd(max(abs(dot_outer(q,fmc.CS)),[],2)));
    if del<fmc.quatmax
      vele=fmc.v(j)*P(j,i);
      vtmp=vcum+vele;
      Ocoarse(i) = mean([Ocoarse(i),fmc.O(j)],'weights',[vcum, vele]);
      
      Qvar(i)=vcum*Qvar(i)+vele*fmc.Varin(j)+(del^2*(vcum*vele)/vtmp);       %Single-pass Variance
      Qvar(i)=Qvar(i)/vtmp;
      vcum=vtmp;
    else
      P(j,i)=0;
    end
  end
  
end

fmc.Qvar = Qvar;
fmc.P = P;
fmc.Ocoarse = Ocoarse;


clear Celements;
clear v vcum vtemp vele;
clear del elelist;
end
%% part 7: Bias weights
function fmc = part7BiasWeights(fmc)
%Use the Qvar and misorientation to find the Mahalanobis distance, then use
%that to reweight the nodes.
[Dl,Dr] = find(fmc.Wcoarse);  % list of cells

q = inverse(fmc.Ocoarse(Dl)).*fmc.Ocoarse(Dr);
misorientation =  real(2*acosd(max(abs(dot_outer(q,fmc.CS)),[],2)));
clear q

Wthreshold = 1e-3;
smallMis = abs(misorientation) <= Wthreshold;

Dl1 = Dl(~smallMis);
Dr1 = Dr(~smallMis);
Dl2 = Dl(smallMis);
Dr2 = Dr(smallMis);
misorientation = misorientation(~smallMis);
clear smallMis Dl Dr

sqrtstuff = sqrt(min(fmc.Qvar(Dl1),fmc.Qvar(Dr1)));

bias = exp(-fmc.cmaha*(abs(misorientation)-1.*sqrtstuff)./sqrtstuff);
bias = sparse(Dl1, Dr1, bias, fmc.sizeWnext, fmc.sizeWnext) +...
  sparse(Dl2, Dr2, 1,fmc.sizeWnext, fmc.sizeWnext);
clear Dl1 Dr1 Dl2 Dr2 N

fmc.Wcoarse = fmc.Wcoarse.*bias;


end

%% part 8: Calculate saliencies
function fmc = part8Salieciens(fmc)

fmc.Sal = 2*((sum(fmc.Wcoarse)' - diag(fmc.Wcoarse)).*diag(fmc.A_Dcoarse))./ ...
  (diag(fmc.Wcoarse).*(sum(fmc.A_Dcoarse,2)-diag(fmc.A_Dcoarse)));

end

