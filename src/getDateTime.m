function creationString = getDateTime()
% get the date and time components required for the CREATIONDATEANDTIME
% lines in the Nexus .enf files

[ hr , min , sec ] = hms(datetime('now')); 
sec = round(sec);
hr  = num2str(hr);
min = num2str(min);
sec = num2str(sec);
[ yr , mth , day ] = ymd(datetime('now'));
yr  = num2str(yr);
mth = num2str(mth);
day = num2str(day);
creationString = [yr,',',mth,',',day,',',hr,',',min,',',sec];
end