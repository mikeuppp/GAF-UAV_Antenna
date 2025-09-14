function varargout = GAF(varargin)
% GAF MATLAB code for GAF.fig
%      GAF, by itself, creates a new GAF or raises the existing
%      singleton*.
%
%      H = GAF returns the handle to a new GAF or the handle to
%      the existing singleton*.
%
%      GAF('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GAF.M with the given input arguments.
%
%      GAF('Property','Value',...) creates a new GAF or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GAF_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GAF_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GAF

% Last Modified by GUIDE v2.5 27-Jul-2025 19:06:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GAF_OpeningFcn, ...
                   'gui_OutputFcn',  @GAF_OutputFcn, ...
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


% --- Executes just before GAF is made visible.
function GAF_OpeningFcn(hObject, ~, handles, varargin)
% Choose default command line output for GAF
handles.output = hObject;
imshow('aeroXess_Logo.jpg', 'Parent', handles.axes1);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GAF wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GAF_OutputFcn(hObject, ~, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;
guidata(hObject, handles);

% --- Executes on button press in define.
function define_Callback(hObject, ~, handles)
defaultdir = [];
selectedFolder = uigetdir(defaultdir, 'Select a folder');
handles.defdir = selectedFolder;
guidata(hObject, handles);

% --- Executes on button press in select.
function select_Callback(hObject, ~, handles)
[file, location] = uigetfile('*.xml', 'Select .xml File', handles.defdir);
directory = strcat(location, file);
handles.xmlfile = directory;
handles.xmlname = file;
set(handles.xmlName, 'string', file);
fid = fopen(directory, 'r');
y = textscan(fid, '%s', 'Delimiter', '\n');
sample_num = str2double(y{1, 1}{3, 1}(10:end-10)); % Number of Samples
handles.samNum = sample_num;
sample_clock = str2double(y{1, 1}{4, 1}(18:end-8)); % Sample Clock Unit
handles.samClock = sample_clock;
% center_freq  = str2double(y{1, 1}{5, 1}(28:end-18)); % Center Frequency
sample_start_time = str2double(y{1, 1}{6, 1}(36:end-18)); % Sample Start Time(Epoch Time)
handles.samSTime = sample_start_time;
sample_end_time = sample_start_time + sample_num/sample_clock;
set(handles.firstTime, 'string', sprintf('%12.6f', sample_start_time));
set(handles.lastTime, 'string', sprintf('%12.6f', sample_end_time));
guidata(hObject, handles);

% --- Executes on button press in execute.
function execute_Callback(hObject, ~, handles)
set(handles.status, 'String', 'Running...');
num = floor(handles.rateVal*handles.samNum/handles.samClock) + 1;
heading = zeros(1, num);
lat = handles.latVal*ones(1, num); lon = handles.lonVal*ones(1, num); alt = handles.hVal*ones(1, num);
vx = zeros(1, num); vy = zeros(1, num); vz = zeros(1, num);
pitch = zeros(1, num); yaw = zeros(1, num); roll = zeros(1, num);
% for i = 1:num
%     time(i) = handles.samSTime + (i-1)/handles.rateVal;
% end
time = handles.samSTime + (0:num-1)/handles.rateVal;
handles.time = time*1000000; handles.heading = heading;
handles.latVals = lat; handles.lonVals = lon; handles.altVals = alt;
handles.vx = vx; handles.vy = vy; handles.vz = vz;
handles.pitch = pitch; handles.yaw = yaw; handles.roll = roll;
set(handles.status, 'String', 'Completed.');
guidata(hObject, handles);

% --- Executes on button press in save.
function save_Callback(hObject, ~, handles)
filename = 'drone_output.txt';
[file, path] = uiputfile('*.txt', 'Save As', fullfile(handles.defdir, filename));
fname = strcat(path, file);
if exist(fname, 'file') == 2
    delete(fname);
end
fid = fopen(fname,'a');
fprintf(fid, '%s\n\n', 'time, lat, lon, alt, velocity_x, velocity_y, velocity_z, heading, Pitch, Yaw, Roll');
for i = 1:length(handles.time)
    str = [num2str(handles.time(i)), ', lat=', sprintf('%6.7f', handles.latVals(i)), ', lon=', sprintf('%6.7f', handles.lonVals(i)), ', alt=', sprintf('%6.2f', handles.altVals(i)), ...
        ', ', num2str(handles.vx(i)), ', ', num2str(handles.vy(i)), ', ', num2str(handles.vz(i)), ', ', num2str(handles.heading(i)), ...
        ', Attitude:pitch=', num2str(handles.pitch(i)), ', yaw=', num2str(handles.yaw(i)), ', roll=', num2str(handles.roll(i))];
    fprintf(fid, '%s\n', str);
end
fclose(fid);
disp('====== Drone Output File generating finished! ======')
guidata(hObject, handles);


function firstTime_Callback(hObject, ~, handles)
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function firstTime_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);


function lastTime_Callback(hObject, ~, handles)
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function lastTime_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);


function xmlName_Callback(hObject, ~, handles)
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function xmlName_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);


function rate_Callback(hObject, ~, handles)
val = str2double(get(hObject, 'String'));
handles.rateVal = val;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function rate_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);


function lat_Callback(hObject, ~, handles)
val = str2double(get(hObject, 'String'));
handles.latVal = val;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function lat_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);

function lon_Callback(hObject, ~, handles)
val = str2double(get(hObject, 'String'));
handles.lonVal = val;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function lon_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);

function height_Callback(hObject, ~, handles)
val = str2double(get(hObject, 'String'));
handles.hVal = val;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function height_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);
