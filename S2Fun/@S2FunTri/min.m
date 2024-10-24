function [sF,v] = min(sF1, sF2)
% global, local and pointwise minima of spherical functions
%
% Syntax
%   [value,pos] = min(sF) % the position where the minimum is atained
%
%   [value,pos] = min(sF,'numLocal',5) % the 5 largest local minima
%
%   sF = min(sF, c) % minimum of a spherical functions and a constant
%   sF = min(sF1, sF2) % minimum of two spherical functions
%   sF = min(sF1, sF2, 'bandwidth', bw) % specify the new bandwidth
%
%   % compute the minimum of a multivariate function along dim
%   sF = min(sFmulti,[],dim)
%
% Input
%  sF, sF1, sF2 - @S2Fun
%  sFmulti - a multivariate @S2Fun
%  c       - double
%
% Output
%  value - double
%  pos   - @vector3d
%  S2F   - @S2Fun
%
% Options
%  numLocal      - number of peaks to return
%
        
if nargin == 1
           
  [sF,pos] = min(sF1.values(:));
           
  v = sF1.vertices(pos);
  v = v.rmOption('resolution');
  
elseif isnumeric(sF1)
            
  sF = sF2;
            
  sF.values = min(sF1, sF.values);
                    
elseif isnumeric(sF2)
            
  sF = sF1;
            
  sF.values = min(sF.values, sF2);
        
else
            
  sF=sF1;
        
  sF.values = min(sF1.values, sF2.values);
   
end
        
end