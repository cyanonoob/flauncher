// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get aboutFlauncher => 'About FLauncher';

  @override
  String get unsplashQueryLabel => 'Search (e.g. nature)';

  @override
  String unsplashErrorMessage(String error) {
    return 'Failed to fetch wallpaper: $error';
  }

  @override
  String get dateFormatSpecifier_d => '[d] Day in month (10)';

  @override
  String get dateFormatSpecifier_E => '[E] Abbreviated day of week (Tue)';

  @override
  String get dateFormatSpecifier_EEEE => '[EEEE] Day of week (Tuesday)';

  @override
  String get dateFormatSpecifier_D => '[D] Day in year (189)';

  @override
  String get dateFormatSpecifier_M => '[M] Month in year (07)';

  @override
  String get dateFormatSpecifier_MMM => '[MMM] Abbreviated month in year (Jul)';

  @override
  String get dateFormatSpecifier_MMMM => '[MMMM] Month in year (July)';

  @override
  String get dateFormatSpecifier_y => '[y] Year (1996)';

  @override
  String get timeFormatSpecifier_h => '[h] Hour in am/pm (1~12)';

  @override
  String get timeFormatSpecifier_H => '[H] Hour in day (0~23)';

  @override
  String get timeFormatSpecifier_m => '[m] Minute in hour (30)';

  @override
  String get timeFormatSpecifier_s => '[s] Second in minute (55)';

  @override
  String get timeFormatSpecifier_a => '[a] am/pm marker (PM)';

  @override
  String get timeFormatSpecifier_k => '[k] Hour in day (1~24)';

  @override
  String get timeFormatSpecifier_K => '[K] Hour in am/pm (0~11)';

  @override
  String get addCategory => 'Add category';

  @override
  String get addSection => 'Add section';

  @override
  String get alphabetical => 'Alphabetical';

  @override
  String get appCardHighlightAnimation => 'App card highlight animation';

  @override
  String get appInfo => 'Application info';

  @override
  String get appKeyClick => 'Click sound on key press';

  @override
  String get applications => 'Applications';

  @override
  String get autoHideAppBar => 'Automatically hide status bar';

  @override
  String get backButtonAction => 'Back button action';

  @override
  String get category => 'Category';

  @override
  String get categories => 'Categories';

  @override
  String get columnCount => 'Column count';

  @override
  String get date => 'Date';

  @override
  String get dateAndTimeFormat => 'Date and time format';

  @override
  String get delete => 'Delete';

  @override
  String get dialogOptionBackButtonActionDoNothing => 'Do nothing';

  @override
  String get dialogOptionBackButtonActionShowScreensaver => 'Show screensaver';

  @override
  String get dialogOptionBackButtonActionShowClock => 'Show clock';

  @override
  String get dialogTextNoFileExplorer =>
      'Please install a file explorer in order to pick a picture.';

  @override
  String get dialogTitleBackButtonAction => 'Choose the back button action';

  @override
  String disambiguateCategoryTitle(String title) {
    return '$title (Category)';
  }

  @override
  String formattedDate(String dateString) {
    return 'Formatted date: $dateString';
  }

  @override
  String formattedTime(String timeString) {
    return 'Formatted time: $timeString';
  }

  @override
  String get gradient => 'Gradient';

  @override
  String get grid => 'Grid';

  @override
  String get height => 'Height';

  @override
  String get hide => 'Hide';

  @override
  String get hiddenApplications => 'Hidden applications';

  @override
  String get launcherSections => 'Sections';

  @override
  String get layout => 'Layout';

  @override
  String get loading => 'Loading';

  @override
  String get manual => 'Manual';

  @override
  String get modifySection => 'Modify section';

  @override
  String get mustNotBeEmpty => 'Must not be empty';

  @override
  String get name => 'Name';

  @override
  String get newSection => 'New section';

  @override
  String get noDateFormatSpecified => 'No date format specified';

  @override
  String get noTimeFormatSpecified => 'No time format specified';

  @override
  String get nonTvApplications => 'Non-TV applications';

  @override
  String get open => 'Open';

  @override
  String get orSelectFormatSpecifiers => 'Or select format specifiers';

  @override
  String get picture => 'Picture';

  @override
  String removeFrom(String name) {
    return 'Remove from $name';
  }

  @override
  String get renameCategory => 'Rename category';

  @override
  String get reorder => 'Reorder';

  @override
  String get row => 'Row';

  @override
  String get rowHeight => 'Row height';

  @override
  String get save => 'Save';

  @override
  String get spacer => 'Spacer';

  @override
  String get spacerMaxHeightRequirement =>
      'Must be greater than 0 and less than or equal to 500';

  @override
  String get statusBar => 'Status bar';

  @override
  String get settings => 'Settings';

  @override
  String get show => 'Show';

  @override
  String get showCategoryTitles => 'Show category titles';

  @override
  String get sort => 'Sort';

  @override
  String get systemSettings => 'System settings';

  @override
  String textAboutDialog(String repoUrl) {
    return 'FLauncher is an open-source alternative launcher for Android TV.\nSource code available at $repoUrl.\n\nLogo by Katie (@fureturoe), design by @FXCostanzo.';
  }

  @override
  String get textEmptyCategory => 'This category is empty.';

  @override
  String get time => 'Time';

  @override
  String get titleStatusBarSettingsPage =>
      'Choose what to display in the status bar';

  @override
  String get tvApplications => 'TV applications';

  @override
  String get type => 'Type';

  @override
  String get typeInTheDateFormat => 'Type in the date format';

  @override
  String get typeInTheHourFormat => 'Type in the hour format';

  @override
  String get uninstall => 'Uninstall';

  @override
  String get wallpaper => 'Wallpaper';

  @override
  String get wallpaperBrightness => 'Wallpaper brightness';

  @override
  String get withEllipsisAddTo => 'Add to...';

  @override
  String get pick => 'Pick';

  @override
  String get apply => 'Apply';

  @override
  String get nowPlaying => 'Now Playing';

  @override
  String get mediaControls => 'Media Controls';

  @override
  String get showNowPlayingInStatusBar => 'Show Now Playing in status bar';

  @override
  String get mediaPermissionRequired => 'Permission Required';

  @override
  String get mediaPermissionGranted => 'Permission Granted';

  @override
  String get mediaPermissionDescription =>
      'FLauncher needs Notification Listener permission to display media from other apps (like VLC, Spotify, etc.) in the status bar.';

  @override
  String get mediaPermissionGrantedDescription =>
      'FLauncher can display media from other apps in the status bar.';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get mediaPermissionInstructions =>
      'In the settings screen:\n1. Find \"FLauncher\" in the list\n2. Enable the toggle switch\n3. Return to FLauncher';
}
