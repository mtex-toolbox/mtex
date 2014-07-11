function [rgb,options] = om_patala(o,varargin)
% converts misorientations to rgb values
%-------------------------------------------------------------------------%
%Filename:  om_patala.m
%Author:    Oliver Johnson
%Date:      7/12/2013
%
% OM_MISORIENTATION provides colorcoding using the Patala colorcoding
% scheme [1], for colorcoding grainboundaries according to misorientation.
%
% Inputs:
%   o - An array of MTEX orientation objects (or an S2Grid object) defining
%       the misorientations for which the computation of disorientations is
%       desired. In the case that o is an S2Grid object, the grid points
%       define misorientation axes and the misorientation angle must be
%       supplied separately (see omega below).
%   CS - (optional) If o is an S2Grid object, then one must provide, as an
%        additional property/value pair of arguments, the crystal symmetry,
%        for example om_patala(o,'CS',symmetry('432'))
%   omega - (optional) If o is an S2Grid object, then one must provide, as
%           an additional property/value pair of arguments, the
%           misorientation angle. omega must be a scalar, which defines the
%           misorientation angle for all misorientation axes provided in o.
%
% Outputs:
%   rgb - A numel(o)-by-3 array defining the colors assigned to each of the 
%         misorientations in o. rgb(i,:) is a 3 element vector of the form
%         [r_value g_value b_value] indicating the color assigned to the
%         misorientation o(i) according to the Patala coloring scheme.
%
% [1] S. Patala, J. K. Mason, and C. A. Schuh, �Improved representations of
%     misorientation information for grain boundary science and 
%     engineering,� Prog. Mater. Sci., vol. 57, no. 8, pp. 1383�1425, 2012.
%-------------------------------------------------------------------------%


switch class(o)
  case 'orientation'
    % get crystal symmetry
    cs = o.CS;
            
    % get disorientations
    m = [o.a,o.b,o.c,o.d];
    d = disorientation(m,cs.properGroup.pointGroup);
    
    % get rodriguez vectors
    r = bsxfun(@rdivide,d(:,2:4),d(:,1));
  case 'S2Grid'
    % get crystal symmetry
    cs = get_option(varargin,'CS');
    
    % get misorientation angle
    omega = get_option(varargin,'omega');
    
    % get spherical coordinates
    theta = o.theta;
    phi = o.rho; %MTEX calls the azimuthal angle rho
    
    % get disorientations
    m = [cos(omega/2)*ones(size(theta(:))),...
      sin(omega/2).*sin(theta(:)).*cos(phi(:)),...
      sin(omega/2).*sin(theta(:)).*sin(phi(:)),...
      sin(omega/2).*cos(theta(:))];
    d = disorientation(m,cs);
    
    % get rodriguez vectors
    r = bsxfun(@rdivide,d(:,2:4),d(:,1));
    
end

% get rgb colors
switch cs.properGroup.pointGroup
  case '23'
    rgb = colormap23(r);
  case '222'
    rgb = colormap222(r);
  case '422'
    rgb = colormap422(r);
  case '432'
    rgb = colormap432(r);
  case '622'
    rgb = colormap622(r);
  otherwise
    assert(any(strcmpi(cs,{'23','222','422','432','622'})),'Point group %s is not supported for Patala colormapping. \nOnly the following point groups are supported: ''23'',''222'',''422'',''432'',''622''.',cs);
end

options = []; %TO DO: Are there any options we care about?

end


% Copyright 2013 Oliver Johnson, Srikanth Patala
% 
% This file is part of MisorientationMaps.
% 
%     MisorientationMaps is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     MisorientationMaps is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with MisorientationMaps.  If not, see <http://www.gnu.org/licenses/>.

