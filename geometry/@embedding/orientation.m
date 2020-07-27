function ori = orientation(obj)
% translate an embedding back into an orientation
% 
% Description
% Given an arbitrary embedding it is projected back to the manifold of
% orientations.
%
% Syntax
%   ori = orientation(e)
%
% Input
%  e - @embedding
%
% Output
%  ori - @orientation
%

ori = project(obj);

end