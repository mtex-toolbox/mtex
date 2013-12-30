function N = calcNeighbour(tetra)
% compute which tetrahegons are connceted by which face

% indicence matrix tetra -> ori
I = sparse(repmat((1:size(tetra,1))',1,4),double(tetra),1);
      
% compute adjacence matrices
A = (I * I')==3;

[u,v] = find(A); % v is sorted

s = tetra(v,:) - tetra(u,:);

% side is first minus of s or last plus
[ind,side] = max(s<0,[],2);
% or last plus
[~,side2] = max(fliplr(s>0),[],2);
side(~ind) = 5-side2(~ind);

% set up neigbouring list
ind = 4*(0:(size(A,1)-1));
ind = repmat(ind,4,1) + reshape(side,4,[]);
N(ind) = int32(u);
N = reshape(N,4,[]).';
     
end
