function  display(shape,varargin)
% standard output

displayClass(shape,inputname(1),'moreInfo',char(shape.how2plot,'compact'));

disp(' ')

if length(shape) ~= 1, disp([' size: ' size2str(shape)]);end
disp([' vertices: ', num2str(size(shape.Vs,1))]);

disp(' ')
