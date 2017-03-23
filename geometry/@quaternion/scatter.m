function varargout = scatter(q,varargin)
% plot function
%
% Input
%  q - Quaternion
%
% Options
%  rodrigues - plot in rodrigues space
%  axisAngle - plot in axis / angle
%

oP = newOrientationPlot(specimenSymmetry,specimenSymmetry,varargin{:});

[varargout{1:nargout}] = oP.plot(q,varargin{:});
