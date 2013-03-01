function varargout = symmetrise(q,CS,SS,varargin)
% symmetrcially equivalent orientations
%
%% Input
%  q  - @quaternion
%  CS - crystal @symmetry
%  SS - specimen @symmetry
%
%% Output
%  q - symmetrically equivalent orientations CS x SS x q
%
%% See also
% CrystalSymmetries

%% !!!!!! very bad workaround !!!!!!!!
% somtimes this function gets called although first argument is vector3d
if isa(q,'vector3d')
  varargin = [{CS,SS},varargin];
  isMiller = cellfun(@(x) isa(x,'Miller'),varargin);
  varargin(isMiller) = [];
  [varargout{1:nargout}] = symmetrise(q,varargin{:});
  return
end  

%%  
q = (q * CS).'; % CS x M
if nargin>2 && length(SS)>1
  q = SS * q;     % SS x (CS X M)
  lSS = length(SS);
else
  lSS = 1;
end

varargout{1} = reshape(q,length(CS) * lSS,[]); % (CSxSS) x M
