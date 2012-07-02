function C = mtimesxx(A,B)
% compute matrix multipliaction with singleton expansion
%
%% Input
%
%
%% Output


% get maximum dimension
nd = max([4,ndims(A),ndims(B)]);

% get original sizes
szA = size(A);
szA(ndims(A)+1:nd) = 1;
szB = size(B);
szB(ndims(B)+1:nd) = 1;

% get max size
sz = max(szA,szB);

% create output
C = zeros([szA(1),szB(2),sz(3:end)]);

% compute singleton expansion 
ind = 1:prod(sz(3:end));
  
[sub{1:length(sz)-2}] = ind2sub(sz(3:end),ind);
  
subA = cell(1,length(sub));
subB = cell(1,length(sub));
for d = 1:length(sub)
  
  subA{d} = min(sub{d},szA(2+d));
  subB{d} = min(sub{d},szB(2+d));
  
end

indA = sub2ind(szA(3:end),subA{:});
indB = sub2ind(szB(3:end),subB{:});  
  
% compute matrix products  
for i = ind
  C(:,:,i) = A(:,:,indA(i)) * B(:,:,indB(i));
end

end
