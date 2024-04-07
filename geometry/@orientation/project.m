function ori = project(ori,varargin)
% projects orientation to a fundamental region
%
% Syntax
%   ori = project(ori,f)
%
% Input
%  ori     - @orientation
%  ori_ref - reference @rotation
%  f       - @fibre
%
% Output
%  phi1, Phi, phi2 - Euler angles
%

if isa(varargin{1},'fibre') % project to fiber
    
  %f = varargin{1};
  
  %h = f.h; r = f.r;
  h = varargin{1}; r = varargin{2};
  rotSym = ori.CS.properGroup.rot;

  d = dot_outer(times(rotSym,h,1), times(inv(ori),r,0),'noSymmetry');
  [~,idSym] = max(d,[],1);
  ori = times(ori, rotSym(idSym),0);

else

end