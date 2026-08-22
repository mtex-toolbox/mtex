function iF = gridLayout(varargin)
% the matrix layout a gridify call asks for, as an @imageFrame
%
% Syntax
%
%   iF = gridLayout()              % columnMajor, the default
%   iF = gridLayout('rowMajor')
%   iF = gridLayout(iF)
%
% Input
%  iF - @imageFrame, given outright
%
% Output
%  iF - @imageFrame, column direction in basis(1) and row direction in basis(2)
%
% Description
% columnMajor is imageFrame(xvector,yvector) - dimension 1 along y and
% dimension 2 along x - and rowMajor is its transpose. A frame given outright
% wins over both flags. This is the one place the two names are defined.
%
% See also
% EBSD/gridify EBSDsquare/transformReferenceFrame imageFrame/layoutIndex

iF = getClass(varargin,'imageFrame',[]);

if isempty(iF)
  if check_option(varargin,'rowMajor')
    iF = imageFrame(yvector,xvector,'name','rowMajor');
  else
    iF = imageFrame(xvector,yvector,'name','columnMajor');
  end
end

end
