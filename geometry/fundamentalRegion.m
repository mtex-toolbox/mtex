function  varargout = fundamentalRegion(varargin)
% get the fundamental zone in orientation space for a symmetry
%
% Syntax
%   oR = fundamentalRegion(cs)
%   oR = fundamentalRegion(cs1,cs2)
%   [oR,dcs,nSym] = fundamentalRegion(ori)
%   [oR,dcs,nSym] = fundamentalRegion(odf)
%
% Input
%  cs,cs1,cs2 - @symmetry
%  ori - @orientation
%  odf - @ODF
%
% Output
%  oR   - @orientationRegion
%  dcs  - common symmetries in cs1 and cs2
%  nSym - number of zones
%
% Options
%  invSymmetry - wheter mori == inv(mori)
%

cs = varargin{1}.CS;
if varargin{1}.antipodal, varargin = [varargin,'antipodal']; end
varargin{1} = varargin{1}.SS;

[varargout{1:nargout}] = fundamentalRegion(cs,varargin{:});
