function matlab2nexus_acquisitionInterface(sessionString, pathList, trial_list)
% main acquisition interface for data capture
%-------------------------------------------------------------------------%
% Vicon Nexus:
% - In 'auto start/stop capture', ensure 'advanced' is selected, and 
%   trigger via netweork connection.
% - Set Nexus to 'recieve' UDP message and listen over all IP addresses.
% - Set Nexus Port as 6610
% - Ensure Nexus is 'armed' prior to capture.
% 
% UDP msg:
% Nexus requires an xml string to start/stop a capture. Additionally, you can 
% dictate the trial name, and where in the database it should be saved. 
% Note, the PacketID VALUE must increment by one every time a UDP packet 
% is sent to Nexus, Nexus will not accept a repeated command.
% ----------------------------------------------------------------------- %
% Created: 29/11/2019
% Updates: 05/12/2019: - previous button working
%                      - next button working
%                      - trial counters working
%          06/12/2019: - comments saving
%                      - UDP sending working
%          17/12/2019: - knee pain radio buttons. writing this to csv
% ----------------------------------------------------------------------- %
% Simnon Thwaites
% simonthwaites1991@gmail.com
% ----------------------------------------------------------------------- %

%% Create main figure
figTag = 'acq_figTag';
acquisitionFig = figure('numbertitle',      'off', ...
                'name',             'Matlab2Nexus Acquisition Interface', ...
                'menubar',          'none', ...
                'toolbar',          'none', ...
                'resize',           'on', ...
                'tag',              figTag, ...
                'renderer',         'painters', ...
                'units',            'normalized', ...
                'outerposition',    [0.2 0.2 0.6 0.6],...
                'HandleVisibility', 'callback'); % hide the handle to prevent unintended modifications
h.acquisitionFig = guihandles(acquisitionFig); % create handles attached to acquisitionFig

%% define GUI object positions (x-pos,y-pos, x-width, y-height)
% h.acquisitionFig.staticText_backgroundColour = [0.85 0.85 0.85];
h.acquisitionFig.staticText_backgroundColour = [0.94 0.94 0.94];
h.acquisitionFig.highlight_button_colour = [0.9290, 0.6940, 0.1250];

% panel positions
trial_list_panel_position = [0.63 0.16 0.35 0.82];
session_info_panel_position = [0.02 0.85 0.6 0.13];
capture_panel_position = [0.02 0.3 0.6 0.53];
comments_panel_position = [0.02 0.02 0.6 0.26];
end_capture_panel_position = [0.63 0.02 0.35 0.12];

% session info panlel objects
sessionString_textPosition = [0.01 0.6 0.98 0.3];
pathList_textPosition = [0.01 0.05 0.98 0.3];

% comment field panel objects
comment_editField_position = [0.01 0.1 0.8 0.8];
comment_editField_staticText_position = [0.01 0.91 0.4 0.1];
comment_updateButton_position = [0.82 0.1 0.17 0.8];

% capture panel objects
nowCapturing_staticText_position = [0.01 0.91 0.2 0.07];
trialNumber_staticText_position = [0.01 0.83 0.2 0.07];
savingAs_staticText_position = [0.01 0.75 0.2 0.07];
nowCapturing_dynamicText_position = [0.21 0.91 0.5 0.07];
trialNumber_dynamicText_position = [0.21 0.83 0.5 0.07];
savingAs_dynamicText_position = [0.21 0.75 0.5 0.07];
nextTrial_staticText_position = [0.79 0.35 0.2 0.08];
previousTrial_staticText_position = [0.01 0.35 0.2 0.08];

nextTrial_button_position = [0.79 0.45 0.2 0.2];
previousTrial_button_position = [0.01 0.45 0.2 0.2];
start_button_position = [0.525 0.4 0.215 0.3];
stop_button_position = [0.26 0.4 0.215 0.3];

h.acquisitionFig.start_colour = [0 .8 0];
h.acquisitionFig.stop_colour = [.8 0 0];
h.acquisitionFig.leftright_colour = [0.4 0.4 0.4];
buttonFont = 16;

% Knee pain objects
radio_height = 0.2;
radio_length = 0.15;
offset = 0.01;
radio_yPos = 0.15;
kneePain_Bgroup_position = [0 0 1 0.275];
kneePain_radio_position = ...
    [offset radio_yPos radio_length radio_height; ...
    offset*2+radio_length radio_yPos radio_length radio_height; ...
    offset*3+radio_length*2 radio_yPos radio_length radio_height; ...
    offset*4+radio_length*3 radio_yPos radio_length radio_height; ...
    offset*5+radio_length*4 radio_yPos radio_length radio_height];
kneePain_staticText_position = ...
    [offset radio_yPos+offset+0.05 0.14 0.1];
kneePainInfo_staticText_position = ...
    [offset radio_yPos+offset 0.5 0.05];
kneePain_storeSelection_button_position = ...
    [offset*4+radio_length*5 0.04 0.2 0.2];

% trial list panel objects
trial_list_text_position = [0.01 0.01 0.8 0.98];

% add the pathlists and session string to the handle
h.acquisitionFig.pathList = pathList;
h.acquisitionFig.sessionString = sessionString;


%% Initialise UI values
% initialise capture info
h.acquisitionFig.thisCaptureString = '<Hit Next Trial button>'; % start as empty
h.acquisitionFig.thisCaptureNumber = '00'; % start as zero
h.acquisitionFig.thisCaptureSavingAs = ''; % start empty

% create cell array from trial list
h.acquisitionFig.trialCellArray = cellstr(trial_list); 
% now create additional collumn for trial counter
h.acquisitionFig.trialCellArray = [h.acquisitionFig.trialCellArray repmat({1},size(h.acquisitionFig.trialCellArray,1),1)];
% create additional collumn for list order
h.acquisitionFig.trialCellArray = [h.acquisitionFig.trialCellArray num2cell((1:length(trial_list))')];

% trial cell array looks like:
% {full trial name}   {short trial name}  {trial ID}  {trial count}  {original trial order}

% create arrays for updated trial lists
h.acquisitionFig.trialCellArray_updated = h.acquisitionFig.trialCellArray;
% completed trials starting as empty list
h.acquisitionFig.trialCellArray_completed = cell(size(h.acquisitionFig.trialCellArray,1),...
    size(h.acquisitionFig.trialCellArray,2));
h.acquisitionFig.trialCellArray_completed_counter = 0;

% starting value for knee pain selection
h.acquisitionFig.kneePain_currentValue = 'None';

% need 2019 install
h.acquisitionFig.kneePain_csvFullFile = [h.acquisitionFig.pathList.session_dir,'\Knee-Pain.csv'];
h.acquisitionFig.kneePain_cell = {'Participant Session',sessionString;'TrialName','KneePain'};
writecell(h.acquisitionFig.kneePain_cell,h.acquisitionFig.kneePain_csvFullFile)

%% initialise UDP object
h.acquisitionFig.IPaddress = '255.255.255.255';     % broadcast over everything
h.acquisitionFig.Port = 6610;                       % needs to also be set as 6610 in Vicon Nexus
h.acquisitionFig.nexusPacketID = 0;                 % for incrementing UDP packets (required for Nexus)
h.acquisitionFig.nexusUDP = dsp.UDPSender('RemoteIPAddress',   h.acquisitionFig.IPaddress,...
    'RemoteIPPort',      h.acquisitionFig.Port,...
    'LocalIPPortSource', 'Property',...
    'LocalIPPort',       31);


%% Define UI panels
h.acquisitionFig.trial_list_panel = uipanel(acquisitionFig, ...
    'Title',        'Trial List', ...
    'FontSize',     14, ...
    'Position',     trial_list_panel_position);
h.acquisitionFig.session_info_panel = uipanel(acquisitionFig, ...
    'Title',        'Session Information', ...
    'FontSize',     14, ...
    'Position',     session_info_panel_position);
h.acquisitionFig.capture_panel = uipanel(acquisitionFig, ...
    'Title',        'Data Capture', ...
    'FontSize',     18, ...
    'Position',     capture_panel_position);
h.acquisitionFig.comments_panel = uipanel(acquisitionFig, ...
    'Title',        'Comments', ...
    'FontSize',     14, ...
    'Position',     comments_panel_position);
h.acquisitionFig.end_capture_panel = uipanel(acquisitionFig, ...
    'Title',        'End Capture Session', ...
    'FontSize',     14, ...
    'Position',     end_capture_panel_position);


%% Define UI controls

% Session info panel objects
h.acquisitionFig.sessionString_Text = uicontrol('Parent',    h.acquisitionFig.session_info_panel, ...
    'Style',                'text',...
    'Units',                'normalized', ...
    'String',               ['Session String:   ', sessionString],...
    'BackgroundColor',      h.acquisitionFig.staticText_backgroundColour, ...
    'Position',             sessionString_textPosition, ...
    'HorizontalAlignment',  'left');
                
h.acquisitionFig.pathList_text = uicontrol('Parent',    h.acquisitionFig.session_info_panel, ...
    'Style',                'text',...
    'Units',                'normalized', ...
    'String',               ['File Path:   ', pathList.session_dir],...
    'BackgroundColor',      h.acquisitionFig.staticText_backgroundColour, ...
    'Position',             pathList_textPosition, ...
    'HorizontalAlignment',  'left');
                
% comment panel objects
h.acquisitionFig.comment_editField = uicontrol('Parent', h.acquisitionFig.comments_panel, ...
    'Style',                'edit', ...
    'Units',                'normalized', ...
    'Position',             comment_editField_position, ...
    'String',               '<WARNING: Remember to commit each comment change with the pushbutton to the right>',...
    'Callback',             @comment_CallBack,...
    'Min',                  1,...
    'Max',                  3); % If Max-Min>1, then multiple lines are allowed
h.acquisitionFig.comment_editField_staticText = uicontrol('Parent', h.acquisitionFig.comments_panel, ...
    'Style',                'text', ...
    'Units',                'normalized', ...
    'Position',             comment_editField_staticText_position, ...
    'String',               'Enter comments on trial/data capture here: ', ...
    'HorizontalAlignment',  'left');
h.acquisitionFig.comment_updateButton = uicontrol('Parent', h.acquisitionFig.comments_panel, ...
    'Style',                'pushbutton', ...
    'Units',                'normalized', ...
    'Enable',               'on', ...
    'String',               'Update Comments.txt', ...
    'Position',             comment_updateButton_position, ...
    'Callback',             @comment_updateButton_CallBack);
                
% trial list panel objects
h.acquisitionFig.trial_list_text = uicontrol('Parent', h.acquisitionFig.trial_list_panel, ...
    'Style',                'listbox', ...
    'Units',                'normalized', ...
    'FontSize',             12, ...
    'Position',             trial_list_text_position, ...
    'String',               h.acquisitionFig.trialCellArray(:,1));

% capture panel objects
h.acquisitionFig.nowCapturing_staticText = uicontrol('Parent',    h.acquisitionFig.capture_panel, ...
    'Style',                'text',...
    'Units',                'normalized', ...
    'String',               'Now capturing:   ',...
    'BackgroundColor',      h.acquisitionFig.staticText_backgroundColour, ...
    'Position',             nowCapturing_staticText_position, ...
    'HorizontalAlignment',  'left', ...
    'FontSize',             10);
h.acquisitionFig.nowCapturing_dynamicText = uicontrol('Parent',    h.acquisitionFig.capture_panel, ...
    'Style',                'text',...
    'Units',                'normalized', ...
    'String',               h.acquisitionFig.thisCaptureString,...
    'BackgroundColor',      h.acquisitionFig.staticText_backgroundColour, ...
    'Position',             nowCapturing_dynamicText_position, ...
    'HorizontalAlignment',  'left', ...
    'FontSize',             10);
h.acquisitionFig.trialNumber_staticText = uicontrol('Parent',    h.acquisitionFig.capture_panel, ...
    'Style',                'text',...
    'Units',                'normalized', ...
    'String',               'Trial Number:   ',...
    'BackgroundColor',      h.acquisitionFig.staticText_backgroundColour, ...
    'Position',             trialNumber_staticText_position, ...
    'HorizontalAlignment',  'left', ...
    'FontSize',             10);
h.acquisitionFig.trialNumber_dynamicText = uicontrol('Parent',    h.acquisitionFig.capture_panel, ...
    'Style',                'text',...
    'Units',                'normalized', ...
    'String',               h.acquisitionFig.thisCaptureNumber,...
    'BackgroundColor',      h.acquisitionFig.staticText_backgroundColour, ...
    'Position',             trialNumber_dynamicText_position, ...
    'HorizontalAlignment',  'left', ...
    'FontSize',             10);
h.acquisitionFig.savingAs_staticText = uicontrol('Parent',    h.acquisitionFig.capture_panel, ...
    'Style',                'text',...
    'Units',                'normalized', ...
    'String',               'Saving As:   ',...
    'BackgroundColor',      h.acquisitionFig.staticText_backgroundColour, ...
    'Position',             savingAs_staticText_position, ...
    'HorizontalAlignment',  'left', ...
    'FontSize',             10);
h.acquisitionFig.savingAs_dynamicText = uicontrol('Parent',    h.acquisitionFig.capture_panel, ...
    'Style',                'text',...
    'Units',                'normalized', ...
    'String',               h.acquisitionFig.thisCaptureSavingAs,...
    'BackgroundColor',      h.acquisitionFig.staticText_backgroundColour, ...
    'Position',             savingAs_dynamicText_position, ...
    'HorizontalAlignment',  'left', ...
    'FontSize',             10);
h.acquisitionFig.nextTrial_staticText = uicontrol('Parent',    h.acquisitionFig.capture_panel, ...
    'Style',                'text',...
    'Units',                'normalized', ...
    'String',               'Next Trial',...
    'BackgroundColor',      h.acquisitionFig.staticText_backgroundColour, ...
    'Position',             nextTrial_staticText_position, ...
    'FontSize',             8);
h.acquisitionFig.previousTrial_staticText = uicontrol('Parent',    h.acquisitionFig.capture_panel, ...
    'Style',                'text',...
    'Units',                'normalized', ...
    'String',               'Previous Trial',...
    'BackgroundColor',      h.acquisitionFig.staticText_backgroundColour, ...
    'Position',             previousTrial_staticText_position, ...
    'FontSize',             8);    
h.acquisitionFig.nextTrial_button = uicontrol('Parent',    h.acquisitionFig.capture_panel, ...
    'unit',                 'normalized',...
    'style',                'pushbutton',...
    'BackgroundColor',      h.acquisitionFig.highlight_button_colour,...
    'string',               '>>>',...
    'FontSize',             buttonFont, ...
    'position',             nextTrial_button_position,...
    'enable',               'on', ...
    'callback',             @nextTrial_button_CallBack);
h.acquisitionFig.previousTrial_button = uicontrol('Parent',    h.acquisitionFig.capture_panel, ...
    'unit',                 'normalized',...
    'style',                'pushbutton',...
    'BackgroundColor',      h.acquisitionFig.leftright_colour,...
    'string',               '<<<',...
    'FontSize',             buttonFont, ...
    'position',             previousTrial_button_position,...
    'enable',               'off', ...
    'callback',             @previousTrial_button_CallBack);
h.acquisitionFig.start_button = uicontrol('Parent',    h.acquisitionFig.capture_panel, ...
    'unit',                 'normalized',...
    'style',                'pushbutton',...
    'BackgroundColor',      h.acquisitionFig.start_colour,...
    'string',               'START',...
    'FontSize',             buttonFont, ...
    'position',             start_button_position,...
    'enable',               'off', ...
    'callback',             @start_button_CallBack);
h.acquisitionFig.stop_button = uicontrol('Parent',    h.acquisitionFig.capture_panel, ...
    'unit',                 'normalized',...
    'style',                'pushbutton',...
    'BackgroundColor',      h.acquisitionFig.stop_colour,...
    'string',               'STOP',...
    'FontSize',             buttonFont, ...
    'position',             stop_button_position,...
    'enable',               'off', ...
    'callback',             @stop_button_CallBack);

% The knee pain section
h.acquisitionFig.kneePain_buttongroup = uibuttongroup('Parent',    h.acquisitionFig.capture_panel, ...
    'Visible',              'off',...
    'unit',                 'normalized',...
    'position',             kneePain_Bgroup_position, ...
    'SelectionChangedFcn',  @kneePain_radio_CallBack);
h.acquisitionFig.kneePain_radio(1) = uicontrol('Parent',    h.acquisitionFig.kneePain_buttongroup, ...
    'unit',                 'normalized',...
    'style',                'radiobutton',...
    'position',             kneePain_radio_position(1,:), ...
    'string',               'None', ...
    'value',                 1,...
    'enable',               'off');
h.acquisitionFig.kneePain_radio(2) = uicontrol('Parent',    h.acquisitionFig.kneePain_buttongroup, ...
    'unit',                 'normalized',...
    'style',                'radiobutton',...
    'position',             kneePain_radio_position(2,:), ...
    'string',               'Mild', ...
    'value',                 0,...
    'enable',               'off');
h.acquisitionFig.kneePain_radio(3) = uicontrol('Parent',    h.acquisitionFig.kneePain_buttongroup, ...
    'unit',                 'normalized',...
    'style',                'radiobutton',...
    'position',             kneePain_radio_position(3,:), ...
    'string',               'Moderate', ...
    'value',                 0,...
    'enable',               'off');
h.acquisitionFig.kneePain_radio(4) = uicontrol('Parent',    h.acquisitionFig.kneePain_buttongroup, ...
    'unit',                 'normalized',...
    'style',                'radiobutton',...
    'position',             kneePain_radio_position(4,:), ...
    'string',               'Severe', ...
    'value',                 0,...
    'enable',               'off');
h.acquisitionFig.kneePain_radio(5) = uicontrol('Parent',    h.acquisitionFig.kneePain_buttongroup, ...
    'unit',                 'normalized',...
    'style',                'radiobutton',...
    'position',             kneePain_radio_position(5,:), ...
    'string',               'Extreme', ...
    'value',                 0,...
    'enable',               'off');    
h.acquisitionFig.kneePain_buttongroup.Visible = 'on'; % turn visibility on now buttons are made.
h.acquisitionFig.kneePain_staticText = uicontrol('Parent',    h.acquisitionFig.capture_panel, ...
    'Style',                'text',...
    'Units',                'normalized', ...
    'String',               'Knee Pain',...
    'BackgroundColor',      h.acquisitionFig.staticText_backgroundColour, ...
    'Position',             kneePain_staticText_position, ...
    'FontSize',             14, ...
    'HorizontalAlignment',  'left');
h.acquisitionFig.kneePainInfo_staticText = uicontrol('Parent',    h.acquisitionFig.capture_panel, ...
    'Style',                'text',...
    'Units',                'normalized', ...
    'String',               'After each trial, enter knee pain level with pushbutton to the right',...
    'BackgroundColor',      h.acquisitionFig.staticText_backgroundColour, ...
    'Position',             kneePainInfo_staticText_position, ...
    'FontSize',             8, ...
    'HorizontalAlignment',  'left');
h.acquisitionFig.kneePain_storeSelection_button = uicontrol('Parent',    h.acquisitionFig.capture_panel, ...
    'Style',                'pushbutton',...
    'Units',                'normalized', ...
    'String',               'Enter knee pain value',...
    'BackgroundColor',      h.acquisitionFig.staticText_backgroundColour, ...
    'Position',             kneePain_storeSelection_button_position, ...
    'FontSize',             8, ...
    'callback',             @kneePain_storeSelection_CallBack,...
    'enable',               'off');

guidata(acquisitionFig,h.acquisitionFig);

end

%% CALLBACKS
function comment_CallBack(text_object, ~, ~)
h.acquisitionFig = guidata(text_object);
set(h.acquisitionFig.comment_updateButton, 'Enable', 'on');
guidata(text_object, h.acquisitionFig) % update handles
end
%%
function comment_updateButton_CallBack(pushButton_object, ~, ~)
h.acquisitionFig = guidata(pushButton_object);
h.acquisitionFig.commentString = h.acquisitionFig.comment_editField.String;
set(h.acquisitionFig.comment_updateButton, 'Enable', 'on');

% save/overwrite the Comments.txt file
fileID = fopen([h.acquisitionFig.pathList.session_dir,'\Comments.txt'],'w');
fprintf(fileID, '~~~\r\nSessionID: \r\n%s\r\n~~~\r\n', h.acquisitionFig.sessionString);
fprintf(fileID, 'Comments: \r\n%s\r\n~~~', h.acquisitionFig.commentString);
fclose(fileID);

guidata(pushButton_object, h.acquisitionFig) % update handles
end
%%
function nextTrial_button_CallBack(pushButton_object, ~, ~)
h.acquisitionFig = guidata(pushButton_object);

% need to have a counter here for the completed cell array
h.acquisitionFig.trialCellArray_completed_counter = h.acquisitionFig.trialCellArray_completed_counter + 1;
counter = h.acquisitionFig.trialCellArray_completed_counter;
set(h.acquisitionFig.nextTrial_button, 'BackgroundColor', h.acquisitionFig.leftright_colour)

% disable knee pain field
set(h.acquisitionFig.kneePain_storeSelection_button, 'enable', 'off');
for i = 1:5
   set(h.acquisitionFig.kneePain_radio(i), 'enable', 'off');
end

if counter < length(h.acquisitionFig.trialCellArray) + 1
    % get next capture info
    h.acquisitionFig.thisCaptureString = h.acquisitionFig.trialCellArray_updated(1,1); % get the next trial from top of trial_list_updated
    h.acquisitionFig.thisCaptureNumber = num2str(h.acquisitionFig.trialCellArray_updated{1,4}, '%02.f'); % get the capture number
    h.acquisitionFig.thisCaptureSavingAs = [h.acquisitionFig.trialCellArray_updated{1,2},'_',h.acquisitionFig.thisCaptureNumber]; % generate the Saving As string
    % update the fields
    set(h.acquisitionFig.nowCapturing_dynamicText, 'String', h.acquisitionFig.thisCaptureString);
    set(h.acquisitionFig.trialNumber_dynamicText, 'String', h.acquisitionFig.thisCaptureNumber);
    set(h.acquisitionFig.savingAs_dynamicText, 'String', h.acquisitionFig.thisCaptureSavingAs);
    
    % remove the current capture from the trial list panel and add to completed
    % list
    h.acquisitionFig.trialCellArray_completed(h.acquisitionFig.trialCellArray_updated{1,5},:) = h.acquisitionFig.trialCellArray_updated(1,:); % add the top of trial list to completed array
    h.acquisitionFig.trialCellArray_updated(1,:) = [];  % remove the top element of the trial list
    set(h.acquisitionFig.trial_list_text, 'String', h.acquisitionFig.trialCellArray_updated(:,1)); % update trial list
    set(h.acquisitionFig.start_button, 'enable', 'on'); % enable start button
    set(h.acquisitionFig.previousTrial_button, 'enable', 'on'); % enable previous trial button
    
    % once you reach end of the trial list, disable the next trial button,
    % highlight previous trial button
    if counter == length(h.acquisitionFig.trialCellArray)
        set(h.acquisitionFig.nextTrial_button, 'enable', 'off');
        set(h.acquisitionFig.previousTrial_button, 'BackgroundColor', h.acquisitionFig.highlight_button_colour)
    end
end
guidata(pushButton_object, h.acquisitionFig) % update handles
end
%%
function previousTrial_button_CallBack(pushButton_object, ~, ~)
h.acquisitionFig = guidata(pushButton_object);

% create counter
counter = h.acquisitionFig.trialCellArray_completed_counter;
set(h.acquisitionFig.previousTrial_button, 'BackgroundColor', h.acquisitionFig.leftright_colour)

% disable knee pain field
set(h.acquisitionFig.kneePain_storeSelection_button, 'enable', 'off');
for i = 1:5
   set(h.acquisitionFig.kneePain_radio(i), 'enable', 'off');
end

if counter ~= 0
    % the row to shift should be one with largest value in 5 collumn
    shift_row_num = max(cell2mat(h.acquisitionFig.trialCellArray_completed(:,5)));
    
    if counter < length(h.acquisitionFig.trialCellArray)+1
        set(h.acquisitionFig.nextTrial_button, 'enable', 'on');
        set(h.acquisitionFig.nextTrial_button, 'BackgroundColor', h.acquisitionFig.leftright_colour);
    end
    
    % update the trial list
    h.acquisitionFig.trialCellArray_updated = [h.acquisitionFig.trialCellArray_completed(shift_row_num,:); h.acquisitionFig.trialCellArray_updated];
    set(h.acquisitionFig.trial_list_text, 'String', h.acquisitionFig.trialCellArray_updated(:,1));
    h.acquisitionFig.trialCellArray_completed(shift_row_num,:) = []; % then make the shifted row empty
    
    % decrease the counter
    counter = counter - 1;
    h.acquisitionFig.trialCellArray_completed_counter = counter;
    
    % once get back to zero, disable previous button, highlight next trial
    % button
    if counter == 0
        set(h.acquisitionFig.previousTrial_button, 'enable', 'off');
        set(h.acquisitionFig.start_button, 'enable', 'off');
        set(h.acquisitionFig.nextTrial_button, 'enable', 'on');
        set(h.acquisitionFig.nextTrial_button, 'BackgroundColor', h.acquisitionFig.highlight_button_colour)
        % update the fields back to starting values
        set(h.acquisitionFig.nowCapturing_dynamicText, 'String', '<Hit Next Trial button>');
        set(h.acquisitionFig.trialNumber_dynamicText, 'String', '00');
        set(h.acquisitionFig.savingAs_dynamicText, 'String', '');
    else
        % update capture info
        h.acquisitionFig.thisCaptureString = h.acquisitionFig.trialCellArray_completed(shift_row_num-1,1); % get the next trial from top of trial_list_updated
        h.acquisitionFig.thisCaptureNumber = num2str(h.acquisitionFig.trialCellArray_completed{shift_row_num-1,4}, '%02.f'); % get the capture number
        h.acquisitionFig.thisCaptureSavingAs = [h.acquisitionFig.trialCellArray_completed{shift_row_num-1,2},'_',h.acquisitionFig.thisCaptureNumber]; % generate the Saving As string
        % update the fields
        set(h.acquisitionFig.nowCapturing_dynamicText, 'String', h.acquisitionFig.thisCaptureString);
        set(h.acquisitionFig.trialNumber_dynamicText, 'String', h.acquisitionFig.thisCaptureNumber);
        set(h.acquisitionFig.savingAs_dynamicText, 'String', h.acquisitionFig.thisCaptureSavingAs);
    end
else
    % if back to start of trial list, disable previous button, highlight
    % next trial button
    set(h.acquisitionFig.previousTrial_button, 'enable', 'off');
    set(h.acquisitionFig.nextTrial_button, 'BackgroundColor', h.acquisitionFig.highlight_button_colour)
end
guidata(pushButton_object, h.acquisitionFig) % update handles
end
%%
function start_button_CallBack(pushButton_object, ~, ~)
h.acquisitionFig = guidata(pushButton_object);

% disble all buttons including start
set(h.acquisitionFig.previousTrial_button, 'enable', 'off');
set(h.acquisitionFig.start_button, 'enable', 'off');
set(h.acquisitionFig.nextTrial_button, 'enable', 'off');
set(h.acquisitionFig.kneePain_storeSelection_button, 'enable', 'off');
for i = 1:5
   set(h.acquisitionFig.kneePain_radio(i), 'enable', 'off');
end

% enable stop button
set(h.acquisitionFig.stop_button, 'enable', 'on');

% Update Nexus packet counter
h.acquisitionFig.nexusPacketID = h.acquisitionFig.nexusPacketID + 1; 
% Generate Nexus start message
nexusStart =['<?xml version="1.0" encoding="UTF-8" standalone="no" ?>'...
    '<CaptureStart>'...
    '<Name VALUE="',            h.acquisitionFig.thisCaptureSavingAs,'"/>'...
    '<Notes VALUE=""/><Description VALUE=""/>'...
    '<DatabasePath VALUE="',    h.acquisitionFig.pathList.session_dir,'"/>'...
    '<Delay VALUE="0"/>'...
    '<PacketID VALUE="',        num2str(h.acquisitionFig.nexusPacketID),'"/>'...
    '</CaptureStart>'];
nexusStart = pad(nexusStart,500); % pad all Nexus messages to same length
% send the start packet
h.acquisitionFig.nexusUDP(int8(nexusStart));

guidata(pushButton_object, h.acquisitionFig) % update handles
end
%%
function stop_button_CallBack(pushButton_object, ~, ~)
h.acquisitionFig = guidata(pushButton_object);

% % counter for trial increment
% counter = h.acquisitionFig.trialCellArray_completed_counter;

% update Nexus packet counter
h.acquisitionFig.nexusPacketID = h.acquisitionFig.nexusPacketID + 1;
% generate Nexus stop message
nexusStop = ['<?xml version="1.0" encoding="UTF-8" standalone="no" ?>'...
    '<CaptureStop RESULT="SUCCESS">'...
    '<Name VALUE="',            h.acquisitionFig.thisCaptureSavingAs,'"/>'...
    '<DatabasePath VALUE="',    h.acquisitionFig.pathList.session_dir,'"/>'...
    '<Delay VALUE="0"/>'...
    '<PacketID VALUE="',        num2str(h.acquisitionFig.nexusPacketID),'"/>'...
    '</CaptureStop>'];
nexusStop = pad(nexusStop,500);
% nexus complete message
h.acquisitionFig.nexusPacketID = h.acquisitionFig.nexusPacketID + 1;
nexusComplete = ['<?xml version="1.0" encoding="UTF-8" standalone="no" ?>'...
    '<CaptureComplete>'...
    '<Name VALUE="',            h.acquisitionFig.thisCaptureSavingAs,'"/>'...
    '<DatabasePath VALUE="',    h.acquisitionFig.pathList.session_dir,'"/>'...
    '<PacketID VALUE="',        num2str(h.acquisitionFig.nexusPacketID),'"/>'...
    '</CaptureComplete>'];
nexusComplete = pad(nexusComplete,500);
% send the stop packets
h.acquisitionFig.nexusUDP(int8(nexusStop));
h.acquisitionFig.nexusUDP(int8(nexusComplete));

% disable stop button
set(h.acquisitionFig.stop_button, 'enable', 'off');

% enable knee pain buttons
set(h.acquisitionFig.kneePain_storeSelection_button, 'enable', 'on');
for i = 1:5
   set(h.acquisitionFig.kneePain_radio(i), 'enable', 'on');
end
% set knee pain pushbutton to orange
set(h.acquisitionFig.kneePain_storeSelection_button, ...
    'BackgroundColor', h.acquisitionFig.highlight_button_colour);

% store this value before updateing counters to write to csv
h.acquisitionFig.saveTrial = h.acquisitionFig.thisCaptureSavingAs;

% update trial counters
add_trial_num_to = max(cell2mat(h.acquisitionFig.trialCellArray_completed(:,5)));
h.acquisitionFig.trialCellArray_completed{add_trial_num_to,4} = h.acquisitionFig.trialCellArray_completed{add_trial_num_to,4} + 1;
h.acquisitionFig.thisCaptureNumber = num2str(h.acquisitionFig.trialCellArray_completed{add_trial_num_to,4}, '%02.f');
h.acquisitionFig.thisCaptureSavingAs = [h.acquisitionFig.trialCellArray_completed{add_trial_num_to,2},'_',h.acquisitionFig.thisCaptureNumber]; % generate the Saving As string
set(h.acquisitionFig.trialNumber_dynamicText, 'String', h.acquisitionFig.thisCaptureNumber);
set(h.acquisitionFig.savingAs_dynamicText, 'String', h.acquisitionFig.thisCaptureSavingAs);

guidata(pushButton_object, h.acquisitionFig) % update handles
end
%%
function kneePain_radio_CallBack(kneePain_radioButton_object, event, ~)
h.acquisitionFig = guidata(kneePain_radioButton_object);
h.acquisitionFig.kneePain_currentValue = event.NewValue.String; % store current selection
guidata(kneePain_radioButton_object, h.acquisitionFig) % update handles
end
%%
function kneePain_storeSelection_CallBack(kneePain_pushbutton_object, ~, ~)
h.acquisitionFig = guidata(kneePain_pushbutton_object);

% store the value to csv but first check if need to overwrite the current 
% knee pain score
oldCsv = readcell(h.acquisitionFig.kneePain_csvFullFile);
if strcmp(oldCsv{end,1},h.acquisitionFig.saveTrial) == 1     % check if user wants to overwtrite last entered knee pain score
    oldCsv{end,2} = h.acquisitionFig.kneePain_currentValue;  % if so, update the value
    writecell(oldCsv, h.acquisitionFig.kneePain_csvFullFile) % write to csv
else % if it's a new trial, append to new row
    h.acquisitionFig.kneePain_cell = [h.acquisitionFig.kneePain_cell;{h.acquisitionFig.saveTrial, h.acquisitionFig.kneePain_currentValue}];
    writecell(h.acquisitionFig.kneePain_cell,h.acquisitionFig.kneePain_csvFullFile)
end

% counter for trial increment
counter = h.acquisitionFig.trialCellArray_completed_counter;
set(h.acquisitionFig.kneePain_storeSelection_button, ...
    'BackgroundColor', h.acquisitionFig.staticText_backgroundColour);
% enable all other buttons
if counter > 0 && counter < length(h.acquisitionFig.trialCellArray) + 1
    set(h.acquisitionFig.nextTrial_button, 'enable', 'on');
    set(h.acquisitionFig.start_button, 'enable', 'on');
    set(h.acquisitionFig.previousTrial_button, 'enable', 'on');
    if counter == length(h.acquisitionFig.trialCellArray) % no more trials so disable next trial.
        set(h.acquisitionFig.nextTrial_button, 'enable', 'off');
        set(h.acquisitionFig.previousTrial_button, 'enable', 'on');
        set(h.acquisitionFig.start_button, 'enable', 'on');
    end
end

% if at start of trial list, only next trial button can be pressed
if counter == 0    
    set(h.acquisitionFig.previousTrial_button, 'enable', 'off');
    set(h.acquisitionFig.start_button, 'enable', 'off');
    set(h.acquisitionFig.nextTrial_button, 'enable', 'on');
end

guidata(kneePain_pushbutton_object, h.acquisitionFig) % update handles
end