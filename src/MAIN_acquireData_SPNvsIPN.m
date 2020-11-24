%% Main script for data acquisition 

% ----------------------------------------------------------------------- %
% Major Revisions:
%   - 19/11/19: - Created
%   - 21/11/19: - Addded participant_info_GUI.m
%   - 22/11/19: - makeDirectories.m working for Healthy stream
%               - created getDateTime.m for .enf files
%               - makeDirectories.m working for clinical stream
%               - created makeNexusEnfs.m for generating Nexus enf files
%   - 06/12/19: - generate_trial_list2.m working
%               - getIPaddress.m working
%               - matlab2nexus_acquisitionInterface.m trial counters working
%   - 17/12/19: - matlab2nexus_acquisitionInterface.m knee pain radio buttons
%               - and write to csv file working
%   - 20/12/19: - incrementing nexuspacketID for multiple sessions
%   - 29/01/20: - static capture only 50 frames
%   - 21/10/20: - updated trial list
%   - 22/10/20: - add in extra warnings for zeroing FPs after step test
%   - 24/11/20: - add DNC option for tests not captured
%               - add highlight for this capture string
%               - added diary for command window logging
%               
% ----------------------------------------------------------------------- %
% Simnon Thwaites
% simon.thwaites@adelaide.edu.au
% simon.thwaites.biomech@gmail.com
% ----------------------------------------------------------------------- %
% Vicon Nexus:
%   - In 'auto start/stop capture', ensure 'advanced' is selected, and 
%     trigger via netweork connection.
%   - Set Nexus to 'recieve' UDP message and listen over all IP addresses.
%   - Set Nexus Port as 6610
%   - Ensure Nexus is 'armed' prior to capture.
% 
% UDP msg:
% Nexus requires an xml string to start/stop a capture. Additionally, you 
% can dictate the trial name, and where in the database it should be saved. 
% Note, the PacketID VALUE must increment by one every time a UDP packet 
% is sent to Nexus, Nexus will not accept a repeated command.
% ----------------------------------------------------------------------- %
close all; close('all','hidden');  % Close figure opened by last run
clc;

machine_ip = getIPaddress();    % check which machine

if  strcmp(machine_ip, '10.90.20.114')
    % work desktop machine
    cd('C:\Users\a1194788\Box\01. PhD\10. Git\Matlab2Nexus_Trigger\src\')
elseif strcmp(machine_ip, '10.90.14.67')
    % gait lab machine
    cd('C:\Thwaites PhD\Matlab2Nexus_Trigger-Knee-Pain\src\')
end

nexusPacketID = 0; % initialise for incrementing UDP packets (required for Nexus)
anotherCapture = true; 

while anotherCapture
    % participant and session information
    [sessionString, affectedSide]= participant_info_GUI();
    
    % check/male directories
    pathList = makeDirectories(sessionString);
    
    % generate trial list
    trial_list = generate_trial_list();
    
    % warnings to set Vicon Nexus database
    w2 = warndlg('Nexus ECLIPSE DATABASE correct and ARMED for capture?','Vicon Nexus Check!');
    uiwait(w2)
    disp('Nexus database correct and armed for capture.')
    
    w1 = warndlg('FORCE PLATFORMS and EMGs ZEROED?','Zero Check!');
    uiwait(w1)
    disp('Force platforms and EMGs zeroed.')
    
    % launch acquisition interface
    disp('Launching Acquisition Interface ...')
    [endCaptureState, nexusPacketID_return] = matlab2nexus_acquisitionInterface(sessionString, pathList, trial_list, nexusPacketID, affectedSide);
    drawnow()
    switch endCaptureState
        case 1 % another capture
            % update packet ID input
            nexusPacketID = nexusPacketID_return;
            anotherCapture = true;
            disp('Capturing another session.')
            disp('----------')
            
            diary off
            
        case 2 % finish session and run analysis
            anotherCapture = false;
            
        case 3 % finish session
            anotherCapture = false;
            disp('Session finished.')
            disp('----------')
            diary off
            
        otherwise
            disp('neither')
            
    end
end

if anotherCapture == true && endCaptureState == 2 
    
    % run analysis for last session
    
end
    
