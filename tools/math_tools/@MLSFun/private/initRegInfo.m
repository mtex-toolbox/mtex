function info = initRegInfo(N)
% regularization diagnostics of N centers, all unset

info = struct;
for name = {'conds_reg','conds_unreg','maxeig','mineig','maxeig_reg', ...
    'mineig_reg','centerAmplification','centerAmplificationRegBound', ...
    'numericalRidge','shapeRegularization'}
  info.(name{1}) = NaN(N,1);
end
for name = {'regularizationActive','deltaFallback','candidateLimit'}
  info.(name{1}) = false(N,1);
end

end
