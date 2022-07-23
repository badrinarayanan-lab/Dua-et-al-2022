function varargout = DAPI_exp_1(varargin)
% DAPI_EXP_1 MATLAB code for DAPI_exp_1.fig
%      DAPI_EXP_1, by itself, creates a new DAPI_EXP_1 or raises the existing
%      singleton*.
%
%      H = DAPI_EXP_1 returns the handle to a new DAPI_EXP_1 or the handle to
%      the existing singleton*. 
%
%      DAPI_EXP_1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DAPI_EXP_1.M with the given input arguments.
%
%      DAPI_EXP_1('Property','Value',...) creates a new DAPI_EXP_1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DAPI_exp_1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DAPI_exp_1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DAPI_exp_1

% Last Modified by GUIDE v2.5 27-Jul-2019 19:19:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DAPI_exp_1_OpeningFcn, ...
                   'gui_OutputFcn',  @DAPI_exp_1_OutputFcn, ...
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


% --- Executes just before DAPI_exp_1 is made visible.
function DAPI_exp_1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DAPI_exp_1 (see VARARGIN)

% Choose default command line output for DAPI_exp_1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DAPI_exp_1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DAPI_exp_1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, path] = uigetfile;
global im_phase crop_index bounding_box;
crop_index = 0;
im_phase = imread(strcat(path, file));
% Segment the cells
[~,threshold] = edge(im_phase,'sobel');
fudgeFactor = 0.5;
BWs = edge(im_phase,'sobel',threshold * fudgeFactor);
fudgeFactor = 1;
BWs = edge(im_phase,'sobel',threshold * fudgeFactor);
se90 = strel('line',3,90);
se0 = strel('line',3,0);
BWsdil = imdilate(BWs,[se90 se0]);
BWdfill = imfill(BWsdil,'holes');
bounding_box = regionprops(BWdfill, 'Area', 'BoundingBox');
% Display the original phase image
axes(handles.axes1);
imshow(localcontrast(im_phase), 'InitialMagnification','fit');

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global im_dapi img_new bounding_box thresh_1 thresh_2 area_min area_max;
thresh_1 = 0.905;
thresh_2 = 0.95;
area_min = 1;
area_max = 500;
[file, path] = uigetfile;
im_dapi = imread(strcat(path, file));
axes(handles.axes3);
imshow(localcontrast(im_dapi), 'InitialMagnification','fit');

% Pre-process DAPI image
img_new = zeros(size(im_dapi), 'uint16');
for k = 1 : length(bounding_box)
thisBB = bounding_box(k).BoundingBox;
if bounding_box(k).Area>0
xMin = ceil(thisBB(1));
xMax = xMin + thisBB(3) - 1;
yMin = ceil(thisBB(2));
yMax = yMin + thisBB(4) - 1;
img_new(yMin:yMax, xMin:xMax) = im_dapi(yMin:yMax, xMin:xMax);
end
end
% Create an image intensity threshold
[f, x] = ecdf(img_new(:));
y = x(and(f>thresh_1,f<1));
thresh = y(1);
img_new(img_new<thresh) = 0;


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global crop_index bounding_box im_dapi img_new thresh_2 area_min area_max;
crop_index = crop_index + 1;
%disp(crop_index)
axes(handles.axes4);
if crop_index < length(bounding_box)+1
bbx = bounding_box(crop_index).BoundingBox;
im_crop = imcrop(im_dapi, bbx);
imshow(imadjust(im_crop), 'InitialMagnification','fit');
end
% 
axes(handles.axes5);
if crop_index < length(bounding_box)+1
bbx = bounding_box(crop_index).BoundingBox;
im_crop = imcrop(im_dapi, bbx);

imshow(imadjust(im_crop), 'InitialMagnification','fit');

s_crop_area = process_crop(crop_index, im_dapi, img_new, bounding_box, thresh_2);
for k = 1:length(s_crop_area)
    thisBB = s_crop_area(k).BoundingBox;
    if and(s_crop_area(k).Area>area_min, s_crop_area(k).Area<area_max)
    rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
    'EdgeColor','r','LineWidth',2 )
    end
end
end
set(handles.edit8, 'String', crop_index);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global crop_index bounding_box im_dapi img_new thresh_2 area_min area_max;
crop_index = crop_index - 1;
axes(handles.axes4);
if crop_index>0
bbx = bounding_box(crop_index).BoundingBox;
im_crop = imcrop(im_dapi, bbx);
imshow(imadjust(im_crop), 'InitialMagnification','fit');

axes(handles.axes5);
bbx = bounding_box(crop_index).BoundingBox;
im_crop = imcrop(im_dapi, bbx);

imshow(imadjust(im_crop), 'InitialMagnification','fit');

s_crop_area = process_crop(crop_index, im_dapi, img_new, bounding_box, thresh_2);
for k = 1:length(s_crop_area)
    thisBB = s_crop_area(k).BoundingBox;
    if and(s_crop_area(k).Area>area_min, s_crop_area(k).Area<area_max)
    rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
    'EdgeColor','r','LineWidth',2 )
    end
end
else
crop_index = 0;
end
set(handles.edit8, 'String', crop_index);


% Put all custom functions at the end.
function s_crop_area = process_crop(crop_index, im_dapi, img_new, bounding_box, thresh_2)
    bbx = bounding_box(crop_index).BoundingBox;
    im_crop = imcrop(img_new, bbx);
    % Identifying spot in cropped cell
    [f, x] = ecdf(im_crop(:));
    try
        y = x(and(f>thresh_2,f<1));
        thresh = y(1);
    catch
        thresh = 0;
    end
    
    im_crop(im_crop<thresh) = 0;
        

    im_crop(im_crop>0) = 60000;%max(im_phase(:));
    s_crop_area = regionprops(imbinarize(im_crop), 'Area', 'BoundingBox');



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global thresh_1 im_dapi img_new bounding_box;
thresh_1 = str2double(get(handles.edit2, 'String'));
% Pre-process DAPI image
img_new = zeros(size(im_dapi), 'uint16');
for k = 1 : length(bounding_box)
thisBB = bounding_box(k).BoundingBox;
if bounding_box(k).Area>0
xMin = ceil(thisBB(1));
xMax = xMin + thisBB(3) - 1;
yMin = ceil(thisBB(2));
yMax = yMin + thisBB(4) - 1;
img_new(yMin:yMax, xMin:xMax) = im_dapi(yMin:yMax, xMin:xMax);
end
end
% Create an image intensity threshold
[f, x] = ecdf(img_new(:));
y = x(and(f>thresh_1,f<1));
thresh = y(1);
img_new(img_new<thresh) = 0;
disp(thresh_1);
% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global thresh_2
thresh_2 = str2double(get(handles.edit3, 'String'));
disp(thresh_2);
% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global area_min
area_min = str2double(get(handles.edit4, 'String'));
disp(area_min);
% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global area_max
area_max = str2double(get(handles.edit5, 'String'));
disp(area_max);
% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double

function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
