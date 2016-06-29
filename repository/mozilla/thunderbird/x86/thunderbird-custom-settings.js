// ------------|thunderbird-custom-settings.js|-----------------
//
// This is the computer-wide Thunderbird settings file.
// We could add settings here, but instead we redirect Thunderbird again to a global config file on the server.
//
//put everything in a try/catch
try {
 
// in this example it is a windows file share. It is also possible to give a real url like http://myserver.net/global_settings.js
lockPref("autoadmin.global_config_url","file://///YOUR-DOMAIN-HERE.COM/netlogon/applications/Thunderbird/thunderbird-global-settings.js");
lockPref("autoadmin.refresh_interval", 120); 
 
// Close the try, and call the catch()
} catch(e) {
  displayError("lockedPref", e);
}