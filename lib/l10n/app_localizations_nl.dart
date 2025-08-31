// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get aboutFlauncher => 'Over FLauncher';

  @override
  String get unsplashQueryLabel => 'Zoekterm (bijv. natuur)';

  @override
  String unsplashErrorMessage(String error) {
    return 'Kon achtergrond niet ophalen: $error';
  }

  @override
  String get dateFormatSpecifier_d => '[d] Dag in maand (10)';

  @override
  String get dateFormatSpecifier_E => '[E] Afgekorte dag van de week (di)';

  @override
  String get dateFormatSpecifier_EEEE => '[EEEE] Dag van de week (dinsdag)';

  @override
  String get dateFormatSpecifier_D => '[D] Dag in jaar (189)';

  @override
  String get dateFormatSpecifier_M => '[M] Maand in jaar (07)';

  @override
  String get dateFormatSpecifier_MMM => '[MMM] Afgekorte maand in jaar (jul)';

  @override
  String get dateFormatSpecifier_MMMM => '[MMMM] Maand in jaar (juli)';

  @override
  String get dateFormatSpecifier_y => '[y] Jaar (1996)';

  @override
  String get timeFormatSpecifier_h => '[h] Uur in am/pm (1~12)';

  @override
  String get timeFormatSpecifier_H => '[H] Uur in dag (0~23)';

  @override
  String get timeFormatSpecifier_m => '[m] Minuut in uur (30)';

  @override
  String get timeFormatSpecifier_s => '[s] Seconde in minuut (55)';

  @override
  String get timeFormatSpecifier_a => '[a] am/pm aanduiding (PM)';

  @override
  String get timeFormatSpecifier_k => '[k] Uur in dag (1~24)';

  @override
  String get timeFormatSpecifier_K => '[K] Uur in am/pm (0~11)';

  @override
  String get addCategory => 'Categorie toevoegen';

  @override
  String get addSection => 'Sectie toevoegen';

  @override
  String get alphabetical => 'Alfabetisch';

  @override
  String get appCardHighlightAnimation => 'App-kaart highlight animatie';

  @override
  String get appInfo => 'Applicatie-informatie';

  @override
  String get appKeyClick => 'Klikgeluid bij toetsdruk';

  @override
  String get applications => 'Applicaties';

  @override
  String get autoHideAppBar => 'Statusbalk automatisch verbergen';

  @override
  String get backButtonAction => 'Actie terug-knop';

  @override
  String get category => 'Categorie';

  @override
  String get categories => 'Categorieën';

  @override
  String get columnCount => 'Aantal kolommen';

  @override
  String get date => 'Datum';

  @override
  String get dateAndTimeFormat => 'Datum- en tijdformaat';

  @override
  String get delete => 'Verwijderen';

  @override
  String get dialogOptionBackButtonActionDoNothing => 'Niets doen';

  @override
  String get dialogOptionBackButtonActionShowScreensaver => 'Screensaver tonen';

  @override
  String get dialogOptionBackButtonActionShowClock => 'Klok tonen';

  @override
  String get dialogTextNoFileExplorer =>
      'Installeer een bestandsverkenner om een afbeelding te kiezen.';

  @override
  String get dialogTitleBackButtonAction => 'Kies de actie voor de terug-knop';

  @override
  String disambiguateCategoryTitle(String title) {
    return '$title (Categorie)';
  }

  @override
  String formattedDate(String dateString) {
    return 'Opgemaakte datum: $dateString';
  }

  @override
  String formattedTime(String timeString) {
    return 'Opgemaakte tijd: $timeString';
  }

  @override
  String get gradient => 'Gradient';

  @override
  String get grid => 'Raster';

  @override
  String get height => 'Hoogte';

  @override
  String get hide => 'Verbergen';

  @override
  String get hiddenApplications => 'Verborgen applicaties';

  @override
  String get launcherSections => 'Secties';

  @override
  String get layout => 'Indeling';

  @override
  String get loading => 'Laden';

  @override
  String get manual => 'Handmatig';

  @override
  String get modifySection => 'Sectie wijzigen';

  @override
  String get mustNotBeEmpty => 'Mag niet leeg zijn';

  @override
  String get name => 'Naam';

  @override
  String get newSection => 'Nieuwe sectie';

  @override
  String get noDateFormatSpecified => 'Geen datumformaat opgegeven';

  @override
  String get noTimeFormatSpecified => 'Geen tijdformaat opgegeven';

  @override
  String get nonTvApplications => 'Niet-TV applicaties';

  @override
  String get open => 'Openen';

  @override
  String get orSelectFormatSpecifiers => 'Of selecteer formaat-specificaties';

  @override
  String get picture => 'Afbeelding';

  @override
  String removeFrom(String name) {
    return 'Verwijderen uit $name';
  }

  @override
  String get renameCategory => 'Categorie hernoemen';

  @override
  String get reorder => 'Herschikken';

  @override
  String get row => 'Rij';

  @override
  String get rowHeight => 'Rijhoogte';

  @override
  String get save => 'Opslaan';

  @override
  String get spacer => 'Ruimte';

  @override
  String get spacerMaxHeightRequirement =>
      'Moet groter zijn dan 0 en kleiner of gelijk aan 500';

  @override
  String get statusBar => 'Statusbalk';

  @override
  String get settings => 'Instellingen';

  @override
  String get show => 'Tonen';

  @override
  String get showCategoryTitles => 'Categorietitels tonen';

  @override
  String get sort => 'Sorteren';

  @override
  String get systemSettings => 'Systeeminstellingen';

  @override
  String textAboutDialog(String repoUrl) {
    return 'FLauncher is een open-source alternatieve launcher voor Android TV.\nBroncode beschikbaar op $repoUrl.\n\nLogo door Katie (@fureturoe), ontwerp door @FXCostanzo.';
  }

  @override
  String get textEmptyCategory => 'Deze categorie is leeg.';

  @override
  String get time => 'Tijd';

  @override
  String get titleStatusBarSettingsPage =>
      'Kies wat er in de statusbalk wordt weergegeven';

  @override
  String get tvApplications => 'TV-applicaties';

  @override
  String get type => 'Type';

  @override
  String get typeInTheDateFormat => 'Typ het datumformaat in';

  @override
  String get typeInTheHourFormat => 'Typ het tijdformaat in';

  @override
  String get uninstall => 'Verwijderen';

  @override
  String get wallpaper => 'Achtergrond';

  @override
  String get withEllipsisAddTo => 'Toevoegen aan...';

  @override
  String get pick => 'Kies';

  @override
  String get apply => 'Toepassen';
}
