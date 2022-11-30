function simulateGrains(this,varargin)
%
% Syntax
%
%   neper.simulateGrains(odf, numGrains)
%
%   % is numGrains == length(ori)?
%   neper.simulateGrains(ori)
%
% Input
%  neper - @neperInstance
%  odf   - @ODF
%  numGrains - number of grains
%  ori   - @orientation
% 

    numGrains=100;    %default

    if nargin==3  %numGrains & ori
      if isnumeric(varargin{1}) && isa(varargin{2},'ODF')
        numGrains=varargin{1};
        ori = varargin{2}.discreteSample(numGrains);
      elseif isnumeric(varargin{2}) && isa(varargin{1},'ODF')
        numGrains=varargin{2};
        ori = varargin{1}.discreteSample(numGrains);
      else
        error 'argument error'
      end
    elseif nargin==2 %ori
      if isa(varargin{1},'orientation')
        ori=varargin{1};
        numGrains=length(varargin{1});
      elseif isa(varargin{1},'ODF')
        ori = varargin{1}.discreteSample(numGrains);
      else
        error 'argument error'
      end
    else %default
      ori=orientation.rand();
      ori.CS=crystalSymmetry('mmm');
      ori = unimodalODF(ori).discreteSample(numGrains);
    end

    %% parsing orientations
    CS=ori.CS.LaueName;
    switch CS
      case '2/m11'
        CS='2/m';
      case '12/m1'
        CS='2/m';
      case '112/m'
        CS='2/m';
      case '-3m1'
        CS='-3m';
      case '-31m'
        CS='-3m';
      otherwise
    end

    %% save ori to file
    oriFilename='ori_in.txt';
    fid=fopen(oriFilename,'w');
    
    fprintf(fid,'%f %f %f\n',ori.Rodrigues.xyz.');
    fclose(fid);

    system([this.cmdPrefix 'neper -T -n ' num2str(numGrains) ...
    ' -morpho "diameq:lognormal(1,0.35),1-sphericity:lognormal(0.145,0.03),aspratio(3,1.5,1)" ' ...
      ' -morphooptistop "itermax=' num2str(this.iterMax) '" ' ... % decreasing the iterations makes things go a bit faster for testing
      ' -oricrysym "' CS '" '...
      ' -ori "file(' oriFilename ')" ' ... % read orientations from file, default rodrigues
      ' -statpoly faceeqs ' ... % some statistics on the faces
      ' -o ' this.fileName3d ' ' ... % output file name
      ' -oridescriptor rodrigues ' ... % orientation format in output file
      ' -oriformat plain ' ...
      ' -format tess,ori' ... % outputfiles
      ' && ' ...
      ...
      this.cmdPrefix 'neper -V ' this.fileName3d '.tess']);

  end