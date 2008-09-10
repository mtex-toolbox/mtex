function ok = eq(S1,S2,varargin)
% check for S2Grid == S2Grid
%
%% Input
%
%
%
%

if length(S1) ~= length(S2)
  ok = 0;
  return
end

epsilon = get_option(varargin,'epsilon',1e-5);

for i = 1:length(S1)

  if GridLength(S1(i)) ~= GridLength(S2(i))
    ok(i) = 0;
    continue
  end

  v1 = vector3d(S1(i));
  v1 = double(v1(:));
  v2 = vector3d(S2(i));
  v2 = double(v2(:));

  ok(i) = max(squeeze(sum((v1 - v2).^2,3)))<epsilon;
end
