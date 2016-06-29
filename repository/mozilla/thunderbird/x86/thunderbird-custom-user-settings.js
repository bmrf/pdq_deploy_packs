// ------------|thunderbird-custom-user-settings.js|-----------------
//
// This is the custom new user default settings file. 
// we could add settings here, but instead redirect to thunderbird-custom-settings.js in the Thunderbird executable folder, since it is installation-wide.
//
pref("general.config.obscure_value", 0); //The file could optionally be byteshifted as an optional security feature
pref("general.config.filename", "thunderbird-custom-settings.js");