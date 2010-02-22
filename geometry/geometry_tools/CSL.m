function q = CSL(sigma)

csl = listCSL;

if nargin>0
  nd = strcmpi(sigma,{csl.sigma});

  if any(nd)
    q = csl(nd).quaternion;
    return
  end
end

for k=1:length(csl)
  fprintf(['  Sigma ' csl(k).sigma '\t: %4.2f' mtexdegchar '/<%i%i%i>\n'],csl(k).angle,csl(k).axis)
end



function csl = listCSL

csl = struct('sigma',[],'angle',[],'axis',[]);

% b.c.c.  <  other symmetries other csl? 
csl = addCSL(csl, '3'  , 60   , [1 1 1]);
csl = addCSL(csl, '5'  , 36.86,	[1 0 0]);
csl = addCSL(csl, '7'  , 38.21,	[1 1 1]);
csl = addCSL(csl, '9'  , 38.94,	[1 1 0]);
csl = addCSL(csl, '11' , 50.47,	[1 1 0]);
csl = addCSL(csl, '13a', 22.62,	[1 0 0]);
csl = addCSL(csl, '13b', 27.79,	[1 1 1]);
csl = addCSL(csl, '15' , 48.19,	[2 1 0]);
csl = addCSL(csl, '17a', 28.07,	[1 0 0]);
csl = addCSL(csl, '17b', 61.9	, [2 2 1]);
csl = addCSL(csl, '19a', 26.53,	[1 1 0]);
csl = addCSL(csl, '19b', 46.8	, [1 1 1]);
csl = addCSL(csl, '21a', 21.78,	[1 1 1]);
csl = addCSL(csl, '21b', 44.41,	[2 1 1]);
csl = addCSL(csl, '23' , 40.45,	[3 1 1]);
csl = addCSL(csl, '25a', 16.26,	[1 0 0]);
csl = addCSL(csl, '25b', 51.68,	[3 3 1]);
csl = addCSL(csl, '27a', 31.59,	[1 1 0]);
csl = addCSL(csl, '27b', 35.43,	[2 1 0]);
csl = addCSL(csl, '29a', 43.6	, [1 0 0]);
csl = addCSL(csl, '29b', 46.4	, [2 2 1]);
csl = addCSL(csl, '31a', 17.9	, [1 1 1]);
csl = addCSL(csl, '31b', 52.2	, [2 1 1]);
csl = addCSL(csl, '33a', 20.1	, [1 1 0]);
csl = addCSL(csl, '33b', 33.6	, [3 1 1]);
csl = addCSL(csl, '33c', 59.0	, [1 1 0]);
csl = addCSL(csl, '35a', 34.0	, [2 1 1]); 
csl = addCSL(csl, '35b', 43.2	, [3 3 1]);


function csl = addCSL(csl,sigma,angle, axis)

if isempty(csl(1).sigma), n = 1;
else n = numel(csl)+1; end

csl(n).sigma = sigma;
csl(n).angle = angle;
csl(n).axis  = axis;
csl(n).quaternion = axis2quat(vector3d(axis),angle*degree);

