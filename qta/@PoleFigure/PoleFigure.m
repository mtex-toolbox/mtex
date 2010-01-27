function P = PoleFigure(h,r,data,CS,SS,varargin)
% constructor 
%
% *PoleFigure* is the low level constructor. For importing real world data
% you might want to use the predefined [[interfacesPoleFigure_index.html,interfaces]]
%
%% Input
%  h     - crystal directions (@vector3d | @Miller)
%  r     - specimen directions (@S2Grid)
%  data  - diffraction counts (double)
%  CS,SS - crystal, specimen @symmetry
%
%% Options
%  SUPERPOSITION - weights for superposed crystal directions
%  BACKGROUND    - background intensities
%
%% See also
% interfacesPoleFigure_index loadPoleFigure loadPoleFigure_txt

if nargin == 0  
  P.comment = [];
  P.h = vector3d;
  P.r = vector3d;
  P.data = [];
  P.bgdata = [];
  P.CS = symmetry;
  P.SS = symmetry;
  P.c  = 1;
  P.P_hat = [];
  P.options = struct;
else
  P.comment = get_option(varargin,'comment',[],'char');
  P.h = argin_check(h,{'vector3d','Miller'});
  P.r = argin_check(r,{'vector3d','S2Grid'});
  P.data = argin_check(data,{'double','int'});
  P.bgdata = get_option(varargin,'BACKGROUND',[],'double');
  P.CS = argin_check(CS,'symmetry');
  P.SS = argin_check(SS,'symmetry');
  P.c = reshape(get_option(varargin,'SUPERPOSITION',ones(1,length(h)),'double'),1,[]);
  P.c= P.c ./sum(P.c);
  P.P_hat = [];
  P.options = get_option(varargin,'options',struct,'struct');  
  
  % make definitions more robust
  P.h = set(P.h,'CS',P.CS);
  if ~check_option(varargin,'complete'), P.r = set_option(P.r,'antipodal');end
  
  assert(numel(P.data) == numel(P.r),'Number of diffraction intensitites is not equal to the number of specimen directions!');
  
end
superiorto('quaternion');
P = class(P,'PoleFigure');
