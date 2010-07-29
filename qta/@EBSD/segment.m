function [grains,ebsd] = segment(ebsd,varargin)
%by pass function to segment2d either segment3d



dim = size(ebsd(1).X,2);


if dim == 3
  
%   if check_option(varargin,'2d')
%     %make a slice
% %     get_option(varargin,'2d')
%     
%     
%   else
  
    [grains, ebsd] = segment3d(ebsd,varargin{:});  
  
    return
%   end
  
end

[grains, ebsd] = segment2d(ebsd,varargin{:});
