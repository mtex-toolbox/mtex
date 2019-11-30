function SO3F = rotate_outer(SO3F,rot,varargin)
% rotate component
    
SO3F.A = rot * SO3F.A;
    
end
