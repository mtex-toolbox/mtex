classdef plane3d < dynOption
%
% The class plane3d describes a pane in 3D space, given by
% the plane equation N.v = d
%
% Syntax
%   plane = plane3d(N,d)
%   plane = plane3d(N,v0)
%   plane = plane3d.byPoints(v)
%
% Input
%  N - normal direction @vector3d
%  d - distance to origin
%  v0, v - @vector3d 
%
% Output
%  plane - @plane3d
%
% See also
% vector3d

properties
  N % normal direction
  d % distance to origin
end
  
methods
    
  function plane = plane3d(N,d,varargin)
    % constructor of the class vector3d
    
    if isa(N,'vector3d')
      
      plane.N = normalize(N);
      
      if nargin>1 && isnumeric(d)
        plane.d = d ./ norm(N);
      elseif nargin>1 && isa(d,'vector3d')
        plane.d = dot(plane.N,d);
      else
        plane.d = zeros(size(N));
      end

    elseif isa(N,'plane3d')
      plane = N;
    end
  end

  function display(plane,varargin) %#ok<DISPLAY>
    % standard output
    
    displayClass(plane,inputname(1),varargin{:},'moreInfo');
    
    if length(plane)>1, disp([' size: ' size2str(plane)]); end
    
    disp(' ');
    
    if length(plane)<=45 && ~isempty(plane)
      dispData(plane)
    elseif ~getMTEXpref('generatingHelpMode')
      disp(' ')
      s = setAllAppdata(0,'data2beDisplayed',@() dispData(plane));
      disp(['  <a href="matlab:feval(getappdata(0,''',s,'''))">display all coordinates</a>'])
      disp(' ')
    end
    
    function dispData(plane)
      % display coordinates
      N = round(plane.N); %#ok<PROPLC>
      d = [N.xyz round(100*plane.d)./100]; %#ok<PROPLC>
      d(abs(d) < 1e-10) = 0; %#ok<PROPLC>
      cprintf(d,'-L','  ','-Lc',{'x' 'y' 'z' 'd'});%#ok<PROPLC>
    end
  end


end
  
methods (Static = true)

  function plane = byPoints(d,varargin)
    if length(d) >= 3
      plane = plane3d(perp(d),d(1),varargin{:});
    else
      error('Enter at least 3 points within the plane')
    end
  end
end
end
