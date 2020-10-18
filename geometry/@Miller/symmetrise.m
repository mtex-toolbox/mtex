function varargout = symmetrise(m,varargin)
% symmetrcially equivalent directions and its multiple
%
% Syntax
%   mSym = symmetrise(m)
%
%   % include antipodal symmetry
%   mSym = symmetrise(m,'antipodal')
%
%   % exclude antipodal symmetry
%   mSym = symmetrise(m,'noAntipodal')
%
%   % every symmetrically equivalent direction only once 
%   [mSym,l,sym] = symmetrise(m,'unique')
%
%   % every symmetrically equivalent axis only once 
%   [mSym,l,sym] = symmetrise(v,S,'unique','noAntipodal')
%
% Input
%  v - @Miller
%
% Output
%  mSym - sym * m  @Miller
%  l    - multiplicity of the crystal directions
%  sym  - @rotation
%
% Flags
%  antipodal   - include <VectorsAxes.html antipodal symmetry>
%  noAntipodal - do not include antipodal symmetry (without option unique)
%  noAntipodal - do not remove antipodal vectors (with option unique)
%  unique      - only return distinct axes or directions (noAntipodal)
%

[varargout{1:nargout}] = symmetrise@vector3d(m,m.CS,varargin{:});
