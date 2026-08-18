function v = fileOrder(m,sel)
% flatten a gridded quantity into the order a text file lists it
%
% Description
%
% Both the .ang and the .ctf format write a map row by row with x varying
% fastest, while MATLAB reads a matrix column wise - hence the transpose.
% |sel| drops the cells the grid holds but the file does not list, see
% gridCells.

v = reshape(double(m).',[],1);

if nargin > 1, v = v(sel); end

end
