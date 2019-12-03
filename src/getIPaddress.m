function machine_ip = getIPaddress()
% function to return the machine's IP adress
% ----------------------------------------------------------------------- %
% Created: 29/11/2019
% ----------------------------------------------------------------------- %
% Simnon Thwaites
% simonthwaites1991@gmail.com
% ----------------------------------------------------------------------- %
%
% [~, result] = system('ipconfig');
% this return a long character string with all the machine's info.  
% Example output:
%
% result =
% 
%     '
%      Windows IP Configuration
%      
%      
%      Ethernet adapter Ethernet:
%      
%         Connection-specific DNS Suffix  . : 
%         Link-local IPv6 Address . . . . . : ***::****:****:****:******
%         IPv4 Address. . . . . . . . . . . : **.**.**.**
%         Subnet Mask . . . . . . . . . . . : ***.***.***.*
%         Default Gateway . . . . . . . . . : **.**.**.***
%      
%      Wireless LAN adapter Wi-Fi:
%      
%         Media State . . . . . . . . . . . : Media disconnected
%         Connection-specific DNS Suffix  . : 
%      
%      Wireless LAN adapter Local Area Connection* 2:
%      
%         Media State . . . . . . . . . . . : Media disconnected
%         Connection-specific DNS Suffix  . : 
%      
%      Wireless LAN adapter Local Area Connection* 3:
%      
%         Media State . . . . . . . . . . . : Media disconnected
%         Connection-specific DNS Suffix  . : 
%      
%      Ethernet adapter Ethernet 2:
%      
%         Media State . . . . . . . . . . . : Media disconnected
%         Connection-specific DNS Suffix  . : 
%      
%      Ethernet adapter Bluetooth Network Connection:
%      
%         Media State . . . . . . . . . . . : Media disconnected
%         Connection-specific DNS Suffix  . : 
%      '
     
[ ~ , result ] = system( 'ipconfig' );

% Need to find the IPv4 address from result text. Could be different number
% of spaces and dots so use 'IPv4 Address' and 'Subnet Mask' location
% indexes and find ip adress between these points.

idx_str_ip = strfind(result, "IPv4 Address");            % find index of 'IPv4  Address' string in result character 
idx_str_subnet = strfind(result, "Subnet Mask")-1;     % find index of 'Subnet Mask' in result character
result = result(idx_str_ip:idx_str_subnet);               % create new char between these two points
idx_colon = strfind(result, ":");                        % find index of colon between them
machine_ip = strtrim(result(idx_colon + 1:end));        % get the ip adress string and trim the whitespace
end