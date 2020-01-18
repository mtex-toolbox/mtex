classdef symmetry < rotation
%
% symmetry is an abstract class for crystal and specimen symmetries
%
% Derived Classes
%  @crystalSymmetry - 
%  @specimenSymmetry - 
%

  properties
    id = 1;         % point group id, compare to symList    
    lattice = 'triclinic' % type of crystal lattice
    pointGroup = '1'         % name of the point group
  end
  
  
  properties (Access = protected)
    hash = 0          % hash number for comparing different symmetries 
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
    
    function s = symmetry(varargin)
                
      % empty constructor
      if nargin == 0
        s.a = 1;
        s.b = 0;
        s.c = 0;
        s.d = 0;
        s.i = false;
        s.hash = calcHash(s);
        return; 
      end
      
      if check_option(varargin,'PointId')
        
        s.id = get_option(varargin,'PointId');
        
      elseif check_option(varargin,'LaueId')
      
        % -1 2/m mmm 4/m 4/mmm m-3 m-3m -3 -3m 6/m 6/mmm
        LaueGroups = [2,8,16,27,32,42,45,18,21,35,40];
        s.id = LaueGroups(get_option(varargin,'LaueId'));
              
      elseif check_option(varargin,'SpaceId')
        
        list = spaceGroups;
        ndx = nnz([list{:,1}] < get_option(varargin,'SpaceId'));
        if ndx>31, error('I''m sorry, I know only 230 space groups ...'); end
        s.id = findsymmetry(list(ndx+1,2));
        
      elseif isa(varargin{1},'quaternion')
        
        s.a = varargin{1}.a;
        s.b = varargin{1}.b;
        s.c = varargin{1}.c;
        s.d = varargin{1}.d;
        try s.i = varargin{1}.i;catch, end
        s.id = 0;
                
      else

        if any(strcmp(varargin{1},{'2','m','2/m'})) && nargin > 2 && isnumeric(varargin{3})
          
          abg = varargin{3};
          if max(abg) > 2*pi, abg = abg * degree; end
          
          [~,i] = max(abs(abg-pi/2));
          
          p = {'1','1','1'};
          p{i} = varargin{1};
          varargin{1} = [p{:}];
          
        end
        
        s.id = findsymmetry(varargin{1});
        
      end
      
      if s.id>0
        s.lattice = symmetry.pointGroups(s.id).lattice;
        s.pointGroup = symmetry.pointGroups(s.id).Inter;
      else
        s.lattice = 'unknown';
        s.pointGroup = 'unknown';
      end
      
      s.hash = calcHash(s);
      
    end
      
    function h = calcHash(cs)
            
      try
        isLaue = cs.id == symmetry.pointGroups(cs.id).LaueId;
      catch % this is required for custom symmetries
        isLaue = any(reshape(rotation(cs) == -rotation.id,[],1));
      end
      
      values = double(cs);
      if isempty(values), values = 0; end
      values = typecast(values(:),'uint8');

      md = java.security.MessageDigest.getInstance('SHA-1');
      md.update(values);

      % Properly format the computed hash as an hexadecimal string:
      h = [uint8(isLaue);md.digest()];
      
    end
    
    function r = isProper(cs) % does it contain only proper rotations
      r = ~any(cs.i(:));
    end
    
    function r = isRotational(cs)      
      r = cs.id == symmetry.pointGroups(cs.id).properId;
    end
    
    function out = le(cs1,cs2)
      % check wheter cs1 is a sub group of cs2
      out = all(any(abs(dot_outer(cs1,cs2))>1-1e-6,2));
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


