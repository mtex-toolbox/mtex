classdef S1Grid
% a class representing a grid of angles
%
% An S1Grid is a sorted list of angles within an interval [min,max], which
% may be periodic. Its point is the fast nearest neighbour search of
% <S1Grid.find.html find> and <S1Grid.dist.html dist>, which is what makes
% the tensor product grids @S2Grid and @SO3Grid work.
%
% Syntax
%   S1G = S1Grid(points,min,max)
%   S1G = S1Grid(points,min,max,'periodic')
%
% Input
%  points - list of angles
%  min    - start of the fundamental region
%  max    - end of the fundamental region
%
% Output
%  S1G - @S1Grid
%
% Options
%  periodic - identify min and max
%  matrix   - one grid per column of points
%
% Class Properties
%  points   - the angles
%  min, max - the fundamental region
%  periodic - are min and max identified
%  period   - max - min if periodic, 0 otherwise
%
% Example
%
%   S1G = S1Grid(0:10*degree:350*degree,0,2*pi,'periodic')
%
% See also
% S2Grid SO3Grid
%

  properties
    points   % the angles
    min = 0  % start of fundamental region
    max = 0  % end of fundamental region
    periodic = false;
  end
  
  properties (Dependent = true)    
    period   % = 0 if not periodic = max - min if periodic
  end
  
  methods
    
    function G = S1Grid(arg1,min,max,varargin)
      % Constructor
      %
      % Input
      %  points - double
      %  min    - double
      %  max    - double
      %
      % Output
      %  S1G - @S1Grid
      %
      % Options
      %  PERIODIC - periodic @S1Grid
       
      if nargin == 0
        
      elseif nargin == 1 % copy constructor
        
        G.points = arg1.points;
        G.min = arg1.min;
        G.max = arg1.max;
        G.periodic = arg1.periodic;
        
      elseif nargin > 2
        
        G.points = reshape(arg1,1,[]);
        G.min = min(1);
        G.max = max(1);
        G.periodic = check_option(varargin,'PERIODIC');
        
        if check_option(varargin,'matrix')
          
          G.points = G.points(:,1);
          G = repmat(G,size(arg1,2),1);
          
          for i = 1:size(arg1,2)
            G(i).min = min(i);
            G(i).max = max(i);
            G(i).points = arg1(:,i)';
          end
        end
              
      else
        error('wrong number of arguments')
      end    
    end
    
    function p = get.period(S1G)
      if S1G.periodic
        p = S1G.max-S1G.min;
      else
        p = 0;
      end
    end
    
  end  
end

