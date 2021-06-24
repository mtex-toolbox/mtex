function weights = calcBndWeights(gB, grainPairs,varargin)
% 
    
kappa = gB.curvature;
%kappa = max(0,kappa - quantile(kappa,0.5));
kappa = min(kappa, quantile(kappa,0.9));
kappa = kappa ./ max(kappa);

kappa = get_option(varargin,'curvatureFactor',1) * kappa;
  

[~,pairId,ind] = gB.selectByGrainId(grainPairs);
%weights = 1 + accumarray(pairId,kappa(ind),[size(grainPairs,1) 1],@median);
weights = 1 + accumarray(pairId,kappa(ind),[size(grainPairs,1) 1],@(x) quantile(x,0.75));
%weights = 1 + sqrt(accumarray(pairId,kappa(ind).^2,[size(grainPairs,1) 1],@sum));
%weights = 1 + accumarray(pairId,kappa(ind),[size(grainPairs,1) 1],@sum);
   
calcODF(pf,)

end