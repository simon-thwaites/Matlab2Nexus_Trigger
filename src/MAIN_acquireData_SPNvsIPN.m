%% Main script for data acquisition 

% ----------------------------------------------------------------------- %
% Major Revisions:
%   - 19/11/19: Created
%   - 21/11/19: Addded participant_info_GUI.m
%   - 22/11/19: makeDirectories.m working for Healthy stream
%               created getDateTime.m for .enf files
%               makeDirectories.m working for clinical stream
%               created makeNexusEnfs.m for generating Nexus enf files
%   - 06/12/19: generate_trial_list2.m working
%               getIPaddress.m working
%               matlab2nexus_acquisitionInterface.m trial counters working
%               
% ----------------------------------------------------------------------- %
% Simnon Thwaites
% simonthwaites1991@gmail.com
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

% participant and session information
sessionString = participant_info_GUI();

% check/male directories
pathList = makeDirectories(sessionString);

% generate trial list
trial_list = generate_trial_list2();

%% launch acquisition interface
matlab2nexus_acquisitionInterface(sessionString, pathList, trial_list)
