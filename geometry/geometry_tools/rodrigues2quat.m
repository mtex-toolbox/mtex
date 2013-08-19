function q = rodrigues2quat(R,varargin)

q = axis2quat(R,atan(norm(R))*2);
