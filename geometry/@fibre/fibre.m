classdef fibre
  %
  % Class representing a fibre in orientation space. Examples are alpha,
  % beta or gamma fibres. In general a fibre is defined by a crystal
  % direction |h| of type <Miller.Miller.html Miller> and a specimen
  % direction of type <vector3d.vector3d.html vector3d>.
  %
  % Syntax
  %   cs = crystalSymmetry('432')
  %   f = fibre.alpha(cs,'full') % the alpha fibre
  %
  %   plotPDF(f,Miller(1,0,0,cs))
  %
  %   f = fibre(o1,o2) % the fibre from o1 to o2
  %
  %   f = fibre(Miller(0,0,1,cs),vector3d.Z,r) % the fibre (001)||ND
  %   f = fibre(h,r)   % the fibre with h parallel to r
  %
  % Input
  %  cs     - @crystalSymmetry
  %  o1, o2 - @orientation
  %  h      - @Miller
  %  r      - @vector3d
  %
  % Class Properties
  %  o1, o2 - start and end @orientation
  %  h      - @Miller
  %
  % See also
  % OrientationFibre FibreODFs ODF.fibreVolume

  properties
    o1 = orientation % starting point
    o2 = orientation % end point (o2 = o1 means full fibre)
    h = Miller  % gradient in id, i.e., ori = o1 * rot(h,omega)
  end

  properties (Dependent = true)
    r % r = ori * h
    CS
    SS
    csL
    csR
    antipodal
  end

  methods
    function f = fibre(o1,varargin)

      if nargin == 0, return; end

      % define a fibre as all o with o*h = r
      if isa(o1,'vector3d')
        f.o1 = orientation.map(o1,varargin{:});
        f.h = o1;
      else
        f.o1 = o1;
      end

      if isa(varargin{1},'quaternion')
        f.o2 = varargin{1};
        varargin(1) = [];
      else
        f.o2 = f.o1;
      end

      if isempty(f.h)
        if ~isempty(varargin) && isa(varargin{1},'vector3d')
          f.h = Miller(varargin{1},o1.CS);
        else
          f.h = axis(inv(o1) .* f.o2,o1.CS,'noSymmetry');
        end
      end

      if check_option(varargin,'full'), f.o2 = f.o1; end
    end

    function n = numArgumentsFromSubscript(varargin)
      n = 0;
    end

    function r = get.r(f)
      r = f.o1 .* f.h;
    end

    function cs = get.CS(f)
      cs = f.o1.CS;
    end

    function f = set.CS(f,cs)
      f.o1.CS = cs;
      if isa(cs,'crystalSymmetry')
        f.h = Miller(f.h,cs);
      else
        f.h = vector3d(f.h);
      end
    end

    function ss = get.SS(f)
      ss = f.o1.SS;
    end

    function f = set.SS(f,ss)
      f.o1.SS = ss;
    end

    function csL = get.csL(f)
      csL = f.SS;
    end

    function f = set.csL(f,csL)
      f.SS = csL;
    end

    function csR = get.csR(f)
      csR = f.CS;
    end

    function f = set.csR(f,csR)
      f.CS = csR;
    end

    function a = get.antipodal(f)
      a = f.h.antipodal;
    end

  end


  methods (Static = true)

    function f = rand(varargin)
      
      n = varargin(cellfun(@isnumeric,varargin));
      sym = varargin(cellfun(@(x) isa(x,'symmetry'),varargin));
      
      h = vector3d.rand(n{:});
      r = vector3d.rand(n{:});
      f = fibre(h,r);
      
      if ~isempty(sym), f.CS = sym{1}; end
      if length(sym)>1, f.SS = sym{2}; end
      
    end
    
    
    function f = alpha(varargin)
      % the alpha fibre
      % from: Comprehensive Materials Processing

      ori1 = orientation.byMiller([0 0 1],[1 1 0],varargin{:});
      ori2 = orientation.byMiller([1 1 1],[1 1 0],varargin{:});

      f = fibre(ori1,ori2,varargin{:});
    end

    function f = beta(varargin)
      % the beta fibre

      ori1 = orientation.byMiller([1 1 2],[1 1 0],varargin{:});
      ori2 = orientation.byMiller([11 11 8],[4 4 11],varargin{:});

      f = fibre(ori1,ori2,varargin{:});
    end

    function f = gamma(varargin)
      % the beta fibre

      ori1 = orientation.byMiller([1 1 1],[1 1 0],varargin{:});
      ori2 = orientation.byMiller([1 1 1],[1 1 2],varargin{:});

      f = fibre(ori1,ori2,varargin{:});
    end

    function f = epsilon(varargin)
    % the epsilon fibre

      ori1 = orientation.byMiller([0 0 1],[1 1 0],varargin{:});
      ori2 = orientation.byMiller([1 1 1],[1 1 2],varargin{:});

      f = fibre(ori1,ori2,varargin{:});
    end

    function f = eta(varargin)
    % the epsilon fibre

      ori1 = orientation.byMiller([0 0 1],[1 0 0],varargin{:});
      ori2 = orientation.byMiller([0 1 1],[1 0 0],varargin{:});

      f = fibre(ori1,ori2,varargin{:});
    end

    function f = tau(varargin)
      % the beta fibre

      ori1 = orientation.byMiller([0 0 1],[1 1 0],varargin{:});
      ori2 = orientation.byMiller([0 1 1],[1 0 0],varargin{:});

      f = fibre(ori1,ori2,varargin{:});
    end
    
    function f = theta(varargin)
      % the theta fibre
      
      CS = getClass(varargin,'crystalSymmetry',crystalSymmetry('432'));
      SS = getClass(varargin,'specimenSymmetry',specimenSymmetry('1'));
      
      f = fibre(Miller(1,0,0,CS),vector3d.Z,SS);
      
    end

    function [f,lambda,delta] = fit(ori,varargin)
      % determines the fibre that fits best a list of orientations
      %
      % Syntax
      %   f = fibre.fit(ori) % fit fibre to a list of orientations
      %
      % Input
      %  ori1, ori2, ori - @orientation
      %
      % Output
      %  f       - @fibre
      %  lambda  - eigenvalues of the orientation tensor

      [~,~,lambda,eigv] = mean(ori);

      ori12 = orientation(quaternion(eigv(:,4:-1:3)),ori.CS,ori.SS);
      f = fibre(ori12(1),ori12(2),'full',varargin{:});
      
      delta = norm(angle(f,ori)) / length(ori);
      
    end

  end
end
