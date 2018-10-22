%UNTITLED2 Summary of this function goes here
% Assuming that the displacement of the particle is sinusoidal, 
% an arbitrary variable describes the function as:
y=[];
p=[];
r=[];
z=[];
x=[];
yd=[];
dummy=[];

Myaw=deg2rad(0);
Mp=deg2rad(0);
Mr=deg2rad(0);
Mz=0;
My=0;
Mx=16;

points=1100;
inc_p=1/points;
sma=0;
sma(points,6)=0;

% Here we use a sinusodal function z(t) = Msin(wt)
% assume w = 2pi*f = 2pi
for i=1:points
    y(i) = Myaw*sin((2*pi*i*inc_p));
    p(i) = Mp*cos((2*pi*i*inc_p));
    r(i) = Mr*sin((2*pi*i*inc_p));
    
    z(i)= Mz*sin((2*pi*i*inc_p));
    yd(i)= My*sin((2*pi*i*inc_p));
    x(i)= Mx*sin((2*pi*i*inc_p));
    
    dummy=getAngles(y(i),p(i),r(i), z(i),x(i),yd(i));
    if(dummy(7)==1)
    for j=1:6
       sma(i,j)=dummy(j); 
    end
    else
        disp('Failed to create.');
        break
    end
end

       

