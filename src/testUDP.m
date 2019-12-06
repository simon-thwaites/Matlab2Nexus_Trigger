% test udp
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
%-------------------------------------------------------------------------%


h.acquisitionFig.pathList = pathList;

%% initialise
h.acquisitionFig.IPaddress = '255.255.255.255';      % broadcast over everything
h.acquisitionFig.Port = 6610;
h.acquisitionFig.nexusPacketID = 0;    % for incrementing UDP packets (required for Nexus)
h.acquisitionFig.viconTrial = 0;
h.acquisitionFig.nexusUDP = dsp.UDPSender('RemoteIPAddress',   h.acquisitionFig.IPaddress,...
                           'RemoteIPPort',      h.acquisitionFig.Port,...    
                           'LocalIPPortSource', 'Property',...
                           'LocalIPPort',       31);
%% send start
h.acquisitionFig.nexusPacketID = h.acquisitionFig.nexusPacketID + 1;
h.acquisitionFig.viconTrial = h.acquisitionFig.viconTrial + 1;

% ~~~~~~~~~~~~~delete this
h.acquisitionFig.thisCaptureSavingAs = ['test',num2str(h.acquisitionFig.viconTrial)];

% Nexus start message
nexusStart =['<?xml version="1.0" encoding="UTF-8" standalone="no" ?>'...
    '<CaptureStart>'...
    '<Name VALUE="',            h.acquisitionFig.thisCaptureSavingAs,'"/>'...
    '<Notes VALUE=""/><Description VALUE=""/>'...
    '<DatabasePath VALUE="',    h.acquisitionFig.pathList.session_dir,'"/>'...
    '<Delay VALUE="0"/>'...
    '<PacketID VALUE="',        num2str(h.acquisitionFig.nexusPacketID),'"/>'...
    '</CaptureStart>'];
nexusStart = pad(nexusStart,500); % pad all Nexus messages to same length

h.acquisitionFig.nexusUDP(int8(nexusStart));


%% send stop
h.acquisitionFig.nexusPacketID = h.acquisitionFig.nexusPacketID + 1;

% nexus stop message
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

h.acquisitionFig.nexusUDP(int8(nexusStop));
h.acquisitionFig.nexusUDP(int8(nexusComplete));