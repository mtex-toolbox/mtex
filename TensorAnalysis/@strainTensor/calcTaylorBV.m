function b = calcTaylorBV(eps,sS,spin,varargin)
%

if sS.CS.Laue ~= eps.CS.Laue

  if length(eps)>1
    error('Not implemented yet. Use the older ''calcTaylor'' method.')
  end

  epsLocal = strainTensor(eps.M(:,:,1));

  % Compute Taylor factor
  b = @(rot) calcTaylorB(rot,epsLocal,sS,spin,varargin{:});
  
  return
end

b = calcTaylorBurgersV(eps,sS,spin,varargin{:});

end

function b = calcTaylorB(rot,eps,sS,spin,varargin)
  ori = orientation(rot,sS.CS,eps.CS);
  try
    W = spin.eval(ori);
  catch
    W = spin(ori);
  end
  b = calcTaylorBurgersV(inv(ori)*eps,sS,W,varargin{:});
end
