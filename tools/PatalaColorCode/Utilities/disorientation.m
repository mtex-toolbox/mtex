% Copyright 2013 Oliver Johnson, Srikanth Patala
% 
% This file is part of MisorientationMaps.
% 
%     MisorientationMaps is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     MisorientationMaps is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with MisorientationMaps.  If not, see <http://www.gnu.org/licenses/>.

%-------------------------------------------------------------------------%
%Filename:  disorientation.m
%Author:    Oliver Johnson
%Date:      2/25/2012
%
% DISORIENTATION determines the unique misorientation between two adjacent
% crystals among all of the symmetrically equivalent ones, satisfying the
% conditions specified in [1], where a unit quaternion is defined by 
% q = [q0 q1 q2 q3]. DISORIENTATION is fully vectorized.
%
% Inputs:
%   m - An npts-by-4 array of unit quaternions representing the
%       misorientations for which a disorientation is desired.
%   cs - A string indicating the crystal symmetry.  The following strings
%        are recognized:
%
%        'triclinic'
%        'monoclinic'
%        'orthorhombic'
%        'trigonal' or 'rhombohedral'
%        'tetragonal'
%        'hexagonal'
%        'cubic'
%
% Outputs:
%   d - An npts-by-4 array containing the quaternion representing the
%       unique disorientation for each misorientation in m, i.e. d(i,:) is
%       the disorientation corresponding to the misorientation m(i,:).
%
% NOTE: The disorientation returned is the unique one satisfying Grimmer's
% conditions for a "reduced rotation". I.e. while there may actually be
% several equivalent disorientations all lying on the boundary of the
% fundamental zone, only one of them is a "reduced rotation" and this is
% the disorientation that is returned.
%
% [1] Grimmer H. Acta crystallographica section a 1980;36:382-389.
%
% Change Log:
%   9/24/2012 - Added support for MTEX 3.3.1 symmetry labels
%-------------------------------------------------------------------------%

% some testing code
% angle = 10*degree;
% v = regularS2Grid('points',50000)
% q = axis2quat(v,angle)
% cs = symmetry('mmm');
% d = disorientation([q.a(:),q.b(:),q.c(:),q.d(:)],cs.LaueName);
% qq = quaternion(d.'), plot(qq.axis)
% hold on, plot(rotate(cs.fundamentalSector,90*degree),'color','r'), hold off
% hold on, plot(rotate(cs.fundamentalSector,axis2quat(yvector,90*degree)*axis2quat(zvector,90*degree)),'color','b'), hold off
% plot(axis2quat(zvector,90*degree)*axis2quat(yvector,90*degree)*q.axis)


function d = disorientation(m,cs)

%---determine appropriate symmetry relations to use---%
switch lower(cs)
    case {'triclinic','c1','1','-1','ci'}
        dis = @(m0,m1,m2,m3) dis_triclinic(m0,m1,m2,m3);
%         neq = 1; %number of equations used for computing symmetryically equivalent rotations
%         nperms = 1;
%         nsigns = 4;
    case {'monoclinic','m','cs','c2h','c2','2/m','2'}
        dis = @(m0,m1,m2,m3) dis_monoclinic(m0,m1,m2,m3);
%         neq = 1;
%         nperms = 2;
%         nsigns = 8;
    case {'orthorhombic','mmm','mm2','d2h','d2','c2v','222'}
        dis = @(m0,m1,m2,m3) dis_orthorhombic(m0,m1,m2,m3);
%         neq = 1;
%         nperms = 4;
%         nsigns = 16;
    case {'trigonal','rhombohedral','d3d','d3','c3v','c3i','c3','3m','32','3','-3m','-3',' -3'}
        dis = @(m0,m1,m2,m3) dis_trigonal(m0,m1,m2,m3);
%         neq = 9;
%         nperms = 2;
%         nsigns = 8;
    case {'tetragonal','s4','d4h','d4','d2d','c4v','c4h','c4','4mm','422','4/mmm','4/m','4','-42m','-4'}
        dis = @(m0,m1,m2,m3) dis_tetragonal(m0,m1,m2,m3);
%         neq = 2;
%         nperms = 8;
%         nsigns = 16;
    case {'hexagonal','d6h','d6','d3h','c6v','c6h','c6','c3h','6mm','622','6/mmm','6/m','6','-6m2','-6'}
        dis = @(m0,m1,m2,m3) dis_hexagonal(m0,m1,m2,m3);
%         neq = 9;
%         nperms = 4;
%         nsigns = 16;
    case {'cubic','m-3m','m-3','th','td','t','oh','o','432','23','-43m'}
        dis = @(m0,m1,m2,m3) dis_cubic(m0,m1,m2,m3);
%         neq = 6;
%         nperms = 24;
%         nsigns = 16;
    otherwise
        str = sprintf(['''',cs,''' crystal symmetry is not supported. \n',...
            'The following crystal symmetries are supported: \n',...
            '\t ''triclinic'' \n',...
            '\t ''monoclinic'' \n',...
            '\t ''orthorhombic'' \n',...
            '\t ''trigonal'' (''rhombohedral'') \n',...
            '\t ''tetragonal'' \n',...
            '\t ''hexagonal'' \n',...
            '\t ''cubic'' \n']);
        error(str) %#ok<SPERR>
end

%---compute disorientation---%
d = dis(m(:,1),m(:,2),m(:,3),m(:,4));

end

%symmetry relations for triclinic crystal symmetry
function D = dis_triclinic(m0,m1,m2,m3)

%---number of misorientations---%
nm = numel(m0);

%---pre-allocate---%
D = zeros(nm,4);

%---compute equivalent misorientations---%
eq = {@(a0,a1,a2,a3) a0,@(a0,a1,a2,a3) a1, @(a0,a1,a2,a3) a2, @(a0,a1,a2,a3) a3};

%---all possible sign changes---%
s = [ 1  1  1  1;...
     -1  1  1  1;...
      1 -1 -1 -1;
     -1 -1 -1 -1];

%---all possible permutations---%
p = [1 2 3 4];

for i = 1:size(eq,1)
    for j = 1:size(s,1)
        for k = 1:size(p,1)
            
            %---form equivalent quaternion---%
            a = eq{i,p(k,1)}(m0,m1,m2,m3).*s(j,1);
            b = eq{i,p(k,2)}(m0,m1,m2,m3).*s(j,2);
            c = eq{i,p(k,3)}(m0,m1,m2,m3).*s(j,3);
            d = eq{i,p(k,4)}(m0,m1,m2,m3).*s(j,4);

            %---test for disorientation---%
            isdis = a >= 0 & d >= 0;
            
            %---suplemental conditions for uniqueness---%
            sup1 = isdis & d == 0;
            if any(sup1)
                isdis(sup1) = c(sup1) >= 0;
                sup2 = sup1 & c == 0;
                if any(sup2)
                    isdis(sup2) = b(sup2) >= 0;
                end
            end
            
            %---store disorientations---%
            if any(isdis)
                D(isdis,:) = [a(isdis), b(isdis), c(isdis), d(isdis)];
            end
            
        end
    end
end

end

%symmetry relations for monoclinic crystal symmetry
function D = dis_monoclinic(m0,m1,m2,m3)

%---number of misorientations---%
nm = numel(m0);

%---pre-allocate---%
D = zeros(nm,4);

%---compute equivalent misorientations---%
eq = {@(a0,a1,a2,a3) a0,@(a0,a1,a2,a3) a1, @(a0,a1,a2,a3) a2,@(a0,a1,a2,a3) a3};

%---all possible sign changes---%
s = zeros(8,4);
ind = 1;
for i = -1:2:1
    for j = -1:2:1
        for k = -1:2:1
            s(ind,:) = [i j k k];
            ind = ind+1;
        end
    end
end

%---all possible permutations---%
p = [ 1  2  3  4;...
      2  1  4 -3];

for i = 1:size(eq,1)
    for j = 1:size(s,1)
        for k = 1:size(p,1)
            
            %---form equivalent quaternion---%
            if k == 2
                a = eq{i,p(k,1)}(m0,m1,m2,m3).*s(j,1);
                b = eq{i,p(k,2)}(m0,m1,m2,m3).*s(j,2);
                c = eq{i,p(k,3)}(m0,m1,m2,m3).*s(j,3);
                d = -eq{i,-p(k,4)}(m0,m1,m2,m3).*s(j,4);
            else
                a = eq{i,p(k,1)}(m0,m1,m2,m3).*s(j,1);
                b = eq{i,p(k,2)}(m0,m1,m2,m3).*s(j,2);
                c = eq{i,p(k,3)}(m0,m1,m2,m3).*s(j,3);
                d = eq{i,p(k,4)}(m0,m1,m2,m3).*s(j,4);
            end

            %---test for disorientation---%
            isdis = a >= b & b >= 0 & d >= 0;
            
            %---supplemental conditions for uniqueness---%
            sup1 = isdis & a == b & d > 0;
            if any(sup1)
                isdis(sup1) = c(sup1) > 0;
            end
            sup2 = isdis & d == 0;
            if any(sup2)
                isdis(sup2) = c(sup2) >= 0;
            end
                        
            %---store disorientations---%
            if any(isdis)
                D(isdis,:) = [a(isdis), b(isdis), c(isdis), d(isdis)];
            end
            
        end
    end
end

end

%symmetry relations for orthorhombic crystal symmetry
function D = dis_orthorhombic(m0,m1,m2,m3)

%---number of misorientations---%
nm = numel(m0);

%---pre-allocate---%
D = zeros(nm,4);

%---compute equivalent misorientations---%
eq = {@(a0,a1,a2,a3) a0,@(a0,a1,a2,a3) a1, @(a0,a1,a2,a3) a2,@(a0,a1,a2,a3) a3};

%---all possible sign changes---%
s = zeros(16,4);
ind = 1;
for i = -1:2:1
    for j = -1:2:1
        for k = -1:2:1
            for l = -1:2:1
                s(ind,:) = [i j k l];
                ind = ind+1;
            end
        end
    end
end

%---all possible permutations---%
p = [1 2 3 4;...
     2 1 4 3;...
     3 4 1 2;...
     4 3 2 1];

for i = 1:size(eq,1)
    for j = 1:size(s,1)
        for k = 1:size(p,1)
            
            %---form equivalent quaternion---%
            a = eq{i,p(k,1)}(m0,m1,m2,m3).*s(j,1);
            b = eq{i,p(k,2)}(m0,m1,m2,m3).*s(j,2);
            c = eq{i,p(k,3)}(m0,m1,m2,m3).*s(j,3);
            d = eq{i,p(k,4)}(m0,m1,m2,m3).*s(j,4);

            %---test for disorientation---%
            isdis = a >= b & b >= 0 & a >= c & c >= 0 & a >= d & d >= 0;
            
            %---suplemental conditions for uniqueness---%
            sup1 = isdis & a == b;
            if any(sup1)
                isdis(sup1) = c(sup1) >= d(sup1);
            end
            sup2 = isdis & a == c;
            if any(sup2)
                isdis(sup2) = b(sup2) >= d(sup2);
            end
            sup3 = isdis & a == d;
            if any(sup3)
                isdis(sup3) = b(sup3) >= c(sup3);
            end
            
            %---store disorientations---%
            if any(isdis)
                D(isdis,:) = [a(isdis), b(isdis), c(isdis), d(isdis)];
            end
            
        end
    end
end

end

%symmetry relations for trigonal (rhombohedral) crystal symmetry
function D = dis_trigonal(m0,m1,m2,m3)

%---number of misorientations---%
nm = numel(m0);

%---pre-allocate---%
D = zeros(nm,4);

%---compute equivalent misorientations---%
eq(1,:) = {@(a0,a1,a2,a3) a0, @(a0,a1,a2,a3) a1, @(a0,a1,a2,a3) a2, @(a0,a1,a2,a3) a3};
eq(2,:) = {@(a0,a1,a2,a3) a0, @(a0,a1,a2,a3) 0.5*(a1+sqrt(3)*a2), @(a0,a1,a2,a3) 0.5*(-a2+sqrt(3)*a1), @(a0,a1,a2,a3) a3};
eq(3,:) = {@(a0,a1,a2,a3) a0, @(a0,a1,a2,a3) 0.5*(a1-sqrt(3)*a2), @(a0,a1,a2,a3) 0.5*(-a2-sqrt(3)*a1), @(a0,a1,a2,a3) a3};
eq(4,:) = {@(a0,a1,a2,a3) a1, @(a0,a1,a2,a3) 0.5*(a0+sqrt(3)*a3), @(a0,a1,a2,a3) 0.5*(a3-sqrt(3)*a0), @(a0,a1,a2,a3) a2};
eq(5,:) = {@(a0,a1,a2,a3) a1, @(a0,a1,a2,a3) 0.5*(a0-sqrt(3)*a3), @(a0,a1,a2,a3) 0.5*(a3+sqrt(3)*a0), @(a0,a1,a2,a3) a2};
eq(6,:) = {@(a0,a1,a2,a3) 0.5*(a0+sqrt(3)*a3), @(a0,a1,a2,a3) 0.5*(a1-sqrt(3)*a2), @(a0,a1,a2,a3) 0.5*(a2+sqrt(3)*a1), @(a0,a1,a2,a3) 0.5*(a3-sqrt(3)*a0)};
eq(7,:) = {@(a0,a1,a2,a3) 0.5*(a0-sqrt(3)*a3), @(a0,a1,a2,a3) 0.5*(a1+sqrt(3)*a2), @(a0,a1,a2,a3) 0.5*(a2-sqrt(3)*a1), @(a0,a1,a2,a3) 0.5*(a3+sqrt(3)*a0)};
eq(8,:) = {@(a0,a1,a2,a3) 0.5*(a0+sqrt(3)*a3), @(a0,a1,a2,a3) 0.5*(a1+sqrt(3)*a2), @(a0,a1,a2,a3) 0.5*(a2-sqrt(3)*a1), @(a0,a1,a2,a3) 0.5*(a3-sqrt(3)*a0)};
eq(9,:) = {@(a0,a1,a2,a3) 0.5*(a0-sqrt(3)*a3), @(a0,a1,a2,a3) 0.5*(a1-sqrt(3)*a2), @(a0,a1,a2,a3) 0.5*(a2+sqrt(3)*a1), @(a0,a1,a2,a3) 0.5*(a3+sqrt(3)*a0)};

%---all possible sign changes---%
s = zeros(8,4);
ind = 1;
for i = -1:2:1
    for j = -1:2:1
        for k = -1:2:1
            s(ind,:) = [i j k k];
            ind = ind+1;
        end
    end
end

%---all possible permutations---%
p = [ 1  2  3  4;...
      2  1  4 -3];

for i = 1:size(eq,1)
    for j = 1:size(s,1)
        for k = 1:size(p,1)
            
            %---form equivalent quaternion---%
            if k == 2
                a = eq{i,p(k,1)}(m0,m1,m2,m3).*s(j,1);
                b = eq{i,p(k,2)}(m0,m1,m2,m3).*s(j,2);
                c = eq{i,p(k,3)}(m0,m1,m2,m3).*s(j,3);
                d = -eq{i,-p(k,4)}(m0,m1,m2,m3).*s(j,4);
            else
                a = eq{i,p(k,1)}(m0,m1,m2,m3).*s(j,1);
                b = eq{i,p(k,2)}(m0,m1,m2,m3).*s(j,2);
                c = eq{i,p(k,3)}(m0,m1,m2,m3).*s(j,3);
                d = eq{i,p(k,4)}(m0,m1,m2,m3).*s(j,4);
            end

            %---test for disorientation---%
            isdis = a >= b & b >= sqrt(3)*abs(c) & a >= sqrt(3)*d & d >= 0;

            %---suplemental conditions for uniqueness---%
            sup1 = isdis & a == b & d > 0;
            if any(sup1)
                isdis(sup1) = c(sup1) > 0;
            end
            sup2 = isdis & d == 0;
            if any(sup2)
                isdis(sup2) = c(sup2) >= 0;
            end
            
            %---store disorientations---%
            if any(isdis)
                D(isdis,:) = [a(isdis), b(isdis), c(isdis), d(isdis)];
            end
            
        end
    end
end

end

%symmetry relations for tetragonal crystal symmetry
function D = dis_tetragonal(m0,m1,m2,m3)

%---number of misorientations---%
nm = numel(m0);

%---pre-allocate---%
D = zeros(nm,4);

%---compute equivalent misorientations---%
eq(1,:) = {@(a0,a1,a2,a3) a0, @(a0,a1,a2,a3) a1, @(a0,a1,a2,a3) a2, @(a0,a1,a2,a3) a3};
eq(2,:) = {@(a0,a1,a2,a3) 2^(-1/2)*(a0+a3), @(a0,a1,a2,a3) 2^(-1/2)*(a1+a2), @(a0,a1,a2,a3) 2^(-1/2)*(a1-a2), @(a0,a1,a2,a3) 2^(-1/2)*(a0-a3)};

%---all possible sign changes---%
s = zeros(16,4);
ind = 1;
for i = -1:2:1
    for j = -1:2:1
        for k = -1:2:1
            for l = -1:2:1
                s(ind,:) = [i j k l];
                ind = ind+1;
            end
        end
    end
end

%---all possible permutations---%
p = [1 2 3 4;...
     2 1 4 3;...
     3 4 1 2;...
     4 3 2 1;...
     4 2 3 1;...
     1 3 2 4;...
     3 1 4 2;...
     2 4 1 3];

for i = 1:size(eq,1)
    for j = 1:size(s,1)
        for k = 1:size(p,1)
            
            %---form equivalent quaternion---%
            a = eq{i,p(k,1)}(m0,m1,m2,m3).*s(j,1);
            b = eq{i,p(k,2)}(m0,m1,m2,m3).*s(j,2);
            c = eq{i,p(k,3)}(m0,m1,m2,m3).*s(j,3);
            d = eq{i,p(k,4)}(m0,m1,m2,m3).*s(j,4);

            %---test for disorientation---%
            isdis = a >= b & b >= c & c >= 0 & a >= 2^(-1/2)*(b+c) &...
                    a >= (sqrt(2)+1)*d & d >= 0;
            
            %---suplemental conditions for uniqueness---%
            sup1 = isdis & a == b;
            if any(sup1)
                isdis(sup1) = c(sup1) >= d(sup1);
            end
            sup2 = isdis & sqrt(2)*a == b+c;
            if any(sup2)
                isdis(sup2) = b(sup2)-c(sup2) >= sqrt(2)*d(sup2);
            end
            sup3 = isdis & a == (sqrt(2)+1)*d;
            if any(sup3)
                isdis(sup3) = b(sup3) >= (sqrt(2)+1)*c(sup3);
            end
            
            %---store disorientations---%
            if any(isdis)
                D(isdis,:) = [a(isdis), b(isdis), c(isdis), d(isdis)];
            end
            
        end
    end
end

end

%symmetry relations for hexagonal crystal symmetry
function D = dis_hexagonal(m0,m1,m2,m3)

%---number of misorientations---%
nm = numel(m0);

%---pre-allocate---%
D = zeros(nm,4);

%---compute equivalent misorientations---%
eq(1,:) = {@(a0,a1,a2,a3) a0, @(a0,a1,a2,a3) a1, @(a0,a1,a2,a3) a2, @(a0,a1,a2,a3) a3};
eq(2,:) = {@(a0,a1,a2,a3) a0, @(a0,a1,a2,a3) 0.5*(a1-sqrt(3)*a2), @(a0,a1,a2,a3) 0.5*(a2+sqrt(3)*a1), @(a0,a1,a2,a3) a3};
eq(3,:) = {@(a0,a1,a2,a3) a0, @(a0,a1,a2,a3) 0.5*(a1+sqrt(3)*a2), @(a0,a1,a2,a3) 0.5*(a2-sqrt(3)*a1), @(a0,a1,a2,a3) a3};
eq(4,:) = {@(a0,a1,a2,a3) 0.5*(a0+sqrt(3)*a3), @(a0,a1,a2,a3) a1, @(a0,a1,a2,a3) a2, @(a0,a1,a2,a3) 0.5*(a3-sqrt(3)*a0)};
eq(5,:) = {@(a0,a1,a2,a3) 0.5*(a0-sqrt(3)*a3), @(a0,a1,a2,a3) a1, @(a0,a1,a2,a3) a2, @(a0,a1,a2,a3) 0.5*(a3+sqrt(3)*a0)};
eq(6,:) = {@(a0,a1,a2,a3) 0.5*(a0+sqrt(3)*a3), @(a0,a1,a2,a3) 0.5*(a1+sqrt(3)*a2), @(a0,a1,a2,a3) 0.5*(a2-sqrt(3)*a1), @(a0,a1,a2,a3) 0.5*(a3-sqrt(3)*a0)};
eq(7,:) = {@(a0,a1,a2,a3) 0.5*(a0+sqrt(3)*a3), @(a0,a1,a2,a3) 0.5*(a1-sqrt(3)*a2), @(a0,a1,a2,a3) 0.5*(a2+sqrt(3)*a1), @(a0,a1,a2,a3) 0.5*(a3-sqrt(3)*a0)};
eq(8,:) = {@(a0,a1,a2,a3) 0.5*(a0-sqrt(3)*a3), @(a0,a1,a2,a3) 0.5*(a1-sqrt(3)*a2), @(a0,a1,a2,a3) 0.5*(a2+sqrt(3)*a1), @(a0,a1,a2,a3) 0.5*(a3+sqrt(3)*a0)};
eq(9,:) = {@(a0,a1,a2,a3) 0.5*(a0-sqrt(3)*a3), @(a0,a1,a2,a3) 0.5*(a1+sqrt(3)*a2), @(a0,a1,a2,a3) 0.5*(a2-sqrt(3)*a1), @(a0,a1,a2,a3) 0.5*(a3+sqrt(3)*a0)};

%---all possible sign changes---%
s = zeros(16,4);
ind = 1;
for i = -1:2:1
    for j = -1:2:1
        for k = -1:2:1
            for l = -1:2:1
                s(ind,:) = [i j k l];
                ind = ind+1;
            end
        end
    end
end

%---all possible permutations---%
p = [1 2 3 4;...
     4 3 2 1;...
     2 1 4 3;...
     3 4 1 2];

for i = 1:size(eq,1)
    for j = 1:size(s,1)
        for k = 1:size(p,1)
            
            %---form equivalent quaternion---%
            a = eq{i,p(k,1)}(m0,m1,m2,m3).*s(j,1);
            b = eq{i,p(k,2)}(m0,m1,m2,m3).*s(j,2);
            c = eq{i,p(k,3)}(m0,m1,m2,m3).*s(j,3);
            d = eq{i,p(k,4)}(m0,m1,m2,m3).*s(j,4);

            %---test for disorientation---%
            isdis = a >= b & b >= sqrt(3)*c & c >= 0 &...
                    a >= 0.5*(sqrt(3)*b+c) &...
                    a >= (2+sqrt(3))*d & d >= 0;

            %---suplemental conditions for uniqueness---%
            sup1 = isdis & a == b;
            if any(sup1)
                isdis(sup1) = c(sup1) >= d(sup1);
            end
            sup2 = isdis & a == 0.5*(sqrt(3)*b+c);
            if any(sup2)
                isdis(sup2) = 0.5*(b(sup2)-sqrt(3)*c(sup2)) >= d(sup2);
            end
            sup3 = isdis & a == (2+sqrt(3))*d;
            if any(sup3)
                isdis(sup3) = b(sup3) >= (2+sqrt(3))*c(sup3);
            end
            
            %---store disorientations---%
            if any(isdis)
                D(isdis,:) = [a(isdis), b(isdis), c(isdis), d(isdis)];
            end
            
        end
    end
end

end

%symmetry relations for cubic crystal symmetry
function D = dis_cubic(m0,m1,m2,m3)

%---number of misorientations---%
nm = numel(m0);

%---pre-allocate---%
D = zeros(nm,4);

%---compute equivalent misorientations---%
eq(1,:) = {@(a0,a1,a2,a3) a0, @(a0,a1,a2,a3) a1, @(a0,a1,a2,a3) a2, @(a0,a1,a2,a3) a3};
eq(2,:) = {@(a0,a1,a2,a3) (2^-0.5)*(a0+a1), @(a0,a1,a2,a3) (2^-0.5)*(a0-a1), @(a0,a1,a2,a3) (2^-0.5)*(a2+a3), @(a0,a1,a2,a3) (2^-0.5)*(a2-a3)};
eq(3,:) = {@(a0,a1,a2,a3) (2^-0.5)*(a0+a2), @(a0,a1,a2,a3) (2^-0.5)*(a0-a2), @(a0,a1,a2,a3) (2^-0.5)*(a1+a3), @(a0,a1,a2,a3) (2^-0.5)*(a1-a3)};
eq(4,:) = {@(a0,a1,a2,a3) (2^-0.5)*(a0+a3), @(a0,a1,a2,a3) (2^-0.5)*(a0-a3), @(a0,a1,a2,a3) (2^-0.5)*(a1+a2), @(a0,a1,a2,a3) (2^-0.5)*(a1-a2)};
eq(5,:) = {@(a0,a1,a2,a3) 0.5*(a0+a1+a2+a3), @(a0,a1,a2,a3) 0.5*(a0+a1-a2-a3), @(a0,a1,a2,a3) 0.5*(a0-a1+a2-a3), @(a0,a1,a2,a3) 0.5*(a0-a1-a2+a3)};
eq(6,:) = {@(a0,a1,a2,a3) 0.5*(a0+a1+a2-a3), @(a0,a1,a2,a3) 0.5*(a0+a1-a2+a3), @(a0,a1,a2,a3) 0.5*(a0-a1+a2+a3), @(a0,a1,a2,a3) 0.5*(a0-a1-a2-a3)};

%---all possible sign changes---%
s = zeros(16,4);
ind = 1;
for i = -1:2:1
    for j = -1:2:1
        for k = -1:2:1
            for l = -1:2:1
                s(ind,:) = [i j k l];
                ind = ind+1;
            end
        end
    end
end

%---all possible permsutations---%
p = perms(1:4);

for i = 1:size(eq,1)
    for j = 1:size(s,1)
        for k = 1:size(p,1)
            
            %---form equivalent quaternion---%
            a = eq{i,p(k,1)}(m0,m1,m2,m3).*s(j,1);
            b = eq{i,p(k,2)}(m0,m1,m2,m3).*s(j,2);
            c = eq{i,p(k,3)}(m0,m1,m2,m3).*s(j,3);
            d = eq{i,p(k,4)}(m0,m1,m2,m3).*s(j,4);

            %---test for disorientation---%
            isdis = (b >= c & c >= d & d >= 0) & (b <= (sqrt(2)-1)*a) &...
                    (b+c+d <= a);
            
            %---suplemental conditions for uniqueness---%
            sup1 = isdis & a == (sqrt(2)+1)*b;
            if any(sup1)
                isdis(sup1) = c(sup1) <= (sqrt(2)+1)*d(sup1);
            end
            
            %---store disorientations---%
            if any(isdis)
                D(isdis,:) = [a(isdis), b(isdis), c(isdis), d(isdis)];
            end
            
        end
    end
end


end
