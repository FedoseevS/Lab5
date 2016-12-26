function varargout = ide(varargin)
% Початок коду ініціалізації
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ide_OpeningFcn, ...
                   'gui_OutputFcn',  @ide_OutputFcn, ...
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
% Кінець коду ініціалізації
% коментар 1 
%коментар 2 

function ide_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

%Визначення робота
handles.R = IRB2400(handles.axes1, hObject);


%Ліміти для слайдерів
set(handles.q1slider,'Min', handles.R.qlim(1)*180/pi)
set(handles.q1slider,'Max', handles.R.qlim(2)*180/pi)
set(handles.q2slider,'Min', handles.R.qlim(3)*180/pi)
set(handles.q2slider,'Max', handles.R.qlim(4)*180/pi)
set(handles.q3slider,'Min', handles.R.qlim(5)*180/pi)
set(handles.q3slider,'Max', handles.R.qlim(6)*180/pi)
set(handles.q4slider,'Min', handles.R.qlim(7)*180/pi)
set(handles.q4slider,'Max', handles.R.qlim(8)*180/pi)
set(handles.q5slider,'Min', handles.R.qlim(9)*180/pi)
set(handles.q5slider,'Max', handles.R.qlim(10)*180/pi)
set(handles.q6slider,'Min', handles.R.qlim(11)*180/pi)
set(handles.q6slider,'Max', handles.R.qlim(12)*180/pi)

q = handles.R.q.*180./pi;

set(handles.q1Text,'String',num2str(q(1)));
set(handles.q2Text,'String',num2str(q(2)));
set(handles.q3Text,'String',num2str(q(3)));
set(handles.q4Text,'String',num2str(q(4)));
set(handles.q5Text,'String',num2str(q(5)));
set(handles.q6Text,'String',num2str(q(6)));
set(handles.q1slider,'Value',q(1));
set(handles.q2slider,'Value',q(2));
set(handles.q3slider,'Value',q(3));
set(handles.q4slider,'Value',q(4));
set(handles.q5slider,'Value',q(5));
set(handles.q6slider,'Value',q(6));


%Ініціалізація Axes1
axes(handles.axes1)
xlabel('X')
ylabel('Y')
zlabel('Z')
set(handles.axes1, 'drawmode', 'fast');
grid on
zlim([0,1700])
xlim([-1700,1700])
ylim([-1700,1700])
set(handles.axes1, 'DataAspectRatioMode', 'manual')
set(handles.axes1, 'CameraPosition', [15000,23000,13000])

%Ініціалізація Axes2 для матриці
axes(handles.axes2)
set(gca,'xcolor',get(gcf,'color'));
set(gca,'ycolor',get(gcf,'color'));
set(gca,'color',get(gcf,'color'));
set(gca,'ytick',[]);
set(gca,'xtick',[]);
handles.A06latex = text('Interpreter','latex',...
'String',['$^0A_6 = $'],...
'Position',[0 0.5],...
'FontSize',13)

TRound = roundn(handles.R.A06,-2);
    set(handles.A06latex, 'String',['$^0A_6 = ' '\left( \begin{array}{cccc} '...
        num2str(TRound(1,1)) ' & ' num2str(TRound(1,2)) ' & ' num2str(TRound(1,3)) ' & ' num2str(TRound(1,4)) ' \\ '...
        num2str(TRound(2,1)) ' & ' num2str(TRound(2,2)) ' & ' num2str(TRound(2,3)) ' & ' num2str(TRound(2,4)) ' \\ '...
        num2str(TRound(3,1)) ' & ' num2str(TRound(3,2)) ' & ' num2str(TRound(3,3)) ' & ' num2str(TRound(3,4)) ' \\ '...
        num2str(TRound(4,1)) ' & ' num2str(TRound(4,2)) ' & ' num2str(TRound(4,3)) ' & ' num2str(TRound(4,4))...
        '\end{array} \right)' '$'])


%Змінні для контролю
handles.control.pInc = 20;
handles.control.aInc = pi/180*90;
handles.control.opt = 0;
set(handles.incPosText,'String',['Збільшення позиції (Numpad 7, +-) на: ',num2str(handles.control.pInc)])
set(handles.incAngText,'String',['Збільшення орієнтації (Numpad 8, +-) на: ',num2str(handles.control.aInc*180/pi),' градусів'])
handles.control.busyRobot = 0;
handles.control.tMinMov = 0.2;


%Таймер для оновлення графічного інтерфейсу
handles.guifig = gcf;
handles.tmr = timer('TimerFcn',...
{@TmrFcn,handles.guifig},'BusyMode','Queue',...
    'ExecutionMode','FixedRate','Period',0.1);


% Оновити структуру
guidata(hObject, handles);
assignin('base','R', handles.R)


function TmrFcn(src,event,handles) %Функція таймера
    handles = guidata(handles);
    
    q = handles.R.q.*180./pi;
    
    set(handles.q1Text,'String',num2str(q(1)));
    set(handles.q2Text,'String',num2str(q(2)));
    set(handles.q3Text,'String',num2str(q(3)));
    set(handles.q4Text,'String',num2str(q(4)));
    set(handles.q5Text,'String',num2str(q(5)));
    set(handles.q6Text,'String',num2str(q(6)));
    set(handles.q1slider,'Value',q(1));
    set(handles.q2slider,'Value',q(2));
    set(handles.q3slider,'Value',q(3));
    set(handles.q4slider,'Value',q(4));
    set(handles.q5slider,'Value',q(5));
    set(handles.q6slider,'Value',q(6));
    
    set(handles.warnText,'String',handles.R.err);

guidata(handles.guifig, handles);


% Вихідні дані функції повертаються у командну стрічку.
function varargout = ide_OutputFcn(hObject, eventdata, handles) 
% VARARGOUT
varargout{1} = handles.output;
guidata(hObject, handles);



function draw(handles)
handles.R.Arefresh();
handles.R.plot3d();


function q1slider_Callback(hObject, eventdata, handles)

sliderValue = get(hObject, 'Value');
set(handles.q1Text,'String', num2str(sliderValue));
theta = sliderValue * pi / 180;
handles.R.q(1) = theta;
draw(handles);
guidata(hObject, handles);


function q1slider_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function q2slider_Callback(hObject, eventdata, handles)


sliderValue = get(hObject, 'Value');
set(handles.q2Text,'String', num2str(sliderValue));
theta = sliderValue * pi / 180;
handles.R.q(2) = theta;
draw(handles);

guidata(hObject, handles);


function q2slider_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function q3slider_Callback(hObject, eventdata, handles)

sliderValue = get(hObject, 'Value');
set(handles.q3Text,'String', num2str(sliderValue));
theta = sliderValue * pi / 180;
handles.R.q(3) = theta;
draw(handles);

guidata(hObject, handles);



function q3slider_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function q4slider_Callback(hObject, eventdata, handles)

sliderValue = get(hObject, 'Value');
set(handles.q4Text,'String', num2str(sliderValue));
theta = sliderValue * pi / 180;
handles.R.q(4) = theta;
draw(handles);

guidata(hObject, handles);


function q4slider_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function q5slider_Callback(hObject, eventdata, handles)

sliderValue = get(hObject, 'Value');
set(handles.q5Text,'String', num2str(sliderValue));
theta = sliderValue * pi / 180;
handles.R.q(5) = theta;
draw(handles);

guidata(hObject, handles);


function q5slider_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function q6slider_Callback(hObject, eventdata, handles)

sliderValue = get(hObject, 'Value');
set(handles.q6Text,'String', num2str(sliderValue));
theta = sliderValue * pi / 180;
handles.R.q(6) = theta;
draw(handles);

guidata(hObject, handles);


function q6slider_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function q1Text_Callback(hObject, eventdata, handles)

function q1Text_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function q2Text_Callback(hObject, eventdata, handles)

function q2Text_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function q3Text_Callback(hObject, eventdata, handles)

function q3Text_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function q4Text_Callback(hObject, eventdata, handles)

function q4Text_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function q5Text_Callback(hObject, eventdata, handles)

function q5Text_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function q6Text_Callback(hObject, eventdata, handles)


function q6Text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pushbutton1_Callback(hObject, eventdata, handles)
handles.R.clearTrayHist();


function pushbutton3_Callback(hObject, eventdata, handles)
   
    T = handles.R.TCD([0 0 0 0 0 0]);

    TRound = roundn(T,-2);
    set(handles.A06latex, 'String',['$^0A_6 = ' '\left( \begin{array}{cccc} '...
        num2str(TRound(1,1)) ' & ' num2str(TRound(1,2)) ' & ' num2str(TRound(1,3)) ' & ' num2str(TRound(1,4)) ' \\ '...
        num2str(TRound(2,1)) ' & ' num2str(TRound(2,2)) ' & ' num2str(TRound(2,3)) ' & ' num2str(TRound(2,4)) ' \\ '...
        num2str(TRound(3,1)) ' & ' num2str(TRound(3,2)) ' & ' num2str(TRound(3,3)) ' & ' num2str(TRound(3,4)) ' \\ '...
        num2str(TRound(4,1)) ' & ' num2str(TRound(4,2)) ' & ' num2str(TRound(4,3)) ' & ' num2str(TRound(4,4))...
        '\end{array} \right)' '$'])

    start(handles.tmr);
    handles.R.goToPoint(T,handles.control.tMinMov);
    stop(handles.tmr);


function pointstb_CreateFcn(hObject, eventdata, handles)

function GoPoints_Callback(hObject, eventdata, handles)

    pstring = get(handles.pointstb,'String');
    for i=1:size(pstring,1)
        p(i,:) = str2num(pstring{i});
    end

    axes(handles.axes1);
    start(handles.tmr);
    handles.R.goline(p');

    TRound = roundn(handles.R.A06,-2);
    set(handles.A06latex, 'String',['$^0A_6 = ' '\left( \begin{array}{cccc} '...
        num2str(TRound(1,1)) ' & ' num2str(TRound(1,2)) ' & ' num2str(TRound(1,3)) ' & ' num2str(TRound(1,4)) ' \\ '...
        num2str(TRound(2,1)) ' & ' num2str(TRound(2,2)) ' & ' num2str(TRound(2,3)) ' & ' num2str(TRound(2,4)) ' \\ '...
        num2str(TRound(3,1)) ' & ' num2str(TRound(3,2)) ' & ' num2str(TRound(3,3)) ' & ' num2str(TRound(3,4)) ' \\ '...
        num2str(TRound(4,1)) ' & ' num2str(TRound(4,2)) ' & ' num2str(TRound(4,3)) ' & ' num2str(TRound(4,4))...
        '\end{array} \right)' '$'])
    
    stop(handles.tmr);





function pushbutton5_Callback(hObject, eventdata, handles)

    handles.R.goToPoint(handles.R.TCD([0 0 0 0 0 0]),1);
    p = [1000 -300 1590; 1000 -300 1090; 1000 100 1090;...
        1000 100 1590; 1000 400 1590; 1000 400 1390;...
        1000 100 1390; 1000 400 1390; 1000 400 1090;...
        1000 500 1090; 1000 500 1590; 1000 800 1590; 1000 800 1090;1000 900 1090;1000 900 1590;1000 1200 1590;1000 1200 1390;1000 900 1390];
    axes(handles.axes1);
    start(handles.tmr);
    handles.R.goline(p');

    TRound = roundn(handles.R.A06,-2);
    set(handles.A06latex, 'String',['$^0A_6 = ' '\left( \begin{array}{cccc} '...
        num2str(TRound(1,1)) ' & ' num2str(TRound(1,2)) ' & ' num2str(TRound(1,3)) ' & ' num2str(TRound(1,4)) ' \\ '...
        num2str(TRound(2,1)) ' & ' num2str(TRound(2,2)) ' & ' num2str(TRound(2,3)) ' & ' num2str(TRound(2,4)) ' \\ '...
        num2str(TRound(3,1)) ' & ' num2str(TRound(3,2)) ' & ' num2str(TRound(3,3)) ' & ' num2str(TRound(3,4)) ' \\ '...
        num2str(TRound(4,1)) ' & ' num2str(TRound(4,2)) ' & ' num2str(TRound(4,3)) ' & ' num2str(TRound(4,4))...
        '\end{array} \right)' '$'])
    
    stop(handles.tmr);



function figure1_KeyPressFcn(hObject, eventdata, handles)
% GCBO
% FIGURE
%	Key: клавіша, яка була натиснута
%GUIDATA
assignin('base', 'eventdata', eventdata);

if(handles.control.busyRobot == 0) %Якщо робот не заблокований
    handles.control.busyRobot = 1; %Заблокувати
    guidata(hObject, handles);
    
    A06 = handles.R.A06;
    p = A06(1:3,4)';
    R = A06(1:3,1:3);

    jumpMove = 0; 
    switch eventdata.Key
        case 'numpad1'
            
            switch handles.control.opt
                case 0
                    p = p + [handles.control.pInc 0 0];
                case 1
                    R = R*rotx(handles.control.aInc);
            end
        case 'numpad2'
            
            switch handles.control.opt
                case 0
                    p = p + [0 handles.control.pInc 0];
                case 1
                    R = R*roty(handles.control.aInc);
            end
        case 'numpad3'
            
            switch handles.control.opt
                case 0
                    p = p + [0 0 handles.control.pInc];
                case 1
                    R = R*rotz(handles.control.aInc);
            end
        case 'numpad4'
            
            switch handles.control.opt
                case 0
                    p = p + [-handles.control.pInc 0 0];
                case 1
                    R = R*rotx(-handles.control.aInc);
            end
        case 'numpad5'
            
            switch handles.control.opt
                case 0
                    p = p + [0 -handles.control.pInc 0];
                case 1
                    R = R*roty(-handles.control.aInc);
            end
        case 'numpad6'
           
            switch handles.control.opt
                case 0
                    p = p + [0 0 -handles.control.pInc];
                case 1
                    R = R*rotz(-handles.control.aInc);
            end
        case 'numpad7'
           
            handles.control.opt = 0;
        case 'numpad8'
            
            handles.control.opt = 1;
        case 'numpad9'
            
        case 'add'
            switch handles.control.opt
                case 0
                    handles.control.pInc = handles.control.pInc + 10;
                case 1
                    handles.control.aInc = handles.control.aInc + pi/180*10;
            end
            set(handles.incPosText,'String',['Збільшення позиції (Numpad 7, +-) на: ',num2str(handles.control.pInc)])
            set(handles.incAngText,'String',['Збільшення орієнтації (Numpad 8, +-) на: ',num2str(handles.control.aInc*180/pi),' градусів'])
            jumpMove = 1; 
        case 'subtract'
            switch handles.control.opt
                case 0
                    if handles.control.pInc >= 10
                         handles.control.pInc = handles.control.pInc - 10;
                    end
                case 1
                    if handles.control.aInc >= pi/180*10
                         handles.control.aInc = handles.control.aInc - pi/180*10;
                    end
            end
            set(handles.incPosText,'String',['Збільшення позиції (Numpad 7, +-) на: ',num2str(handles.control.pInc)])
            set(handles.incAngText,'String',['Збільшення орієнтації (Numpad 8, +-) на: ',num2str(handles.control.aInc*180/pi),' градусів'])
            jumpMove = 1;
    end

    % Оновити структуру
    guidata(hObject, handles);
    
    if jumpMove == 0
        T = A06;
        T(1:3,1:3) = R;
        T(1:3,4) = p';

        start(handles.tmr);
        handles.R.goToPoint(T,handles.control.tMinMov);
        stop(handles.tmr);
        
        if (strcmp(handles.R.err, 'Помилка: дана точка знаходиться поза робочою зоною робота')==0)
            TRound = roundn(T,-2);
            set(handles.A06latex, 'String',['$^0A_6 = ' '\left( \begin{array}{cccc} '...
                num2str(TRound(1,1)) ' & ' num2str(TRound(1,2)) ' & ' num2str(TRound(1,3)) ' & ' num2str(TRound(1,4)) ' \\ '...
                num2str(TRound(2,1)) ' & ' num2str(TRound(2,2)) ' & ' num2str(TRound(2,3)) ' & ' num2str(TRound(2,4)) ' \\ '...
                num2str(TRound(3,1)) ' & ' num2str(TRound(3,2)) ' & ' num2str(TRound(3,3)) ' & ' num2str(TRound(3,4)) ' \\ '...
                num2str(TRound(4,1)) ' & ' num2str(TRound(4,2)) ' & ' num2str(TRound(4,3)) ' & ' num2str(TRound(4,4))...
                '\end{array} \right)' '$'])
        end
        
    end

    handles.control.busyRobot = 0; %Розблокувати робот для подальших дій
    guidata(hObject, handles);
end
