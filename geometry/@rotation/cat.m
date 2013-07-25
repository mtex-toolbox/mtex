function r = cat(dim,varargin)
%

r = rotation(varargin{1});

inv = cell(size(varargin));
a = inv; b = a; c = a; d = a;

for i = 1:numel(varargin)
  
  x = varargin{i};
  a{i} = x.a;
  b{i} = x.b;
  c{i} = x.c;
  d{i} = x.d;

  if ~isa(x,'rotation') || isempty(x.i)
    inv{i} = false(size(x));
  else
    inv{i} = x.i;
  end 
  
end

r.a = cat(dim,a{:});
r.b = cat(dim,b{:});
r.c = cat(dim,c{:});
r.d = cat(dim,d{:});
r.i = cat(dim,inv{:});
