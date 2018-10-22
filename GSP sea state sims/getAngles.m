%============================== Summary ===================================
%==========================================================================
% 'getAngles takes' in 6 motions and returns
% the corresponding motor angles.
% NOTE: s = 100;
%       a = 30;
%       s^2-a^2=9100
% Detailed explanation goes here
function sma = getAngles( yaw, pitch, roll, heave, surge, sway )
    load('variables.mat','xb','xt','yb','yt','zb','zt','h');       % get the top and bot points
    flg=1;                                                    % variable to determine passable or not
    beta = [11/6*pi, 3/2*pi, pi/2, pi/6, 7/6*pi, 5/6*pi];   % Angle of motors to horizontal
    li=[];                                                  % declare li variable
    magli=[];                                                  % declare magli variable
    L=[];
    M=[];
    N=[];
    delta=[];
    
        rbx = [cos(yaw)*cos(pitch), (-sin(yaw)*cos(roll))+(cos(yaw)*sin(pitch)*sin(roll)), (sin(yaw)*sin(roll))+(cos(yaw)*sin(pitch)*cos(roll))];
        rby = [sin(yaw)*cos(pitch), (cos(yaw)*cos(roll))+(sin(yaw)*sin(pitch)*sin(roll)), -cos(yaw)*sin(roll)+(sin(yaw)*sin(pitch)*cos(roll))];
        rbz = [-sin(pitch), cos(pitch)*sin(roll), cos(pitch)*cos(roll)];
getprb
leglen
findang


% This function stores the qi values into li[6:3] '6x3' matrix
%==============================
    function getprb
        for i=1:6                                           % run the for loop 6 times
            li(i,1)=rbx(1)*xt(i)+rby(1)*yt(i)+rbz(1)*0 + surge;     % finds the corresponding x values
            li(i,2)=rbx(2)*xt(i)+rby(2)*yt(i)+rbz(2)*0 + sway;      % finds the corresponding y values
            li(i,3)=rbx(3)*xt(i)+rby(3)*yt(i)+(rbz(3)*0) + heave +h;     % finds the corresponding z values
            %disp(li(i,3));
       end
    end
%==============================

% This function calculates imaginary leg lenths --> magli[6]
%==============================
    function leglen
        for i=1:6                                                               % for loop
           magli(i)= ((li(i,1)-xb(i))^2+(li(i,2)-yb(i))^2+(li(i,3)-zb(i))^2)^0.5;  % pythagoras
           %disp(magli(i));
        end
    end
%==============================


%==============================
    function findang
        for i=1:6
          L(i)=(magli(i)^2-9100);
          M(i)=( 60*(li(i,3)-zb(i)) );
          N(i)=( 60* ((li(i,1)-xb(i))*cos(beta(i)) + sin(beta(i))*(li(i,2)-yb(i))) );
          delta(i) = (atan(N(i)/M(i)));
          sma(i) = ( asin((L(i)/((M(i)^2+N(i)^2)^0.5))-delta(i) ) );
          if i==2|i==4|i==6
              sma(i)= -sma(i);
          end
          
          if (sma(i)<-pi/3)|(sma(i)>pi/3)
              flg=0;
          end
              
          if isreal(sma(i))==0
              flg = 0;
          end
          
        end
        sma(7)=flg;
    end


end

% NOTE TO SELF
% The size of the indicated variable or array appears to be changing with
% each loop iteration. Commonly, this message appears because an array is
% growing by assignment or concatenation. Growing an array by assignment or
% concatenation can be expensive. For large arrays, MATLAB must allocate a
% new block of memory and copy the older array contents to the new array as
% it makes each assignment. Programs that change a variable's size in this
% way can spend most of their run time in this inefficient activity.
% 
% For the same reasons, there is significant overhead in shrinking an array
% or in changing the size of a variable on each iteration
% 

