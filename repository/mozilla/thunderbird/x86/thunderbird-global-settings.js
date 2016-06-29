// ------------|thunderbird-global-settings.js|-----------------
//

// All Thunderbird clients on the network are pointed to use this file for their config.
// If you change any setting in this file, those changes will propogate to ALL domain computers
// within 60 minutes. Keep this in mind when changing settings, and change carefully.


// When setting a pref, you can use:
// - pref			:	to make settings which are set after each start and are changable by the user during runtime
// - defaultPref	:	to make settings which can be changed by the user permanently and
// - lockPref		:	to make settings which can't be changed by the user at all.

// Take care on upper and lower case in all pref commandes!


//////////////
// SETTINGS //
//////////////

// Options -> Advanced -> Update -> Automatically check for updates to : Thunderbird
lockPref("app.update.enabled", false);
// Options -> Advanced -> Update -> Automatically check for updates to : Installed Extensions and Themes
defaultPref("extensions.update.enabled", true);
defaultPref("extensions.update.autoUpdateDefault", true);
// Options -> Advanced -> Update -> Automatically check for updates to : Search Engines
pref("browser.search.update", false);

// Disable the request to send performance data:
pref("toolkit.telemetry.rejected", true);
// Disable the request to send performance data from displaying - old version
//pref("toolkit.telemetry.prompted", true); // Disabled, this setting is deprecated
 
// Prevent the "Know Your Rights" info bar at the bottom of the application: 
pref("mail.rights.version", 1);
 
// Disable the Migration Assistant and What's New pages from showing after upgrades:
pref("mail.ui.show.migration.on.upgrade", false);
pref("app.update.showInstalledUI", false);
pref("browser.startup.homepage_override.mstone", "ignore");
pref("mailnews.start_page_override.mstone", "ignore");

