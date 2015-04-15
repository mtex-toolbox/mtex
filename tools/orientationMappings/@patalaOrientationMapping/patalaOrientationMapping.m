classdef patalaOrientationMapping < orientationMapping
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
% [1] S. Patala, J. K. Mason, and C. A. Schuh, Improved representations of
%     misorientation information for grain boundary science and 
%     engineering, Prog. Mater. Sci., vol. 57, no. 8, pp. 1383-1425, 2012.
%-------------------------------------------------------------------------

  
  properties
    
  end
  
  methods
   
    function oM = patalaOrientationMapping(varargin)
      oM = oM@orientationMapping(varargin{:});
    end
    
    function rgb = orientation2color(oM,mori) 

      rot = rotation(mori);

      axis = project2FundamentalRegion(rot.axis,oM.CS1.Laue);

      v = Rodrigues(rotation('axis',axis(:),'angle',mori.angle));

      switch oM.CS1.LaueName
        case 'm-3m'
          rgb = colormap432(v);
        case 'mmm'
          rgb = colormap222(v);
        case {'m-3'}
          rgb = colormap23(v);
        case {'4/mmm'}
          rgb = colormap422(v);
        case {'6/mmm'}
          rgb = colormap622(v);       
        otherwise
          error('For symmetry %s patala colorcoding is not defined.',...
            cs.pointGroup)
      end
      rgb = reshape(rgb,[size(mori) 3]);
    end
  end
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

