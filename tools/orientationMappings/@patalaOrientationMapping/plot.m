function patalaColorbar(cs,cc,varargin) 
% plot colorbar with patala misorientation colorcoding

% pass the symmetry
varargin = set_option(varargin,'CS',cs);

% get sections
if check_option(varargin,'omega')
    w = get_option(varargin,'omega');
else
    wmax = maxmisorientation(cs)/degree; %max misorientation angle in degrees
    wmax = floor((wmax-1)/10)*10; %round down to nearest 10 degree increment
    w = linspace(10,wmax,6);
end

% get resolution
nTheta = get_option(varargin,'nTheta',20);
nRho = get_option(varargin,'nRho',40);
    
% identify crystal symmetry
switch Laue(get_option(varargin,'CS'))
  
  case 'm-3'
    fun = @(Deg) DisorientLegend_23(Deg,nTheta,nRho);
    annote_place = 'TR';
  case 'mmm'
    fun = @(Deg) DisorientLegend_222(Deg,nTheta,nRho);
    annote_place = 'TR';
  case '4/mmm'
    fun = @(Deg) DisorientLegend_422(Deg,nTheta,nRho);
    annote_place = 'TL';
  case 'm-3m'
    fun = @(Deg) DisorientLegend_432(Deg,nTheta,nRho);
    annote_place = 'TL';
  case '6/mmm'
    fun = @(Deg) DisorientLegend_622(Deg,nTheta,nRho);
    annote_place = 'TL';
  otherwise
    error('Unsupported crystal symmetry for Patala colormap.')
end

for i = 1:numel(w)
    
    % set the rotation angle section value
    varargin = set_option(varargin,'omega',w(i)*degree);
    
    h{i} = w(i);
    d{i} = fun;
    
end

% temporarily turn off warnings
idRGB = 'MATLAB:hg:patch:RGBColorDataNotSupported';
idDelaunay = 'MATLAB:delaunay:DupPtsDelaunayWarnId';
warning('off',idRGB)
warning('off',idDelaunay)

% plot
multiplot(numel(d),@(i) h{i},@(i) d{i},'patchPatala',annote_place,@(i) ['\ ',num2str(w(i)),'^\circ\ '],varargin{:});

% turn warnings back on
warning('on',idRGB)
warning('on',idDelaunay)

% finalize plots
ax = findobj(gcf,'type','axes');
set(ax,'visible','on','xtick',[],'ytick',[],'box','on','gridlinestyle','none')
% Note: There is a bug with both zbuffer and opengl. Using zbuffer as the
% renderer there are holes in some patches. Using opengl the axes borders
% (boxes) are cut off. This is a workaround for the opengl problem. For
% documentation on the bug see the following resources:
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/293598
% http://www.mathworks.com/support/solutions/en/data/1-5TS5P4/index.html?product=ML&solution=1-5TS5P4
% http://www.mathworks.com/support/solutions/en/data/1-OAWEH/index.html?product=ML&solution=1-OAWEH
% http://www.mathworks.com/support/solutions/en/data/1-5X41G7/index.html
if ~isunix
  set(gcf,'renderer','zbuffer');
  state_opengl = opengl('data');
  opengl software
  set(gcf,'renderer','opengl')
  if state_opengl.Software == 0 %if it was previously hardware accelerated return opengl to original state
    opengl hardware
  end
else
% for unix it seems to work just fine  
end
end
% Copyright 2013 Oliver Johnson, Srikanth Patala
% 
% The following function (patalaColorbar) is part of MisorientationMaps.
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
