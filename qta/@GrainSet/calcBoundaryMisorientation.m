function [m,weights] = calcBoundaryMisorientation(grains,varargin)


if check_option(varargin,{'sub','subboundary','internal','intern'})
  I_FD = grains.I_FDsub;
elseif  check_option(varargin,{'external','ext','extern'})
  I_FD = grains.I_FDext;
else % otherwise select all boundaries
  I_FD = grains.I_FDext | grains.I_FDsub;
end

[d,i] = find(I_FD(sum(I_FD,2) == 2,any(grains.I_DG,2))');
pairs = reshape(d,2,[]);

phase = get(grains.EBSD,'phase');
phaseMap = get(grains,'phaseMap');

r       = get(grains.EBSD,'rotations');
phase   = get(grains.EBSD,'phase');
notIndexed = ~isNotIndexed(grains.EBSD);

phase = phase(pairs);
notIndexed = notIndexed(pairs);

del = diff(phase)~=0 | any(~notIndexed);
phase(:,del) = []; pairs(:,del) = [];

% check only a single phase is involved
if numel(unique(phase)) > 1
  
  error('MTEX:MultiplePhases',['This operatorion is only permitted for a single phase! ' ...
    'See ' doclink('xx','xx')  ...
    ' for how to restrict GrainSet to a single phase.']);
  
else
  
  sel = phase == phaseMap(grains.phase(1));
  
  if any(sel(:))
    CS = get(grains,'CSCell');
    SS = get(grains,'SS');
    
    
    phasepair = reshape(pairs(sel),2,[]);
    o   = orientation(r(phasepair),CS{grains.phase(1)},SS);
    m  = o(1,:).\o(2,:); % misorientation
  else
    warning('selected phase does not contain any boundaries')
    m = orientation;
  end
  
end
