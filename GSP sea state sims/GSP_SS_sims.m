function varargout = GSP_SS_sims(varargin)
% GSP_SS_SIMS MATLAB code for GSP_SS_sims.fig
%      GSP_SS_SIMS, by itself, creates a new GSP_SS_SIMS or raises the existing
%      singleton*.
%
%      H = GSP_SS_SIMS returns the handle to a new GSP_SS_SIMS or the handle to
%      the existing singleton*.
%
%      GSP_SS_SIMS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GSP_SS_SIMS.M with the given input arguments.
%
%      GSP_SS_SIMS('Property','Value',...) creates a new GSP_SS_SIMS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GSP_SS_sims_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GSP_SS_sims_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GSP_SS_sims

% Last Modified by GUIDE v2.5 19-Oct-2018 00:26:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GSP_SS_sims_OpeningFcn, ...
                   'gui_OutputFcn',  @GSP_SS_sims_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GSP_SS_sims is made visible.
function GSP_SS_sims_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GSP_SS_sims (see VARARGIN)

% Choose default command line output for GSP_SS_sims
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GSP_SS_sims wait for user response (see UIRESUME)
% uiwait(handles.figure1);
%=======================================================================================================
clear;
clc;
delete(instrfind({'Port'},{'COM5'}));                       % Clear the port and com variable locations
global ArduinoS;                                            % Define global variable SERIAL COMM.
ArduinoS = serial('COM5','BaudRate',115200,'DataBits',8);   % Setup the communication with parameters
% Initialise globabl variables
global yaw;             % Yaw angle to be updated on slider movement
global pitch;           % pitch angle to be updated on slider movement
global roll;            % roll angle to be updated on slider movement
global heave;           % heave translation, updated on slider movement
global surge;           % surge translatoin, updated on slider movement
global sway;            % sway translation, updated on slider movement
global routmodechosen;
yaw=0;              % init to zero
pitch=0;            % init to zero
roll=0;             % init to zero
heave =0;           % init to zero
surge =0;           % init to zero
sway=0;             % init to zero
global PosAng;          % variable for lower bound pulse
global NegAng;          % variable for upper bound pulse for u
PosAng=800/deg2rad(66);     % calculate pulse scaler for lower bound
NegAng=650/deg2rad(72);     % calculate pulse scaler for upper bound
%=======================================================================================================


% --- Outputs from this function are returned to the command line.
function varargout = GSP_SS_sims_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in CNCT_btn.
%=======================================================================================================
function CNCT_btn_Callback(hObject, eventdata, handles)
% hObject    handle to CNCT_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ArduinoS;                                            % Define global variable

CNCT_state = get(handles.CNCT_btn,'Value');                 % Store button state in variable
if (CNCT_state == 1)                                        % If stop pressed:
    fopen(ArduinoS);                                        % Start communication
    set(handles.CNCT_btn,'string','Stop connection');       % Change string on button
    
else                                                        % If not pressed
    breakTo(0, 0, 0, 0, 0, 0,handles);
    
    fclose(ArduinoS);                                       % Close SComm.
    set(handles.CNCT_btn,'string', 'Start connection');     % Change string on button
end
%=======================================================================================================


% --- Executes on slider movement.
%=======================================================================================================
function yaw_sldr_Callback(hObject, eventdata, handles)
% hObject    handle to yaw_sldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ArduinoS;                      % access global variable
global yaw;                           % access global variable
global pitch;                         % access global variable
global roll;                          % access global variable
global heave;                         % access global variable
global surge;                         % access global variable
global sway;                          % access global variable
global PosAng;                        % access global variable
global NegAng;                        % access global variable
yaw = get(handles.yaw_sldr,'Value');                % get yaw value from slider
set(handles.yaw_txt,'string',int2str(yaw));         % round value and update textbox
yaw = deg2rad(yaw);                                 % convert to radians

sma = getAngles(yaw,pitch,roll,heave,surge,sway);   % get motor angles

if sma(7)==1                                % Error catching. If value is complex, value !passed
   set(handles.ob_txt,'string','');         % Clear the OB text box if real
   for i=1:6                        
       if(sma(i)<=0)                        % if angle is negative
            pulse=-sma(i)*NegAng+1500;      % apply scaling
       else                                 % otherwise
            pulse=1500-sma(i)*PosAng;       % apply positive scaling
       end
       s1=int2str(i);                       % must typecast from int to string
       s2=int2str(pulse);                   % typecast the servo motor pulse width
       spulse =strcat(s1,'/',s2,'/');       % concatenate the strings
       fprintf(ArduinoS,'%c',spulse);       % Print data to arduino in character form
   end
else
    set(handles.ob_txt,'string','OUT OF BOUNDS!');  % If complex, indicate OB
end
    

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%=======================================================================================================


% --- Executes during object creation, after setting all properties.
function yaw_sldr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yaw_sldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
%=======================================================================================================
function pitch_sldr_Callback(hObject, eventdata, handles)
% hObject    handle to pitch_sldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ArduinoS;                      % access global variable
global yaw;                           % access global variable
global pitch;                         % access global variable
global roll;                          % access global variable
global heave;                         % access global variable
global surge;                         % access global variable
global sway;                          % access global variable
global PosAng;                        % access global variable
global NegAng;                        % access global variable
pitch = get(handles.pitch_sldr,'Value');                % get pitch value from slider
set(handles.pitch_txt,'string',int2str(pitch));         % round value and update textbox
pitch = deg2rad(pitch);                                 % convert to radians

sma = getAngles(yaw,pitch,roll,heave,surge,sway);       % get motor angles

if sma(7)==1                                % Error catching. If value is complex, value !passed
   set(handles.ob_txt,'string','');         % Clear OB text if values are real
   for i=1:6
       if(sma(i)<=0)                        % if angle is negative
            pulse=-sma(i)*NegAng+1500;      % apply scaling
       else                                 % otherwise
            pulse=1500-sma(i)*PosAng;       % apply positive scaling
       end
       s1=int2str(i);                       % must typecast from int to string  
       s2=int2str(pulse);                   % typecast the servo motor pulse width
       spulse =strcat(s1,'/',s2,'/');       % concatenate the strings       
       fprintf(ArduinoS,'%c',spulse);       % Print data to arduino in character form
   end
else
    set(handles.ob_txt,'string','OUT OF BOUNDS!');  % Indicate OB if complex
end
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%=======================================================================================================


% --- Executes during object creation, after setting all properties.
function pitch_sldr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pitch_sldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
%=======================================================================================================
function roll_sldr_Callback(hObject, eventdata, handles)
% hObject    handle to roll_sldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ArduinoS;                      % access global variable
global yaw;                           % access global variable
global pitch;                         % access global variable
global roll;                          % access global variable
global heave;                         % access global variable
global surge;                         % access global variable
global sway;                          % access global variable
global PosAng;                        % access global variable
global NegAng;                        % access global variable
roll = get(handles.roll_sldr,'Value');                % get roll value from slider
set(handles.roll_txt,'string',int2str(roll));         % round value and update textbox
roll = deg2rad(roll);                                 % convert to radians

sma = getAngles(yaw,pitch,roll,heave,surge,sway);   % get motor angles

if sma(7)==1                                % Error catching. If value is complex, value !passed
   set(handles.ob_txt,'string','');         % Clear OB text if values are real
   for i=1:6
       if(sma(i)<=0)                        % if angle is negative
            pulse=-sma(i)*NegAng+1500;      % apply scaling
       else                                 % otherwise
            pulse=1500-sma(i)*PosAng;       % apply positive scaling
       end
       s1=int2str(i);                       % must typecast from int to string  
       s2=int2str(pulse);                   % typecast the servo motor pulse width
       spulse =strcat(s1,'/',s2,'/');       % concatenate the strings       
       fprintf(ArduinoS,'%c',spulse);       % Print data to arduino in character form
   end
else
    set(handles.ob_txt,'string','OUT OF BOUNDS!');  % Indicate OB if complex
end
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%=======================================================================================================


% --- Executes during object creation, after setting all properties.
function roll_sldr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roll_sldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
%=======================================================================================================
function heave_sldr_Callback(hObject, eventdata, handles)
% hObject    handle to heave_sldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ArduinoS;                      % access global variable
global yaw;                           % access global variable
global pitch;                         % access global variable
global roll;                          % access global variable
global heave;                         % access global variable
global surge;                         % access global variable
global sway;                          % access global variable
global PosAng;                        % access global variable
global NegAng;                        % access global variable
heave = get(handles.heave_sldr,'Value');                % get heave value from slider
set(handles.heave_txt,'string',int2str(heave));         % round value and update textbox

sma = getAngles(yaw,pitch,roll,heave,surge,sway);   % get motor angles

if sma(7)==1                                % Error catching. If value is complex, value !passed
   set(handles.ob_txt,'string','');         % Clear OB text if values are real
   for i=1:6
       if(sma(i)<=0)                        % if angle is negative
            pulse=-sma(i)*NegAng+1500;      % apply scaling
       else                                 % otherwise
            pulse=1500-sma(i)*PosAng;       % apply positive scaling
       end
       s1=int2str(i);                       % must typecast from int to string  
       s2=int2str(pulse);                   % typecast the servo motor pulse width
       spulse =strcat(s1,'/',s2,'/');       % concatenate the strings       
       fprintf(ArduinoS,'%c',spulse);       % Print data to arduino in character form
   end
else
    set(handles.ob_txt,'string','OUT OF BOUNDS!');  % Indicate OB if complex
end
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%=======================================================================================================


% --- Executes during object creation, after setting all properties.
function heave_sldr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to heave_sldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
%=======================================================================================================
function surge_sldr_Callback(hObject, eventdata, handles)
% hObject    handle to surge_sldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ArduinoS;                      % access global variable
global yaw;                           % access global variable
global pitch;                         % access global variable
global roll;                          % access global variable
global heave;                         % access global variable
global surge;                         % access global variable
global sway;                          % access global variable
global PosAng;                        % access global variable
global NegAng;                        % access global variable
surge = get(handles.surge_sldr,'Value');                % get surge value from slider
set(handles.surge_txt,'string',int2str(surge));         % round value and update textbox

sma = getAngles(yaw,pitch,roll,heave,surge,sway);   % get motor angles

if sma(7)==1                                % Error catching. If value is complex, value !passed
   set(handles.ob_txt,'string','');         % Clear OB text if values are real
   for i=1:6
       if(sma(i)<=0)                        % if angle is negative
            pulse=-sma(i)*NegAng+1500;      % apply scaling
       else                                 % otherwise
            pulse=1500-sma(i)*PosAng;       % apply positive scaling
       end
       s1=int2str(i);                       % must typecast from int to string  
       s2=int2str(pulse);                   % typecast the servo motor pulse width
       spulse =strcat(s1,'/',s2,'/');       % concatenate the strings       
       fprintf(ArduinoS,'%c',spulse);       % Print data to arduino in character form
   end
else
    set(handles.ob_txt,'string','OUT OF BOUNDS!');  % Indicate OB if complex
end
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%=======================================================================================================


% --- Executes during object creation, after setting all properties.
function surge_sldr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to surge_sldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
%=======================================================================================================
function sway_sldr_Callback(hObject, eventdata, handles)
% hObject    handle to sway_sldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ArduinoS;                      % access global variable
global yaw;                           % access global variable
global pitch;                         % access global variable
global roll;                          % access global variable
global heave;                         % access global variable
global surge;                         % access global variable
global sway;                          % access global variable
global PosAng;                        % access global variable
global NegAng;                        % access global variable
sway = get(handles.sway_sldr,'Value');                % get sway value from slider
set(handles.sway_txt,'string',int2str(sway));         % round value and update textbox

sma = getAngles(yaw,pitch,roll,heave,surge,sway);   % get motor angles

if sma(7)==1                                % Error catching. If value is complex, value !passed
   set(handles.ob_txt,'string','');         % Clear OB text if values are real
   for i=1:6
       if(sma(i)<=0)                        % if angle is negative
            pulse=-sma(i)*NegAng+1500;      % apply scaling
       else                                 % otherwise
            pulse=1500-sma(i)*PosAng;       % apply positive scaling
       end
       s1=int2str(i);                       % must typecast from int to string  
       s2=int2str(pulse);                   % typecast the servo motor pulse width
       spulse =strcat(s1,'/',s2,'/');       % concatenate the strings       
       fprintf(ArduinoS,'%c',spulse);       % Print data to arduino in character form
   end
else
    set(handles.ob_txt,'string','OUT OF BOUNDS!');  % Indicate OB if complex
end
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%=======================================================================================================


% --- Executes during object creation, after setting all properties.
function sway_sldr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sway_sldr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in mmode_btn.
function mmode_btn_Callback(hObject, eventdata, handles)
% hObject    handle to mmode_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global yaw;                           % access global variable
global pitch;                         % access global variable
global roll;                          % access global variable
global heave;                         % access global variable
global surge;                         % access global variable
global sway;                          % access global variable
    set(handles.rmode_panel,'visible','off');
    set(handles.mmode_btn,'enable','off');
    set(handles.rmode_btn,'enable','on');
    drawnow;
    
    yaw_temp = deg2rad(get(handles.yaw_sldr,'Value'));                % get sway value from slider
    pitch_temp = deg2rad(get(handles.pitch_sldr,'Value'));                % get sway value from slider
    roll_temp = deg2rad(get(handles.roll_sldr,'Value'));                % get sway value from slider
    heave_temp = get(handles.heave_sldr,'Value');                % get sway value from slider
    surge_temp = get(handles.pitch_sldr,'Value');                % get sway value from slider
    sway_temp = get(handles.roll_sldr,'Value');                % get sway value from slider
    
    breakTo(yaw_temp, pitch_temp, roll_temp, heave_temp, surge_temp, sway_temp, handles);
    
    
% Hint: get(hObject,'Value') returns toggle state of mmode_btn


% --- Executes on button press in rmode_btn.
%======================================================================================================
function rmode_btn_Callback(hObject, eventdata, handles)
% hObject    handle to rmode_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.rmode_panel,'visible','on')
    uistack(handles.rmode_panel,'top');
    set(handles.rmode_btn,'enable','off');
    set(handles.mmode_btn,'enable','on');
    drawnow;
% Hint: get(hObject,'Value') returns toggle state of rmode_btn
%======================================================================================================




function breakTo ( yawf,pitchf,rollf,heavef,surgef,swayf,handles)
%Breaking function to prevent violent servo motor actions
global ArduinoS;                      % access global variable
global yaw;                           % access global variable
global pitch;                         % access global variable
global roll;                          % access global variable
global heave;                         % access global variable
global surge;                         % access global variable
global sway;                          % access global variable
global PosAng;                        % access global variable
global NegAng;                        % access global variable
curr_agl = [yaw,pitch,roll,heave,surge,sway];
new_agl =[yawf,pitchf,rollf,heavef,surgef,swayf];

diff=[];
for i=1:6
    diff(i)= (abs(curr_agl(i)-new_agl(i)))/500;
    if (curr_agl(i)>new_agl(i))
        diff(i)=-diff(i);
    elseif (curr_agl(i)<new_agl(i))
    else
    diff(i)=0;
    end
end

for j=1:500
    yaw=yaw+diff(1);
    pitch=pitch+diff(2);
    roll=roll+diff(3);
    heave=heave+diff(4);
    surge=surge+diff(5);
    sway=sway+diff(6);
    
    sma = getAngles(yaw-diff(1),pitch-diff(2),roll-diff(3),heave-diff(4),surge-diff(5),sway-diff(6));   % get motor angles

if sma(7)==1                                % Error catching. If value is complex, value !passed
   set(handles.ob_txt,'string','');         % Clear OB text if values are real
   for i=1:6
       if(sma(i)<=0)                        % if angle is negative
            pulse=-sma(i)*NegAng+1500;      % apply scaling
       else                                 % otherwise
            pulse=1500-sma(i)*PosAng;       % apply positive scaling
       end
       s1=int2str(i);                       % must typecast from int to string  
       s2=int2str(pulse);                   % typecast the servo motor pulse width
       spulse =strcat(s1,'/',s2,'/');       % concatenate the strings       
       fprintf(ArduinoS,'%c',spulse);       % Print data to arduino in character form
   end
else
    set(handles.ob_txt,'string','OUT OF BOUNDS!');  % Indicate OB if complex
    break;
end
end
pause(0.5);


% --- Executes on button press in heavebtn.
function heavebtn_Callback(hObject, eventdata, handles)
% hObject    handle to heavebtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ArduinoS;            % access global variable
global yaw;                           % access global variable
global pitch;                         % access global variable
global roll;                          % access global variable
global heave;                         % access global variable
global surge;                         % access global variable
global sway;                          % access global variable
global PosAng;              % access global variable
global NegAng;              % access global variable
load('heave.mat','sma','points','yaw_passed','p','r','z','x','y');         % load the array of motor angles                                   
rsma=sma;                 % store 2D array into routine servo motor array

breakTo(yaw_passed(1,1),p(1,1),r(1,1),z(1,1),x(1,1),y(1,1),handles);

if get(hObject, 'Value')
    set(handles.pitchbtn,'enable','off');
    set(handles.surgebtn,'enable','off');
    set(handles.swaybtn,'enable','off');
    set(handles.yawbtn,'enable','off');
    set(handles.rollbtn,'enable','off');
    drawnow;
    while 1
        for i=1:points        % loop for n*element times
            for j=1:6
                if(rsma(i,j)<=0)                       % if angle is negative
                    pulse=-rsma(i,j)*NegAng+1500;      % apply scaling
                    s1=int2str(j);                     % typecast motor number from int to string
                    s2=int2str(pulse);                   % typecast the servo motor pulse width
                    spulse =strcat(s1,'/',s2,'/');       % concatenate the strings
                    fprintf(ArduinoS,'%c',spulse);       % Print data to arduino in character form
                else                                     % otherwise
                    pulse=1500-rsma(i,j)*PosAng;          % apply positive scaling
                    s1=int2str(j);                       % typecast motor number from int to string
                    s2=int2str(pulse);                   % typecast the servo motor pulse width
                    spulse =strcat(s1,'/',s2,'/');       % concatenate the strings
                    fprintf(ArduinoS,'%c',spulse);       % Print data to arduino in character form
                end
            end
        end
        drawnow;               % Pause is required to flush out event que to update event
        if ~get(hObject, 'Value')
            break
        end
    end
else
    set(handles.pitchbtn,'enable','on');
    set(handles.surgebtn,'enable','on');
    set(handles.swaybtn,'enable','on');
    set(handles.yawbtn,'enable','on');
    set(handles.rollbtn,'enable','on');
    yaw=yaw_passed(1,1);
    pitch=p(1,1);
    roll=r(1,1);
    heave=z(1,1);
    surge=x(1,1);
    sway=y(1,1);
end

% --- Executes on button press in surgebtn.
function surgebtn_Callback(hObject, eventdata, handles)
% hObject    handle to surgebtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ArduinoS;            % access global variable
global PosAng;              % access global variable
global NegAng;              % access global variable

load('surge.mat','sma','points','y','p','r','z','x','yd');         % load the array of motor angles                                   
rsma=sma;                 % store 2D array into routine servo motor array

breakTo(y(1,1),p(1,1),r(1,1),z(1,1),x(1,1),yd(1,1),handles);

if get(hObject, 'Value')
    set(handles.heavebtn,'enable','off');
    set(handles.pitchbtn,'enable','off');
    set(handles.swaybtn,'enable','off');
    set(handles.yawbtn,'enable','off');
    set(handles.rollbtn,'enable','off');
    drawnow;
    while 1
        for i=1:points        % loop for n*element times
            for j=1:6
                if(rsma(i,j)<=0)                       % if angle is negative
                    pulse=-rsma(i,j)*NegAng+1500;      % apply scaling
                    s1=int2str(j);                     % typecast motor number from int to string
                    s2=int2str(pulse);                   % typecast the servo motor pulse width
                    spulse =strcat(s1,'/',s2,'/');       % concatenate the strings
                    fprintf(ArduinoS,'%c',spulse);       % Print data to arduino in character form
                else                                     % otherwise
                    pulse=1500-rsma(i,j)*PosAng;          % apply positive scaling
                    s1=int2str(j);                       % typecast motor number from int to string
                    s2=int2str(pulse);                   % typecast the servo motor pulse width
                    spulse =strcat(s1,'/',s2,'/');       % concatenate the strings
                    fprintf(ArduinoS,'%c',spulse);       % Print data to arduino in character form
                end
            end
        end
        drawnow;               % Pause is required to flush out event que to update event
        if ~get(hObject, 'Value')
            break
        end
    end
else
    set(handles.heavebtn,'enable','on');
    set(handles.pitchbtn,'enable','on');
    set(handles.swaybtn,'enable','on');
    set(handles.yawbtn,'enable','on');
    set(handles.rollbtn,'enable','on');
end


% --- Executes on button press in swaybtn.
function swaybtn_Callback(hObject, eventdata, handles)
% hObject    handle to swaybtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ArduinoS;            % access global variable
global PosAng;              % access global variable
global NegAng;              % access global variable

load('sway.mat','sma','points','y','p','r','z','x','yd');         % load the array of motor angles                                   
rsma=sma;                 % store 2D array into routine servo motor array

breakTo(y(1,1),p(1,1),r(1,1),z(1,1),x(1,1),yd(1,1),handles);

if get(hObject, 'Value')
    set(handles.heavebtn,'enable','off');
    set(handles.surgebtn,'enable','off');
    set(handles.pitchbtn,'enable','off');
    set(handles.yawbtn,'enable','off');
    set(handles.rollbtn,'enable','off');
    drawnow;
    while 1
        for i=1:points        % loop for n*element times
            for j=1:6
                if(rsma(i,j)<=0)                       % if angle is negative
                    pulse=-rsma(i,j)*NegAng+1500;      % apply scaling
                    s1=int2str(j);                     % typecast motor number from int to string
                    s2=int2str(pulse);                   % typecast the servo motor pulse width
                    spulse =strcat(s1,'/',s2,'/');       % concatenate the strings
                    fprintf(ArduinoS,'%c',spulse);       % Print data to arduino in character form
                else                                     % otherwise
                    pulse=1500-rsma(i,j)*PosAng;          % apply positive scaling
                    s1=int2str(j);                       % typecast motor number from int to string
                    s2=int2str(pulse);                   % typecast the servo motor pulse width
                    spulse =strcat(s1,'/',s2,'/');       % concatenate the strings
                    fprintf(ArduinoS,'%c',spulse);       % Print data to arduino in character form
                end
            end
        end
        drawnow;               % Pause is required to flush out event que to update event
        if ~get(hObject, 'Value')
            break
        end
    end
else
    set(handles.heavebtn,'enable','on');
    set(handles.surgebtn,'enable','on');
    set(handles.pitchbtn,'enable','on');
    set(handles.yawbtn,'enable','on');
    set(handles.rollbtn,'enable','on');
end


% --- Executes on button press in yawbtn.
function yawbtn_Callback(hObject, eventdata, handles)
% hObject    handle to yawbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ArduinoS;            % access global variable
global PosAng;              % access global variable
global NegAng;              % access global variable

load('yaw.mat','sma','points','y','p','r','z','x','yd');         % load the array of motor angles                                   
rsma=sma;                 % store 2D array into routine servo motor array

breakTo(y(1,1),p(1,1),r(1,1),z(1,1),x(1,1),yd(1,1),handles);

if get(hObject, 'Value')
    set(handles.heavebtn,'enable','off');
    set(handles.surgebtn,'enable','off');
    set(handles.swaybtn,'enable','off');
    set(handles.pitchbtn,'enable','off');
    set(handles.rollbtn,'enable','off');
    drawnow;
    while 1
        for i=1:points        % loop for n*element times
            for j=1:6
                if(rsma(i,j)<=0)                       % if angle is negative
                    pulse=-rsma(i,j)*NegAng+1500;      % apply scaling
                    s1=int2str(j);                     % typecast motor number from int to string
                    s2=int2str(pulse);                   % typecast the servo motor pulse width
                    spulse =strcat(s1,'/',s2,'/');       % concatenate the strings
                    fprintf(ArduinoS,'%c',spulse);       % Print data to arduino in character form
                else                                     % otherwise
                    pulse=1500-rsma(i,j)*PosAng;          % apply positive scaling
                    s1=int2str(j);                       % typecast motor number from int to string
                    s2=int2str(pulse);                   % typecast the servo motor pulse width
                    spulse =strcat(s1,'/',s2,'/');       % concatenate the strings
                    fprintf(ArduinoS,'%c',spulse);       % Print data to arduino in character form
                end
            end
        end
        drawnow;               % Pause is required to flush out event que to update event
        if ~get(hObject, 'Value')
            break
        end
    end
else
    set(handles.heavebtn,'enable','on');
    set(handles.surgebtn,'enable','on');
    set(handles.swaybtn,'enable','on');
    set(handles.pitchbtn,'enable','on');
    set(handles.rollbtn,'enable','on');
end


% --- Executes on button press in rollbtn.
function rollbtn_Callback(hObject, eventdata, handles)
% hObject    handle to rollbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ArduinoS;            % access global variable
global PosAng;              % access global variable
global NegAng;              % access global variable

load('roll.mat','sma','points','y','p','r','z','x','yd');         % load the array of motor angles                                   
rsma=sma;                 % store 2D array into routine servo motor array

breakTo(y(1,1),p(1,1),r(1,1),z(1,1),x(1,1),yd(1,1),handles);

if get(hObject, 'Value')
    set(handles.heavebtn,'enable','off');
    set(handles.surgebtn,'enable','off');
    set(handles.swaybtn,'enable','off');
    set(handles.yawbtn,'enable','off');
    set(handles.pitchbtn,'enable','off');
    drawnow;
    while 1
        for i=1:points        % loop for n*element times
            for j=1:6
                if(rsma(i,j)<=0)                       % if angle is negative
                    pulse=-rsma(i,j)*NegAng+1500;      % apply scaling
                    s1=int2str(j);                     % typecast motor number from int to string
                    s2=int2str(pulse);                   % typecast the servo motor pulse width
                    spulse =strcat(s1,'/',s2,'/');       % concatenate the strings
                    fprintf(ArduinoS,'%c',spulse);       % Print data to arduino in character form
                else                                     % otherwise
                    pulse=1500-rsma(i,j)*PosAng;          % apply positive scaling
                    s1=int2str(j);                       % typecast motor number from int to string
                    s2=int2str(pulse);                   % typecast the servo motor pulse width
                    spulse =strcat(s1,'/',s2,'/');       % concatenate the strings
                    fprintf(ArduinoS,'%c',spulse);       % Print data to arduino in character form
                end
            end
        end
        drawnow;               % Pause is required to flush out event que to update event
        if ~get(hObject, 'Value')
            break
        end
    end
else
    set(handles.heavebtn,'enable','on');
    set(handles.surgebtn,'enable','on');
    set(handles.swaybtn,'enable','on');
    set(handles.yawbtn,'enable','on');
    set(handles.pitchbtn,'enable','on');
end


% --- Executes on button press in pitchbtn.
function pitchbtn_Callback(hObject, eventdata, handles)
% hObject    handle to pitchbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ArduinoS;            % access global variable
global PosAng;              % access global variable
global NegAng;              % access global variable

load('pitch.mat','sma','points','y','p','r','z','x','yd');         % load the array of motor angles                                   
rsma=sma;                 % store 2D array into routine servo motor array

breakTo(y(1,1),p(1,1),r(1,1),z(1,1),x(1,1),yd(1,1),handles);

if get(hObject, 'Value')
    set(handles.heavebtn,'enable','off');
    set(handles.surgebtn,'enable','off');
    set(handles.swaybtn,'enable','off');
    set(handles.yawbtn,'enable','off');
    set(handles.rollbtn,'enable','off');
    drawnow;
    while 1
        for i=1:points        % loop for n*element times
            for j=1:6
                if(rsma(i,j)<=0)                       % if angle is negative
                    pulse=-rsma(i,j)*NegAng+1500;      % apply scaling
                    s1=int2str(j);                     % typecast motor number from int to string
                    s2=int2str(pulse);                   % typecast the servo motor pulse width
                    spulse =strcat(s1,'/',s2,'/');       % concatenate the strings
                    fprintf(ArduinoS,'%c',spulse);       % Print data to arduino in character form
                else                                     % otherwise
                    pulse=1500-rsma(i,j)*PosAng;          % apply positive scaling
                    s1=int2str(j);                       % typecast motor number from int to string
                    s2=int2str(pulse);                   % typecast the servo motor pulse width
                    spulse =strcat(s1,'/',s2,'/');       % concatenate the strings
                    fprintf(ArduinoS,'%c',spulse);       % Print data to arduino in character form
                end
            end
        end
        drawnow;               % Pause is required to flush out event que to update event
        if ~get(hObject, 'Value')
            break
        end
    end
else
    set(handles.heavebtn,'enable','on');
    set(handles.surgebtn,'enable','on');
    set(handles.swaybtn,'enable','on');
    set(handles.yawbtn,'enable','on');
    set(handles.rollbtn,'enable','on');
end


% --- Executes on button press in wavebtn.
function wavebtn_Callback(hObject, eventdata, handles)
% hObject    handle to wavebtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ArduinoS;            % access global variable
global PosAng;              % access global variable
global NegAng;              % access global variable

load('prh.mat','sma','points','y','p','r','z','x','yd');         % load the array of motor angles                                   
rsma=sma;                 % store 2D array into routine servo motor array

breakTo(y(1,1),p(1,1),r(1,1),z(1,1),x(1,1),yd(1,1),handles);

if get(hObject, 'Value')
    set(handles.rmode_btn,'enable','off');
    set(handles.mmode_btn,'enable','off');
    set(handles.yaw_sldr,'enable','off');
    set(handles.pitch_sldr,'enable','off');
    set(handles.roll_sldr,'enable','off');
    set(handles.heave_sldr,'enable','off');
    set(handles.sway_sldr,'enable','off');
    set(handles.surge_sldr,'enable','off');
    
    drawnow;
    while 1
        for i=1:points        % loop for n*element times
            for j=1:6
                if(rsma(i,j)<=0)                       % if angle is negative
                    pulse=-rsma(i,j)*NegAng+1500;      % apply scaling
                    s1=int2str(j);                     % typecast motor number from int to string
                    s2=int2str(pulse);                   % typecast the servo motor pulse width
                    spulse =strcat(s1,'/',s2,'/');       % concatenate the strings
                    fprintf(ArduinoS,'%c',spulse);       % Print data to arduino in character form
                else                                     % otherwise
                    pulse=1500-rsma(i,j)*PosAng;          % apply positive scaling
                    s1=int2str(j);                       % typecast motor number from int to string
                    s2=int2str(pulse);                   % typecast the servo motor pulse width
                    spulse =strcat(s1,'/',s2,'/');       % concatenate the strings
                    fprintf(ArduinoS,'%c',spulse);       % Print data to arduino in character form
                end
            end
        end
        drawnow;               % Pause is required to flush out event que to update event
        if ~get(hObject, 'Value')
            break
        end
    end
else
    set(handles.rmode_btn,'enable','on');
    set(handles.mmode_btn,'enable','on');
    set(handles.yaw_sldr,'enable','on');
    set(handles.pitch_sldr,'enable','on');
    set(handles.roll_sldr,'enable','on');
    set(handles.heave_sldr,'enable','on');
    set(handles.sway_sldr,'enable','on');
    set(handles.surge_sldr,'enable','on');
end
