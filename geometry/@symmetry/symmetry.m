classdef symmetry < handle
%
% symmetry is an abstract class for crystal and specimen symmetries
%
% Derived Classes
%  @crystalSymmetry - 
%  @specimenSymmetry - 
%

  properties
    id = 1;               % point group id, compare to symList    
    lattice = 'triclinic' % type of crystal lattice
    pointGroup = '1'      % name of the point group
    rot = rotation.id     % the symmetry elements
  end
   
  properties (Access = protected)
    
    LaueRef = []
    
  end
  
  
  properties (Constant = true)
    
    pointGroups = pointGroupList % list of all point groups
    
  end

  % this is an abstract class
  methods (Abstract = true)
    display(s)
    dispLine(s)
  end
  
  methods
    
    function sym = symmetry(varargin)
                
      % empty constructor
      if nargin == 0, return; end
      
      % determine the correct id
      if check_option(varargin,'PointId')
        
        sym.id = get_option(varargin,'PointId');
        
      elseif check_option(varargin,'LaueId')
      
        % -1 2/m mmm 4/m 4/mmm m-3 m-3m -3 -3m 6/m 6/mmm
        LaueGroups = [2,8,16,27,32,42,45,18,21,35,40];
        sym.id = LaueGroups(get_option(varargin,'LaueId'));
              
      elseif check_option(varargin,'SpaceId')
        
        list = spaceGroups;
        ndx = nnz([list{:,1}] < get_option(varargin,'SpaceId'));
        if ndx>31, error('I''m sorry, I know only 230 space groups ...'); end
        sym.id = findsymmetry(list(ndx+1,2));
        
      elseif isa(varargin{1},'quaternion')
        
        sym.rot = rotation(varargin{1});
        sym.id = 0;
                
      else

        % expand 2, m, and 2/m to 112 or 121 or 211 depending on the angles
        if any(strcmp(varargin{1},{'2','m','2/m'})) && nargin > 2 && isnumeric(varargin{3})
          
          abg = varargin{3};
          if max(abg) > 2*pi, abg = abg * degree; end
          
          [~,i] = max(abs(abg-pi/2));
          
          p = {'1','1','1'};
          p{i} = varargin{1};
          varargin{1} = [p{:}];
          
        end
        
        sym.id = findsymmetry(varargin{1});
        
      end
      
      % determine pointGroup and lattice names
      if sym.id>0
        sym.lattice = symmetry.pointGroups(sym.id).lattice;
        sym.pointGroup = symmetry.pointGroups(sym.id).Inter;
      else
        sym.lattice = 'unknown';
        sym.pointGroup = 'unknown';
      end
                  
    end
      
   
    function r = isProper(sym) % does it contain only proper rotations
      
      r = ~any(sym.rot.i(:));
      
    end
    
    function out = le(cs1,cs2)
      % check wheter cs1 is a sub group of cs2
      out = all(any(abs(dot_outer(cs1.rot,cs2.rot))>1-1e-6,2));
    end
    
    function out = ge(cs1,cs2)
      % check wheter cs2 is a sub group of cs1
      out = le(cs2,cs1);
    end
        
    function out = lt(cs1,cs2)
      % check wheter cs1 is a true sub group of cs2
      out = le(cs1,cs2) & ~le(cs2,cs1);
    end
    
    function out = gt(cs1,cs2)
      % check wheter cs2 is a true sub group of cs1
      out = lt(cs2,cs1);
    end
    
  end
      
end

% ---------------------------------------------------------------

function list = spaceGroups

list = { 1,    '1';
  2,   '-1';
  5,    '2';
  9,    'm';
  15,   '2/m';
  24,    '222';
  46,    'mm2';
  74,   'mmm';
  80,    '4';
  82,    '-4';
  88,   '4/m';
  98,    '422';
  110,    '4mm';
  122,   '-42m';
  142,    '4/mmm';
  146,    '3';
  148,   '-3';
  155,    '32';
  161,    '3m';
  167,   '-3m';
  173,    '6';
  174,    '-6';
  176,    '6/m';
  182,   '622';
  186,   '6mm';
  190,  '-6m2';
  194, '6/mmm';
  199,    '23';
  206,   'm-3';
  214,   '432';
  220,  '-43m';
  230,  'm-3m'};
end


