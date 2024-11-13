function plane = cat(dim,varargin)
% implement cat for plane3d
%
% Syntax 
%   v = cat(dim,p1,p2,p3)
%
% Input
%  dim - dimension
%  p1, p2, p3 - @plane3d
%
% Output
%  v - @plane3d
%
% See also
% plane3d/horzcat, plane3d/vertcat


% remove empty arguments
varargin(cellfun('isempty',varargin)) = [];
plane = varargin{1};

a = zeros(size(varargin)); b = a; c = a; d = a;
for i = 1:numel(varargin)
  p = varargin{i};
  if ~isempty(p)
    a(i) = p.a;
    b(i) = p.b;
    c(i) = p.c;
    d(i) = p.d;
    % plotting convention is dropped
  end
end

plane.N = cat(dim,N(:));
plane.d = cat(dim,d(:));
