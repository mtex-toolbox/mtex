function sS = cat(dim,varargin)
% implement cat for slipSystem
%
% Syntax 
%   sS = cat(dim,sS1,sS2,sS3)
%
% Input
%  dim - dimension
%  sS1, sS2, sS3 - @slipSystem
%
% Output
%  sS - @slipSystem
%
% See also
% slipSystem/horzcat, slipSystem/vertcat

% remove emtpy arguments
varargin(cellfun('isempty',varargin)) = [];
sS = varargin{1};

sSb = cell(size(varargin)); sSn = sSb; sSCRSS = sSb;
for i = 1:numel(varargin)
  sS2 = varargin{i};
  if ~isempty(sS2)
    sSb{i} = sS2.b;
    sSn{i} = sS2.n;
    sSCRSS{i} = sS2.CRSS;
  end
end

sS.b = cat(dim,sSb{:});
sS.n = cat(dim,sSn{:});
sS.CRSS = cat(dim,sSCRSS{:});
