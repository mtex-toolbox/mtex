function e = cat(dim,varargin)
% implement cat for embedding
%
% Syntax 
%   e = cat(dim,e1,e2,e3)
%
% Input
%  dim - dimension
%  e1, e2, e3 - @embedding
%
% Output
%  e - @embedding
%
% See also
% embedding/horzcat, embedding/vertcat

% remove emtpy arguments
varargin(cellfun('isempty',varargin)) = [];
e = varargin{1};

for i=1:length(e.rank)
  
  ui =  cellfun(@(e) e.u{i},varargin,'UniformOutput',false);
  e.u{i} = cat(dim,ui{:});
  
end
