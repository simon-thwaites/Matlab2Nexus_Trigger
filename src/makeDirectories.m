function pathList = makeDirectories(sessionString)
% check and make directories based on sessionString input
% output directory ist as pathList

% create cell strings for Nexus .enf file creation
nexusEnf.classification = { '[Node Information]' ; ...
                            'TYPE=PATIENT_CLASSIFICATION' ; ...
                            '[PATIENT_CLASSIFICATION_INFO]' ; ...
                            'CREATIONDATEANDTIME='};
nexusEnf.patient =  { '[Node Information]' ; ...
                      'TYPE=SUBJECT' ; ...
                      '[SUBJECT_INFO]' ; ...  
                      'CREATIONDATEANDTIME='};
nexusEnf.session =  { '[Node Information]' ; ...
                      'TYPE=SESSION' ; ...
                      '[SESSION_INFO]' ; ...
                      'CREATIONDATEANDTIME='};

% currently in src, move up one
WD = pwd;
cd ..

% make sure data directory exists
if ~exist([pwd,'\data'],'dir')
    mkdir([pwd,'\data'])
end

% move into data directory
cd([ pwd , '\data' ])
pathList.data_dir = pwd;

% check/make Vicon Nexus folder
if ~exist([pwd,'\Vicon Nexus'],'dir')
    mkdir([pwd,'\Vicon Nexus'])
end

% move to Vicon Nexus dir
cd([ pwd , '\Vicon Nexus' ])
pathList.viconNexus_dir = pwd;

% check eclipse database .enf file exists
if ~exist('Vicon Nexus.enf', 'file')
    FID = fopen('Vicon Nexus.enf', 'w');
    fclose(FID);
end

% check healthy or clinical
cohortString  =  sessionString(1:2);
cohortStringCheck = strcmp(cohortString,'HE');

% Check Healthy diretory exists > move in
if cohortStringCheck == 1 
    if ~exist([ pwd , '\Healthy' ],'dir')
    mkdir([ pwd , '\Healthy' ])
    end
    cd([ pwd , '\Healthy' ])
    pathList.healthy_dir = pwd;
    
    % check patient classifaction (healthy) .enf file exists
    if ~exist('Healthy.enf', 'file')
        cs = cellstr(nexusEnf.classification);
        FID = fopen('Healthy.txt', 'w');
        fprintf(FID, '%s\r\n',cs{:});
        fclose(FID);
    end
    
    % now check ID string and make directory
    idString = sessionString(3:5);
    if ~isnan(str2double(idString))
        if ~exist([ pwd , '\' , sessionString(1:5) ],'dir')
            mkdir([ pwd , '\' , sessionString(1:5) ])
        end
    else
        error('Participant ID not valid');
    end
    
    % move into ID directory and check/create patient claddification.enf
    cd([ pwd ,  '\' , sessionString(1:5) ]);
    pathList.particpantID_dir = pwd;
    
    
    
    
   
    
% check Clinical directory exists > move in
else
    cohortStringCheck = strcmp(cohortString,'CL');
    if cohortStringCheck == 1 % clinical
        if ~exist([ pwd , '\Clinical' ],'dir')
            mkdir([ pwd , '\Clinical' ])
        end
        cd([pwd , '\Clinical' ])
        pathList.clinical = pwd;
    end
end
end
