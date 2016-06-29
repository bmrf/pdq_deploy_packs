///////////////////////////
// FIREFOX SETTINGS FILE //
///////////////////////////


// When setting a pref, you can use:
// - pref			:	automatically set and can be changed by the user until next start
// - defaultPref	:	automatically set and can be changed by the user permanently
// - lockPref		:	automatically set and cannot be changed by the user at all

// Take care to use correct case in all pref commands, they're case sensitive!

// EXAMPLE: We could use one of these to specify a global config file (can be a network share or URL) if we desire.
//pref("autoadmin.global_config_url","http://yourdomain.com/autoconfigfile.js");
//lockPref("autoadmin.global_config_url","file://///yourdomain.com/netlogon/autoconfigfile.js");

// set Firefox Default homepage
// pref("browser.startup.homepage","http://www.google.com/");

// Use classic downloader
pref("browser.download.useDownloadDir", false);

// Disable 'know your rights' button from displaying on first run
pref("browser.rights.3.shown", true);

// Options -> Advanced -> Update -> Automatically install updates to : Firefox
lockPref("app.update.enabled", false);

// Options -> Advanced -> General -> Always check to see if Firefox is the default browser on startup
pref("browser.shell.checkDefaultBrowser", false);
pref("browser.startup.homepage_override.mstone", "ignore");

// Options -> Advanced -> Data Choices -> Telemetry -> unselect Enable Telemetry
// Disable request to send performance data from displaying
lockPref("toolkit.telemetry.prompted", 2);
lockPref("toolkit.telemetry.rejected", true);

// Options -> Advanced -> Data Choices -> Firefox Health Report -> unselect Enable Firefox Health Report
// Disable Firefox Health Report component (v21 and up)
lockPref("datareporting.healthreport.service.enabled", false);
lockPref("datareporting.healthreport.uploadEnabled", false);
// These two clear out URLs that FHR reports to, just in case
lockPref("datareporting.healthreport.infoURL", "");
lockPref("datareporting.healthreport.about.reportUrl", "");

// Disable stupid "Hello" embedded chat plugin
pref("loop.enabled", false);

// Disable stupid "tiles" screen on new tabs. Sigh.
pref("browser.newtab.url", "about:blank");

// Disable stupid "Social Share" functionality
lockPref("social.share.activationPanelEnabled", false);
lockPref("social.remote-install.enabled", false);
lockPref("social.activeProviders", "");