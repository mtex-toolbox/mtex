function T = fitTo(proto,ps)
% the transform of proto's class, fitted to the measured shifts
%
% A drift stage continues its end segments: the resampling needs coordinates
% above the first and below the last row of tiles as well.

opt = fitOptions(proto);
T = proto.fit(ps.pos,ps.pos + ps.u,opt{:},'weights',ps.peak,'extrapolate');

end
