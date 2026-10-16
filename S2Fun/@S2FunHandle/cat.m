function sF = cat(dim,varargin)
% overloads cat
%
% Syntax
%   sF = cat(dim,sF1,sF2,...)
%
% Input
%  dim       - dimension
%  sF1, sF2  - @S2Fun
%
% Output
%  sF - @S2FunHandle evaluating all functions

varargin(cellfun('isempty',varargin)) = [];
sF = varargin{1};

for i = 2:numel(varargin)
  ensureCompatibleSymmetries(sF,varargin{i});
  sF.fun = @(v) cat(1+dim,reshape(sF.eval(v),[numel(v) size(sF)]), ...
    reshape(varargin{i}.eval(v),[numel(v) size(varargin{i})]));
end

end
