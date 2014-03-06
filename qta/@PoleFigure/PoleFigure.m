function P = PoleFigure(h,r,data,varargin)
% constructor 
%
% *PoleFigure* is the low level constructor. For importing real world data
% you might want to use the predefined [[ImportPoleFigureData.html,interfaces]]
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
% ImportPoleFigureData loadPoleFigure loadPoleFigure_generic

if nargin == 0  
  
  P = struct('comment',{},'h',{},'r',{},'data',{},'bgdata',{},...
    'CS',{},'SS',{},'c',{},'P_hat',{},'options',{});
  
else
  P.comment = get_option(varargin,'comment',[],'char');
  P.h = argin_check(h,{'vector3d','Miller'});
  P.r = argin_check(r,{'vector3d','S2Grid'});
  P.data = argin_check(data,{'double','int'});
  P.bgdata = get_option(varargin,'BACKGROUND',[],'double');
  
  [P.CS,varargin] = get_class(varargin,'symmetry',symmetry('cubic'));
  [P.SS,varargin] = get_class(varargin,'symmetry',symmetry('orthorhombic'));
  
  P.c = reshape(get_option(varargin,'SUPERPOSITION',ones(1,length(h)),'double'),1,[]);
  P.c= P.c ./sum(P.c);
  P.P_hat = [];
  P.options = get_option(varargin,'options',struct,'struct');  
  
  % make definitions more robust
  P.h = ensureCS(P.CS,{P.h});
  if ~check_option(varargin,'complete'), P.r = set_option(P.r,'antipodal');end
  
  assert(numel(P.data) == numel(P.r),'Number of diffraction intensitites is not equal to the number of specimen directions!');
  
end
P = class(P,'PoleFigure');

function [obj,options] = get_class(options,class,default)

pos = find(cellfun(@(x) isa(x,class),options),1);
if isempty(pos)
  obj = default;
else
  obj = options{pos};
  options(pos) = [];
end
