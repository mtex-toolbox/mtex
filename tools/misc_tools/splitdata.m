function ind = splitdata(x,n,varargin)
% make n - partitions of a list, returns its indices

[x,ndx] = sort(x,varargin{:});

k = 1;
xf = cell(1,n);
xf{1} = {x};

while k < n
  xf{k+1} = cell(1,2^k);
  
  for l = 1:(2^(k-1))
    [m, xf{k+1}{l*2-1}, xf{k+1}{l*2}] = split(xf{k}{l});
  end
  k = k+1;
end

ind = xf{k};
ind = ind(~cellfun('isempty',ind));

cs = cellfun('length',ind);
csz = [0 cumsum(cs)];

for k=1:length(ind)
  ind{k} = ndx(csz(k)+1:csz(k+1));  
end

function [m, xl, xr] = split(x)

m = mean(x);
xl = x(x <= m);
xr = x(x > m);
