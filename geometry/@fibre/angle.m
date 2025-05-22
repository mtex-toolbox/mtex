function [omega, oriF] = angle(f,ori,varargin)
% angle fiber to orientation or fiber to fibre
%
% Syntax
% 
%   omega = angle(f,ori) % angle orientation to fibre
%   [omega, oriF] = angle(f,ori)
%
%   omega = angle(f1,f2) % angle fibre to fibre
%
% Input
%  f, f1, f2 - @fibre
%  ori - @orientation
%
% Output
%  omega - double
%  oriF  - @orientation on the fibre that minimizes the angle
%
% See also 
% orientation/angle

if isa(ori,'orientation')

  if ori.SS.id <= 2 % only right / crystal symmetry
    
    hOri = ori .\ f.r;
    hSym = f.h.symmetrise;

    [omega,hId] = min(angle_outer(hOri, hSym, 'noSymmetry', varargin{:}),[],2);

    if nargout == 2 % compute also nearest orientation on fibre
      rotH = orientation.map(hSym(hId),hOri);
      oriF = ori .* rotH;
    end

  elseif ori.CS.id <= 2 % only left / specimen symmetry
    
    rOri = ori .* f.h;
    rSym = f.r.symmetrise;

    [omega,rId] = min(angle_outer(rOri, rSym, 'noSymmetry', varargin{:}),[],2);

    if nargout == 2 % compute also nearest orientation on fibre
      rotR = orientation.map(rOri,rSym(rId));
      oriF = rotR .* ori;
    end

  else % left + right symmetry, aka misorientations

    oriSym = ori.symmetrise;

    [omega,symId] = min(angle(oriSym(:).' .* f.h(:), f.r(:), 'noSymmetry', varargin{:}),[],2);

    if nargout == 2 % compute also nearest orientation on fibre
      rotR = orientation.map(oriSym(symId) .* f.h,f.r);
      oriF = rotR .* oriSym(symId);
    end

  end

else

  omega = max(angle(f,orientation(ori),varargin{:}));

  % in the non symmetric case we have also
  %omega = min(angle(f.h,ori.h) + angle(f.r,ori.r), angle(f.h,-ori.h) + angle(f.r,-ori.r));

end

end
