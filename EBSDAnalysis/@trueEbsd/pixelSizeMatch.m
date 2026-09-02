function job = pixelSizeMatch(job, varargin)
% @trueEbsd method
% resize all job.interImgs images to the same pixel size
%
% Syntax
%   job = pixelSizeMatch(job, pixelsize)
%   job = pixelSizeMatch(job) % default pixel size = smallest of job.imgList{:}.dx
%   job = pixelSizeMatch(job, 0) % pixelsize = 0 - use default pixel size
%   job = pixelSizeMatch(job,pixelsize,'offsetMatch','centre','extentMatch','largest');
%   job = pixelSizeMatch(job,pixelsize,'offsetMatch','centre','extentMatch','smallest');
%   job = pixelSizeMatch(job,pixelsize,'offsetMatch','topLeft','extentMatch','largest');
%   job = pixelSizeMatch(job,pixelsize,'offsetMatch','topLeft','extentMatch','smallest');
%
%
% Inputs
% job = @trueEbsd object
% job.imgList contains input data as a @mapImage array
%
% Optional inputs
% pixelsize = numeric scalar (default = smallest)
%
%  Name, Value pair options:
% 'offsetMatch', 'centre' or 'topLeft' (default = centre)
%    How to overlay the images if the fields of view are different sizes.
%    'centre' means the images will start with the central pixel aligned.
%    'topLeft' means the images will start with the top left corner aligned.
%    You should select the option that minimises the total rigid body shift
%    between images.
% 'extentMatch', 'largest' or 'smallest' (default = largest)
%    Whether to crop images to the smallest image field of view (‘smallest’), or
%    extrapolate images to the largest image field of view ( largest’) by
%    repeating the edge and corner pixels to fill the space.
%

% default params. Note the options are read whether or not a pixel size was
% given: gating them on nargin made pixelSizeMatch(job) take a different path
% from pixelSizeMatch(job,0), which are meant to be the same request
[pixelsize,varargin] = getClass(varargin,'numeric',0);
offsetMatch = get_option(varargin,'offsetMatch','centre',{'char'});
extentMatch = get_option(varargin,'extentMatch','largest',{'char'});

if ~(pixelsize>0) %0, nan, or not given at all
  pixelsize = min([job.imgList.dx]);
  disp(append("using default pixel size of ", num2str(pixelsize), " um, minimum from imgList"));
end


%preallocate variables
intpi=cell(1,numel(job.imgList)); % image interpolant
% interpolant function for old image
% with offsetMatch to set zero position
% @griddedInterpolant for image values (numeric r*c*z rray)

extentMax = zeros(numel(job.imgList),2); extentMin=extentMax;
v=cell(numel(job.imgList),1); %xyz pixel position vectors

%% Step 1. calculate original pixel position grids and  set up interpolants
% main outputs in this section:
% intpi{n} = griddedInterpolant object describing xyz pixel positions for image job.imgList(n).img
% v{n} = grid vectors defining pixel positions of job.resizedList(n).img
% v{1} = 1*r numeric vector containing row(Y) positions
% v{2} = 1*c numeric vector containing col(X) positions
% v{3} = [1:z] for z image (colour) channels
% uses ndgrid convention in MATLAB (so [r,c,z] not [x,y,z])


for n = 1:numel(job.imgList) %loop through all images in workflow
  %old pixel size
  pxn=job.imgList(n).dx;

  %preallocate variables
  v{n} = cell(1,ndims(job.imgList(n).img)); % cell array to hold xy pixel position lists for each image
  g=v{n};
  for nd = 1:ndims(job.imgList(n).img)
    if nd<3
      %create xy vector
      %initialise as [0,0] = centre of top left pixel
      v{n}{nd} = pxn*(0:size(job.imgList(n).img,nd)-1);
      % handle offset between images in job.imgList{:}
      switch offsetMatch
        case 'centre'
          %[0,0] = centre of image FOV
          v{n}{nd} = v{n}{nd} - (max(v{n}{nd})/2);
        case 'topLeft'
          %[0,0] = top left corner of image FOV -->
          %centre of top left pixel = [pxn/2,pxn/2]
          v{n}{nd} = v{n}{nd} + (pxn/2);
      end
    else
      %handle 3rd image as colour channels (pixel depth = 1 and don't
      %match anything) -- but don't assume it's always RGB 3
      %channels - e.g. forescatter images have 5 channels
      v{n}{nd} = 1:size(job.imgList(n).img,nd);
    end
  end
  [g{:}] = ndgrid(v{n}{:}); % pixel positions
  % pos is derived from the origin and the steps on a @mapImage, so unlike
  % @distortedImg there is nothing to write back onto the input list
  % intp = interpolant function
  % intpi = interpolant for image
  intpi{n}=griddedInterpolant(g{:},job.imgList(n).img,'linear','none');

  % calculate exent of common pixel position grid
  for nd2=1:2 %only do this for xy coordinates
    extentMax(n,nd2)= max(intpi{n}.GridVectors{nd2} + pxn/2);
    extentMin(n,nd2)= min(intpi{n}.GridVectors{nd2} - pxn/2);
  end


end

%%  Step 2. calculate common pixel position grid
% with optional extra dimensions
%
% main output in this section:
% vc = grid vectors defining pixel positions of common image grid in job.resizedList{:}
% vc{nd2} = row-col pixel positions of in length units (default um)
% vc{1} = 1*r numeric vector containing row(Y) positions
% vc{2} = 1*c numeric vector containing col(X) positions
% uses ndgrid convention in MATLAB (so [r,c] not [x,y])
% colour channels are left unchanged so numel(vc) = 2
% eventually goes into job.resizedList(n).pos (via gn{:} - defined in Step 4)
%

%1. first figure out how many pixels you need
%take into account half-pxn step at image edges
vc=cell(1,2); %common xy position vectors
offsetPos = zeros(1,2); % xy (east/south) position offset
for nd2=1:2 %only do this for xy coordinates
  switch extentMatch
    %you could do min:pixelsize:max but this method avoids rounding instabilities
    case 'largest'
      % vc{nd2} = min(extentMin(:,nd2)) : pixelsize : max(extentMax(:,nd2)) + eps*10000;
      npix = floor(eps*10000 + (max(extentMax(:,nd2))- min(extentMin(:,nd2)))/pixelsize);
    case 'smallest'
      % vc{nd2} = max(extentMin(:,nd2)) : pixelsize : min(extentMax(:,nd2)) + eps*10000;
      npix = floor(eps*10000 + (min(extentMax(:,nd2))- max(extentMin(:,nd2)))/pixelsize);
    otherwise
      error('MTEX:trueEbsd:badExtentMatch', ...
        'invalid extentMatch option: use either ''largest'' or ''smallest''');
  end

  switch offsetMatch
    case 'centre' %[0,0] = centre of image FOV
      % 2. create xy pos vector with the new length (npix) and
      % pixelsize, then ...
      % 3. adjust vector offset to put [0,0] back in the middle
      offsetPos(nd2) = (-(npix+1)/2)*pixelsize;

      % sanity check:
      % if npix is even, [0,0] is at a pixel edge
      % but if npix is odd, [0,0] position is a pixel centre

    case 'topLeft' %[0,0] = top left corner of image FOV -->
      %centre of top left pixel = [pixelsize/2,pixelsize/2]
      offsetPos(nd2) = (-0.5)*pixelsize;
    otherwise
      error('MTEX:trueEbsd:badOffsetMatch', ...
        'invalid offsetMatch option: use either ''centre'' or ''topLeft''');
  end
  %convert to length units (um) and apply position offset between images
  vc{nd2} = pixelsize*(1:npix) + offsetPos(nd2);
end

%%  Step 4. resample images and edge transforms on common grid
% Main inputs in this section:
% intpi{n} = griddedInterpolant object describing image values
%   for image job.imgList(n).img from Step 1
% v{n} = original (old) image grid position vectors for each image in
%   job.imgList(n) from Step 1
% vc = common (new) image grid row-col position vectors for all images in
%   job.resizedList{:} from Step 2
%
% Calculated helper variables
% vn = common (new) image grid position vectors for all images in
%   job.resizedList{:} (including colour channels)
% gn{:} = the same information as vn{n} but formatted as ndgrid

% Main outputs in this section:
% job.resizedList(n).img = image values resampled on the common pixel position
%   grid gn{:} using intpi{n} griddedInterpolant
% job.resizedList(n).pos = @vector3d of pixel positions from gn{:}
% job.resizedList(n).ebsd = (if it exists) @EBSD where ebsd.id is resampled
% on the common pixel position grid gn{:} using intpi{n}
% griddedInterpolant using nearest neighbour interpolation (i.e.
% orientations are not actually interpolated)


% write outputs to job.resizedList
job.resizedList = repmat(mapImage,1,numel(job.imgList));
for n = 1:numel(job.imgList)

  vn=v{n}; %new vector
  gn=cell(size(v{n})); % ndgrid positions for image job.resized{n}.img, constructed from vn
  vn(1:2) = vc; %replace xy with common vectors but leave colour channels alone
  [gn{:}] = ndgrid(vn{:}); %new grid

  % resample image values on new grid
  imgNew = intpi{n}(gn{:});

  % the layout says which specimen directions the row and column indices
  % advance along, so the common grid's geometry follows from it
  gL = job.imgList(n).layout;
  d1New = pixelsize*gL.basis(1);              % row step
  d2New = pixelsize*gL.basis(2);              % column step
  originNew = vc{2}(1)*gL.basis(2) + vc{1}(1)*gL.basis(1);

  % the map goes with its image: the common grid, in the map's own
  % coordinates, is looked up point by point. Pixel (i,j) of the image sits
  % at v{n}{1}(i), v{n}{2}(j), and pixel (1,1) is where the map begins
  if ~isempty(job.imgList(n).ebsd)

    ebsd = job.imgList(n).ebsd;
    src = ebsd.pos(1,1) + (gn{1}(:,:,1) - v{n}{1}(1)) .* gL.basis(1) + ...
      (gn{2}(:,:,1) - v{n}{2}(1)) .* gL.basis(2);

    ebsdNew = interp(ebsd,src(:));

    % on the common grid, in the frame the image is aligned in - the same
    % handle, so the two cannot drift apart
    ebsdNew.pos = reshape(gn{2}(:,:,1) .* gL.basis(2) + gn{1}(:,:,1) .* gL.basis(1),[],1);
    ebsdNew.frame = job.imgList(n).frame;
    ebsdNew = updateUnitCell(ebsdNew);

    % in the array order the entry's image is in - without the layout
    % gridify would canonicalise the map to d1 along y
    job.resizedList(n) = mapImage(imgNew,gridify(ebsdNew,gL),'name',job.imgList(n).name);

  else

    job.resizedList(n) = mapImage(imgNew,'name',job.imgList(n).name);
    job.resizedList(n).frame = job.imgList(n).frame;
    job.resizedList(n).d1 = d1New;
    job.resizedList(n).d2 = d2New;
    job.resizedList(n).origin = originNew;

  end

  % roiSize is a length and is measured by autoTune when it is left at
  % 'auto', so there is nothing to fill in here any more

end