function varargout = accept_filter(varargin)
% ACCEPT_FILTER MATLAB code for accept_filter.fig
%      ACCEPT_FILTER, by itself, creates a new ACCEPT_FILTER or raises the existing
%      singleton*.
%
%      H = ACCEPT_FILTER returns the handle to a new ACCEPT_FILTER or the handle to
%      the existing singleton*.
%
%      ACCEPT_FILTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ACCEPT_FILTER.M with the given input arguments.
%
%      ACCEPT_FILTER('Property','Value',...) creates a new ACCEPT_FILTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before accept_filter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to accept_filter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help accept_filter

% Last Modified by GUIDE v2.5 29-Sep-2015 14:48:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @accept_filter_OpeningFcn, ...
                   'gui_OutputFcn',  @accept_filter_OutputFcn, ...
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


% --- Executes just before accept_filter is made visible.
function accept_filter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to accept_filter (see VARARGIN)

% Input parameters:
%   Data - array of non-filtered data
%   Fs - sample rate
% Output:
%   filtered data

if(numel(varargin))
    handles.Data = varargin{1};
    handles.filtparams.Fs = varargin{2};
else
    error('Not enough input arguments.');
end

handles.t = [0:length(handles.Data) - 1] ./ handles.filtparams.Fs;

handles.filtparams.Apass = str2double(get(handles.Apass, 'String'));
handles.filtparams.Astop = str2double(get(handles.Astop, 'String'));
handles.filtparams.Fpass = str2double(get(handles.Fpass, 'String'));
handles.filtparams.Fstop = str2double(get(handles.Fstop, 'String'));

df = create_filter(handles.filtparams);

handles.Data_filtered = filtfilt(df, handles.Data);

hold on;
grid on;

plot(handles.t, handles.Data);
handles.plot_data_filtered = plot(handles.t, handles.Data_filtered, 'LineWidth', 1.5);

legend('Data', 'Filtered data');

% Choose default command line output for accept_filter
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes accept_filter wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = accept_filter_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.Data_filtered;
delete(hObject);


% --- Executes on button press in done_Btn.
function done_Btn_Callback(hObject, eventdata, handles)
% hObject    handle to done_Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(handles.figure1);


function params_edit_Callback(hObject, eventdata, handles)

param_name = get(hObject, 'Tag');
val = str2double(get(hObject, 'String'));

handles.filtparams = setfield(handles.filtparams, param_name, val);

df = create_filter(handles.filtparams);

handles.Data_filtered = filtfilt(df, handles.Data);

set(handles.plot_data_filtered, 'YData', handles.Data_filtered);

% Update handles structure
guidata(hObject, handles);


function [ df ] = create_filter(filtparams)

df = designfilt('lowpassiir', ...
    'PassbandFrequency', filtparams.Fpass, ...
    'StopbandFrequency', filtparams.Fstop, ...
    'PassbandRipple', filtparams.Apass, ...
    'StopbandAttenuation', filtparams.Astop, ...
    'SampleRate', filtparams.Fs);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end
