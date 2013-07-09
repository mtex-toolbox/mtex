%Performs one coarsening step.


%% part 0: Edge dilution procedure in Kushnir 2006

Sums=sum(W,2)-diag(W);                  %Total weights of each entry to its neighbors, not counting itself
[newRows,newCols,newVals]=find(W);      
lengths = sum(W>0)';  %Total numer of neighbors each entry has

%If the weight between two nodes, (e.g. a to b) is less than the total
%weights of a to all its neighbors normalized by the total number of a's
%neighbors, set that weight to zero. Same for b. 
parfor i=1:length(newRows)
   if ( ( newVals(i) < (Sums(newRows(i))/(gammaW*lengths(newRows(i)))) ) &&...
        ( newVals(i) < (Sums(newCols(i))/(gammaW*lengths(newCols(i)))) ) ) 
       newVals(i)=0;
   end
end
clear Sums lengths;

W = sparse(newRows,newCols,newVals,sizeW,sizeW);
clear newRows newCols newVals;


%% part 1: Select Coarse Seeds

%F represents whether the nodes are Coarse nodes or not.
%0 means they are, 1 means they aren't
Finv = false(sizeW,1); %Initialize inverse(F) Nx1 vector of zeros

%Celements is the list of nodes that are coarse nodes.
%The nodes are considered in order of descending size
Celements = zeros(1,sizeW); %preallocate memory
CEindex = 1;

alphaSumV = alpha*(sum(W,2)-diag(W));   

% if s == 1 sort by weights
% else sort by size
if s == 1
    [~,iorder] = sort(sum((W)),'descend');        
else
    [~,iorder] = sort(v, 'descend');
    iorder = iorder';
end

for rowI = iorder %for all rows of W
    %find the indices of all nonzero elements that are in F
    [~,ind1] = find(W(rowI,:)); %ind1 is the vector of indices of NZ entries of the rowI'th row
    ind2 = ind1(Finv(ind1));    %ind2 contains the indices of ind1 that are coarse nodes
    sumK = sum(W(rowI,ind2));   %sum of the weights between I'th pixel and nodes that are coarse

    if sumK<alphaSumV(rowI)
        Finv(rowI)=1;
        Celements(CEindex) = rowI; %add to Celements
        CEindex = CEindex+1;
    end
end

Celements(CEindex:end)=[]; %remove unneeded memory
sizeWnext = length(Celements);
F = ~Finv;  % change back to F

clear Finv NNZind ind1 ind2 rowI CEindex sumK alphaSumV sumWeights;
%% part 2: Create P

% if F(i)==1, P(i,:)=W(i,Celements);
%populate the rows of P that correspond to fine nodes with weights between themselves and the coarse nods
Pfine=sparse(sizeW, sizeWnext);
Pfine(F,:) = W(F,Celements); 

% if F(i)==0, P(i, Celements == i )=1;
%coarse nodes are fully weighted with their seeds
Pcoarse = sparse(Celements, 1:sizeWnext, 1, sizeW, sizeWnext);

P = Pfine + Pcoarse;
clear F


%% part 3: Normalize P

Windices = (1:sizeW)';

% if sum(P(i,:))>0, P(i,:)=P(i,:)/sum(P(i,:));
Psum = sum(P,2);
WindMore = Windices(Psum > 0);
P(WindMore,:)=bsxfun(@rdivide,P(WindMore,:),Psum(WindMore));
clear WindMore;

%'if sum<0'
newRows = Windices(Psum <= 0); clear Windices Psum;
origsizeWnext = sizeWnext;
Celements = [Celements newRows'];

newCols = zeros(length(newRows),1);

parfor i = 1:length(newRows)
    newCols(i) = find(Celements(1:origsizeWnext+i) == newRows(i));
end

sizeWnext = length(Celements);
P = sparseConcat(P,newRows,newCols,ones(length(newRows),1), [sizeW, sizeWnext]);
clear newRows newCols newSize Psum;

%% part 6: Interpolate weights

%Calculate the new W and links
Wcoarse=P'*W*P; clear W;
A_Dcoarse=P'*A_D*P; clear A_D;

%Initialize the new cluster averages
Ocoarse = O(Celements);

%calculate the number of data points in each new node            
vcoarse=P'*v;

%Qvar is the variance of each new node
Qvar=zeros(sizeWnext,1);

%estimate size of array
newRows = zeros(sizeWnext,1);
newCols = zeros(sizeWnext,1);

%Calculate the new quaternion variances and averages using
%the online variance updating algorithm 
for i=1:sizeWnext
    elelist=find(P(:,i)>.05)';
    elelist(elelist==Celements(i))=[];
    Qvar(i)=Varin(Celements(i));
    vcum=v(Celements(i));
    O(elelist) = project2FundamentalRegion(O(elelist),CS,CS,Ocoarse(i));
    for j=elelist
        q = Ocoarse(i)'.*O(j);
        del =  real(2*acosd(max(abs(dot_outer(q,CS)),[],2))); 
        if del<quatmax
            vele=v(j)*P(j,i);
            vtmp=vcum+vele; 
            Ocoarse(i) = mean([Ocoarse(i),O(j)],'weights',[vcum, vele]);

            Qvar(i)=vcum*Qvar(i)+vele*Varin(j)+(del^2*(vcum*vele)/vtmp);       %Single-pass Variance
            Qvar(i)=Qvar(i)/vtmp;
            vcum=vtmp;
        else
            P(j,i)=0;
        end
    end

end


clear Celements; 
clear v vcum vtemp vele;
clear del elelist;

%% part 7: Bias weights

%Use the Qvar and misorientation to find the Mahalanobis distance, then use
%that to reweight the nodes.   
[Dl,Dr] = find(Wcoarse);  % list of cells

q = Ocoarse(Dl)'.*Ocoarse(Dr);
misorientation =  real(2*acosd(max(abs(dot_outer(q,CS)),[],2)));
clear q

Wthreshold = 1e-3;
smallMis = abs(misorientation) <= Wthreshold;

Dl1 = Dl(~smallMis);
Dr1 = Dr(~smallMis);
Dl2 = Dl(smallMis);
Dr2 = Dr(smallMis);
misorientation = misorientation(~smallMis);
clear smallMis Dl Dr

sqrtstuff = sqrt(min(Qvar(Dl1),Qvar(Dr1)));

bias = exp(-cmaha*(abs(misorientation)-1.*sqrtstuff)./sqrtstuff);
bias = sparse(Dl1, Dr1, bias, sizeWnext, sizeWnext) + sparse(Dl2, Dr2, 1, sizeWnext, sizeWnext);
clear Dl1 Dr1 Dl2 Dr2 N

Wcoarse = Wcoarse.*bias;


%% part 8: Calculate saliencies

Lcoarse=sparse(1:sizeWnext,1:sizeWnext,sum(Wcoarse)) - Wcoarse;
Sal=zeros(sizeWnext,1);

parfor i=1:sizeWnext
    Sal(i)=2*(Lcoarse(i,i)*(A_Dcoarse(i,i)))/(Wcoarse(i,i)*(sum(A_Dcoarse(:,i))-A_Dcoarse(i,i)));
end
clear Lcoarse


