function pathList = makeNexusEnfs(pathList,sessionString)
% generate Nexus enf files for patient classification, patient, session.

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
                  
% get info from session string
cohortString  =  sessionString(1:2);
idString = sessionString(3:5);
cohortIDstring = sessionString(1:5);                  

cd(pathList.viconNexus_dir)
cohortStringCheck = strcmp(cohortString,'HE');
if cohortStringCheck == 1 
    cohort = 'Healthy';
    healthy = 1;
else
    cohortStringCheck = strcmp(cohortString,'CL');
    if cohortStringCheck == 1
        cohort = 'Clinical';
        healthy = 0;
    end
end

if ~exist([ pwd , '\' , cohort ],'dir')
    mkdir([ pwd , '\' , cohort ])
end
cd([ pwd , '\' , cohort ])
pathList.cohort_dir = pwd;

% check patient classifaction .enf file exists
if ~exist([ cohort , '.Patient Classification.enf'], 'file')
    
    % date and time paramaters to write to the .enf file
    cd(pathList.src_dir);
    creationString = getDateTime();
    cd(pathList.cohort_dir);
    
    % cat the date and time paramters to the CREATIONANDTIME entry
    nexusEnf.classification{4} = [ nexusEnf.classification{4} , creationString ];
    FID = fopen([ cohort , '.Patient Classification.enf' ], 'w'); % write to the file
    fprintf( FID, '%s\r\n' , nexusEnf.classification{:} ); % \r = carriage return and \n line feed
                                                       % (CR and LF markers in notepad++)
    fclose(FID);
end

% now check ID string and make directory
if ~isnan(str2double(idString))
    if ~exist([ pwd , '\' , cohortIDstring ],'dir')
        mkdir([ pwd , '\' , cohortIDstring ])
    end
else
    error('Participant ID not valid');
end

% move into ID directory and check/create patient classification.enf
cd([ pwd ,  '\' , cohortIDstring ]);
pathList.particpantID_dir = pwd;

% check for pateint.enf
if ~exist([ cohortIDstring , '.Patient.enf' ],'file')
    % date and time paramaters to write to the .enf file
    cd(pathList.src_dir);
    creationString = getDateTime();
    cd(pathList.particpantID_dir);
    
    % cat the date and time paramters to the CREATIONANDTIME entry
    nexusEnf.patient{4} = [ nexusEnf.patient{4} , creationString ];
    FID = fopen([ cohortIDstring , '.Patient.enf' ], 'w');
    fprintf( FID, '%s\r\n' , nexusEnf.patient{:} );
    fclose(FID);
end

% using try block
% if try to access the 6th element of sessionString returns error, cohort
% must be healthy
% try
%     nexusSessionString = sessionString(6:end)
% catch
%     nexusSessionString = 'New Session'
% end

% if nexusSessionString(7:end) is empty, then must be healthy
% if healthy, only one session (New Session)
% if clinical take rest of string as session name

nexusSessionString = sessionString(7:end);
if isempty(nexusSessionString)
    nexusSessionString = 'New Session';
end

% now check if there is a session for the healthy participant
if ~exist([ pwd , '\' , nexusSessionString ],'dir')
    mkdir([ pwd , '\' , nexusSessionString ])
end

cd([ pwd , '\' , nexusSessionString ]);
pathList.session_dir = pwd;

if ~exist([nexusSessionString,'.Session.enf'],'file')
    % date and time paramaters to write to the .enf file
    cd(pathList.src_dir);
    creationString = getDateTime();
    cd(pathList.session_dir);
    
    % cat the date and time paramters to the CREATIONANDTIME entry
    nexusEnf.session{4} = [ nexusEnf.session{4} , creationString ];
    FID = fopen([nexusSessionString,'.Session.enf'], 'w');
    fprintf(FID, '%s\r\n',nexusEnf.session{:});
    fclose(FID);
end

cd(pathList.src_dir)

% using switch
% switch healthy
%     case 1 
%         % Healthy > only need "New Session"
%         % check for New Session.enf
%         if ~exist('New Session.Session.enf','file')
%             % date and time paramaters to write to the .enf file
%             cd(pathList.src_dir);
%             creationString = getDateTime();
%             cd(pathList.session_dir);
%             
%             % cat the date and time paramters to the CREATIONANDTIME entry
%             nexusEnf.session{4} = [ nexusEnf.session{4} , creationString ];
%             FID = fopen('New Session.Session.enf', 'w');
%             fprintf(FID, '%s\r\n',nexusEnf.session{:});
%             fclose(FID);
%         end
%     case 0 
%         % Clinical > now want to check if nail removed and also want time
%         % points for the session name 
%         % if nail removed have format:
%         % sessionString = 'CL999_NR_3months'
%         % if nail not removed have format: 
%         % sessionString = 'CL999_3months'
%         % so scan string for NR, get string from last underscore to end for
%         % timepoint
%         
%         % check nail removed
        

end