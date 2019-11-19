function [ID, session] = participant_info_GUI()
%% Get particiapnt info for data collection
% user to enter in GUI
%   - participant  ID (w radio button selection for healthy/clinical)
%   - comment field to store text as required during capture. 
% ----------------------------------------------------------------------- %
% Major Revisions:
%   - 19/11/19 (created)
% ----------------------------------------------------------------------- %
% Simnon Thwaites
% simonthwaites1991@gmail.com
% ----------------------------------------------------------------------- %

% initialise GUI
inputFig = figure('Tag',        'figTag', ...
                    'numbertitle', 'off', ...
                    'name',     'Participant Information', ...
                    'units',    'pixels',...
                    'position', [680 678 480 240],...
                    'toolbar',  'none',...
                    'menu',     'none');
                
% creates handles attached to inputFig
% returns a structure containing handles of objects in a figure, 
% using their tags as fieldnames
h.inputFig = guihandles(inputFig); 

% define UI controls
h.inputFig.IDtext = uicontrol('Parent',    inputFig, ...
                    'Style',    'text',...
                    'Units',    'pixels', ...
                    'String',   'Participant ID:   ',...
                    'Position', [10,200,100,15]);
h.inputFig.IDtextInput = uicontrol('Parent',    inputFig, ...
                    'Style',    'edit',...
                    'Callback', @textCallBack,...
                    'Units',    'pixels', ...
                    'String',   'Enter Participant ID:   ',...
                    'Position', [110,200,150,15]);               
h.inputFig.radioText = uicontrol('Parent',    inputFig, ...
                    'Style',    'text',...
                    'Units',    'pixels', ...
                    'String',   'Select Session:   ',...
                    'Position', [15,100,100,15]);
h.inputFig.radio(1) = uicontrol('Parent',    inputFig, ...
                    'Style',    'radiobutton', ...
                    'Callback', @radioButtonCallback, ...
                    'Units',    'pixels', ...
                    'Position', [110,100,100,15], ...
                    'String',   'Healthy', ...
                    'Value',    1);
h.inputFig.radio(2) = uicontrol('Parent',    inputFig, ...
                    'Style',    'radiobutton', ...
                    'Callback', @radioButtonCallback, ...
                    'Units',    'pixels', ...
                    'Position', [210,100,100,15], ...
                    'String',   'Clinical', ...
                    'Value',    0);
h.inputFig.pushButton = uicontrol('Parent',    inputFig, ...
                    'style',    'pushbutton',...  
                    'units',    'pixels',...
                    'position', [40,5,70,20],...
                    'string',   'OK',...
                    'callback', @pushButtonCallback);
h.inputFig.textEntered = 0;     % var to make sure Participant ID entered first 
guidata(inputFig,h.inputFig);  % update handles
uiwait(inputFig)
inputData = get(0,'UserData');
ID = inputData.ID;
session = inputData.session;
end

function textCallBack(text_object,~,~)
h.inputFig = guidata(text_object);
h.inputFig.textEntered = 1;    % change to 1, allow other callbacks to run
h.inputFig.participantID = h.inputFig.IDtextInput.String; 
%-------------------------------%
% could make input string more robust here
%-------------------------------%

% stores the specified data in the figure's application data
guidata(text_object,h.inputFig)
end

function radioButtonCallback(radio_bject,~,~)
h.inputFig = guidata(radio_bject);
% if handles.textEntered == 1
%     % force only one button to be selected
    otherRadio = h.inputFig.radio(h.inputFig.radio ~= radio_bject);
    set(otherRadio, 'Value', 0);
    % % find which button
    % vals = get(handles.radio,'Value');
    % checked = find([vals{:}]);
    % switch checked
    %     case 1
    %         handles.session = 'Session 1';
    %     case 2
    %         handles.session = 'Session 2';
    % end
    % % store ID and session as matlab root UserData structure so it can be
    % % accessed once the inputFig is closed by pushButtonCallback
    % inputData = struct('ID',handles.participantID,'session',handles.session);
    % set(0,'UserData',inputData);
    guidata(radio_bject,h.inputFig)
% else
%     warndlg('Enter participant ID','!! Warning !!')
% end
end
       
function pushButtonCallback(pushButton_object,~,~)
h.inputFig = guidata(pushButton_object);
if h.inputFig.textEntered == 1
   % find which button
    vals = get( h.inputFig.radio,'Value');
    checked = find([vals{:}]);
    switch checked
        case 1
            h.inputFig.session = 'Healthy';
        case 2
            h.inputFig.session = 'Clinical';
    end
    % store ID and session as matlab root UserData structure so it can be
    % accessed once the inputFig is closed by pushButtonCallback
    inputData = struct('ID',h.inputFig.participantID,'session',h.inputFig.session);
    set(0,'UserData',inputData);
    guidata(pushButton_object,h.inputFig)
    close(get(pushButton_object,'Parent'))    % close parent of pushButton_object (inputFig)  
else
    warndlg('Enter participant ID','!! Warning !!')
end
end