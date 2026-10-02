function x = proxTVSquare(x,lambda,alpha)
% the TV proximal steps along the rows and the columns of a square grid, x n x m x 4

[n,m,~] = size(x);
lambda = alpha * lambda; % only the product matters

% apply proxTV horizontally
mMax = 2*floor((m+1)/2)-1; % round down to an odd number
[x(:,2:2:mMax,:),x(:,3:2:mMax,:)] = proxTV(x(:,2:2:mMax,:),x(:,3:2:mMax,:),lambda);

mMax = 2*floor(m/2); % round down to an even number
[x(:,1:2:mMax,:),x(:,2:2:mMax,:)] = proxTV(x(:,1:2:mMax,:),x(:,2:2:mMax,:),lambda);

% apply proxTV vertically
nMax = 2*floor((n+1)/2)-1; % round down to an odd number
[x(2:2:nMax,:,:),x(3:2:nMax,:,:)] = proxTV(x(2:2:nMax,:,:),x(3:2:nMax,:,:),lambda);

nMax = 2*floor(n/2); % round down to an even number
[x(1:2:nMax,:,:),x(2:2:nMax,:,:)] = proxTV(x(1:2:nMax,:,:),x(2:2:nMax,:,:),lambda);
