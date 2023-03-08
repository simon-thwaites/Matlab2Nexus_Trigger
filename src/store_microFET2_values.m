function  store_microFET2_values(pathName, trialString)
% fucntion for user to enter Peak Force and duration as measured by
% microFET2 handheld Dynamometer. Device records vale in pounds of force
% (lbs) so need to covert to N (*4.44822)
prompt = {'Peak Force (lbs):','Test Duration (s):'};
dlgtitle = 'Max. Thigh Muscle Strength (microFET2)';
dims = [1 70];
answer = inputdlg(prompt,dlgtitle,dims);

% convert lbs to N
peakForce_N = num2str(str2double(answer{1})*4.44822);

% read old csv
oldCsv = readcell(pathName);

% append then write new file
% csv file layout: 'TrialName','PeakForce_lbs','Duration','PeakForce_N'
newCsv = [oldCsv;{trialString,  answer{1}, answer{2}, peakForce_N}];
writecell(newCsv,pathName)
end