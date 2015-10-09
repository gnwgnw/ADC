function varargout = Pi2(varargin)
% PI2 MATLAB code for Pi2.fig
%      PI2, by itself, creates a new PI2 or raises the existing
%      singleton*.
%
%      H = PI2 returns the handle to a new PI2 or the handle to
%      the existing singleton*.
%
%      PI2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PI2.M with the given input arguments.
%
%      PI2('Property','Value',...) creates a new PI2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Pi2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Pi2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Pi2

% Last Modified by GUIDE v2.5 08-Oct-2015 13:02:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Pi2_OpeningFcn, ...
                   'gui_OutputFcn',  @Pi2_OutputFcn, ...
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


% --- Executes just before Pi2 is made visible.
function Pi2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Pi2 (see VARARGIN)

handles = enable_gui(handles, 'off');

% Choose default command line output for Pi2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = Pi2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in button_load.
function button_load_Callback(hObject, eventdata, handles)
% hObject    handle to button_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Load out.txt file; fill T, XY components, P; set default values;
% calculate u on filth data; handle plots.

[filename, pathname] = uigetfile('out.txt', 'Выберите файл данных');
if  ~isequal(filename,0)
    handles.figure1.('Pointer') = 'watch';
    pause(0.01);
    
    % Remember path for save data.txt file in the same folder as the
    % out.txt
    handles.dir_path = pathname;
    filename = fullfile(pathname, filename);
    
    handles = clear_workspace(handles);
    
    % Prepare data
    FREQ = 102400;
    SPREAD = 10;
    
    M = dlmread(filename, '', 1, 0);
    
    handles.freq = FREQ / SPREAD;
    
    handles.T = M(1:SPREAD:end, 1);
    handles.X_filth = M(1:SPREAD:end, 2);
    handles.Y_filth = M(1:SPREAD:end, 3);
    handles.P_filth = M(1:SPREAD:end, 4);
    
    handles.t0 = handles.T(1);
    handles.t1 = handles.T(end);
    
    handles.L = str2double(handles.edit_L.('String'));
    
    handles.X = handles.X_filth;
    handles.Y = handles.Y_filth;
    handles.P = handles.P_filth;
    handles.dP = diff(handles.P) .* handles.freq;
    
    handles.shift_X = str2double(handles.edit_shiftX.('String'));
    handles.shift_Y = str2double(handles.edit_shiftY.('String'));
    
    handles.multipler = 1e-1;
    
    handles = main_calculate(handles);
    
    % Show results
    handles.text_filename.('String') = filename;
    handles.edit_t1.('String') = handles.t1;
    handles.text_K.('String') = handles.K;
    
    axes(handles.axes_XY);
    hold on;
    grid on;

    handles.plot_X = plot(handles.T, handles.X);
    handles.plot_Y = plot(handles.T, handles.Y);
    handles.plot_t0_XY = vline(handles.t0);
    handles.plot_t1_XY = vline(handles.t1);
    legend('X', 'Y');


    axes(handles.axes_curve);
    hold on;
    axis equal;
    grid on;

    handles.plot_G = plot(handles.X, handles.Y);
    legend('G');


    axes(handles.axes_phi);
    hold on;
    grid on;

    handles.plot_phi = plot(handles.T, handles.phi);
    handles.plot_t0_phi = vline(handles.t0);
    handles.plot_t1_phi = vline(handles.t1);
    legend('phi');


    axes(handles.axes_P);
    hold on;
    grid on;

    handles.plot_P = plot(handles.T, handles.P);
    handles.plot_t0_P = vline(handles.t0);
    handles.plot_t1_P = vline(handles.t1);
    legend('P');


    axes(handles.axes_dP);
    hold on;
    grid on;

    handles.plot_dP = plot(handles.T(1:end-1), handles.dP);
	handles.plot_t0_dP = vline(handles.t0);
    handles.plot_t1_dP = vline(handles.t1);
    legend('dP');


    axes(handles.axes_u);
    hold on;
    grid on;

    handles.plot_u = plot(handles.T(1:end-1), handles.u);
	handles.plot_t0_u = vline(handles.t0);
    handles.plot_t1_u = vline(handles.t1);
    legend('u');
    
    handles.figure1.('Pointer') = 'arrow';
    handles = enable_gui(handles, 'on');
    
    % Update handles structure
    guidata(hObject, handles);
end


% --- Executes on button press in button_filter<>.
function button_filter_Callback(hObject, eventdata, handles)
% hObject    handle to button_filterP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.figure1.('Pointer') = 'watch';
pause(0.01);
    
tag = hObject.('Tag');
tokens = regexp(tag,'button_filter(\w)', 'tokens');
field = tokens{1}{1};
filth_field = strcat(field, '_filth');

handles.(field) = accept_filter(handles.(filth_field), handles.freq);

switch field
    case 'P'
        handles = update_P(handles);
    otherwise
        handles = update_XY(handles);
end

handles.figure1.('Pointer') = 'arrow';

% Update handles structure
guidata(hObject, handles);


function edit_L_Callback(hObject, eventdata, handles)
% hObject    handle to edit_L (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.L = str2double(hObject.('String'));
handles = update_K(handles);

% Update handles structure
guidata(hObject, handles);


function edit_t_Callback(hObject, eventdata, handles)
% hObject    handle to edit_t<> (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = str2double(hObject.('String'));

tag = hObject.('Tag');
tokens = regexp(tag,'edit_(t\d)', 'tokens');
field = tokens{1}{1};

handles.(field) = val;

handles = update_K(handles);

% Update handles structure
guidata(hObject, handles);


function edit_shift_Callback(hObject, eventdata, handles)
% hObject    handle to edit_shift<> (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = str2double(hObject.('String'));

tag = hObject.('Tag');
tokens = regexp(tag,'edit_shift(\w)', 'tokens');
field = tokens{1}{1};
field = strcat('shift_', field);

handles.(field) = val;

handles = update_XY(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in shift buttons.
function button_shift_Callback(hObject, eventdata, handles)
% hObject    handle to button_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tag = hObject.('Tag');
tokens = regexp(tag,'button_(\w+)', 'tokens');
dir = tokens{1}{1};

switch dir
    case 'up'
        handles.shift_Y = handles.shift_Y + handles.multipler;
    case 'down'
        handles.shift_Y = handles.shift_Y - handles.multipler;
    case 'left'
        handles.shift_X = handles.shift_X - handles.multipler;
    case 'right'
        handles.shift_X = handles.shift_X + handles.multipler;
end

handles = update_XY(handles);
handles = update_shift_text(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in multipler radiobuttons.
function radiobutton_mulitpler_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.multipler = str2double(hObject.('String'));

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in button_save.
function button_save_Callback(hObject, eventdata, handles)
% hObject    handle to button_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.figure1.('Pointer') = 'watch';
pause(0.01);
    
file_path = strcat(handles.dir_path, 'data.txt');
fileID = fopen(file_path, 'w');

out = [handles.T(1:end-1)'; handles.P(1:end-1)'; handles.u'];

fprintf(fileID, '%8s %8s %8s\n', 't', 'P', 'u');
fprintf(fileID, '%8.5f %8.4f %8.4f\n', out);

fclose(fileID);

handles.figure1.('Pointer') = 'arrow';



function phi = phi(X, Y)

G = complex(X, Y);
phi = unwrap(angle(G));


function omega = omega(phi, freq)

omega = diff(phi) .* freq;


function u = u(omega, K)

u = omega .* K;


function K = K(L, phi0, phi1)

K = L / abs(phi1 - phi0);


function handles = main_calculate(handles)

handles.phi = phi(handles.X, handles.Y);
handles.omega = omega(handles.phi, handles.freq);

sample0 = int64(handles.t0 * handles.freq) + 1;
sample1 = int64(handles.t1 * handles.freq);

handles.K = K(handles.L, handles.phi(sample0), handles.phi(sample1));

handles.u = u(handles.omega, handles.K);


function handles = update_XY(handles)

X_shifted = handles.X + handles.shift_X;
Y_shifted = handles.Y + handles.shift_Y;

% Update data
handles.phi = phi(X_shifted, Y_shifted);
handles.omega = omega(handles.phi, handles.freq);
handles.u = u(handles.omega, handles.K);

% Update plots
handles.plot_X.YData = X_shifted;
handles.plot_Y.YData = Y_shifted;

handles.plot_G.XData = X_shifted;
handles.plot_G.YData = Y_shifted;

handles.plot_phi.YData = handles.phi;

handles.plot_u.YData = handles.u;

handles = update_t_plots(handles);


function handles = update_K(handles)

% Update data
sample0 = int64(handles.t0 * handles.freq) + 1;
sample1 = int64(handles.t1 * handles.freq);

handles.K = K(handles.L, handles.phi(sample0), handles.phi(sample1));
handles.u = u(handles.omega, handles.K);

% Update plots
handles.text_K.('String') = handles.K;

handles.plot_u.YData = handles.u;

handles = update_t_plots(handles);


function handles = update_t_plots(handles)

plots = {'XY', 'phi', 'P', 'u', 'dP'};

t0 = handles.t0;
t1 = handles.t1;

for name = plots
    name = name{1};

    axes_name = strcat('axes_', name);
    plot0_name = strcat('plot_t0_', name);
    plot1_name = strcat('plot_t1_', name);
    
    delete(handles.(plot0_name));
    delete(handles.(plot1_name));
    
    axes(handles.(axes_name));
    handles.(plot0_name) = vline(t0);
    handles.(plot1_name) = vline(t1);
end


function handles = update_P(handles)

% Update plots
handles.plot_P.YData = handles.P;
handles.dP = diff(handles.P) .* handles.freq;
handles.plot_dP.YData = handles.dP;

handles = update_t_plots(handles);


function handles = update_shift_text(handles)

handles.edit_shiftX.('String') = handles.shift_X;
handles.edit_shiftY.('String') = handles.shift_Y;


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

tokens = regexp(eventdata.Key, '(\w+)arrow', 'tokens');

if ~isempty(tokens)
    dir = tokens{1}{1};
    tag = strcat('button_', dir);
    
    if strcmp(handles.(tag).('Enable'), 'on')
        button_shift_Callback(handles.(tag), eventdata, handles);
    end
end


function handles = enable_gui(handles, status)

controls = {'edit_L', 'button_filterX', 'button_filterY', 'button_filterP', ...
    'edit_t0', 'edit_t1', 'edit_shiftX', 'edit_shiftY', 'button_up', ...
    'button_down', 'button_left', 'button_right', 'button_save', ...
    'edit_auto_positioning_X', 'edit_auto_positioning_Y', ...
    'button_auto_positioning_X', 'button_auto_positioning_Y'};

for control = controls
    control = control{1};
    handles.(control).('Enable') = status;
end


function handles = clear_workspace(handles)

names = fieldnames(handles);

for name = names'
    name = name{1};
    
    if isa(handles.(name), 'matlab.graphics.chart.primitive.Line')
        delete(handles.(name));
    end
end


function max_corr = f_X0(handles, shift)

X_shifted = handles.X + shift;
Y_shifted = handles.Y + handles.shift_Y;

phi_ = phi(X_shifted, Y_shifted);
u_ = diff(phi_);
acorr = xcorr(X_shifted, u_);
max_corr = max(abs(acorr));


function max_corr = f_Y0(handles, shift)

X_shifted = handles.X + handles.shift_X;
Y_shifted = handles.Y + shift;

phi_ = phi(X_shifted, Y_shifted);
u_ = diff(phi_);
acorr = xcorr(Y_shifted, u_);
max_corr = max(abs(acorr));


% --- Executes on button press in button_auto_positioning_X.
function button_auto_positioning_X_Callback(hObject, eventdata, handles)
% hObject    handle to button_auto_positioning_X (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.figure1.('Pointer') = 'watch';
pause(0.01);

eps = 1e-4;
radius_X = abs(str2double(handles.edit_auto_positioning_X.('String')));
min_X = handles.shift_X - radius_X;
max_X = handles.shift_X + radius_X;

X0 = gss(@(x) f_X0(handles, x), min_X, max_X, eps);

handles.shift_X = X0;

handles = update_XY(handles);
handles = update_shift_text(handles);

handles.figure1.('Pointer') = 'arrow';

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in button_auto_positioning_Y.
function button_auto_positioning_Y_Callback(hObject, eventdata, handles)
% hObject    handle to button_auto_positioning_Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.figure1.('Pointer') = 'watch';
pause(0.01);

eps = 1e-4;
radius_Y = str2double(handles.edit_auto_positioning_Y.('String'));
min_Y = handles.shift_Y - radius_Y;
max_Y = handles.shift_Y + radius_Y;

Y0 = gss(@(x) f_Y0(handles, x), min_Y, max_Y, eps);

handles.shift_Y = Y0;

handles = update_XY(handles);
handles = update_shift_text(handles);

handles.figure1.('Pointer') = 'arrow';

% Update handles structure
guidata(hObject, handles);
