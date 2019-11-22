function pathList = makeDirectories(sessionString)
% check and make directories based on sessionString input
% output directory ist as pathList

% create cell strings for Nexus .enf file creation
% nexusEnf.classification = { '[Node Information]' ; ...
%                             'TYPE=PATIENT_CLASSIFICATION' ; ...
%                             '[PATIENT_CLASSIFICATION_INFO]' ; ...
%                             'CREATIONDATEANDTIME='};
% nexusEnf.patient =  { '[Node Information]' ; ...
%                       'TYPE=SUBJECT' ; ...
%                       '[SUBJECT_INFO]' ; ...  
%                       'CREATIONDATEANDTIME='};
% nexusEnf.session =  { '[Node Information]' ; ...
%                       'TYPE=SESSION' ; ...
%                       '[SESSION_INFO]' ; ...
%                       'CREATIONDATEANDTIME='};
                  
% get info from session string
% cohortString  =  sessionString(1:2);
% idString = sessionString(3:5);
% cohortIDstring = sessionString(1:5);

% currently in src, move up one
pathList.src_dir = pwd;
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

cd(pathList.src_dir)
pathList = makeNexusEnfs(pathList,sessionString);

% % check healthy or clinical cohort
% cohortStringCheck = strcmp(cohortString,'HE');
% 
% % Check Healthy diretory exists > move in
% if cohortStringCheck == 1 
%     cohort = 'Healthy';
%     if ~exist([ pwd , '\' , cohort ],'dir')
%     mkdir([ pwd , '\' , cohort ])
%     end
%     cd([ pwd , '\' , cohort ])
%     pathList.cohort_dir = pwd;
%     
%     % check patient classifaction (healthy) .enf file exists
%     if ~exist([ cohort , '.Patient Classification.enf'], 'file')
%         
%         % date and time paramaters to write to the .enf file
%         cd(pathList.src_dir);
%         creationString = getDateTime();
%         cd(pathList.cohort_dir);
%         
%         % cat the date and time paramters to the CREATIONANDTIME entry
%         nexusEnf.classification{4} = [nexusEnf.classification{4},creationString];
%         FID = fopen([ cohort , '.Patient Classification.enf' ], 'w'); % write to the file
%         fprintf(FID, '%s\r\n',nexusEnf.classification{:}); % \r = carriage return and \n line feed 
%                                                            % (CR and LF markers in notepad++)
%         fclose(FID);
%     end
%     
%     % now check ID string and make directory
%     if ~isnan(str2double(idString))
%         if ~exist([ pwd , '\' , cohortIDstring ],'dir')
%             mkdir([ pwd , '\' , cohortIDstring ])
%         end
%     else
%         error('Participant ID not valid');
%     end
%     
%     % move into ID directory and check/create patient claddification.enf
%     cd([ pwd ,  '\' , cohortIDstring ]);
%     pathList.particpantID_dir = pwd;
%     
%     % check for pateint.enf
%     if ~exist([cohortIDstring,'.Patient.enf'],'file')
%         % date and time paramaters to write to the .enf file
%         cd(pathList.src_dir);
%         creationString = getDateTime();
%         cd(pathList.particpantID_dir);
%         
%         % cat the date and time paramters to the CREATIONANDTIME entry
%         nexusEnf.patient{4} = [nexusEnf.patient{4},creationString];
%         FID = fopen([cohortIDstring,'.Patient.enf'], 'w');
%         fprintf(FID, '%s\r\n',nexusEnf.patient{:}); 
%         fclose(FID);
%     end
%     
%     % now check if there is a session for the healthy participant
%     if ~exist([ pwd , '\' , 'New Session' ],'dir')
%         mkdir([ pwd , '\' , 'New Session' ])
%     end
%     
%     cd([ pwd , '\' , 'New Session' ]);
%     pathList.session_dir = pwd;
%     
%     % check for New Session.enf
%     if ~exist('New Session.Session.enf','file')
%         % date and time paramaters to write to the .enf file
%         cd(pathList.src_dir);
%         creationString = getDateTime();
%         cd(pathList.session_dir);
%         
%         % cat the date and time paramters to the CREATIONANDTIME entry
%         nexusEnf.session{4} = [nexusEnf.session{4},creationString];
%         FID = fopen('New Session.Session.enf', 'w');
%         fprintf(FID, '%s\r\n',nexusEnf.session{:});
%         fclose(FID);
%     end
%    
%     
% % check Clinical directory exists > move in
% else
%     cohortStringCheck = strcmp(cohortString,'CL');
%     if cohortStringCheck == 1 % clinical
%         if ~exist([ pwd , '\Clinical' ],'dir')
%             mkdir([ pwd , '\Clinical' ])
%         end
%         cd([pwd , '\Clinical' ])
%         pathList.clinical = pwd;
%         
%         % check patient classifaction (healthy) .enf file exists
%     if ~exist('Clinical.Patient Classification.enf', 'file')
%         
%         % date and time paramaters to write to the .enf file
%         cd(pathList.src_dir);
%         creationString = getDateTime();
%         cd(pathList.cohort_dir);
%         
%         % cat the date and time paramters to the CREATIONANDTIME entry
%         nexusEnf.classification{4} = [nexusEnf.classification{4},creationString];
%         FID = fopen('Clinical.Patient Classification.enf', 'w'); % write to the file
%         nexusEnf.classification(:)
%         fprintf(FID, '%s\r\n',nexusEnf.classification{:}); % \r = carriage return and \n line feed 
%                                                            % (CR and LF markers in notepad++)
%         fclose(FID);
%     end
%     
%     % now check ID string and make directory
%     if ~isnan(str2double(idString))
%         if ~exist([ pwd , '\' , cohortIDstring ],'dir')
%             mkdir([ pwd , '\' , cohortIDstring ])
%         end
%     else
%         error('Participant ID not valid');
%     end
%     
%     % move into ID directory and check/create patient claddification.enf
%     cd([ pwd ,  '\' , cohortIDstring ]);
%     pathList.particpantID_dir = pwd;
%     
%     % check for pateint.enf
%     if ~exist([cohortIDstring,'.Patient.enf'],'file')
%         % date and time paramaters to write to the .enf file
%         cd(pathList.src_dir);
%         creationString = getDateTime();
%         cd(pathList.particpantID_dir);
%         
%         % cat the date and time paramters to the CREATIONANDTIME entry
%         nexusEnf.patient{4} = [nexusEnf.patient{4},creationString];
%         nexusEnf.patient(:)
%         FID = fopen([cohortIDstring,'.Patient.enf'], 'w');
%         fprintf(FID, '%s\r\n',nexusEnf.patient{:}); 
%         fclose(FID);
%     end
%     end
% end
end
