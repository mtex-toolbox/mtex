function r = cat(dim,varargin)
% implement cat for rotation
%
% Syntax 
%   r = cat(dim,r1,r2,r3)
%
% Input
%  dim - dimension
%  r1, r2, r3 - @rotation
%
% Output
%  r - @rotation
%
% See also
% rotation/horzcat, rotation/vertcat

% remove emtpy arguments
varargin(cellfun('isempty',varargin)) = [];

% ensure result is at least rotation
r = varargin{1};
if ~isa(r,'rotation'), r = rotation(r);end

% convert to cells
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

% concatenate cells
r.a = cat(dim,a{:});
r.b = cat(dim,b{:});
r.c = cat(dim,c{:});
r.d = cat(dim,d{:});
r.i = cat(dim,inv{:});
