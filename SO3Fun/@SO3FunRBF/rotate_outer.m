function SO3F = rotate_outer(SO3F,rot,varargin)
%
    
SO3F.center = rot * SO3F.center;
    
end
