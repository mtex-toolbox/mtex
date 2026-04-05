classdef simulateEBSD < handle
% Class guiding through the simple simulation of an EBSD object
%
% Description
% It allows to simulate a single/multigradient EBSD map with a free
% choice of the starting orientation, size, misorientation axis,
% direction of misorientaiton increase, type and range of noise
% Multiple gradients can be superposed and you can use an existing map
% and add noise or deform it.
%
% TODO:
% - add the singleJump, multiKnob, polyGrain
% - make noise distribution more flexible
% - allow to start from a different pos
% - fix first column of pixels
%
% Syntax
%
%   % initialize the object
%   ebsdSIM = simulateEBSD
%
%   % set the dimension (optional)
%   ebsdSIM.xdim = 50
%   ebsdSIM.ydim = 50
%
%   % change the initial orientation (optional)
%   ebsdSIM.ori0 = orientation.byEuler([0, pi, 30]*degree,ebsdSIM.CS)
%
%   % make a planar map
%   ebsdSIM.makeMap
%   plot(ebsdSIM.EBSDsim)
%
%   % 1) create a simple gradient
%   % 1a) set the misorientation axis
%   ebsdSIM.axS = vector3d(1,1,0)
%   % 1b) set the direction towards which the misorientation increases
%   ebsdSIM.gradDir = vector3d(1,0,0);
%   % 1c) create the gradient
%   ebsdSIM.addFeature_simpleGradient
%
%   % 2) add noise
%   % 2a) specify noise type: 'uniform' or 'logn'
%   ebsdSIM.noiseFun = 'logn'
%   % 2b) specify maximum noise
%   ebsdSIM.noiseMax = 0.1*degree;
%   % 2c) create noise
%   ebsdSIM.addnoise
%
%   % 3) add a circular "subgrain"
%   % 3a) set the misorientation axis
%   ebsdSIM.axS = vector3d(1,1,1)
%   % 3b) add "subgrain"
%   ebsdSIM.addFeature_circularSubgrain
%
%   % inspect the result
%   ebsd = ebsdSIM.EBSDsim;
%   plot(ebsd,angle(ebsd.orientations,ebsd.orientations(1))/degree)
%   nextAxis
%   ebsd = ebsd.gridify
%   plot(ebsd,ebsd.gradientX.norm)
%   nextAxis
%   plot(ebsd,ebsd.gradientY.norm)
%   nextAxis
%   sax = axis(ebsd(1).orientations,ebsd.orientations)
%   ck= HSVDirectionKey(specimenSymmetry('1'))
%   plot(ebsd,ck.direction2color(sax))
%   nextAxis
%   plot(ck)
%


properties
  xdim = 100;                 % size of the map
  ydim = 100;                 % size of the map
  stepSize = 1;               %
  domainID                    % used for subgrain assignment (not implemented yet)
  noiseFun                    % ' ' 'uniform', 'logn'
  noiseMax  = 0.05*degree     %
  EBSDsim                     % EBSD at the current stage of simulation
  axS = yvector;              % misorientation axis in specimen coordinates
  gradDir = xvector;          % gradient direction
  mori_angle = 0.0017;        % misorientation angle increment per unit step
  % initial orientation
  ori0 = orientation.id(crystalSymmetry('1','mineral','kryptonite'));
    
end

properties (Dependent=true)
  CS
  % EBSD at the current stage of simulation
end

methods
  function job = simulateEBSD(); end

  %create a map
  function makeMap(job,varargin)

    %define coords
    xlong = 1:job.stepSize:job.xdim;
    ylong  =1:job.stepSize:job.ydim;
    [x,y] = meshgrid(xlong,ylong);
    
    % how many pixels
    sizeX = size(xlong,2);
    sizeY  =size(ylong,2);
    
    % put it all together
    pos = vector3d(x(:),y(:),0);
    
    % set all rots identical
    if size(job.ori0(:))==1
      rot = repmat(rotation(job.ori0),sizeX*sizeY,1);
    elseif size(job.ori0(:)) == size(pos(:))
      rot = rotation(job.ori0);
    else
      error(['job.ori0 needs to either be of size 1 or ' num2str(size(pos(:))) ' pixels'])
    end
    % set phases
    phases = ones(sizeX*sizeY,1);
    
    % set a cslist
    CSList = {'notIndexed' job.CS};
    prop.emptyProp = ones(sizeX*sizeY,1); % one never knows
    
    % assemble ESBD
    job.EBSDsim = EBSD(pos,rot,phases,CSList,prop);
    
  end
  
  
  %make a simple gradient
  function addFeature_simpleGradient(job)
    
    % simply update orientations according to gradient and axis
    job.EBSDsim.orientations = updateOri(job.EBSDsim, job);
    
  end
  
  %make a simple gradient
  function addFeature_circularSubgrain(job)
    
    % 1) determine region of subgrain and assign domainID
    c = [job.xdim/2 job.ydim/2];
    r = min(c)/2;
    theta = linspace(0,2*pi,360);
    job.domainID = ...
      job.EBSDsim.inpolygon([cos(theta)*r; sin(theta)*r]' + c);
    
    % 2) update orientation inside domainID
    ms = job.axS * job.mori_angle;
    job.EBSDsim.orientations(job.domainID) = ...
      exp(job.EBSDsim.orientations(job.domainID),ms,SO3TangentSpace.leftVector);
    
  end
  
  %make a single step
  function addFeature_singleStep(job)
    
    % 1) determine region of sugrain and assign domainID
    %  now set subregions
    %   a _______f
    %    |       |
    %    |b_c    |
    %       |d___|e
    
    a = [job.xdim/3               0];
    b = [job.xdim/3      job.ydim/2];
    c = [2*job.xdim/3    job.ydim/2];
    d = [2*job.xdim/3      job.ydim];
    e=  [job.xdim          job.ydim];
    f=  [job.xdim                 0];
    
    job.domainID = ...
      job.EBSDsim.inpolygon([a;b;c;d;e;f]);
    
    % 2) update orientation inside domainID
    ms = job.axS * job.mori_angle;
    job.EBSDsim.orientations(job.domainID) = ...
      exp(job.EBSDsim.orientations(job.domainID),ms,SO3TangentSpace.leftVector);
  end
  
  
  %add noise
  function addnoise(job)
    
    % random axis
    rax = vector3d.rand(length(job.EBSDsim),1);
    
    switch job.noiseFun
      
      case {'uniform' 'uniForm'}
        
        rax = vector3d.rand(length(job.EBSDsim),1);
        rang = job.noiseMax .* rand(length(job.EBSDsim),1);
        
      case {'lognorm' 'logn'}
        
        mu  = 0;            % todo; make this a user choice
        sig = 1;            % todo; make this a user choice
        
        % use cdf as a lookup table for uniform input
        icdf = @(cdfx,mu,sig) exp( erfinv(2*cdfx - 1) * sig * sqrt(2) + mu);
        rang = icdf(rand(length(job.EBSDsim),1),mu,sig);
        rang = rang/max(rang) * job.noiseMax;
    end
    
    rot = rotation.byAxisAngle(rax,rang);
    job.EBSDsim.orientations = rot.*job.EBSDsim.orientations;
    
  end
  
  
  function out = get.EBSDsim(job)
    out = job.EBSDsim;
  end
  
  function set.EBSDsim(job,ebsd)
    job.EBSDsim = ebsd;
  end
  
  function out = get.CS(job)
    out = job.ori0.CS;
  end
  
  function set.CS(job,CS)
    job.ori0.CS = CS;
  end
  
end
end

function ori_new = updateOri(ebsd, job)

% derive new orientations
% ebsd might also be a subset e.g. when jumps ore more than one grain will
% be involved, everythign else comes from the job

% in case axS comes in crystal coords
if isa(job.axS,'Miller'), job.axS = inv(ebsd.orientations).* job.axS; end

% 1) define misorientation vector in specimen coordinates
% direction of the vector is the misorientation axis, angle it's length
ms = job.axS * job.mori_angle;

% 2) the misorientation should increase along gradDir
% normalize ebsd position vectors to stepsize
pos = ebsd.pos / ebsd.dPos;
% incremental position: length of pos projected on gradient direction
ipos = pos .* (job.gradDir.normalize).^2;

% 3) scale misorientation by the norm of ipos which should get the
% misorientation at pixel positions
mpp = norm(ipos) .* -ms;

% 4) new ori
ori_new =  exp(ebsd.orientations,mpp,SO3TangentSpace.leftVector);
end