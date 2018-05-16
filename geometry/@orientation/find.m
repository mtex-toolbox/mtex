function varargout = find(lookup,ref,varargin)
% return indece and distance of all nodes within a eps neighborhood
%
% Syntax  
%   % find for each orientation in ref the closest orientation in lookup 
%   [ind,d] = find(table,ref,radius)
%
%   % find for each orientation in ref the closest orientation in lookup 
%   [ind,d,i,j] = find(table,ref,radius)
%
%   % find for each orientation in ref all orientation in lookup that have
%   % angle not larger then epsilon
%   [ind,d] = find(table,rotation,epsilon)
%
% Input
%  table - @orientation
%  ref   - @orientation
%  epsilon - double
%
% Output
%  ind - 
%  d - 
%

if nargout <=2
  [varargout{1:nargout}] = find@quaternion(lookup,ref,varargin{:});
  return;
end
  
