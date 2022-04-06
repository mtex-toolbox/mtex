function component = rotate(component,q,varargin)
% rotate component
    
component.A = q * component.A;
    
end
