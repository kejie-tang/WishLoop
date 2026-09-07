import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'localizations_ar.g.dart';
import 'localizations_cs.g.dart';
import 'localizations_de.g.dart';
import 'localizations_en.g.dart';
import 'localizations_es.g.dart';
import 'localizations_eu.g.dart';
import 'localizations_fa.g.dart';
import 'localizations_fr.g.dart';
import 'localizations_he.g.dart';
import 'localizations_hu.g.dart';
import 'localizations_it.g.dart';
import 'localizations_ja.g.dart';
import 'localizations_nb.g.dart';
import 'localizations_nl.g.dart';
import 'localizations_pl.g.dart';
import 'localizations_pt.g.dart';
import 'localizations_ru.g.dart';
import 'localizations_tr.g.dart';
import 'localizations_uk.g.dart';
import 'localizations_vi.g.dart';
import 'localizations_zh.g.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/localizations.g.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n? of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n);
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('cs'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('eu'),
    Locale('fa'),
    Locale('fr'),
    Locale('he'),
    Locale('hu'),
    Locale('it'),
    Locale('ja'),
    Locale('nb'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('uk'),
    Locale('vi'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// The human-readable name of the language used for the locale.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get localeScriptName;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'WishLoop'**
  String get appName;

  /// Separator used between items in compact localized lists.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get common_listSeparator;

  /// No description provided for @habitEdit_saveButton_text.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get habitEdit_saveButton_text;

  /// No description provided for @habitEdit_habitName_hintText.
  ///
  /// In en, this message translates to:
  /// **'Habit Name ...'**
  String get habitEdit_habitName_hintText;

  /// No description provided for @habitEdit_colorPicker_title.
  ///
  /// In en, this message translates to:
  /// **'Pick color'**
  String get habitEdit_colorPicker_title;

  /// No description provided for @habitEdit_colorPicker_historySectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Recently used'**
  String get habitEdit_colorPicker_historySectionLabel;

  /// No description provided for @habitEdit_colorPicker_customSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'{tinted, select, true {Custom (Tinted)} false {Custom} other {Custom}}'**
  String habitEdit_colorPicker_customSectionLabel(String tinted);

  /// No description provided for @habitEdit_colorPicker_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get habitEdit_colorPicker_cancel;

  /// No description provided for @habitEdit_colorPicker_tintToggleLabel.
  ///
  /// In en, this message translates to:
  /// **'Tint to theme'**
  String get habitEdit_colorPicker_tintToggleLabel;

  /// No description provided for @habitEdit_colorPicker_tintedLabel.
  ///
  /// In en, this message translates to:
  /// **'Tinted'**
  String get habitEdit_colorPicker_tintedLabel;

  /// No description provided for @habitEdit_colorPicker_untintedLabel.
  ///
  /// In en, this message translates to:
  /// **'Not tinted'**
  String get habitEdit_colorPicker_untintedLabel;

  /// No description provided for @habitEdit_colorPicker_tintToggleOnHint.
  ///
  /// In en, this message translates to:
  /// **'Tinting may shift the final color away from the one you picked.'**
  String get habitEdit_colorPicker_tintToggleOnHint;

  /// No description provided for @habitEdit_colorPicker_tintToggleOffHint.
  ///
  /// In en, this message translates to:
  /// **'Some colors may reduce text readability in light or dark theme.'**
  String get habitEdit_colorPicker_tintToggleOffHint;

  /// No description provided for @habitEdit_habitTypeDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Habit type'**
  String get habitEdit_habitTypeDialog_title;

  /// No description provided for @habitEdit_habitType_positiveText.
  ///
  /// In en, this message translates to:
  /// **'Positive'**
  String get habitEdit_habitType_positiveText;

  /// No description provided for @habitEdit_habitType_negativeText.
  ///
  /// In en, this message translates to:
  /// **'Negative'**
  String get habitEdit_habitType_negativeText;

  /// default habit daily goal
  ///
  /// In en, this message translates to:
  /// **'Daily goal, default {number}'**
  String habitEdit_habitDailyGoal_hintText(num number);

  /// default habit daily goal for negative habit
  ///
  /// In en, this message translates to:
  /// **'Minimum daily threshold, default {number}'**
  String habitEdit_habitDailyGoal_negativeHintText(num number);

  /// minimum number for habit daily goal
  ///
  /// In en, this message translates to:
  /// **'daily goal must > {number}'**
  String habitEdit_habitDailyGoal_errorText01(num number);

  /// maximum number for habit daily goal
  ///
  /// In en, this message translates to:
  /// **'daily goal must ≤ {number}'**
  String habitEdit_habitDailyGoal_errorText02(num number);

  /// minimum number for negative habit daily goal
  ///
  /// In en, this message translates to:
  /// **'daily goal must ≥ {number}'**
  String habitEdit_habitDailyGoal_negativeErrorText01(num number);

  /// maximum number for negative habit daily goal
  ///
  /// In en, this message translates to:
  /// **'daily goal must ≤ {number}'**
  String habitEdit_habitDailyGoal_negativeErrorText02(num number);

  /// No description provided for @habitEdit_habitDailyGoalUnit_hintText.
  ///
  /// In en, this message translates to:
  /// **'Daily goal unit'**
  String get habitEdit_habitDailyGoalUnit_hintText;

  /// No description provided for @habitEdit_habitDailyGoalExtra_hintText.
  ///
  /// In en, this message translates to:
  /// **'Desired maximum daily goal'**
  String get habitEdit_habitDailyGoalExtra_hintText;

  /// No description provided for @habitEdit_habitDailyGoalExtra_errorText.
  ///
  /// In en, this message translates to:
  /// **'invalid value, must be empty or ≥ {dailyGoal}'**
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal);

  /// No description provided for @habitEdit_habitDailyGoalExtra_negativeHintText.
  ///
  /// In en, this message translates to:
  /// **'Maximum daily limit'**
  String get habitEdit_habitDailyGoalExtra_negativeHintText;

  /// No description provided for @habitEdit_frequencySelector_title.
  ///
  /// In en, this message translates to:
  /// **'Select frequency'**
  String get habitEdit_frequencySelector_title;

  /// No description provided for @habitEdit_habitFreq_daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get habitEdit_habitFreq_daily;

  /// No description provided for @habitEdit_habitFreq_perweek_text.
  ///
  /// In en, this message translates to:
  /// **'%%time%% times per week'**
  String get habitEdit_habitFreq_perweek_text;

  /// No description provided for @habitEdit_habitFreq_permonth_text.
  ///
  /// In en, this message translates to:
  /// **'%%time%% times per month'**
  String get habitEdit_habitFreq_permonth_text;

  /// No description provided for @habitEdit_habitFreq_predayfreq_text.
  ///
  /// In en, this message translates to:
  /// **'%%time%% times in %%day%% days'**
  String get habitEdit_habitFreq_predayfreq_text;

  /// No description provided for @habitEdit_habitFreq_show_daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get habitEdit_habitFreq_show_daily;

  /// No description provided for @habitEdit_habitFreq_show_perweek.
  ///
  /// In en, this message translates to:
  /// **'{freq, plural, =1{Per week} other{At least {freq} times per week}}'**
  String habitEdit_habitFreq_show_perweek(int freq);

  /// No description provided for @habitEdit_habitFreq_show_permonth.
  ///
  /// In en, this message translates to:
  /// **'{freq, plural, =1{Per month} other{At least {freq} times per month}}'**
  String habitEdit_habitFreq_show_permonth(int freq);

  /// No description provided for @habitEdit_habitFreq_show_perdayfreq.
  ///
  /// In en, this message translates to:
  /// **'{freq, plural, =1{In every {days} days} other{At least {freq} times in every {days} days}}'**
  String habitEdit_habitFreq_show_perdayfreq(int freq, int days);

  /// No description provided for @habitEdit_targetDays_title.
  ///
  /// In en, this message translates to:
  /// **'{targetDays} days'**
  String habitEdit_targetDays_title(int targetDays);

  /// No description provided for @habitEdit_targetDays_dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Target Days'**
  String get habitEdit_targetDays_dialogTitle;

  /// No description provided for @habitEdit_targetDays.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get habitEdit_targetDays;

  /// No description provided for @habitEdit_reminder_hintText.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get habitEdit_reminder_hintText;

  /// No description provided for @habitEdit_reminder_freq_weekHelpText.
  ///
  /// In en, this message translates to:
  /// **'Any day of week'**
  String get habitEdit_reminder_freq_weekHelpText;

  /// Comma-separated day list used in the weekly reminder sentence.
  ///
  /// In en, this message translates to:
  /// **'{days} in every week'**
  String habitEdit_reminder_freq_week_text(String days);

  /// No description provided for @habitEdit_reminder_freq_monthHelpText.
  ///
  /// In en, this message translates to:
  /// **'Any day of month'**
  String get habitEdit_reminder_freq_monthHelpText;

  /// Comma-separated day list used in the monthly reminder sentence.
  ///
  /// In en, this message translates to:
  /// **'{days} in every month'**
  String habitEdit_reminder_freq_month_text(String days);

  /// No description provided for @habitEdit_reminderQuest_hintText.
  ///
  /// In en, this message translates to:
  /// **'Question, e.g. Did you exercise today?'**
  String get habitEdit_reminderQuest_hintText;

  /// No description provided for @habitEdit_reminder_dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose reminder type'**
  String get habitEdit_reminder_dialogTitle;

  /// No description provided for @habitEdit_reminder_dialogType_whenNeeded.
  ///
  /// In en, this message translates to:
  /// **'When need to check in'**
  String get habitEdit_reminder_dialogType_whenNeeded;

  /// No description provided for @habitEdit_reminder_dialogType_daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get habitEdit_reminder_dialogType_daily;

  /// No description provided for @habitEdit_reminder_dialogType_week.
  ///
  /// In en, this message translates to:
  /// **'Per week'**
  String get habitEdit_reminder_dialogType_week;

  /// No description provided for @habitEdit_reminder_dialogType_month.
  ///
  /// In en, this message translates to:
  /// **'Per month'**
  String get habitEdit_reminder_dialogType_month;

  /// No description provided for @habitEdit_reminder_dialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get habitEdit_reminder_dialogConfirm;

  /// No description provided for @habitEdit_reminder_dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get habitEdit_reminder_dialogCancel;

  /// No description provided for @habitEdit_reminder_cancelDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get habitEdit_reminder_cancelDialogTitle;

  /// No description provided for @habitEdit_reminder_cancelDialogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Do you confirm to remove this reminder'**
  String get habitEdit_reminder_cancelDialogSubtitle;

  /// No description provided for @habitEdit_reminder_cancelDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get habitEdit_reminder_cancelDialogConfirm;

  /// No description provided for @habitEdit_reminder_cancelDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get habitEdit_reminder_cancelDialogCancel;

  /// No description provided for @habitEdit_reminder_weekdayText_monday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get habitEdit_reminder_weekdayText_monday;

  /// No description provided for @habitEdit_reminder_weekdayText_tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get habitEdit_reminder_weekdayText_tuesday;

  /// No description provided for @habitEdit_reminder_weekdayText_wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get habitEdit_reminder_weekdayText_wednesday;

  /// No description provided for @habitEdit_reminder_weekdayText_thursday.
  ///
  /// In en, this message translates to:
  /// **'Tur'**
  String get habitEdit_reminder_weekdayText_thursday;

  /// No description provided for @habitEdit_reminder_weekdayText_friday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get habitEdit_reminder_weekdayText_friday;

  /// No description provided for @habitEdit_reminder_weekdayText_saturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get habitEdit_reminder_weekdayText_saturday;

  /// No description provided for @habitEdit_reminder_weekdayText_sunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get habitEdit_reminder_weekdayText_sunday;

  /// No description provided for @habitEdit_desc_hintText.
  ///
  /// In en, this message translates to:
  /// **'Memo, support Markdown'**
  String get habitEdit_desc_hintText;

  /// No description provided for @habitEdit_create_datetime_prefix.
  ///
  /// In en, this message translates to:
  /// **'Created: '**
  String get habitEdit_create_datetime_prefix;

  /// No description provided for @habitEdit_modify_datetime_prefix.
  ///
  /// In en, this message translates to:
  /// **'Modified: '**
  String get habitEdit_modify_datetime_prefix;

  /// No description provided for @habitDisplay_fab_text.
  ///
  /// In en, this message translates to:
  /// **'New Habit'**
  String get habitDisplay_fab_text;

  /// No description provided for @habitDisplay_emptyImage_text_01.
  ///
  /// In en, this message translates to:
  /// **'A journey of a thousand miles begins with a single step'**
  String get habitDisplay_emptyImage_text_01;

  /// Displayed when no habits match the current search
  ///
  /// In en, this message translates to:
  /// **'No matching habits found'**
  String get habitDisplay_notFoundImage_text_01;

  /// Displayed when no habits match the specified keyword
  ///
  /// In en, this message translates to:
  /// **'No matching habits for \"{keyword}\"'**
  String habitDisplay_notFoundImage_text_02(String keyword);

  /// No description provided for @habitDisplay_archiveHabitsConfirmDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Archive Selected Habits?'**
  String get habitDisplay_archiveHabitsConfirmDialog_title;

  /// No description provided for @habitDisplay_archiveHabitsConfirmDialog_confirm.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get habitDisplay_archiveHabitsConfirmDialog_confirm;

  /// No description provided for @habitDisplay_archiveHabitsConfirmDialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get habitDisplay_archiveHabitsConfirmDialog_cancel;

  /// No description provided for @habitDisplay_archiveHabitsSuccSnackbarText.
  ///
  /// In en, this message translates to:
  /// **'Archived {count} habits'**
  String habitDisplay_archiveHabitsSuccSnackbarText(int count);

  /// No description provided for @habitDisplay_unarchiveHabitsConfirmDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Unarchive Selected Habits?'**
  String get habitDisplay_unarchiveHabitsConfirmDialog_title;

  /// No description provided for @habitDisplay_unarchiveHabitsConfirmDialog_confirm.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm;

  /// No description provided for @habitDisplay_unarchiveHabitsConfirmDialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel;

  /// No description provided for @habitDisplay_unarchiveHabitsSuccSnackbarText.
  ///
  /// In en, this message translates to:
  /// **'Unarchived {count} habits'**
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count);

  /// No description provided for @habitDisplay_deleteHabitsConfirmDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected Habits?'**
  String get habitDisplay_deleteHabitsConfirmDialog_title;

  /// No description provided for @habitDisplay_deleteHabitsConfirmDialog_confirm.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get habitDisplay_deleteHabitsConfirmDialog_confirm;

  /// No description provided for @habitDisplay_deleteHabitsConfirmDialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get habitDisplay_deleteHabitsConfirmDialog_cancel;

  /// No description provided for @habitDisplay_deleteHabitsSuccSnackbarText.
  ///
  /// In en, this message translates to:
  /// **'Deleted {count} habits'**
  String habitDisplay_deleteHabitsSuccSnackbarText(int count);

  /// No description provided for @habitDisplay_deleteSingleHabitSuccSnackbarText.
  ///
  /// In en, this message translates to:
  /// **'Deleted habit: \"{name}\"'**
  String habitDisplay_deleteSingleHabitSuccSnackbarText(String name);

  /// No description provided for @habitDisplay_exportHabitsSuccSnackbarText.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {Exported habit.} other {Exported {count} habits.}}'**
  String habitDisplay_exportHabitsSuccSnackbarText(int count);

  /// No description provided for @habitDisplay_exportAllHabitsSuccSnackbarText.
  ///
  /// In en, this message translates to:
  /// **'Exported All Habits'**
  String get habitDisplay_exportAllHabitsSuccSnackbarText;

  /// No description provided for @habitDisplay_editPopMenu_selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get habitDisplay_editPopMenu_selectAll;

  /// Mirrors Apple's localized UIKitCore Localizable.strings "Select" system action.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get habitDisplay_selectButton_label;

  /// Mirrors Apple's localized UIKitCore Localizable.strings "Done" system bar button item.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get habitDisplay_doneButton_label;

  /// Apple selection AppBar title showing the number of selected habits
  ///
  /// In en, this message translates to:
  /// **'Selected {count}'**
  String habitDisplay_selectedHabits_title(int count);

  /// No description provided for @habitDisplay_editPopMenu_export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get habitDisplay_editPopMenu_export;

  /// No description provided for @habitDisplay_editPopMenu_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get habitDisplay_editPopMenu_delete;

  /// No description provided for @habitDisplay_editPopMenu_clone.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get habitDisplay_editPopMenu_clone;

  /// No description provided for @habitDisplay_editButton_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get habitDisplay_editButton_tooltip;

  /// No description provided for @habitDisplay_archiveButton_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get habitDisplay_archiveButton_tooltip;

  /// No description provided for @habitDisplay_unarchiveButton_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get habitDisplay_unarchiveButton_tooltip;

  /// No description provided for @habitDisplay_settingButton_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get habitDisplay_settingButton_tooltip;

  /// No description provided for @habitDisplay_statsMenu_statSubgroupText.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get habitDisplay_statsMenu_statSubgroupText;

  /// No description provided for @habitDisplay_statsMenu_completedTileText.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get habitDisplay_statsMenu_completedTileText;

  /// No description provided for @habitDisplay_statsMenu_inProgresTileText.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get habitDisplay_statsMenu_inProgresTileText;

  /// No description provided for @habitDisplay_statsMenu_archivedTileText.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get habitDisplay_statsMenu_archivedTileText;

  /// No description provided for @habitDisplay_statsMenu_popularitySubgroupText.
  ///
  /// In en, this message translates to:
  /// **'Top Habits: Last 30 Days Changes'**
  String get habitDisplay_statsMenu_popularitySubgroupText;

  /// No description provided for @habitDisplay_statisticsAction_label.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get habitDisplay_statisticsAction_label;

  /// No description provided for @habitDisplay_displayFilterAction_label.
  ///
  /// In en, this message translates to:
  /// **'Display Filter'**
  String get habitDisplay_displayFilterAction_label;

  /// No description provided for @habitDisplay_displayFilter_inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get habitDisplay_displayFilter_inProgress;

  /// No description provided for @habitDisplay_displayFilter_archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get habitDisplay_displayFilter_archived;

  /// No description provided for @habitDisplay_displayFilter_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get habitDisplay_displayFilter_completed;

  /// No description provided for @common_appThemeMode_light.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get common_appThemeMode_light;

  /// No description provided for @common_appThemeMode_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get common_appThemeMode_dark;

  /// No description provided for @common_appThemeMode_followSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get common_appThemeMode_followSystem;

  /// No description provided for @habitDisplay_mainMenu_lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get habitDisplay_mainMenu_lightTheme;

  /// No description provided for @habitDisplay_mainMenu_darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get habitDisplay_mainMenu_darkTheme;

  /// No description provided for @habitDisplay_mainMenu_followSystemTheme.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get habitDisplay_mainMenu_followSystemTheme;

  /// No description provided for @habitDisplay_mainMenu_showArchivedTileText.
  ///
  /// In en, this message translates to:
  /// **'Show Archived'**
  String get habitDisplay_mainMenu_showArchivedTileText;

  /// No description provided for @habitDisplay_mainMenu_showCompletedTileText.
  ///
  /// In en, this message translates to:
  /// **'Show Completed'**
  String get habitDisplay_mainMenu_showCompletedTileText;

  /// No description provided for @habitDisplay_mainMenu_showActivedTileText.
  ///
  /// In en, this message translates to:
  /// **'Show Actived'**
  String get habitDisplay_mainMenu_showActivedTileText;

  /// No description provided for @habitDisplay_mainMenu_settingTileText.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get habitDisplay_mainMenu_settingTileText;

  /// No description provided for @habitDisplay_groupType_name.
  ///
  /// In en, this message translates to:
  /// **'By Name'**
  String get habitDisplay_groupType_name;

  /// No description provided for @habitDisplay_groupType_colorType.
  ///
  /// In en, this message translates to:
  /// **'By Color'**
  String get habitDisplay_groupType_colorType;

  /// No description provided for @habitDisplay_groupType_createDate.
  ///
  /// In en, this message translates to:
  /// **'By Creation Date'**
  String get habitDisplay_groupType_createDate;

  /// No description provided for @habitDisplay_groupType_habitCount.
  ///
  /// In en, this message translates to:
  /// **'By Habit Count'**
  String get habitDisplay_groupType_habitCount;

  /// No description provided for @habitDisplay_groupTypeDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Group Sort'**
  String get habitDisplay_groupTypeDialog_title;

  /// No description provided for @habitDisplay_groupTypeDialog_confirm.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get habitDisplay_groupTypeDialog_confirm;

  /// No description provided for @habitDisplay_groupTypeDialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get habitDisplay_groupTypeDialog_cancel;

  /// No description provided for @habitDisplay_groupTypeDialog_none.
  ///
  /// In en, this message translates to:
  /// **'Flat'**
  String get habitDisplay_groupTypeDialog_none;

  /// No description provided for @habitDisplay_editPopMenu_groupModify.
  ///
  /// In en, this message translates to:
  /// **'Modify Group'**
  String get habitDisplay_editPopMenu_groupModify;

  /// No description provided for @habitDisplay_groupModifyDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Modify Group'**
  String get habitDisplay_groupModifyDialog_title;

  /// No description provided for @habitDisplay_groupModifyDialog_removeGroup.
  ///
  /// In en, this message translates to:
  /// **'Remove Group'**
  String get habitDisplay_groupModifyDialog_removeGroup;

  /// No description provided for @habitDisplay_groupModifyDialog_emptyGroups.
  ///
  /// In en, this message translates to:
  /// **'No groups available'**
  String get habitDisplay_groupModifyDialog_emptyGroups;

  /// No description provided for @habitDisplay_groupModifyDialog_alreadyInGroup.
  ///
  /// In en, this message translates to:
  /// **'Selected habits are already in this group'**
  String get habitDisplay_groupModifyDialog_alreadyInGroup;

  /// No description provided for @habitDisplay_groupModifyDialog_createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get habitDisplay_groupModifyDialog_createGroup;

  /// No description provided for @habitDisplay_groupModifyDialog_saveAndApply.
  ///
  /// In en, this message translates to:
  /// **'Save & Apply'**
  String get habitDisplay_groupModifyDialog_saveAndApply;

  /// No description provided for @habitDisplay_groupModifyConfirm_titleNew.
  ///
  /// In en, this message translates to:
  /// **'Move to Group'**
  String get habitDisplay_groupModifyConfirm_titleNew;

  /// No description provided for @habitDisplay_groupModifyConfirm_titleMixed.
  ///
  /// In en, this message translates to:
  /// **'Confirm Group Change'**
  String get habitDisplay_groupModifyConfirm_titleMixed;

  /// No description provided for @habitDisplay_groupModifyConfirm_bodyNewGroup.
  ///
  /// In en, this message translates to:
  /// **'{groupName} habits will be moved to this group'**
  String habitDisplay_groupModifyConfirm_bodyNewGroup(String groupName);

  /// No description provided for @habitDisplay_groupModifyConfirm_bodyRemoveGroup.
  ///
  /// In en, this message translates to:
  /// **'Habits will have their group removed'**
  String get habitDisplay_groupModifyConfirm_bodyRemoveGroup;

  /// No description provided for @habitDisplay_groupModifyConfirm_bodyChangeStat.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {{count} habit will change from \"{fromGroup}\" to \"{toGroup}\"} other {{count} habits will change from \"{fromGroup}\" to \"{toGroup}\"}}'**
  String habitDisplay_groupModifyConfirm_bodyChangeStat(
    int count,
    String fromGroup,
    String toGroup,
  );

  /// No description provided for @habitDisplay_groupModifyConfirm_bodyAddStat.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {{count} uncategorized habit will be added to \"{toGroup}\"} other {{count} uncategorized habits will be added to \"{toGroup}\"}}'**
  String habitDisplay_groupModifyConfirm_bodyAddStat(int count, String toGroup);

  /// No description provided for @habitDisplay_groupModifyConfirm_bodyRemoveStat.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {{count} habit will have its group removed} other {{count} habits will have their groups removed}}'**
  String habitDisplay_groupModifyConfirm_bodyRemoveStat(int count);

  /// No description provided for @habitDisplay_groupModifyConfirm_nameSeparator.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get habitDisplay_groupModifyConfirm_nameSeparator;

  /// No description provided for @habitDisplay_groupModify_snackbarText.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {Moved habit to \"{groupName}\"} other {Moved {count} habits to \"{groupName}\"}}'**
  String habitDisplay_groupModify_snackbarText(int count, String groupName);

  /// No description provided for @habitDisplay_groupModify_snackbarTextRemoved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {Removed group from habit} other {Removed groups from {count} habits}}'**
  String habitDisplay_groupModify_snackbarTextRemoved(int count);

  /// No description provided for @habitDisplay_groupModify_undoFailed.
  ///
  /// In en, this message translates to:
  /// **'Group has been modified elsewhere, cannot undo'**
  String get habitDisplay_groupModify_undoFailed;

  /// No description provided for @habitDisplay_sort_reverseText.
  ///
  /// In en, this message translates to:
  /// **'Reverse'**
  String get habitDisplay_sort_reverseText;

  /// No description provided for @habitDisplay_sortDirection_asc.
  ///
  /// In en, this message translates to:
  /// **'(Asc)'**
  String get habitDisplay_sortDirection_asc;

  /// No description provided for @habitDisplay_sortDirection_Desc.
  ///
  /// In en, this message translates to:
  /// **'(Desc)'**
  String get habitDisplay_sortDirection_Desc;

  /// No description provided for @habitDisplay_sortType_manual.
  ///
  /// In en, this message translates to:
  /// **'My order'**
  String get habitDisplay_sortType_manual;

  /// No description provided for @habitDisplay_sortType_name.
  ///
  /// In en, this message translates to:
  /// **'By Name'**
  String get habitDisplay_sortType_name;

  /// No description provided for @habitDisplay_sortType_colorType.
  ///
  /// In en, this message translates to:
  /// **'By Color'**
  String get habitDisplay_sortType_colorType;

  /// No description provided for @habitDisplay_sortType_progress.
  ///
  /// In en, this message translates to:
  /// **'By Rate'**
  String get habitDisplay_sortType_progress;

  /// No description provided for @habitDisplay_sortType_startT.
  ///
  /// In en, this message translates to:
  /// **'By Start Date'**
  String get habitDisplay_sortType_startT;

  /// No description provided for @habitDisplay_sortType_status.
  ///
  /// In en, this message translates to:
  /// **'By Status'**
  String get habitDisplay_sortType_status;

  /// No description provided for @habitDisplay_sortTypeDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get habitDisplay_sortTypeDialog_title;

  /// No description provided for @habitDisplay_sortTypeDialog_confirm.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get habitDisplay_sortTypeDialog_confirm;

  /// No description provided for @habitDisplay_sortTypeDialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get habitDisplay_sortTypeDialog_cancel;

  /// No description provided for @habitDisplay_debug_debugSubgroup_title.
  ///
  /// In en, this message translates to:
  /// **'🛠️Debug'**
  String get habitDisplay_debug_debugSubgroup_title;

  /// No description provided for @habitDisplay_searchBar_hintText.
  ///
  /// In en, this message translates to:
  /// **'Search habits'**
  String get habitDisplay_searchBar_hintText;

  /// No description provided for @habitDisplay_searchFilter_ongoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get habitDisplay_searchFilter_ongoing;

  /// No description provided for @habitDisplay_searchFilter_ongoing_desc.
  ///
  /// In en, this message translates to:
  /// **'Shows habits that are currently active and ongoing (not archived or deleted).'**
  String get habitDisplay_searchFilter_ongoing_desc;

  /// No description provided for @habitDisplay_searchFilter_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get habitDisplay_searchFilter_completed;

  /// No description provided for @habitDisplay_searchFilter_habitType_groupTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit Type'**
  String get habitDisplay_searchFilter_habitType_groupTitle;

  /// No description provided for @habitDisplay_searchFilter_tooltips.
  ///
  /// In en, this message translates to:
  /// **'Show Filters'**
  String get habitDisplay_searchFilter_tooltips;

  /// No description provided for @habitDisplay_searchFilter_clearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get habitDisplay_searchFilter_clearFilter;

  /// No description provided for @habitDisplay_tab_habits_label.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habitDisplay_tab_habits_label;

  /// No description provided for @habitDisplay_tab_today_label.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get habitDisplay_tab_today_label;

  /// No description provided for @habitToday_appBar_title.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get habitToday_appBar_title;

  /// Celebratory text shown when the user completes all their habit tasks for today
  ///
  /// In en, this message translates to:
  /// **'YOU MADE IT'**
  String get habitToday_image_desc;

  /// No description provided for @habitToday_card_subtitle_text.
  ///
  /// In en, this message translates to:
  /// **'Kept it up for {days} days'**
  String habitToday_card_subtitle_text(int days);

  /// Button label for completing today's habit with dialog
  ///
  /// In en, this message translates to:
  /// **'Done+'**
  String get habitToday_card_donePlusButton_label;

  /// Button label for skipping today's habit with dialog
  ///
  /// In en, this message translates to:
  /// **'Skip+'**
  String get habitToday_card_skipPlusButton_label;

  /// No description provided for @habitDetail_editButton_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get habitDetail_editButton_tooltip;

  /// No description provided for @habitDetail_editPopMenu_unarchive.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get habitDetail_editPopMenu_unarchive;

  /// No description provided for @habitDetail_editPopMenu_archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get habitDetail_editPopMenu_archive;

  /// No description provided for @habitDetail_editPopMenu_export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get habitDetail_editPopMenu_export;

  /// No description provided for @habitDetail_editPopMenu_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get habitDetail_editPopMenu_delete;

  /// No description provided for @habitDetail_editPopMenu_clone.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get habitDetail_editPopMenu_clone;

  /// No description provided for @habitDetail_confirmDialog_confirm.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get habitDetail_confirmDialog_confirm;

  /// No description provided for @habitDetail_confirmDialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get habitDetail_confirmDialog_cancel;

  /// No description provided for @habitDetail_archiveConfirmDialog_titleText.
  ///
  /// In en, this message translates to:
  /// **'Archive Habit?'**
  String get habitDetail_archiveConfirmDialog_titleText;

  /// No description provided for @habitDetail_unarchiveConfirmDialog_titleText.
  ///
  /// In en, this message translates to:
  /// **'Unarchive Habit?'**
  String get habitDetail_unarchiveConfirmDialog_titleText;

  /// No description provided for @habitDetail_deleteConfirmDialog_titleText.
  ///
  /// In en, this message translates to:
  /// **'Delete Habit?'**
  String get habitDetail_deleteConfirmDialog_titleText;

  /// No description provided for @habitDetail_summary_title.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get habitDetail_summary_title;

  /// No description provided for @habitDetail_summary_body.
  ///
  /// In en, this message translates to:
  /// **'Current grade is {score}, and it has been {days} days since the start.'**
  String habitDetail_summary_body(String score, int days);

  /// No description provided for @habitDetail_summary_preBody.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Starting tomorrow.} other{Start in {days} days.}}'**
  String habitDetail_summary_preBody(int days);

  /// No description provided for @habitDetail_heatmap_leftHelpText.
  ///
  /// In en, this message translates to:
  /// **'{habitType, plural, =1{INCOMPLETE} =2{SUBSTANDARD} other{}}'**
  String habitDetail_heatmap_leftHelpText(int habitType);

  /// No description provided for @habitDetail_heatmap_rightHelpText.
  ///
  /// In en, this message translates to:
  /// **'{habitType, plural, =1{OVERFULFIL} =2{IMPECCABLE} other{}}'**
  String habitDetail_heatmap_rightHelpText(int habitType);

  /// No description provided for @habitDetail_descDailyGoal_titleText.
  ///
  /// In en, this message translates to:
  /// **'{habitType, plural, =2{Threshold} other{Goal}}'**
  String habitDetail_descDailyGoal_titleText(int habitType);

  /// No description provided for @habitDetail_descDailyGoal_unitText.
  ///
  /// In en, this message translates to:
  /// **'Unit: {unit}'**
  String habitDetail_descDailyGoal_unitText(String unit);

  /// No description provided for @habitDetail_descDailyGoal_unitEmptyText.
  ///
  /// In en, this message translates to:
  /// **'null'**
  String get habitDetail_descDailyGoal_unitEmptyText;

  /// No description provided for @habitDetail_descTargetDays_titleText.
  ///
  /// In en, this message translates to:
  /// **'{habitType, plural, other{Days}}'**
  String habitDetail_descTargetDays_titleText(int habitType);

  /// No description provided for @habitDetail_descTargetDays_unitText.
  ///
  /// In en, this message translates to:
  /// **'d'**
  String get habitDetail_descTargetDays_unitText;

  /// No description provided for @habitDetail_descRecordsNum_titleText.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get habitDetail_descRecordsNum_titleText;

  /// No description provided for @habitDetail_scoreChart_title.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get habitDetail_scoreChart_title;

  /// No description provided for @habitDetail_scoreChartCombine_dailyText.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get habitDetail_scoreChartCombine_dailyText;

  /// No description provided for @habitDetail_scoreChartCombine_weeklyText.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get habitDetail_scoreChartCombine_weeklyText;

  /// No description provided for @habitDetail_scoreChartCombine_monthlyText.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get habitDetail_scoreChartCombine_monthlyText;

  /// No description provided for @habitDetail_scoreChartCombine_yearlyText.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get habitDetail_scoreChartCombine_yearlyText;

  /// No description provided for @habitDetail_freqChart_freqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get habitDetail_freqChart_freqTitle;

  /// No description provided for @habitDetail_freqChart_historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get habitDetail_freqChart_historyTitle;

  /// No description provided for @habitDetail_freqChart_combinedTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequency & History'**
  String get habitDetail_freqChart_combinedTitle;

  /// No description provided for @habitDetail_freqChartCombine_weeklyText.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get habitDetail_freqChartCombine_weeklyText;

  /// No description provided for @habitDetail_freqChartCombine_monthlyText.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get habitDetail_freqChartCombine_monthlyText;

  /// No description provided for @habitDetail_freqChartCombine_yearlyText.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get habitDetail_freqChartCombine_yearlyText;

  /// No description provided for @habitDetail_freqChartNaviBar_nowText.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get habitDetail_freqChartNaviBar_nowText;

  /// No description provided for @habitDetail_freqChart_expanded_hideTooltip.
  ///
  /// In en, this message translates to:
  /// **'Hide History Chart'**
  String get habitDetail_freqChart_expanded_hideTooltip;

  /// No description provided for @habitDetail_freqChart_expanded_showTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show History Chart'**
  String get habitDetail_freqChart_expanded_showTooltip;

  /// No description provided for @habitDetail_descSubgroup_title.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get habitDetail_descSubgroup_title;

  /// No description provided for @habitDetail_otherSubgroup_title.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get habitDetail_otherSubgroup_title;

  /// No description provided for @habitDetail_habitType_title.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get habitDetail_habitType_title;

  /// No description provided for @habitDetail_reminderTile_title.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get habitDetail_reminderTile_title;

  /// No description provided for @habitDetail_freqTile_title.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get habitDetail_freqTile_title;

  /// No description provided for @habitDetail_startDateTile_title.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get habitDetail_startDateTile_title;

  /// No description provided for @habitDetail_createDateTile_title.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get habitDetail_createDateTile_title;

  /// No description provided for @habitDetail_modifyDateTile_title.
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get habitDetail_modifyDateTile_title;

  /// No description provided for @habitDetail_editHeatmapCal_dateButtonText.
  ///
  /// In en, this message translates to:
  /// **'date'**
  String get habitDetail_editHeatmapCal_dateButtonText;

  /// No description provided for @habitDetail_editHeatmapCal_valueButtonText.
  ///
  /// In en, this message translates to:
  /// **'value'**
  String get habitDetail_editHeatmapCal_valueButtonText;

  /// No description provided for @habitDetail_editHeatmapCal_backToToday_tooltipText.
  ///
  /// In en, this message translates to:
  /// **'back to today'**
  String get habitDetail_editHeatmapCal_backToToday_tooltipText;

  /// No description provided for @common_loadError_text.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get common_loadError_text;

  /// No description provided for @common_loadError_retryText.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get common_loadError_retryText;

  /// No description provided for @habitDetail_notFoundText.
  ///
  /// In en, this message translates to:
  /// **'Load habit failed'**
  String get habitDetail_notFoundText;

  /// No description provided for @habitDetail_notFoundRetryText.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get habitDetail_notFoundRetryText;

  /// No description provided for @habitDetail_changeGoal_title.
  ///
  /// In en, this message translates to:
  /// **'Change goal'**
  String get habitDetail_changeGoal_title;

  /// No description provided for @habitDetail_changeGoal_currentChipText.
  ///
  /// In en, this message translates to:
  /// **'current: {goal}'**
  String habitDetail_changeGoal_currentChipText(String goal);

  /// No description provided for @habitDetail_changeGoal_doneChipText.
  ///
  /// In en, this message translates to:
  /// **'done: {goal}'**
  String habitDetail_changeGoal_doneChipText(String goal);

  /// No description provided for @habitDetail_changeGoal_undoneChipText.
  ///
  /// In en, this message translates to:
  /// **'undone'**
  String get habitDetail_changeGoal_undoneChipText;

  /// No description provided for @habitDetail_changeGoal_extraChipText.
  ///
  /// In en, this message translates to:
  /// **'{goal}'**
  String habitDetail_changeGoal_extraChipText(String goal);

  /// No description provided for @habitDetail_changeGoal_helpText.
  ///
  /// In en, this message translates to:
  /// **'Daily goal, default: {goal}'**
  String habitDetail_changeGoal_helpText(String goal);

  /// No description provided for @habitDetail_changeGoal_cancelText.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get habitDetail_changeGoal_cancelText;

  /// No description provided for @habitDetail_changeGoal_saveText.
  ///
  /// In en, this message translates to:
  /// **'save'**
  String get habitDetail_changeGoal_saveText;

  /// No description provided for @habitDetail_skipReason_title.
  ///
  /// In en, this message translates to:
  /// **'Skip reason'**
  String get habitDetail_skipReason_title;

  /// No description provided for @habitDetail_skipReason_bodyHelpText.
  ///
  /// In en, this message translates to:
  /// **'Write something here...'**
  String get habitDetail_skipReason_bodyHelpText;

  /// No description provided for @habitDetail_skipReason_cancelText.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get habitDetail_skipReason_cancelText;

  /// No description provided for @habitDetail_skipReason_saveText.
  ///
  /// In en, this message translates to:
  /// **'save'**
  String get habitDetail_skipReason_saveText;

  /// No description provided for @appSetting_appbar_titleText.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get appSetting_appbar_titleText;

  /// No description provided for @appSetting_displaySubgroupText.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get appSetting_displaySubgroupText;

  /// No description provided for @appSetting_operationSubgroupText.
  ///
  /// In en, this message translates to:
  /// **'Operation'**
  String get appSetting_operationSubgroupText;

  /// No description provided for @appSetting_dragCalendarByPageTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Drag calendar by page'**
  String get appSetting_dragCalendarByPageTile_titleText;

  /// No description provided for @appSetting_dragCalendarByPageTile_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'If the switch is enabled, the app bar calendar on the home page will be dragged page by page. By default, the switch is disabled.'**
  String get appSetting_dragCalendarByPageTile_subtitleText;

  /// No description provided for @appSetting_changeRecordStatusOpTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Change Record Status'**
  String get appSetting_changeRecordStatusOpTile_titleText;

  /// No description provided for @appSetting_changeRecordStatusOpTile_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Modify the click behavior to change the status of daily records on main page.'**
  String get appSetting_changeRecordStatusOpTile_subtitleText;

  /// No description provided for @appSetting_openRecordStatusDialogOpTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Open Detailed Record'**
  String get appSetting_openRecordStatusDialogOpTile_titleText;

  /// No description provided for @appSetting_openRecordStatusDialogOpTile_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Modify the click behavior to open the detailed popup for daily records on main page.'**
  String get appSetting_openRecordStatusDialogOpTile_subtitleText;

  /// Title for the group expand timer delay setting tile
  ///
  /// In en, this message translates to:
  /// **'Group expand delay'**
  String get appSetting_expandTimerDelayTile_titleText;

  /// No description provided for @appSetting_expandTimerDelayTile_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Set how long to hover over a collapsed group header before it auto-expands during drag-and-drop.'**
  String get appSetting_expandTimerDelayTile_subtitleText;

  /// No description provided for @appSetting_expandTimerDelay_default.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get appSetting_expandTimerDelay_default;

  /// No description provided for @appSetting_expandTimerDelay_fast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get appSetting_expandTimerDelay_fast;

  /// No description provided for @appSetting_expandTimerDelay_slow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get appSetting_expandTimerDelay_slow;

  /// No description provided for @appSetting_appThemeColorTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Theme Color'**
  String get appSetting_appThemeColorTile_titleText;

  /// No description provided for @appSetting_appThemeModeTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get appSetting_appThemeModeTile_titleText;

  /// No description provided for @appSetting_appThemeColorChosenDiloag_titleText.
  ///
  /// In en, this message translates to:
  /// **'Choose Theme Color'**
  String get appSetting_appThemeColorChosenDiloag_titleText;

  /// No description provided for @appSetting_appThemeColorChosenDialog_subTitleText_android.
  ///
  /// In en, this message translates to:
  /// **'Use wallpaper\'s main color (Android 12+)'**
  String get appSetting_appThemeColorChosenDialog_subTitleText_android;

  /// No description provided for @appSetting_appThemeColorChosenDialog_subTitleText_linux.
  ///
  /// In en, this message translates to:
  /// **'Use GTK+ theme\'s selected background color'**
  String get appSetting_appThemeColorChosenDialog_subTitleText_linux;

  /// No description provided for @appSetting_appThemeColorChosenDialog_subTitleText_macos.
  ///
  /// In en, this message translates to:
  /// **'Use system theme color'**
  String get appSetting_appThemeColorChosenDialog_subTitleText_macos;

  /// No description provided for @appSetting_appThemeColorChosenDialog_subTitleText_windows.
  ///
  /// In en, this message translates to:
  /// **'Use system accent or window/glass color'**
  String get appSetting_appThemeColorChosenDialog_subTitleText_windows;

  /// No description provided for @appSetting_firstDayOfWeek_titleText.
  ///
  /// In en, this message translates to:
  /// **'First day of week'**
  String get appSetting_firstDayOfWeek_titleText;

  /// No description provided for @appSetting_firstDayOfWeekDialog_titleText.
  ///
  /// In en, this message translates to:
  /// **'Show first day of week'**
  String get appSetting_firstDayOfWeekDialog_titleText;

  /// No description provided for @appSetting_firstDayOfWeekDialog_defaultText.
  ///
  /// In en, this message translates to:
  /// **' (Default)'**
  String get appSetting_firstDayOfWeekDialog_defaultText;

  /// No description provided for @appSetting_changeLanguage_followSystem_text.
  ///
  /// In en, this message translates to:
  /// **'Follow System ({localeName})'**
  String appSetting_changeLanguage_followSystem_text(String localeName);

  /// No description provided for @appSetting_changeLanguage_followSystem_noLocale_text.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get appSetting_changeLanguage_followSystem_noLocale_text;

  /// No description provided for @appSetting_changeLanguageTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get appSetting_changeLanguageTile_titleText;

  /// No description provided for @appSetting_changeLanguageDialog_titleText.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get appSetting_changeLanguageDialog_titleText;

  /// No description provided for @appSetting_languageSubgroupText.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get appSetting_languageSubgroupText;

  /// No description provided for @appSetting_openSystemLanguageTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'System Language Settings'**
  String get appSetting_openSystemLanguageTile_titleText;

  /// No description provided for @appSetting_openSystemLanguageTile_dialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Open System Language Settings'**
  String get appSetting_openSystemLanguageTile_dialogTitle;

  /// Dialog subtitle rendered as Markdown via markdown_widget. Supports **bold** syntax and numbered lists (1. ...). See https://commonmark.org/help/ for supported Markdown features.
  ///
  /// In en, this message translates to:
  /// **'Due to macOS limitations, the app language cannot be changed directly. To switch languages, follow these steps:\n\n1. Open **System Settings > General > Language & Region**\n2. Add this app in the **Applications** list and choose a language'**
  String get appSetting_openSystemLanguageTile_macosDialogContent;

  /// No description provided for @appSetting_dateDisplayFormat_titleText.
  ///
  /// In en, this message translates to:
  /// **'Date display format ({formatTemplate})'**
  String appSetting_dateDisplayFormat_titleText(String formatTemplate);

  /// No description provided for @appSetting_dateDisplayFormat_titleTemplate_followSystemText.
  ///
  /// In en, this message translates to:
  /// **'follow system setting'**
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText;

  /// No description provided for @appSetting_dateDisplayFormat_subTitleText.
  ///
  /// In en, this message translates to:
  /// **'Configured date format will be applied to the date display on habit detail page.'**
  String get appSetting_dateDisplayFormat_subTitleText;

  /// No description provided for @appSetting_compactUISwitcher_titleText.
  ///
  /// In en, this message translates to:
  /// **'Enable Compact UI on habits page'**
  String get appSetting_compactUISwitcher_titleText;

  /// No description provided for @appSetting_compactUISwitcher_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Allow habits check table to display more content, but some UI and text may appear smaller.'**
  String get appSetting_compactUISwitcher_subtitleText;

  /// No description provided for @appSetting_collapsed_calendar_bararea_titleText.
  ///
  /// In en, this message translates to:
  /// **'Habits check area radio adjustment'**
  String get appSetting_collapsed_calendar_bararea_titleText;

  /// No description provided for @appSetting_collapsed_calendar_bararea_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Adjust percentage for more/less space in habits check table area.'**
  String get appSetting_collapsed_calendar_bararea_subtitleText;

  /// No description provided for @appSetting_collapsed_calendar_bararea_defaultText.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get appSetting_collapsed_calendar_bararea_defaultText;

  /// No description provided for @appSetting_reminderSubgroupText.
  ///
  /// In en, this message translates to:
  /// **'Reminder & Notification'**
  String get appSetting_reminderSubgroupText;

  /// No description provided for @appSetting_dailyReminder_titleText.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get appSetting_dailyReminder_titleText;

  /// No description provided for @appSetting_backupAndRestoreSubgroupText.
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get appSetting_backupAndRestoreSubgroupText;

  /// No description provided for @appSetting_export_titleText.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get appSetting_export_titleText;

  /// No description provided for @appSetting_export_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Exported habits as JSON format, This file can be import back.'**
  String get appSetting_export_subtitleText;

  /// No description provided for @appSetting_import_titleText.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get appSetting_import_titleText;

  /// No description provided for @appSetting_import_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Import habits from json file.'**
  String get appSetting_import_subtitleText;

  /// No description provided for @appSetting_thirdPartyImport_titleText.
  ///
  /// In en, this message translates to:
  /// **'Import from third-party'**
  String get appSetting_thirdPartyImport_titleText;

  /// No description provided for @appSetting_thirdPartyImport_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Import habits from other habit tracker apps'**
  String get appSetting_thirdPartyImport_subtitleText;

  /// No description provided for @appSetting_thirdPartyImport_provider_loopName.
  ///
  /// In en, this message translates to:
  /// **'Loop Habit Tracker'**
  String get appSetting_thirdPartyImport_provider_loopName;

  /// No description provided for @appSetting_thirdPartyImport_provider_versionHint.
  ///
  /// In en, this message translates to:
  /// **'Supports CSV (tested up to <ver/>)'**
  String get appSetting_thirdPartyImport_provider_versionHint;

  /// No description provided for @appSetting_importDialog_confirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm import {count} habits?'**
  String appSetting_importDialog_confirmTitle(int count);

  /// No description provided for @appSetting_importDialog_confirmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Note: Import doesn\'t delete existing habits.'**
  String get appSetting_importDialog_confirmSubtitle;

  /// No description provided for @appSetting_importDialog_option_includeHabits.
  ///
  /// In en, this message translates to:
  /// **'Include habits'**
  String get appSetting_importDialog_option_includeHabits;

  /// No description provided for @appSetting_importDialog_option_includeGroups.
  ///
  /// In en, this message translates to:
  /// **'Include groups'**
  String get appSetting_importDialog_option_includeGroups;

  /// No description provided for @appSetting_importDialog_tile_includeHabits.
  ///
  /// In en, this message translates to:
  /// **'Include {count} habits'**
  String appSetting_importDialog_tile_includeHabits(int count);

  /// No description provided for @appSetting_importDialog_tile_includeGroups.
  ///
  /// In en, this message translates to:
  /// **'Include {count} groups'**
  String appSetting_importDialog_tile_includeGroups(int count);

  /// No description provided for @appSetting_importConfirmDialog_sourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source: {provider}'**
  String appSetting_importConfirmDialog_sourceLabel(String provider);

  /// No description provided for @appSetting_thirdPartyImport_error_fileReadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to read the selected file.'**
  String get appSetting_thirdPartyImport_error_fileReadError;

  /// No description provided for @appSetting_thirdPartyImport_error_noHabitsFound.
  ///
  /// In en, this message translates to:
  /// **'No habits found in the import file.'**
  String get appSetting_thirdPartyImport_error_noHabitsFound;

  /// No description provided for @appSetting_thirdPartyImport_error_parseError.
  ///
  /// In en, this message translates to:
  /// **'Failed to parse import file'**
  String get appSetting_thirdPartyImport_error_parseError;

  /// No description provided for @appSetting_thirdPartyImport_error_unknown.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred during import.'**
  String get appSetting_thirdPartyImport_error_unknown;

  /// No description provided for @appSetting_importDialog_confirm_confirmText.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get appSetting_importDialog_confirm_confirmText;

  /// No description provided for @appSetting_importDialog_confirm_cancelText.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get appSetting_importDialog_confirm_cancelText;

  /// No description provided for @appSetting_importDialog_importingTitle.
  ///
  /// In en, this message translates to:
  /// **'Imported {completeCount}/{totalCount}'**
  String appSetting_importDialog_importingTitle(
    int completeCount,
    int totalCount,
  );

  /// No description provided for @appSetting_importDialog_completeTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete import {count} habits'**
  String appSetting_importDialog_completeTitle(int count);

  /// No description provided for @appSetting_importDialog_completeTitleGroups.
  ///
  /// In en, this message translates to:
  /// **'Completed import {count} groups'**
  String appSetting_importDialog_completeTitleGroups(int count);

  /// No description provided for @appSetting_importDialog_complete_closeLabel.
  ///
  /// In en, this message translates to:
  /// **'close'**
  String get appSetting_importDialog_complete_closeLabel;

  /// No description provided for @appSetting_resetConfig_titleText.
  ///
  /// In en, this message translates to:
  /// **'Reset configs'**
  String get appSetting_resetConfig_titleText;

  /// No description provided for @appSetting_resetConfig_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Reset all configs to default.'**
  String get appSetting_resetConfig_subtitleText;

  /// No description provided for @appSetting_resetConfigDialog_titleText.
  ///
  /// In en, this message translates to:
  /// **'Reset configs?'**
  String get appSetting_resetConfigDialog_titleText;

  /// No description provided for @appSetting_resetConfigDialog_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Reset all configs to default, must restart application to apply.'**
  String get appSetting_resetConfigDialog_subtitleText;

  /// No description provided for @appSetting_resetConfigDialog_cancelText.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get appSetting_resetConfigDialog_cancelText;

  /// No description provided for @appSetting_resetConfigDialog_confirmText.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get appSetting_resetConfigDialog_confirmText;

  /// No description provided for @appSetting_resetConfigSuccess_snackbarText.
  ///
  /// In en, this message translates to:
  /// **'reset app configs succeed'**
  String get appSetting_resetConfigSuccess_snackbarText;

  /// No description provided for @appSetting_otherSubgroupText.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get appSetting_otherSubgroupText;

  /// No description provided for @appSetting_developMode_titleText.
  ///
  /// In en, this message translates to:
  /// **'Develop Mode'**
  String get appSetting_developMode_titleText;

  /// No description provided for @appSetting_clearCache_titleText.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get appSetting_clearCache_titleText;

  /// No description provided for @appSetting_clearCacheDialog_titleText.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get appSetting_clearCacheDialog_titleText;

  /// No description provided for @appSetting_clearCacheDialog_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'After clearing cache, some custom values will be restored to defaults.'**
  String get appSetting_clearCacheDialog_subtitleText;

  /// No description provided for @appSetting_clearCacheDialog_cancelText.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get appSetting_clearCacheDialog_cancelText;

  /// No description provided for @appSetting_clearCacheDialog_confirmText.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get appSetting_clearCacheDialog_confirmText;

  /// No description provided for @appSetting_clearCache_snackBar_partSuccText.
  ///
  /// In en, this message translates to:
  /// **'Partial Cache cleared failed'**
  String get appSetting_clearCache_snackBar_partSuccText;

  /// No description provided for @appSetting_clearCache_snackBar_succText.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get appSetting_clearCache_snackBar_succText;

  /// No description provided for @appSetting_clearCache_snackBar_failText.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared failed'**
  String get appSetting_clearCache_snackBar_failText;

  /// No description provided for @appSetting_debugger_titleText.
  ///
  /// In en, this message translates to:
  /// **'Debug Info'**
  String get appSetting_debugger_titleText;

  /// No description provided for @appSetting_about_titleText.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get appSetting_about_titleText;

  /// No description provided for @appSetting_experimentalFeatureTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Experimental Features'**
  String get appSetting_experimentalFeatureTile_titleText;

  /// No description provided for @appSetting_synSubgroupText.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get appSetting_synSubgroupText;

  /// No description provided for @appSetting_syncOption_titleText.
  ///
  /// In en, this message translates to:
  /// **'Sync Options'**
  String get appSetting_syncOption_titleText;

  /// No description provided for @appSetting_notify_titleTile.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get appSetting_notify_titleTile;

  /// No description provided for @appSetting_notify_subtitleTile.
  ///
  /// In en, this message translates to:
  /// **'Manage notification preferences'**
  String get appSetting_notify_subtitleTile;

  /// No description provided for @appSetting_notify_subtitleTile_android.
  ///
  /// In en, this message translates to:
  /// **'Tap to open system notification settings'**
  String get appSetting_notify_subtitleTile_android;

  /// No description provided for @appSync_nowTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get appSync_nowTile_titleText;

  /// No description provided for @appSync_nowTile_titleText_syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get appSync_nowTile_titleText_syncing;

  /// No description provided for @appSync_nowTile_dateFormat.
  ///
  /// In en, this message translates to:
  /// **'{ymd} {jms}'**
  String appSync_nowTile_dateFormat(DateTime ymd, DateTime jms);

  /// No description provided for @appSync_nowTile_text_noDate.
  ///
  /// In en, this message translates to:
  /// **'Last Sync: N/A'**
  String get appSync_nowTile_text_noDate;

  /// No description provided for @appSync_nowTile_text.
  ///
  /// In en, this message translates to:
  /// **'Last Sync: {dateStr}'**
  String appSync_nowTile_text(String dateStr);

  /// No description provided for @appSync_nowTile_errorText_noDate.
  ///
  /// In en, this message translates to:
  /// **'Last Sync (Error): N/A'**
  String get appSync_nowTile_errorText_noDate;

  /// No description provided for @appSync_nowTile_errorText.
  ///
  /// In en, this message translates to:
  /// **'Last Sync (Error): {dateStr}'**
  String appSync_nowTile_errorText(String dateStr);

  /// No description provided for @appSync_nowTile_syncingText.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get appSync_nowTile_syncingText;

  /// No description provided for @appSync_nowTile_syncingText_withPrt.
  ///
  /// In en, this message translates to:
  /// **'Syncing: {prt}'**
  String appSync_nowTile_syncingText_withPrt(num prt);

  /// No description provided for @appSync_nowTile_cancellingText.
  ///
  /// In en, this message translates to:
  /// **'Canceling...'**
  String get appSync_nowTile_cancellingText;

  /// No description provided for @appSync_nowTile_cancelText_noDate.
  ///
  /// In en, this message translates to:
  /// **'Last Sync (Cancelled): N/A'**
  String get appSync_nowTile_cancelText_noDate;

  /// No description provided for @appSync_nowTile_cancelText.
  ///
  /// In en, this message translates to:
  /// **'Last Sync (Cancelled): {dateStr}'**
  String appSync_nowTile_cancelText(String dateStr);

  /// No description provided for @appSync_failedTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Check Failure Logs'**
  String get appSync_failedTile_titleText;

  /// No description provided for @appSync_failedTile_errorText.
  ///
  /// In en, this message translates to:
  /// **'[Error]: {info}'**
  String appSync_failedTile_errorText(String info);

  /// No description provided for @appSync_failedTile_webdavMulti_counterText.
  ///
  /// In en, this message translates to:
  /// **'{reason}: {count}'**
  String appSync_failedTile_webdavMulti_counterText(String reason, int count);

  /// No description provided for @appSync_webdav_resultStatus.
  ///
  /// In en, this message translates to:
  /// **'{status, select, success {Completed} cancelled {Canceled} failed {Failed} multi {Multiple statuses} other {Unknown status}}'**
  String appSync_webdav_resultStatus(String status);

  /// No description provided for @appSync_webdav_resultStatus_withReason.
  ///
  /// In en, this message translates to:
  /// **'{status, select, success {Completed due to {reason}} cancelled {Canceled due to {reason}} failed {Failed due to {reason}} multi {Multiple statuses due to {reason}} other {Unknown status}}'**
  String appSync_webdav_resultStatus_withReason(String status, String reason);

  /// No description provided for @appSync_webdav_resultReason.
  ///
  /// In en, this message translates to:
  /// **'{reason, select, error {Error} userAction {User action required} missingHabitUuid {Missing habit UUID} empty {Empty data} other {Unknown reason}}'**
  String appSync_webdav_resultReason(String reason);

  /// No description provided for @appSync_webdav_newServerConfirmDialog_titleText.
  ///
  /// In en, this message translates to:
  /// **'New Location'**
  String get appSync_webdav_newServerConfirmDialog_titleText;

  /// No description provided for @appSync_webdav_newServerConfirmDialog_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Syncing will create necessary directories and upload local habits to the server. Continue?'**
  String get appSync_webdav_newServerConfirmDialog_subtitleText;

  /// No description provided for @appSync_webdav_newServerConfirmDialog_confirmText.
  ///
  /// In en, this message translates to:
  /// **'Sync Now!'**
  String get appSync_webdav_newServerConfirmDialog_confirmText;

  /// No description provided for @appSync_webdav_oldServerConfirmDialog_titleText.
  ///
  /// In en, this message translates to:
  /// **'Confirm Sync'**
  String get appSync_webdav_oldServerConfirmDialog_titleText;

  /// No description provided for @appSync_webdav_oldServerConfirmDialog_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Directory isn\'t empty. Syncing will merge server and local habits. Continue?'**
  String get appSync_webdav_oldServerConfirmDialog_subtitleText;

  /// No description provided for @appSync_webdav_oldServerConfirmDialog_confirmText.
  ///
  /// In en, this message translates to:
  /// **'Confirm Merge'**
  String get appSync_webdav_oldServerConfirmDialog_confirmText;

  /// No description provided for @appSync_exportAllLogsTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Export Failed Sync Logs'**
  String get appSync_exportAllLogsTile_titleText;

  /// No description provided for @appSync_exportAllLogsTile_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'{isEmpty, select, true {No log founded} false {Tap to export} other {loading...}}'**
  String appSync_exportAllLogsTile_subtitleText(String isEmpty);

  /// No description provided for @appSync_syncServerType_text.
  ///
  /// In en, this message translates to:
  /// **'{isCurrent, select, true {Current: } other {}}{name, select, webdav {WebDAV} fake {Fake (Only For Debugger)} other {Unknown ({name})}}'**
  String appSync_syncServerType_text(String name, String isCurrent);

  /// No description provided for @appSync_networkType_text.
  ///
  /// In en, this message translates to:
  /// **'{type, select, mobile {Mobile} wifi {Wifi} other {Unknown}}'**
  String appSync_networkType_text(String type);

  /// Localized display text for app sync interval
  ///
  /// In en, this message translates to:
  /// **'{name, select, manual {Manual} minute5 {5 Minutes} minute15 {15 Minutes} minute30 {30 Minutes} hour1 {1 Hour} other {Unknown}}'**
  String appSync_syncInterval_text(String name);

  /// No description provided for @appSync_syncIntervalTile_title.
  ///
  /// In en, this message translates to:
  /// **'Fetch Interval'**
  String get appSync_syncIntervalTile_title;

  /// No description provided for @appSync_summaryTile_title.
  ///
  /// In en, this message translates to:
  /// **'Sync Server'**
  String get appSync_summaryTile_title;

  /// No description provided for @appSync_summaryTile_subtitle_text_notConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not Configured'**
  String get appSync_summaryTile_subtitle_text_notConfigured;

  /// No description provided for @appSync_exportAllLogsTile_exportSubjectText.
  ///
  /// In en, this message translates to:
  /// **'All recent failed sync logs'**
  String get appSync_exportAllLogsTile_exportSubjectText;

  /// No description provided for @appSync_serverEditor_saveDialog_titleText.
  ///
  /// In en, this message translates to:
  /// **'Confirm Save Changes'**
  String get appSync_serverEditor_saveDialog_titleText;

  /// No description provided for @appSync_serverEditor_saveDialog_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Saving will overwrite previous server configuration.'**
  String get appSync_serverEditor_saveDialog_subtitleText;

  /// No description provided for @appSync_serverEditor_exitDialog_titleText.
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get appSync_serverEditor_exitDialog_titleText;

  /// No description provided for @appSync_serverEditor_exitDialog_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Exiting will discard all unsaved changes.'**
  String get appSync_serverEditor_exitDialog_subtitleText;

  /// No description provided for @appSync_serverEditor_deleteDialog_titleText.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get appSync_serverEditor_deleteDialog_titleText;

  /// No description provided for @appSync_serverEditor_deleteDialog_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Deleting will remove current server config.'**
  String get appSync_serverEditor_deleteDialog_subtitleText;

  /// No description provided for @appSync_serverEditor_titleText_add.
  ///
  /// In en, this message translates to:
  /// **'New Sync Server'**
  String get appSync_serverEditor_titleText_add;

  /// No description provided for @appSync_serverEditor_titleText_modify.
  ///
  /// In en, this message translates to:
  /// **'Modify Sync Server'**
  String get appSync_serverEditor_titleText_modify;

  /// No description provided for @appSync_serverEditor_advance_titleText.
  ///
  /// In en, this message translates to:
  /// **'Advanced Configs'**
  String get appSync_serverEditor_advance_titleText;

  /// No description provided for @appSync_serverEditor_pathTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get appSync_serverEditor_pathTile_titleText;

  /// No description provided for @appSync_serverEditor_pathTile_hintText.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid WebDAV path here.'**
  String get appSync_serverEditor_pathTile_hintText;

  /// No description provided for @appSync_serverEditor_pathTile_errorText_emptyPath.
  ///
  /// In en, this message translates to:
  /// **'Path shouldn\'t be empty!'**
  String get appSync_serverEditor_pathTile_errorText_emptyPath;

  /// No description provided for @appSync_serverEditor_usernameTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get appSync_serverEditor_usernameTile_titleText;

  /// No description provided for @appSync_serverEditor_usernameTile_hintText.
  ///
  /// In en, this message translates to:
  /// **'Enter username here, leave empty if not required.'**
  String get appSync_serverEditor_usernameTile_hintText;

  /// No description provided for @appSync_serverEditor_passwordTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get appSync_serverEditor_passwordTile_titleText;

  /// No description provided for @appSync_serverEditor_ignoreSSLTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Ignore SSL Certificate'**
  String get appSync_serverEditor_ignoreSSLTile_titleText;

  /// No description provided for @appSync_serverEditor_timeoutTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Sync Timeout Seconds'**
  String get appSync_serverEditor_timeoutTile_titleText;

  /// No description provided for @appSync_serverEditor_timeoutTile_hintText.
  ///
  /// In en, this message translates to:
  /// **'Default: {seconds, plural, =0 {Infinite} other {{seconds}{unit}}}'**
  String appSync_serverEditor_timeoutTile_hintText(int seconds, String unit);

  /// No description provided for @appSync_serverEditor_timeoutTile_unitText.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get appSync_serverEditor_timeoutTile_unitText;

  /// No description provided for @appSync_serverEditor_connTimeoutTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Network Connection Timeout Seconds'**
  String get appSync_serverEditor_connTimeoutTile_titleText;

  /// No description provided for @appSync_serverEditor_connTimeoutTile_hintText.
  ///
  /// In en, this message translates to:
  /// **'Default: {seconds, plural, =0 {Infinite} other {{seconds}{unit}}}'**
  String appSync_serverEditor_connTimeoutTile_hintText(
    int seconds,
    String unit,
  );

  /// No description provided for @appSync_serverEditor_connTimeoutTile_unitText.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get appSync_serverEditor_connTimeoutTile_unitText;

  /// No description provided for @appSync_serverEditor_connRetryCountTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Network Connection Retry Count'**
  String get appSync_serverEditor_connRetryCountTile_titleText;

  /// No description provided for @appSync_serverEditor_connRetryCountTile_hintText.
  ///
  /// In en, this message translates to:
  /// **'Default: {count, plural, =0 {Retry disabled} other {{count}}}'**
  String appSync_serverEditor_connRetryCountTile_hintText(int count);

  /// No description provided for @appSync_serverEditor_netTypeTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Network Sync Mode'**
  String get appSync_serverEditor_netTypeTile_titleText;

  /// No description provided for @appSync_serverEditor_netTypeTile_typeTooltip.
  ///
  /// In en, this message translates to:
  /// **'{type, select, mobile {Sync on Cellular Network} wifi {Sync on Wifi} other {Unknown}}'**
  String appSync_serverEditor_netTypeTile_typeTooltip(String type);

  /// No description provided for @appSync_serverEditor_netTypeTile_lowDataText.
  ///
  /// In en, this message translates to:
  /// **'LowData'**
  String get appSync_serverEditor_netTypeTile_lowDataText;

  /// No description provided for @appSync_noti_readyToSync_body.
  ///
  /// In en, this message translates to:
  /// **'Preparing to sync...'**
  String get appSync_noti_readyToSync_body;

  /// No description provided for @appSync_noti_syncing_title.
  ///
  /// In en, this message translates to:
  /// **'{synced, select, synced {Synced ({type})} failed {Sync Failed ({type})} other {Syncing ({type})}}'**
  String appSync_noti_syncing_title(String synced, String type);

  /// No description provided for @appSync_serverEditor_netTypeTile_lowDataTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sync in Low Data Mode'**
  String get appSync_serverEditor_netTypeTile_lowDataTooltip;

  /// No description provided for @experimentalFeatures_warnginBanner_title.
  ///
  /// In en, this message translates to:
  /// **'One or more experimental features are enabled, Use with caution.'**
  String get experimentalFeatures_warnginBanner_title;

  /// No description provided for @experimentalFeatures_habitSyncTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Habit Cloud Sync'**
  String get experimentalFeatures_habitSyncTile_titleText;

  /// No description provided for @experimentalFeatures_habitSyncTile_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Once enabled, the app\'s sync option will appear in settings'**
  String get experimentalFeatures_habitSyncTile_subtitleText;

  /// No description provided for @experimentalFeatures_warnTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Experimental feature ({syncName}) is disabled, but the function is still running.'**
  String experimentalFeatures_warnTile_titleText(String syncName);

  /// No description provided for @experimentalFeatures_warnTile_forHabitSyncText.
  ///
  /// In en, this message translates to:
  /// **'To completely disable, long press to access \'{menuName}\' and turn it off.'**
  String experimentalFeatures_warnTile_forHabitSyncText(String menuName);

  /// No description provided for @experimentalFeatures_habitSearchTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Habit Search'**
  String get experimentalFeatures_habitSearchTile_titleText;

  /// No description provided for @experimentalFeatures_habitSearchTile_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Once enabled, a search bar will appear at the top of the Habits screen and allowing to search habits.'**
  String get experimentalFeatures_habitSearchTile_subtitleText;

  /// No description provided for @appAbout_appbarTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get appAbout_appbarTile_titleText;

  /// No description provided for @appAbout_versionTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Version: {appVersion}'**
  String appAbout_versionTile_titleText(String appVersion);

  /// No description provided for @appAbout_versionTile_changeLogPath.
  ///
  /// In en, this message translates to:
  /// **'CHANGELOG.md'**
  String get appAbout_versionTile_changeLogPath;

  /// No description provided for @appAbout_sourceCodeTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get appAbout_sourceCodeTile_titleText;

  /// No description provided for @appAbout_issueTrackerTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Issue tracker'**
  String get appAbout_issueTrackerTile_titleText;

  /// No description provided for @appAbout_contactEmailTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Contact me'**
  String get appAbout_contactEmailTile_titleText;

  /// No description provided for @appAbout_contactEmailTile_emailBody.
  ///
  /// In en, this message translates to:
  /// **'Hi, I\'m glad you reached out to me.\nIf you\'re reporting a bug, please indicate the app version and describe the steps to reproduce it.\n--------------------------------------'**
  String get appAbout_contactEmailTile_emailBody;

  /// No description provided for @appAbout_licenseTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get appAbout_licenseTile_titleText;

  /// No description provided for @appAbout_licenseTile_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'Apache License, Version 2.0'**
  String get appAbout_licenseTile_subtitleText;

  /// No description provided for @appAbout_licenseThirdPartyTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Third Party Licensing Statement'**
  String get appAbout_licenseThirdPartyTile_titleText;

  /// No description provided for @appAbout_licenseThirdPartyTile_subtitleText.
  ///
  /// In en, this message translates to:
  /// **'flutter'**
  String get appAbout_licenseThirdPartyTile_subtitleText;

  /// No description provided for @appAbout_privacyTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get appAbout_privacyTile_titleText;

  /// No description provided for @appAbout_privacyTile_subTitleText.
  ///
  /// In en, this message translates to:
  /// **'Access the privacy policy in this app'**
  String get appAbout_privacyTile_subTitleText;

  /// No description provided for @appAbout_donateTile_titleText.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get appAbout_donateTile_titleText;

  /// No description provided for @appAbout_donateTile_subTitleText.
  ///
  /// In en, this message translates to:
  /// **'I\'m a personal developer. If you like this app, please buy me a ☕.'**
  String get appAbout_donateTile_subTitleText;

  /// Donate begin with `@` and split with `,`, available ways: paypal, buyMeACoffee, alipay, wechatPay
  ///
  /// In en, this message translates to:
  /// **'@paypal,@buyMeACoffee,@alipay,@wechatPay,@cryptoCurrencyAll'**
  String get appAbout_donateTile_ways;

  /// No description provided for @donateWay_paypal.
  ///
  /// In en, this message translates to:
  /// **'Paypal'**
  String get donateWay_paypal;

  /// No description provided for @donateWay_buyMeACoffee.
  ///
  /// In en, this message translates to:
  /// **'Buy me a coffee'**
  String get donateWay_buyMeACoffee;

  /// No description provided for @donateWay_alipay.
  ///
  /// In en, this message translates to:
  /// **'Alipay'**
  String get donateWay_alipay;

  /// No description provided for @donateWay_wechatPay.
  ///
  /// In en, this message translates to:
  /// **'Wechat Pay'**
  String get donateWay_wechatPay;

  /// No description provided for @donateWay_cryptoCurrency.
  ///
  /// In en, this message translates to:
  /// **'Crypto Currencies'**
  String get donateWay_cryptoCurrency;

  /// No description provided for @donateWay_cryptoCurrency_BTC.
  ///
  /// In en, this message translates to:
  /// **'BTC'**
  String get donateWay_cryptoCurrency_BTC;

  /// No description provided for @donateWay_cryptoCurrency_ETH.
  ///
  /// In en, this message translates to:
  /// **'ETH'**
  String get donateWay_cryptoCurrency_ETH;

  /// No description provided for @donateWay_cryptoCurrency_BNB.
  ///
  /// In en, this message translates to:
  /// **'BNB'**
  String get donateWay_cryptoCurrency_BNB;

  /// No description provided for @donateWay_cryptoCurrency_AVAX.
  ///
  /// In en, this message translates to:
  /// **'AVAX'**
  String get donateWay_cryptoCurrency_AVAX;

  /// No description provided for @donateWay_cryptoCurrency_FTM.
  ///
  /// In en, this message translates to:
  /// **'FTM'**
  String get donateWay_cryptoCurrency_FTM;

  /// No description provided for @donateWay_firstQRGroup.
  ///
  /// In en, this message translates to:
  /// **'Alipay & Wechat Pay'**
  String get donateWay_firstQRGroup;

  /// No description provided for @appAbout_donateDialog_copiedCrypto_msg.
  ///
  /// In en, this message translates to:
  /// **'Copied {name}\'s Address'**
  String appAbout_donateDialog_copiedCrypto_msg(String name);

  /// No description provided for @batchCheckin_appbar_title.
  ///
  /// In en, this message translates to:
  /// **'Batch Check-in'**
  String get batchCheckin_appbar_title;

  /// No description provided for @batchCheckin_datePicker_prevButton_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get batchCheckin_datePicker_prevButton_tooltip;

  /// No description provided for @batchCheckin_datePicker_nextButton_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get batchCheckin_datePicker_nextButton_tooltip;

  /// No description provided for @batchCheckin_status_skip_text.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get batchCheckin_status_skip_text;

  /// No description provided for @batchCheckin_status_ok_text.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get batchCheckin_status_ok_text;

  /// No description provided for @batchCheckin_status_double_text.
  ///
  /// In en, this message translates to:
  /// **'x2 Hit!'**
  String get batchCheckin_status_double_text;

  /// No description provided for @batchCheckin_status_zero_text.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get batchCheckin_status_zero_text;

  /// No description provided for @batchCheckin_habits_groupTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{Habit} other{Habits}} selected'**
  String batchCheckin_habits_groupTitle(int count);

  /// No description provided for @batchCheckin_save_button_text.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get batchCheckin_save_button_text;

  /// No description provided for @batchCheckin_reset_button_text.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get batchCheckin_reset_button_text;

  /// No description provided for @batchCheckin_completed_snackbar_text.
  ///
  /// In en, this message translates to:
  /// **'Modified {count, plural, =1{habit\'s status} other{status of {count} habits}}'**
  String batchCheckin_completed_snackbar_text(int count);

  /// No description provided for @batchCheckin_save_confirmDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Overwrite Existing Records'**
  String get batchCheckin_save_confirmDialog_title;

  /// No description provided for @batchCheckin_save_confirmDialog_body.
  ///
  /// In en, this message translates to:
  /// **'Existing records will be overwritten After saving, previous records will be lost.'**
  String get batchCheckin_save_confirmDialog_body;

  /// No description provided for @batchCheckin_save_confirmDialog_confirmButton_text.
  ///
  /// In en, this message translates to:
  /// **'save'**
  String get batchCheckin_save_confirmDialog_confirmButton_text;

  /// No description provided for @batchCheckin_save_confirmDialog_cancelButton_text.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get batchCheckin_save_confirmDialog_cancelButton_text;

  /// No description provided for @batchCheckin_close_confirmDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm Return'**
  String get batchCheckin_close_confirmDialog_title;

  /// No description provided for @batchCheckin_close_confirmDialog_body.
  ///
  /// In en, this message translates to:
  /// **'Check-in Status Changes won\'t be applied before saved'**
  String get batchCheckin_close_confirmDialog_body;

  /// No description provided for @batchCheckin_close_confirmDialog_confirmButton_text.
  ///
  /// In en, this message translates to:
  /// **'exit'**
  String get batchCheckin_close_confirmDialog_confirmButton_text;

  /// No description provided for @batchCheckin_close_confirmDialog_cancelButton_text.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get batchCheckin_close_confirmDialog_cancelButton_text;

  /// No description provided for @appReminder_dailyReminder_title.
  ///
  /// In en, this message translates to:
  /// **'WishLoop'**
  String get appReminder_dailyReminder_title;

  /// No description provided for @appReminder_dailyReminder_body.
  ///
  /// In en, this message translates to:
  /// **'Make a little time for something you love today.'**
  String get appReminder_dailyReminder_body;

  /// No description provided for @common_habitColorType_cc1.
  ///
  /// In en, this message translates to:
  /// **'Deep lilac'**
  String get common_habitColorType_cc1;

  /// No description provided for @common_habitColorType_cc2.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get common_habitColorType_cc2;

  /// No description provided for @common_habitColorType_cc3.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get common_habitColorType_cc3;

  /// No description provided for @common_habitColorType_cc4.
  ///
  /// In en, this message translates to:
  /// **'Royal blue'**
  String get common_habitColorType_cc4;

  /// No description provided for @common_habitColorType_cc5.
  ///
  /// In en, this message translates to:
  /// **'Dark cyan'**
  String get common_habitColorType_cc5;

  /// No description provided for @common_habitColorType_cc6.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get common_habitColorType_cc6;

  /// No description provided for @common_habitColorType_cc7.
  ///
  /// In en, this message translates to:
  /// **'Amber'**
  String get common_habitColorType_cc7;

  /// No description provided for @common_habitColorType_cc8.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get common_habitColorType_cc8;

  /// No description provided for @common_habitColorType_cc9.
  ///
  /// In en, this message translates to:
  /// **'Lime green'**
  String get common_habitColorType_cc9;

  /// No description provided for @common_habitColorType_cc10.
  ///
  /// In en, this message translates to:
  /// **'Dark orchid'**
  String get common_habitColorType_cc10;

  /// No description provided for @common_habitColorType_custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get common_habitColorType_custom;

  /// unknown habit color type name
  ///
  /// In en, this message translates to:
  /// **'Color {index}'**
  String common_habitColorType_default(int index);

  /// No description provided for @common_appThemeColor_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get common_appThemeColor_system;

  /// No description provided for @common_appThemeColor_primary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get common_appThemeColor_primary;

  /// No description provided for @common_appThemeColor_dynamic.
  ///
  /// In en, this message translates to:
  /// **'Dynamic'**
  String get common_appThemeColor_dynamic;

  /// No description provided for @common_customDateTimeFormatPicker_useSystemFormat_text.
  ///
  /// In en, this message translates to:
  /// **'Use system format'**
  String get common_customDateTimeFormatPicker_useSystemFormat_text;

  /// No description provided for @common_customDateTimeFormatPicker_fmtTileText.
  ///
  /// In en, this message translates to:
  /// **'Date format'**
  String get common_customDateTimeFormatPicker_fmtTileText;

  /// No description provided for @common_customDateTimeFormatPicker_ymd_text.
  ///
  /// In en, this message translates to:
  /// **'Year Month Day'**
  String get common_customDateTimeFormatPicker_ymd_text;

  /// No description provided for @common_customDateTimeFormatPicker_mdy_text.
  ///
  /// In en, this message translates to:
  /// **'Month Day Year'**
  String get common_customDateTimeFormatPicker_mdy_text;

  /// No description provided for @common_customDateTimeFormatPicker_dmy_text.
  ///
  /// In en, this message translates to:
  /// **'Day Month Year'**
  String get common_customDateTimeFormatPicker_dmy_text;

  /// No description provided for @common_customDateTimeFormatPicker_SepTileText.
  ///
  /// In en, this message translates to:
  /// **'Separator'**
  String get common_customDateTimeFormatPicker_SepTileText;

  /// No description provided for @common_customDateTimeFormatPicker_sepDash_text.
  ///
  /// In en, this message translates to:
  /// **'Dash'**
  String get common_customDateTimeFormatPicker_sepDash_text;

  /// No description provided for @common_customDateTimeFormatPicker_sepSlash_text.
  ///
  /// In en, this message translates to:
  /// **'Slash'**
  String get common_customDateTimeFormatPicker_sepSlash_text;

  /// No description provided for @common_customDateTimeFormatPicker_sepSpace_text.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get common_customDateTimeFormatPicker_sepSpace_text;

  /// No description provided for @common_customDateTimeFormatPicker_sepDot_text.
  ///
  /// In en, this message translates to:
  /// **'Dot'**
  String get common_customDateTimeFormatPicker_sepDot_text;

  /// No description provided for @common_customDateTimeFormatPicker_empty_text.
  ///
  /// In en, this message translates to:
  /// **'No Separator'**
  String get common_customDateTimeFormatPicker_empty_text;

  /// split char
  ///
  /// In en, this message translates to:
  /// **'{splitName}: \"{splitChar}\"'**
  String common_customDateTimeFormatPicker_sep_formatter(
    String splitName,
    String splitChar,
  );

  /// No description provided for @common_customDateTimeFormatPicker_12Hour_text.
  ///
  /// In en, this message translates to:
  /// **'Use 12-hour format'**
  String get common_customDateTimeFormatPicker_12Hour_text;

  /// No description provided for @common_customDateTimeFormatPicker_monthName_text.
  ///
  /// In en, this message translates to:
  /// **'Use full name'**
  String get common_customDateTimeFormatPicker_monthName_text;

  /// No description provided for @common_customDateTimeFormatPicker_applyFreqChart_text.
  ///
  /// In en, this message translates to:
  /// **'Apply for Freq Chart'**
  String get common_customDateTimeFormatPicker_applyFreqChart_text;

  /// No description provided for @common_customDateTimeFormatPicker_applyHeapmap_text.
  ///
  /// In en, this message translates to:
  /// **'Apply for Calendar'**
  String get common_customDateTimeFormatPicker_applyHeapmap_text;

  /// No description provided for @common_customDateTimeFormatPicker_cancelButton_text.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get common_customDateTimeFormatPicker_cancelButton_text;

  /// No description provided for @common_customDateTimeFormatPicker_confirmButton_text.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get common_customDateTimeFormatPicker_confirmButton_text;

  /// No description provided for @common_errorPage_title.
  ///
  /// In en, this message translates to:
  /// **'Oops, Crashed!'**
  String get common_errorPage_title;

  /// No description provided for @common_errorPage_copied.
  ///
  /// In en, this message translates to:
  /// **'Copied crash information'**
  String get common_errorPage_copied;

  /// No description provided for @common_enable_text.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get common_enable_text;

  /// No description provided for @common_dontShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show again'**
  String get common_dontShowAgain;

  /// No description provided for @calendarPicker_clip_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get calendarPicker_clip_today;

  /// No description provided for @calendarPicker_clip_tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get calendarPicker_clip_tomorrow;

  /// No description provided for @calendarPicker_clip_after7Days.
  ///
  /// In en, this message translates to:
  /// **'Next {date}'**
  String calendarPicker_clip_after7Days(DateTime date);

  /// No description provided for @exportConfirmDialog_title_exportAll.
  ///
  /// In en, this message translates to:
  /// **'Export all habits?'**
  String get exportConfirmDialog_title_exportAll;

  /// No description provided for @exportConfirmDialog_title_exportMulti.
  ///
  /// In en, this message translates to:
  /// **'Export {number, plural, =0{current habit} =1{1 habit} other{{number} habits}}?'**
  String exportConfirmDialog_title_exportMulti(int number);

  /// No description provided for @exportConfirmDialog_option_includeRecords.
  ///
  /// In en, this message translates to:
  /// **'include records'**
  String get exportConfirmDialog_option_includeRecords;

  /// No description provided for @exportConfirmDialog_option_includeGroups.
  ///
  /// In en, this message translates to:
  /// **'include groups'**
  String get exportConfirmDialog_option_includeGroups;

  /// No description provided for @exportConfirmDialog_tile_includeRecords.
  ///
  /// In en, this message translates to:
  /// **'Include {count} records'**
  String exportConfirmDialog_tile_includeRecords(int count);

  /// No description provided for @exportConfirmDialog_tile_includeGroups.
  ///
  /// In en, this message translates to:
  /// **'Include {count} groups'**
  String exportConfirmDialog_tile_includeGroups(int count);

  /// No description provided for @exportConfirmDialog_cancel_buttonText.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get exportConfirmDialog_cancel_buttonText;

  /// No description provided for @exportConfirmDialog_confirm_buttonText.
  ///
  /// In en, this message translates to:
  /// **'export'**
  String get exportConfirmDialog_confirm_buttonText;

  /// No description provided for @debug_logLevelTile_title.
  ///
  /// In en, this message translates to:
  /// **'Logging Level'**
  String get debug_logLevelTile_title;

  /// No description provided for @debug_logLevelDialog_title.
  ///
  /// In en, this message translates to:
  /// **'Change Logging Level'**
  String get debug_logLevelDialog_title;

  /// No description provided for @debug_logLevel_debug.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get debug_logLevel_debug;

  /// No description provided for @debug_logLevel_info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get debug_logLevel_info;

  /// No description provided for @debug_logLevel_warn.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get debug_logLevel_warn;

  /// No description provided for @debug_logLevel_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get debug_logLevel_error;

  /// No description provided for @debug_logLevel_fatal.
  ///
  /// In en, this message translates to:
  /// **'Fatal'**
  String get debug_logLevel_fatal;

  /// No description provided for @debug_collectLogTile_title.
  ///
  /// In en, this message translates to:
  /// **'Collecting Logs'**
  String get debug_collectLogTile_title;

  /// No description provided for @debug_collectLogTile_enable_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to stop logging collection.'**
  String get debug_collectLogTile_enable_subtitle;

  /// No description provided for @debug_collectLogTile_disable_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to start logging collection.'**
  String get debug_collectLogTile_disable_subtitle;

  /// No description provided for @debug_downladDebugLogs_subject.
  ///
  /// In en, this message translates to:
  /// **'Downloading debugging logs'**
  String get debug_downladDebugLogs_subject;

  /// No description provided for @dbeug_clearDebugLogs_complete_snackbar.
  ///
  /// In en, this message translates to:
  /// **'Debugging logs Cleared.'**
  String get dbeug_clearDebugLogs_complete_snackbar;

  /// No description provided for @debug_downladDebugInfo_subject.
  ///
  /// In en, this message translates to:
  /// **'Downloading debugging information'**
  String get debug_downladDebugInfo_subject;

  /// No description provided for @debug_downladDebugZip_subject.
  ///
  /// In en, this message translates to:
  /// **'Downloading {fileName}'**
  String debug_downladDebugZip_subject(String fileName);

  /// No description provided for @debug_missingDebugLogFile_snackbar.
  ///
  /// In en, this message translates to:
  /// **'Debug log doesn\'t exist.'**
  String get debug_missingDebugLogFile_snackbar;

  /// No description provided for @debug_debuggerLogCard_title.
  ///
  /// In en, this message translates to:
  /// **'Logging Information'**
  String get debug_debuggerLogCard_title;

  /// No description provided for @debug_debuggerLogCard_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Includes local debugging log information, need to turn on the log collection switcher.'**
  String get debug_debuggerLogCard_subtitle;

  /// No description provided for @debug_debuggerLogCard_saveButton_text.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get debug_debuggerLogCard_saveButton_text;

  /// No description provided for @debug_debuggerLogCard_clearButton_text.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get debug_debuggerLogCard_clearButton_text;

  /// No description provided for @debug_debuggerInfoCard_title.
  ///
  /// In en, this message translates to:
  /// **'Debugging Information'**
  String get debug_debuggerInfoCard_title;

  /// No description provided for @debug_debuggerInfoCard_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Includes app\'s debugging information.'**
  String get debug_debuggerInfoCard_subtitle;

  /// No description provided for @debug_debuggerInfoCard_openButton_text.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get debug_debuggerInfoCard_openButton_text;

  /// No description provided for @debug_debuggerInfoCard_saveButton_text.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get debug_debuggerInfoCard_saveButton_text;

  /// No description provided for @debug_debuggerInfo_notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Collecting App\'s Info...'**
  String get debug_debuggerInfo_notificationTitle;

  /// No description provided for @confirmDialog_confirm_text.
  ///
  /// In en, this message translates to:
  /// **'{type, select, save {Save} exit {Exit} delete {Delete} other {Confirm}}'**
  String confirmDialog_confirm_text(String type);

  /// No description provided for @confirmDialog_cancel_text.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get confirmDialog_cancel_text;

  /// No description provided for @snackbar_undoText.
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get snackbar_undoText;

  /// No description provided for @snackbar_dismissText.
  ///
  /// In en, this message translates to:
  /// **'DISMISS'**
  String get snackbar_dismissText;

  /// No description provided for @contributors_tile_title.
  ///
  /// In en, this message translates to:
  /// **'Contributors'**
  String get contributors_tile_title;

  /// No description provided for @userAction_tap.
  ///
  /// In en, this message translates to:
  /// **'Tap'**
  String get userAction_tap;

  /// No description provided for @userAction_doubleTap.
  ///
  /// In en, this message translates to:
  /// **'Double'**
  String get userAction_doubleTap;

  /// No description provided for @userAction_longTap.
  ///
  /// In en, this message translates to:
  /// **'Long'**
  String get userAction_longTap;

  /// No description provided for @channelName_habitReminder.
  ///
  /// In en, this message translates to:
  /// **'Habit Reminder'**
  String get channelName_habitReminder;

  /// No description provided for @channelName_appReminder.
  ///
  /// In en, this message translates to:
  /// **'Prompt'**
  String get channelName_appReminder;

  /// No description provided for @channelName_appDebugger.
  ///
  /// In en, this message translates to:
  /// **'Debugger'**
  String get channelName_appDebugger;

  /// No description provided for @channelName_appSyncing.
  ///
  /// In en, this message translates to:
  /// **'Sync Process'**
  String get channelName_appSyncing;

  /// No description provided for @channelDesc_appSyncing.
  ///
  /// In en, this message translates to:
  /// **'Used to show sync progress and non-failure results'**
  String get channelDesc_appSyncing;

  /// No description provided for @channelName_appSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync Failed'**
  String get channelName_appSyncFailed;

  /// No description provided for @channelDesc_appSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Used to alert when sync fails'**
  String get channelDesc_appSyncFailed;

  /// Title in the MaterialBanner showing the current version changelog on first open after upgrade.
  ///
  /// In en, this message translates to:
  /// **'What\'s New in v{version}'**
  String changelog_banner_title(String version);

  /// Dismiss button label on the changelog MaterialBanner.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get changelog_banner_action;

  /// View button label on the changelog MaterialBanner that opens the full changelog dialog.
  ///
  /// In en, this message translates to:
  /// **'VIEW'**
  String get changelog_banner_view;

  /// No description provided for @changelog_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Changelog'**
  String get changelog_dialog_title;

  /// Button label inside the changelog dialog to toggle from current-version-only to full CHANGELOG.md content.
  ///
  /// In en, this message translates to:
  /// **'View Full Changelog'**
  String get changelog_view_full;

  /// Virtual group name for habits without a group
  ///
  /// In en, this message translates to:
  /// **'No Group'**
  String get habitGroup_uncategorized;

  /// Title for the group info tile on the habit detail page
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get habitDetail_groupTile_title;

  /// Title for the group selector tile on the habit edit page
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get habitEdit_groupTile_title;

  /// Placeholder text for the group picker search field
  ///
  /// In en, this message translates to:
  /// **'Search or create group'**
  String get habitEdit_groupPicker_hintText;

  /// Option text for selecting no group
  ///
  /// In en, this message translates to:
  /// **'No Group'**
  String get habitEdit_groupPicker_noGroup;

  /// Button text to create a new group with the given name
  ///
  /// In en, this message translates to:
  /// **'Create \"{name}\"'**
  String habitEdit_groupPicker_createGroup(String name);

  /// Placeholder text shown in the group picker while groups are loading
  ///
  /// In en, this message translates to:
  /// **'Loading groups…'**
  String get habitEdit_groupPicker_loading;

  /// Title for the Group management page AppBar
  ///
  /// In en, this message translates to:
  /// **'Manage Groups'**
  String get groupManage_appbar_title;

  /// AppBar title in selection mode, {count} = number of selected groups
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String groupManage_selectionAppbar_title(int count);

  /// Empty state text shown when no groups exist
  ///
  /// In en, this message translates to:
  /// **'No groups yet\nTap + to create your first group'**
  String get groupManage_emptyState_text;

  /// Title for the delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Group'**
  String get groupManage_deleteDialog_title;

  /// Content body for the delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {Habits in this group will become uncategorized.} other {Habits in these {count} groups will become uncategorized.}}'**
  String groupManage_deleteDialog_content(int count);

  /// Confirm button text for delete dialog
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get groupManage_deleteDialog_confirm;

  /// Cancel button text for delete dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get groupManage_deleteDialog_cancel;

  /// SnackBar text after successful group deletion
  ///
  /// In en, this message translates to:
  /// **'Group deleted'**
  String get groupManage_deleted_snackbarText;

  /// SnackBar undo button text
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get groupManage_undo_snackbarAction;

  /// Title for the group edit dialog
  ///
  /// In en, this message translates to:
  /// **'Edit Group'**
  String get groupManage_editDialog_title;

  /// Title for the group creation dialog
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get groupManage_createDialog_title;

  /// Validation error when group name is empty
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get groupManage_nameRequired;

  /// Validation error when group name exceeds max length
  ///
  /// In en, this message translates to:
  /// **'Name must be ≤ {max} characters'**
  String groupManage_nameTooLong(int max);

  /// Label for the group name input field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get groupManage_name_label;

  /// Label for the group description input field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get groupManage_desc_label;

  /// Validation warning when group description exceeds recommended length
  ///
  /// In en, this message translates to:
  /// **'Description should be ≤ {max} characters'**
  String groupManage_descTooLong(int max);

  /// Label for the sort selector entry
  ///
  /// In en, this message translates to:
  /// **'Sort Groups'**
  String get groupManage_sortTile_text;

  /// Section header text for Groups in Settings page
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groupManage_sectionTitle_text;

  /// Label shown for the group creation date in the edit dialog
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get groupManage_createDateTile_title;

  /// Label shown for the group modification date in the edit dialog
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get groupManage_modifyDateTile_title;

  /// Section label for the icon picker in group create/edit forms
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get groupManage_icon_label;

  /// Tooltip for the 'no icon' option in the group icon picker
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get groupManage_icon_none;

  /// Section label for the color picker in group create/edit forms
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get groupManage_color_label;

  /// Tooltip for the 'no color' option in the group color picker
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get groupManage_color_none;

  /// Tooltip for the reorder button that enters manual sort + selection mode
  ///
  /// In en, this message translates to:
  /// **'Reorder groups'**
  String get groupManage_reorder_tooltip;

  /// Menu item label for editing a group
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get groupManage_menu_edit;

  /// Menu item label for deleting a group
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get groupManage_menu_delete;

  /// Button in selection mode AppBar to select or deselect all groups
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get groupManage_selectAll;

  /// Menu item on Group header long-press to navigate to the group management page
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get groupHeader_menu_manage;

  /// Menu item on Group header long-press to collapse all groups
  ///
  /// In en, this message translates to:
  /// **'Collapse all'**
  String get groupHeader_menu_collapseAll;

  /// Menu item on Group header long-press to expand all groups
  ///
  /// In en, this message translates to:
  /// **'Expand all'**
  String get groupHeader_menu_expandAll;

  /// Subtitle for the Manage Groups tile in Settings
  ///
  /// In en, this message translates to:
  /// **'Create, edit, and delete habit groups'**
  String get appSetting_manageGroups_subtitleText;

  /// Group sort type: manual ordering via drag-and-drop
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get habitDisplay_groupType_manual;

  /// No description provided for @wToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get wToday;

  /// No description provided for @wHobbies.
  ///
  /// In en, this message translates to:
  /// **'Hobbies'**
  String get wHobbies;

  /// No description provided for @wWallet.
  ///
  /// In en, this message translates to:
  /// **'Hobby wallet'**
  String get wWallet;

  /// No description provided for @wWalletTab.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wWalletTab;

  /// No description provided for @wWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishes'**
  String get wWishlist;

  /// No description provided for @wTodayReward.
  ///
  /// In en, this message translates to:
  /// **'Today’s rewards'**
  String get wTodayReward;

  /// No description provided for @wMonthReward.
  ///
  /// In en, this message translates to:
  /// **'Monthly net rewards'**
  String get wMonthReward;

  /// No description provided for @wSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save a little dedication for the things you love.'**
  String get wSubtitle;

  /// No description provided for @wCurrentWish.
  ///
  /// In en, this message translates to:
  /// **'Your next reward'**
  String get wCurrentWish;

  /// No description provided for @wTodayHobbies.
  ///
  /// In en, this message translates to:
  /// **'Today’s hobbies'**
  String get wTodayHobbies;

  /// No description provided for @wAllDone.
  ///
  /// In en, this message translates to:
  /// **'Today’s dedication is safely saved.'**
  String get wAllDone;

  /// No description provided for @wEmptyToday.
  ///
  /// In en, this message translates to:
  /// **'No hobbies to record on this day.'**
  String get wEmptyToday;

  /// No description provided for @wEmptyHobbies.
  ///
  /// In en, this message translates to:
  /// **'Start with one thing you love'**
  String get wEmptyHobbies;

  /// No description provided for @wEmptyHobbiesBody.
  ///
  /// In en, this message translates to:
  /// **'Add a hobby and choose a small reward for each check-in.'**
  String get wEmptyHobbiesBody;

  /// No description provided for @wEmptyWishes.
  ///
  /// In en, this message translates to:
  /// **'Something to look forward to'**
  String get wEmptyWishes;

  /// No description provided for @wEmptyWishesBody.
  ///
  /// In en, this message translates to:
  /// **'Add something you truly want, then work toward it one day at a time.'**
  String get wEmptyWishesBody;

  /// No description provided for @wEmptyLedger.
  ///
  /// In en, this message translates to:
  /// **'Every small step will leave a record here.'**
  String get wEmptyLedger;

  /// No description provided for @wAddHobby.
  ///
  /// In en, this message translates to:
  /// **'Add hobby'**
  String get wAddHobby;

  /// No description provided for @wEditHobby.
  ///
  /// In en, this message translates to:
  /// **'Edit hobby'**
  String get wEditHobby;

  /// No description provided for @wAddWish.
  ///
  /// In en, this message translates to:
  /// **'Add wish'**
  String get wAddWish;

  /// No description provided for @wEditWish.
  ///
  /// In en, this message translates to:
  /// **'Edit wish'**
  String get wEditWish;

  /// No description provided for @wName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get wName;

  /// No description provided for @wEmoji.
  ///
  /// In en, this message translates to:
  /// **'Emoji / icon'**
  String get wEmoji;

  /// No description provided for @wDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get wDescription;

  /// No description provided for @wDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration (minutes)'**
  String get wDuration;

  /// No description provided for @wReward.
  ///
  /// In en, this message translates to:
  /// **'Amount per occurrence (¥)'**
  String get wReward;

  /// No description provided for @wFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get wFrequency;

  /// No description provided for @wWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Days of the week'**
  String get wWeekdays;

  /// No description provided for @wTimes.
  ///
  /// In en, this message translates to:
  /// **'Times per period'**
  String get wTimes;

  /// No description provided for @wDays.
  ///
  /// In en, this message translates to:
  /// **'Days per period'**
  String get wDays;

  /// No description provided for @wDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get wDaily;

  /// No description provided for @wWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get wWeekly;

  /// No description provided for @wMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get wMonthly;

  /// No description provided for @wCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom period'**
  String get wCustom;

  /// No description provided for @wFrequencyHint.
  ///
  /// In en, this message translates to:
  /// **'Check in on selected weekdays, at most once a day. Rest after reaching the period’s target.'**
  String get wFrequencyHint;

  /// No description provided for @wComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get wComplete;

  /// No description provided for @wCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed ✓'**
  String get wCompleted;

  /// No description provided for @wUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get wUndo;

  /// No description provided for @wSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get wSave;

  /// No description provided for @wCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get wCancel;

  /// No description provided for @wDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get wDelete;

  /// No description provided for @wArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get wArchive;

  /// No description provided for @wRestoreHobby.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get wRestoreHobby;

  /// No description provided for @wArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get wArchived;

  /// No description provided for @wShowArchived.
  ///
  /// In en, this message translates to:
  /// **'Show archived hobbies'**
  String get wShowArchived;

  /// No description provided for @wAdjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust balance'**
  String get wAdjust;

  /// No description provided for @wAdjustHelp.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive amount to add or a negative amount to subtract. Every adjustment is recorded.'**
  String get wAdjustHelp;

  /// No description provided for @wAmount.
  ///
  /// In en, this message translates to:
  /// **'Adjustment (¥)'**
  String get wAmount;

  /// No description provided for @wReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get wReason;

  /// No description provided for @wRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get wRecent;

  /// No description provided for @wLedgerLimit.
  ///
  /// In en, this message translates to:
  /// **'Showing the latest 200 entries. Full history is included in backups.'**
  String get wLedgerLimit;

  /// No description provided for @wEarn.
  ///
  /// In en, this message translates to:
  /// **'Hobby reward'**
  String get wEarn;

  /// No description provided for @wSpend.
  ///
  /// In en, this message translates to:
  /// **'Wish redeemed'**
  String get wSpend;

  /// No description provided for @wAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get wAdjustment;

  /// No description provided for @wTargetPrice.
  ///
  /// In en, this message translates to:
  /// **'Target price (¥)'**
  String get wTargetPrice;

  /// No description provided for @wNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get wNote;

  /// No description provided for @wPrimary.
  ///
  /// In en, this message translates to:
  /// **'Make this my primary wish'**
  String get wPrimary;

  /// No description provided for @wRedeem.
  ///
  /// In en, this message translates to:
  /// **'Redeem reward'**
  String get wRedeem;

  /// No description provided for @wConfirmRedeem.
  ///
  /// In en, this message translates to:
  /// **'Confirm redemption'**
  String get wConfirmRedeem;

  /// No description provided for @wReady.
  ///
  /// In en, this message translates to:
  /// **'🎉 Your reward is within reach'**
  String get wReady;

  /// No description provided for @wRedeemed.
  ///
  /// In en, this message translates to:
  /// **'Redeemed'**
  String get wRedeemed;

  /// No description provided for @wSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get wSettings;

  /// No description provided for @wCurrency.
  ///
  /// In en, this message translates to:
  /// **'Default currency'**
  String get wCurrency;

  /// No description provided for @wCurrencyValue.
  ///
  /// In en, this message translates to:
  /// **'CNY ¥ · Virtual bookkeeping unit'**
  String get wCurrencyValue;

  /// No description provided for @wDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Amounts in your hobby wallet are only for personal motivation and virtual bookkeeping.\nThe app does not provide real money rewards, withdrawals or currency exchange.'**
  String get wDisclaimer;

  /// No description provided for @wAbout.
  ///
  /// In en, this message translates to:
  /// **'About WishLoop'**
  String get wAbout;

  /// No description provided for @wAboutBody.
  ///
  /// In en, this message translates to:
  /// **'WishLoop · Hobby Wallet\nBuild lasting hobbies and reward yourself.\nBased on Table Habit, licensed under Apache-2.0.'**
  String get wAboutBody;

  /// No description provided for @wBackup.
  ///
  /// In en, this message translates to:
  /// **'Export full backup'**
  String get wBackup;

  /// No description provided for @wBackupHelp.
  ///
  /// In en, this message translates to:
  /// **'Includes hobbies, check-ins, ledger and wishes. Theme and language stay on this device.'**
  String get wBackupHelp;

  /// No description provided for @wImport.
  ///
  /// In en, this message translates to:
  /// **'Restore full backup'**
  String get wImport;

  /// No description provided for @wImportConfirm.
  ///
  /// In en, this message translates to:
  /// **'Restore replaces all current hobbies, check-ins, ledger and wishes. Export a backup first. Invalid files leave your data unchanged.'**
  String get wImportConfirm;

  /// No description provided for @wImportDone.
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get wImportDone;

  /// No description provided for @wBackupDone.
  ///
  /// In en, this message translates to:
  /// **'Backup saved'**
  String get wBackupDone;

  /// No description provided for @wLegacyImport.
  ///
  /// In en, this message translates to:
  /// **'Import Table Habit data'**
  String get wLegacyImport;

  /// No description provided for @wLegacyHelp.
  ///
  /// In en, this message translates to:
  /// **'Keep existing hobbies and check-ins. Historical records do not earn retroactive rewards.'**
  String get wLegacyHelp;

  /// No description provided for @wLegacyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Merge hobbies and historical check-ins. Matching records may be updated. Export a full backup first.'**
  String get wLegacyConfirm;

  /// No description provided for @wLegacyDone.
  ///
  /// In en, this message translates to:
  /// **'Import finished. Check your hobbies; historical check-ins do not earn rewards.'**
  String get wLegacyDone;

  /// No description provided for @wNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications & reminders'**
  String get wNotifications;

  /// No description provided for @wReminder.
  ///
  /// In en, this message translates to:
  /// **'Hobby reminder'**
  String get wReminder;

  /// No description provided for @wReminderHelp.
  ///
  /// In en, this message translates to:
  /// **'A gentle reminder at your chosen time. Android battery settings may delay delivery.'**
  String get wReminderHelp;

  /// No description provided for @wReminderDenied.
  ///
  /// In en, this message translates to:
  /// **'Could not enable reminders. Allow WishLoop notifications in Android settings.'**
  String get wReminderDenied;

  /// No description provided for @wTestNotification.
  ///
  /// In en, this message translates to:
  /// **'Send test notification'**
  String get wTestNotification;

  /// No description provided for @wTestSent.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent'**
  String get wTestSent;

  /// No description provided for @wRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get wRetry;

  /// No description provided for @wError.
  ///
  /// In en, this message translates to:
  /// **'The action could not be completed. Please try again.'**
  String get wError;

  /// No description provided for @wLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your data. Please retry.'**
  String get wLoadError;

  /// No description provided for @wInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter valid details and an amount; amounts round to two decimal places.'**
  String get wInvalid;

  /// No description provided for @wInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Not enough rewards to redeem this wish.'**
  String get wInsufficient;

  /// No description provided for @wAlreadyRedeemed.
  ///
  /// In en, this message translates to:
  /// **'This wish has already been redeemed.'**
  String get wAlreadyRedeemed;

  /// No description provided for @wSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get wSaved;

  /// No description provided for @wUndoDone.
  ///
  /// In en, this message translates to:
  /// **'Check-in and its reward undone'**
  String get wUndoDone;

  /// No description provided for @wNegativeBalance.
  ///
  /// In en, this message translates to:
  /// **'Undoing or adjusting can make your balance negative. Future rewards will continue to add up.'**
  String get wNegativeBalance;

  /// No description provided for @wDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Deleting does not erase rewards you have already earned.'**
  String get wDeleteConfirm;

  /// No description provided for @wNotificationsOff.
  ///
  /// In en, this message translates to:
  /// **'Reminders are off'**
  String get wNotificationsOff;

  /// No description provided for @wNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Make a little time for something you love today.'**
  String get wNotificationBody;

  /// No description provided for @wMinutes.
  ///
  /// In en, this message translates to:
  /// **'About {value} min'**
  String wMinutes(int value);

  /// No description provided for @wRewardLabel.
  ///
  /// In en, this message translates to:
  /// **'Reward {amount}'**
  String wRewardLabel(String amount);

  /// No description provided for @wCompleteFeedback.
  ///
  /// In en, this message translates to:
  /// **'{name} complete. Reward {amount} 🎉'**
  String wCompleteFeedback(String name, String amount);

  /// No description provided for @wWishAmounts.
  ///
  /// In en, this message translates to:
  /// **'{balance} / {target}'**
  String wWishAmounts(String balance, String target);

  /// No description provided for @wShortfall.
  ///
  /// In en, this message translates to:
  /// **'{amount} to go'**
  String wShortfall(String amount);

  /// No description provided for @wRedeemTitle.
  ///
  /// In en, this message translates to:
  /// **'Redeem {name}?'**
  String wRedeemTitle(String name);

  /// No description provided for @wRedeemBody.
  ///
  /// In en, this message translates to:
  /// **'Deduct from your hobby wallet:\n{price}\n\nBalance after redemption:\n{balance}\n\nThis is a virtual ledger entry. Any real purchase is your own decision.'**
  String wRedeemBody(String price, String balance);

  /// No description provided for @wRedeemedAt.
  ///
  /// In en, this message translates to:
  /// **'Redeemed {date}'**
  String wRedeemedAt(String date);

  /// No description provided for @wReminderBody.
  ///
  /// In en, this message translates to:
  /// **'You haven’t completed {name} today. Your reward: {amount}.'**
  String wReminderBody(String name, String amount);

  /// No description provided for @wRewardCalendar.
  ///
  /// In en, this message translates to:
  /// **'Reward calendar'**
  String get wRewardCalendar;

  /// No description provided for @wCalendarWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get wCalendarWeek;

  /// No description provided for @wCalendarMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get wCalendarMonth;

  /// No description provided for @wPreviousPeriod.
  ///
  /// In en, this message translates to:
  /// **'Previous period'**
  String get wPreviousPeriod;

  /// No description provided for @wNextPeriod.
  ///
  /// In en, this message translates to:
  /// **'Next period'**
  String get wNextPeriod;

  /// No description provided for @wPeriodNet.
  ///
  /// In en, this message translates to:
  /// **'Net rewards {amount}'**
  String wPeriodNet(String amount);

  /// No description provided for @wCalendarLegend.
  ///
  /// In en, this message translates to:
  /// **'Red: gain · Green: loss · Intensity scaled to this period'**
  String get wCalendarLegend;

  /// No description provided for @wExpandMonth.
  ///
  /// In en, this message translates to:
  /// **'Swipe down for month; swipe sideways to change week'**
  String get wExpandMonth;

  /// No description provided for @wCollapseWeek.
  ///
  /// In en, this message translates to:
  /// **'Swipe up on the header for week; swipe sideways to change month'**
  String get wCollapseWeek;

  /// No description provided for @wFutureDay.
  ///
  /// In en, this message translates to:
  /// **'Future date: recording is unavailable'**
  String get wFutureDay;

  /// No description provided for @wDateHobbies.
  ///
  /// In en, this message translates to:
  /// **'Hobbies for {date}'**
  String wDateHobbies(String date);

  /// No description provided for @wSelectedNet.
  ///
  /// In en, this message translates to:
  /// **'Selected day: {amount} net'**
  String wSelectedNet(String amount);

  /// No description provided for @wSignedRewardHelp.
  ///
  /// In en, this message translates to:
  /// **'Positive amounts reward you; negative amounts deduct for unwanted habits. Amounts round to two decimal places.'**
  String get wSignedRewardHelp;

  /// No description provided for @wPenalty.
  ///
  /// In en, this message translates to:
  /// **'Habit deduction'**
  String get wPenalty;

  /// No description provided for @wPenaltyLabel.
  ///
  /// In en, this message translates to:
  /// **'Occurrence deduction {amount}'**
  String wPenaltyLabel(String amount);

  /// No description provided for @wRecordPenalty.
  ///
  /// In en, this message translates to:
  /// **'Record occurrence'**
  String get wRecordPenalty;

  /// No description provided for @wPenaltyRecorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded ✓'**
  String get wPenaltyRecorded;

  /// No description provided for @wPenaltyFeedback.
  ///
  /// In en, this message translates to:
  /// **'{name} recorded: {amount} deducted'**
  String wPenaltyFeedback(String name, String amount);

  /// No description provided for @wPenaltyReminder.
  ///
  /// In en, this message translates to:
  /// **'Avoid {name}; recording an occurrence deducts {amount}.'**
  String wPenaltyReminder(String name, String amount);

  /// No description provided for @wEstimateReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached'**
  String get wEstimateReached;

  /// No description provided for @wEstimateDays.
  ///
  /// In en, this message translates to:
  /// **'About {days} more days'**
  String wEstimateDays(int days);

  /// No description provided for @wEstimateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No estimate: net rewards over the last 14 days are not positive'**
  String get wEstimateUnavailable;

  /// No description provided for @wSwitchToMonth.
  ///
  /// In en, this message translates to:
  /// **'Switch to month view'**
  String get wSwitchToMonth;

  /// No description provided for @wSwitchToWeek.
  ///
  /// In en, this message translates to:
  /// **'Switch to week view'**
  String get wSwitchToWeek;

  /// No description provided for @wHobbyNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a hobby name.'**
  String get wHobbyNameRequired;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'cs',
    'de',
    'en',
    'es',
    'eu',
    'fa',
    'fr',
    'he',
    'hu',
    'it',
    'ja',
    'nb',
    'nl',
    'pl',
    'pt',
    'ru',
    'tr',
    'uk',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return L10nZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return L10nAr();
    case 'cs':
      return L10nCs();
    case 'de':
      return L10nDe();
    case 'en':
      return L10nEn();
    case 'es':
      return L10nEs();
    case 'eu':
      return L10nEu();
    case 'fa':
      return L10nFa();
    case 'fr':
      return L10nFr();
    case 'he':
      return L10nHe();
    case 'hu':
      return L10nHu();
    case 'it':
      return L10nIt();
    case 'ja':
      return L10nJa();
    case 'nb':
      return L10nNb();
    case 'nl':
      return L10nNl();
    case 'pl':
      return L10nPl();
    case 'pt':
      return L10nPt();
    case 'ru':
      return L10nRu();
    case 'tr':
      return L10nTr();
    case 'uk':
      return L10nUk();
    case 'vi':
      return L10nVi();
    case 'zh':
      return L10nZh();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
