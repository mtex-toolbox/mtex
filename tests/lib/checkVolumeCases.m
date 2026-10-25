function checkVolumeCases(pairs,varargin)
% compare volume and fibreVolume with the integral over a grid of the region
%
% Syntax
%   checkVolumeCases(pairs)
%   checkVolumeCases(pairs,'fibres',1:3,'radii',[15 45]*degree)
%
% Input
%  pairs - cell of {pointGroup, specimenPointGroup}, 'exchange' for the
%          misorientations of one phase with grain exchange
%
% Options
%  centers - which of the vertex of the region, cube, a generic center
%  fibres  - which of (100)||z, (111)||r, (124)||r, none for []
%  radii   - the radii of the balls and tubes
%
% Description
% The region of volume is the union of the symmetric copies of the ball,
% that of fibreVolume the union of the tubes about the symmetric copies of
% the fibre; they coincide where a symmetry fixes the center and overlap for
% a large radius, and the union counts once. The reference is the integral
% over an equispaced grid of the fundamental region of the orientations
% whose symmetry reduced angle to the center, or to the fibre, is below the
% radius, for the uniform, unimodal, fibre and harmonic representations.
%
% See also
% SO3Fun/volume SO3Fun/fibreVolume

centerIds = get_option(varargin,'centers',1:3);
fibreIds = get_option(varargin,'fibres',1:3);
radii = get_option(varargin,'radii',[15 45]*degree);

for p = 1:numel(pairs)

  cs = crystalSymmetry(pairs{p}{1});
  exchange = strcmp(pairs{p}{2},'exchange');
  if exchange, ss = cs; else, ss = specimenSymmetry(pairs{p}{2}); end

  % the centers, as antipodal misorientations for grain exchange
  oR = fundamentalRegion(cs,ss);
  centers = {orientation(oR.V(1),cs,ss), orientation.id(cs,ss), ...
    orientation.byEuler(40*degree,25*degree,10*degree,cs,ss)};
  centers = centers(centerIds);
  for k = 1:numel(centers), centers{k}.antipodal = exchange; end

  % a function of every representation, the fibre density only on orientations
  mode = orientation.byEuler(47*degree,31*degree,15*degree,cs,ss);
  mode.antipodal = exchange;
  fs = {uniformODF(cs,ss), unimodalODF(mode,'halfwidth',12*degree)};
  if exchange
    fs{1}.antipodal = true;
  else
    fs{end+1} = fibreODF(Miller(1,1,1,cs),vector3d(1,0,2),ss,'halfwidth',15*degree); %#ok<AGROW>
  end
  fs{end+1} = SO3FunHarmonic(fs{2},'bandwidth',32); %#ok<AGROW>

  % the reference grid and the values of the functions on it
  S3G = equispacedSO3Grid(cs,ss,'resolution',1.5*degree);
  S3G.antipodal = exchange;
  values = cellfun(@(f) reshape(f.eval(S3G),[],1) / length(S3G),fs,'UniformOutput',false);

  % the centers change at a fixed radius, which a grid reused for another
  % center would miss
  d = cellfun(@(c) angle(S3G(:),c),centers,'UniformOutput',false);
  for radius = radii
    for k = 1:numel(centers)
      for j = 1:numel(fs)
        % with grain exchange the region is counted on a grid of the whole region
        res = radius/15; if exchange, res = min(res,1.5*degree); end
        check(volume(fs{j},centers{k},radius,'resolution',res), ...
          sum(values{j}(d{k} < radius)), 0.04, sprintf('volume, %s, center %d, %g degree, function %d', ...
          strjoin(pairs{p},'/'),k,radius/degree,j));
      end
    end
  end

  if exchange || isempty(fibreIds), continue; end

  fibres = {fibre(Miller(1,0,0,cs),zvector), fibre(Miller(1,1,1,cs),vector3d(0.3,0.5,0.8)), ...
    fibre(Miller(1,2,4,cs),vector3d(0.3,0.5,0.8))};
  fibres = fibres(fibreIds);
  for k = 1:numel(fibres)
    fibres{k}.SS = ss;
    d = angle(fibres{k},S3G(:));
    for radius = radii
      for j = 1:numel(fs)
        check(fibreVolume(fs{j},fibres{k},radius,'resolution',radius/10), sum(values{j}(d < radius)), 0.06, ...
          sprintf('fibreVolume, %s, fibre %d, %g degree, function %d', ...
          strjoin(pairs{p},'/'),k,radius/degree,j));
      end
    end
  end

end

end

% the quadrature of the tube is coarser in the checks, its tolerance wider;
% the errors checked for are factors of two and more
function check(v,ref,tol,what)
assert(abs(v - ref) <= tol * ref + 2e-4, ...
  'check_volume:mismatch','%s: %.5g for %.5g',what,v,ref);
end
