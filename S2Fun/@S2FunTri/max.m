function [sF,v] = max(sF1,sF2)
% global, local and pointwise maxima of spherical functions
%
% Syntax
%   [v,pos] = max(sF) % the position where the maximum is atained
%
%   [v,pos] = max(sF,'numLocal',5) % the 5 largest local maxima
%
%   sF = max(sF, c) % maximum of a spherical functions and a constant
%   sF = max(sF1, sF2) % maximum of two spherical functions
%   sF = max(sF1, sF2, 'bandwidth', bw) % specify the new bandwidth
%
%   % compute the maximum of a multivariate function along dim
%   sF = max(sFmulti,[],dim)
%
% Input
%  sF, sF1, sF2 - @S2FunTri
%  sFmulti - a multivariate @S2FunTri
%  c       - double
%
% Output
%  v - double
%  pos - @vector3d
%
% Options
%  numLocal      - number of peaks to return

if nargin == 1
  
  [sF,pos] = max(sF1.values(:));
  
  v = sF1.vertices(pos);
  v = v.rmOption('resolution');
  
elseif isnumeric(sF1)
  
  sF = sF2;
  
  sF.values = max(sF.values, sF1);
  
elseif isnumeric(sF2)
  
  sF = sF1;
  
  sF.values = max(sF1.values, sF2);
        
else
        
  sF = sF1;
        
  sF.values=max(sF1.values, sF2.values);
        
end
      
end