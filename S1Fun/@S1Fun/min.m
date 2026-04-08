function varargout = min(varargin)
% global, local and pointwise minima of periodic functions
%
% Syntax
%   % global minimum
%   [v,pos] = min(sF)
%
%   % local minima
%   [v,pos] = min(sF,'numLocal',5) % the 5 smallest local minima
%
%   % pointwise minima
%   sF = min(sF, c) % pointwise minimum of a S1Fun and the constant c
%   sF = min(sF1, sF2) % pointwise minimum of two S1Fun's
%   sF = min(sF1, sF2, 'bandwidth', bw) % specify the new bandwidth
%
%   % pointwise minima of a vector valued function along dim
%   sF = min(S1Fmulti,[],dim)
%
% Input
%  sF, sF1, sF2 - @S1Fun
%  S1Fmulti     - a vector valued @S1Fun
%  c            - double
%
% Output
%  v - double
%  pos - double
%
% Options
%  kmax          - number of iterations
%  numLocal      - number of local minima to return
%  startingNodes - double
%  tolerance     - minimum distance between two peaks
%  resolution    - minimum step size 
%  maxStepSize   - maximm step size
%
% See also
% S1Fun/max

varargin{1} = -varargin{1};
if nargin>1 && ( ~isempty(varargin{2}) && isa(varargin{2},'double') || isa(varargin{2},'S1Fun' ))
  varargin{2} = -varargin{2};
end

[varargout{1:nargout}] = max(varargin{:});

varargout{1} = -varargout{1};