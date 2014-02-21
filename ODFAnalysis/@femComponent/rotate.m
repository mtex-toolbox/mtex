function component = rotate(component,q,varargin)
% called by ODF/rotate
    
component.center = q * component.center;
    
end
