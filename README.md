# Simple Hide Viewmodel
**Compiled in SM 1.11.6869**

Simple plugin for toggling weapon viewmodel visibility in CSGO. There is a convar for enabling and disabling the hide viewmodel commands.

## Credits:
- Thanks to [tilgep](https://steamcommunity.com/id/tilgep/) for reading through the plugin and helping me answer my questions with the plugin

## Commands
Toggle View Model
```
sm_hideviewmodel
sm_hidevm
sm_viewmodel
```

## Changelogs
### 1.0.0
- Initial commit and adding files

### 1.1.0
- Added an alternate version of the plugin that does not use `ClientPrefs`
- Enabled hide viewmodel commands by default

### 1.1.1
- Changed `IsValidClient()` function to be more simple
- Update code formatting and add comments
- Fixed an issue where when client cookies are cached, their setting does not actually take effect

## Additional Information
Please report any issues to me or make an issue post. If you have your own changes in mind, feel free to fork the plugin and make your changes.
