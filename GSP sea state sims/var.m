%================ Define variables ================
%==================================================
h = 78.36;               % height
bss = 77.92;            % short side of base
bls = 79.25;            % long side of base
tss = 15;               % short side of top
tls = 128.1;            % long side of top

d1 = bss*sin(pi/3);     % (*) refer to diagram
d2 = bls*sin(pi/3);     % (*)
d3 = d1+d2;             % (*)
d = d3+d1;              % (*)

D1 = tss*sin(pi/3);     % (*)
D2 = tls*sin(pi/3);     % (*)
D3 = D1+D2;             % (*)
D = D3+D1;              % (*)
%=================================================

%======joint in the arrays of x [], y[], z[]======
%=================================================
xb = [ (1/3*d)-d1, 1/3*d, 1/3*d, (1/3*d)-d1, -(2/3*d)+d1, -(2/3*d)+d1];
xt = [ -(1/3*D)+D1, 2/3*D-D1, 2/3*D-D1, -1/3*D+D1, -1/3*D,-1/3*D];

yb = [ (bls+bss)/-2, -0.5*bls, 0.5*bls, (bls+bss)/2, 0.5*bss, -0.5*bss];
yt = [-(tls+tss)/2, -0.5*tss, 0.5*tss, 0.5*(tls+tss), 0.5*tls, -0.5*tls];

zb = [ 0, 0, 0, 0, 0, 0];
zt = [h, h, h, h, h, h];
%=================================================
% Note to self: 
% For previous versions and commented,refer to 
% comments section in the var.m file from
% calculations V4.
