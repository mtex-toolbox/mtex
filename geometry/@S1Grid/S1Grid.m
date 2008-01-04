function G = S1Grid(points,min,max,varargin)
% Constructor
%
%% Input
%  points - double
%  min    - double
%  max    - double
%
%% Output
%  S1G - @S1Grid
%
%% Options
%  PERIODIC - periodic @S1Grid

if (nargout == 0) && (nargin == 0)
	disp('constructs a grid on S^1');
	disp('Arguments: points, min, max');
	return;
end

if nargin == 0
	
	G.points = [];
	G.min = 0;
	G.max = 0;
	G.periodic = 0;
	G = class(G,'S1Grid');
	
elseif nargin == 1
	
    G = points;
		
elseif nargin > 2

	G.points = points;
	G.min = min;
	G.max = max;
  G.periodic = check_option(varargin,'PERIODIC');
	G = class(G,'S1Grid');
else
	error('wrong number of arguments')
end
