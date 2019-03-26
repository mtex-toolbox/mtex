function x = proxTVhex(x,lambda,alpha,varargin)

[n,m] = size(x);
lambda = alpha * lambda; % only the product matters

% apply proxTV horizontally in the rows
mMax = 2*floor((m+1)/2)-1; % round down to an odd number
[x(:,2:2:mMax),x(:,3:2:mMax)] = proxTV(x(:,2:2:mMax),x(:,3:2:mMax),lambda,varargin{:});

mMax = 2*floor(m/2); % round down to an even number
[x(:,1:2:mMax),x(:,2:2:mMax)] = proxTV(x(:,1:2:mMax),x(:,2:2:mMax),lambda,varargin{:});

% apply proxTV vertically
nMax = 2*floor((n+1)/2)-1; % round down to an odd number
[x(2:2:nMax,:),x(3:2:nMax,:)] = proxTV(x(2:2:nMax,:),x(3:2:nMax,:),lambda,varargin{:});

nMax = 2*floor(n/2); % round down to an even number
[x(1:2:nMax,:),x(2:2:nMax,:)] = proxTV(x(1:2:nMax,:),x(2:2:nMax,:),lambda,varargin{:});

%apply proxTV vertically with changing rows
if (n>2)&&(m>1)
    nMax = 2*floor((n+1)/2)-1; % round down to an odd number
    [x(2:2:nMax,1:m-1),x(3:2:nMax,2:m)] = proxTV(x(2:2:nMax,1:m-1),x(3:2:nMax,2:m),lambda,varargin{:});
end

if (n>1)&&(m>1)
    nMax = 2*floor(n/2); % round down to an even number
    [x(1:2:nMax,2:m),x(2:2:nMax,1:m-1)] = proxTV(x(1:2:nMax,2:m),x(2:2:nMax,1:m-1),lambda,varargin{:});
end