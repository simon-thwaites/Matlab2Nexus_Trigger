function pathList = makeDirectories(sessionString)
%% check and make directories based on sessionString input
% output directories as pathList
% ----------------------------------------------------------------------- %
% Major Revisions:
%   - 21/11/19: created, working for healthy stream
%   - 22/11/19: working for both clinical and healthy streams
% ----------------------------------------------------------------------- %
% Simnon Thwaites
% simonthwaites1991@gmail.com
% ----------------------------------------------------------------------- %

% currently in src, move up one
pathList.src_dir = pwd;
cd ..

% make sure data directory exists
% if ~exist([pwd,'\data'],'dir')
%     mkdir([pwd,'\data'])
% end

if ~isfolder([pwd,'\data'])
    mkdir([pwd,'\data'])
end

% move into data directory
cd([ pwd , '\data' ])
pathList.data_dir = pwd;

% check/make Vicon Nexus folder
% if ~exist([pwd,'\Vicon Nexus'],'dir')
%     mkdir([pwd,'\Vicon Nexus'])
% end

if ~isfolder([pwd,'\Vicon Nexus'])
    mkdir([pwd,'\Vicon Nexus'])
end

% move to Vicon Nexus dir
cd([ pwd , '\Vicon Nexus' ])
pathList.viconNexus_dir = pwd;

% check eclipse database .enf file exists
% if ~exist('Vicon Nexus.enf', 'file')
%     FID = fopen('Vicon Nexus.enf', 'w');
%     fclose(FID);
% end

if ~isfile('Vicon Nexus.enf')
    FID = fopen('Vicon Nexus.enf', 'w');
    fclose(FID);
end

cd(pathList.src_dir)
pathList = makeNexusEnfs(pathList,sessionString);
end
