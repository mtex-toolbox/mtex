function dS = cat(dim,varargin)
% implement cat for dislocationSystem
%
% Syntax 
%   dS = cat(dim,dS1,dS2,dS3)
%
% Input
%  dim - dimension
%  dS1, dS2, dS3 - @dislocationSystem
%
% Output
%  dS - @dislocationSystem
%
% See also
% dislocationSystem/horzcat, dislocationSystem/vertcat

% remove emtpy arguments
varargin(cellfun('isempty',varargin)) = [];
dS = varargin{1};

dSb = cell(size(varargin)); dSl = dSb; dSu = dSb;
for i = 1:numel(varargin)
  dS2 = varargin{i};
  if ~isempty(dS2)
    dSb{i} = dS2.b;
    dSl{i} = dS2.l;
    dSu{i} = dS2.u;
  end
end

dS.b = cat(dim,dSb{:});
dS.l = cat(dim,dSl{:});
dS.u = cat(dim,dSu{:});
