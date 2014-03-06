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

	G.points = reshape(points,1,[]);
	G.min = min(1);
	G.max = max(1);
  G.periodic = check_option(varargin,'PERIODIC');

  if check_option(varargin,'matrix')
    
    G.points = G.points(:,1);
    G = repmat(G,size(points,2),1);
    
    for i = 1:size(points,2)
      G(i).min = min(i);
      G(i).max = max(i);
      G(i).points = points(:,i)';
    end
  else
    
  end
  
  G = class(G,'S1Grid');
  
  
else
	error('wrong number of arguments')
end
