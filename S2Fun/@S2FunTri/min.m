function [sF,pos] = min(sF,varargin)
% global, local and pointwise minima of spherical functions
%
% Syntax
%   [value,pos] = min(sF) % the position where the minimum is atained
%
%   [value,pos] = min(sF,'numLocal',5) % the 5 largest local minima
%
%   sF = min(sF, c) % minimum of a spherical functions and a constant
%   sF = min(sF1, sF2) % minimum of two spherical functions
%   sF = min(sF1, sF2, 'bandwidth', bw) % specify the new bandwidth
%
%   % compute the minimum of a vector valued function along dim
%   sF = min(sFmulti,[],dim)
%
% Input
%  sF, sF1, sF2 - @S2Fun
%  sFmulti - a vector valued @S2Fun
%  c       - double
%
% Output
%  value - double
%  pos   - @vector3d
%  S2F   - @S2Fun
%
% Options
%  numLocal      - number of peaks to return
%

if isnumeric(sF)
  sF = min(varargin{1},sF,varargin{2:end});
  return
end

% pointwise minimum of two spherical functions
if nargin > 1 && isa(varargin{1}, 'S2FunTri') && varargin{1}.tri==sF.tri

  sF.values = min(sF.values, varargin{1}.values);

elseif ( nargin > 1 ) && ( isa(varargin{1}, 'S2Fun') )

  sF.values = min( sF.values, reshape(varargin{1}.eval(sF.vertices),size(sF.values)) );  

% pointwise minimum of spherical harmonics
elseif ( nargin > 1 ) && ~isempty(varargin{1}) && ( isa(varargin{1}, 'double') )
  
  sF.values = min(sF.values,varargin{1});

else % detect global minima
  
  % TODO: local
  nL = get_option(varargin,'numLocal',1);
  [value,pos] = mink(sF.values(:),nL);
  pos = sF.vertices(pos);
  sF = value;

end



end