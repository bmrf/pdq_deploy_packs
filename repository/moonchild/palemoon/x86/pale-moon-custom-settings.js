/////////////////////////////
// PALE MOON SETTINGS FILE //
/////////////////////////////


// When setting a pref, you can use:
// - pref			:	automatically set and can be changed by the user until next start
// - defaultPref	:	automatically set and can be changed by the user permanently
// - lockPref		:	automatically set and cannot be changed by the user at all

// Take care to use correct case in all pref commands, since they're case sensitive!

// EXAMPLE: We could use one of these to specify a global config file (can be a network share or URL) if we desire.
//pref("autoadmin.global_config_url","http://yourdomain.com/autoconfigfile.js");
//lockPref("autoadmin.global_config_url","file://///yourdomain.com/netlogon/autoconfigfile.js");

// set default homepage
pref("browser.startup.homepage","about:blank");

// Disables the 'know your rights' button from displaying on first run
pref("browser.rights.3.shown", true);

// Options -> Advanced -> Update -> Automatically install updates to : Pale Moon
lockPref("app.update.enabled", false);

// Options -> Advanced -> General -> Always check to see if Pale Moon is the default browser on startup
pref("browser.shell.checkDefaultBrowser", false);
pref("browser.startup.homepage_override.mstone", "ignore");

// Options -> Advanced -> Data Choices -> Telemetry -> unselect Enable Telemetry
// Disables the request to send performance data from displaying
lockPref("toolkit.telemetry.prompted", 2);
lockPref("toolkit.telemetry.rejected", true);

// Options -> Advanced -> Data Choices -> Pale Moon Health Report -> unselect Enable Pale Moon Health Report
// Disables the Pale Moon Health Report component (v21 and up)
lockPref("datareporting.healthreport.service.enabled", false);
lockPref("datareporting.healthreport.uploadEnabled", false);
// These two clear out the URLs that FHR reports to, just in case
lockPref("datareporting.healthreport.infoURL", "");
lockPref("datareporting.healthreport.about.reportUrl", "");