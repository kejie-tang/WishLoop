// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class L10nPl extends L10n {
  L10nPl([String locale = 'pl']) : super(locale);

  @override
  String get localeScriptName => 'Polski';

  @override
  String get appName => 'WishLoop';

  @override
  String get common_listSeparator => ', ';

  @override
  String get habitEdit_saveButton_text => 'Zapisz';

  @override
  String get habitEdit_habitName_hintText => 'Nazwa Nawyku ...';

  @override
  String get habitEdit_colorPicker_title => 'Wybierz kolor';

  @override
  String get habitEdit_colorPicker_historySectionLabel => 'Recently used';

  @override
  String habitEdit_colorPicker_customSectionLabel(String tinted) {
    String _temp0 = intl.Intl.selectLogic(tinted, {
      'true': 'Custom (Tinted)',
      'false': 'Custom',
      'other': 'Custom',
    });
    return '$_temp0';
  }

  @override
  String get habitEdit_colorPicker_cancel => 'Cancel';

  @override
  String get habitEdit_colorPicker_tintToggleLabel => 'Tint to theme';

  @override
  String get habitEdit_colorPicker_tintedLabel => 'Tinted';

  @override
  String get habitEdit_colorPicker_untintedLabel => 'Not tinted';

  @override
  String get habitEdit_colorPicker_tintToggleOnHint =>
      'Tinting may shift the final color away from the one you picked.';

  @override
  String get habitEdit_colorPicker_tintToggleOffHint =>
      'Some colors may reduce text readability in light or dark theme.';

  @override
  String get habitEdit_habitTypeDialog_title => 'Typ nawyku';

  @override
  String get habitEdit_habitType_positiveText => 'Pozytywny';

  @override
  String get habitEdit_habitType_negativeText => 'Negatywny';

  @override
  String habitEdit_habitDailyGoal_hintText(num number) {
    return 'Podstawowy cel nawyku (domyślnie: $number)';
  }

  @override
  String habitEdit_habitDailyGoal_negativeHintText(num number) {
    return 'Podstawowy cel negatywnego nawyku (domyślnie: $number)';
  }

  @override
  String habitEdit_habitDailyGoal_errorText01(num number) {
    return 'Dzienne minimum musi być większe niż $number';
  }

  @override
  String habitEdit_habitDailyGoal_errorText02(num number) {
    return 'Dzienne maksimum nie może być większe niż $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText01(num number) {
    return 'Dzienne minimum nie może być mniejsze niż $number';
  }

  @override
  String habitEdit_habitDailyGoal_negativeErrorText02(num number) {
    return 'Dzienne maksimum nie może być większe niż $number';
  }

  @override
  String get habitEdit_habitDailyGoalUnit_hintText =>
      'Jednostka celu dziennego';

  @override
  String get habitEdit_habitDailyGoalExtra_hintText =>
      'Docelowe dzienne maksimum';

  @override
  String habitEdit_habitDailyGoalExtra_errorText(num dailyGoal) {
    return 'Nieprawidłowa wartość — pole musi być puste lub większe bądź równe $dailyGoal';
  }

  @override
  String get habitEdit_habitDailyGoalExtra_negativeHintText =>
      'Maksymalny dzienny limit';

  @override
  String get habitEdit_frequencySelector_title => 'Wybierz częstotliwość';

  @override
  String get habitEdit_habitFreq_daily => 'Codziennie';

  @override
  String get habitEdit_habitFreq_perweek_text =>
      'Tygodniowo %%time%% razy w tygodniu';

  @override
  String get habitEdit_habitFreq_permonth_text =>
      'Miesięcznie %%time%% razy w miesiącu';

  @override
  String get habitEdit_habitFreq_predayfreq_text =>
      'W określonym okresie %%time%% razy w ciągu %%day%% dni';

  @override
  String get habitEdit_habitFreq_show_daily => 'Codziennie';

  @override
  String habitEdit_habitFreq_show_perweek(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Przynajmniej $freq razy w tygodniu',
      one: 'Raz w tygodniu',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_permonth(int freq) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Przynajmniej $freq razy w miesiącu',
      one: 'Raz w miesiącu',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_habitFreq_show_perdayfreq(int freq, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      freq,
      locale: localeName,
      other: 'Przynajmniej $freq razy co $days dni',
      one: 'Co $days dni',
    );
    return '$_temp0';
  }

  @override
  String habitEdit_targetDays_title(int targetDays) {
    String _temp0 = intl.Intl.pluralLogic(
      targetDays,
      locale: localeName,
      other: '$targetDays dni',
      one: '1 dzień',
    );
    return '$_temp0';
  }

  @override
  String get habitEdit_targetDays_dialogTitle =>
      'Wybierz liczbę dni docelowych';

  @override
  String get habitEdit_targetDays => 'dni';

  @override
  String get habitEdit_reminder_hintText => 'Przypomnienie';

  @override
  String get habitEdit_reminder_freq_weekHelpText => 'Dowolny dzień tygodnia';

  @override
  String habitEdit_reminder_freq_week_text(String days) {
    return '$days w każdym tygodniu';
  }

  @override
  String get habitEdit_reminder_freq_monthHelpText => 'Dowolny dzień miesiąca';

  @override
  String habitEdit_reminder_freq_month_text(String days) {
    return '$days w każdym miesiącu';
  }

  @override
  String get habitEdit_reminderQuest_hintText =>
      'Pytanie, np. Czy ćwiczyłeś dzisiaj?';

  @override
  String get habitEdit_reminder_dialogTitle => 'Wybierz typ przypomnienia';

  @override
  String get habitEdit_reminder_dialogType_whenNeeded =>
      'Kiedy trzeba sprawdzić';

  @override
  String get habitEdit_reminder_dialogType_daily => 'Codziennie';

  @override
  String get habitEdit_reminder_dialogType_week => 'W tygodniu';

  @override
  String get habitEdit_reminder_dialogType_month => 'W miesiącu';

  @override
  String get habitEdit_reminder_dialogConfirm => 'potwierdź';

  @override
  String get habitEdit_reminder_dialogCancel => 'anuluj';

  @override
  String get habitEdit_reminder_cancelDialogTitle => 'Potwierdzenie';

  @override
  String get habitEdit_reminder_cancelDialogSubtitle =>
      'Czy na pewno chcesz usunąć to przypomnienie?';

  @override
  String get habitEdit_reminder_cancelDialogConfirm => 'potwierdź';

  @override
  String get habitEdit_reminder_cancelDialogCancel => 'anuluj';

  @override
  String get habitEdit_reminder_weekdayText_monday => 'Pn';

  @override
  String get habitEdit_reminder_weekdayText_tuesday => 'Wt';

  @override
  String get habitEdit_reminder_weekdayText_wednesday => 'Śr';

  @override
  String get habitEdit_reminder_weekdayText_thursday => 'Czw';

  @override
  String get habitEdit_reminder_weekdayText_friday => 'Pt';

  @override
  String get habitEdit_reminder_weekdayText_saturday => 'Sb';

  @override
  String get habitEdit_reminder_weekdayText_sunday => 'Nd';

  @override
  String get habitEdit_desc_hintText => 'Notatka, obsługuje Markdown';

  @override
  String get habitEdit_create_datetime_prefix => 'Utworzono: ';

  @override
  String get habitEdit_modify_datetime_prefix => 'Zmodyfikowano: ';

  @override
  String get habitDisplay_fab_text => 'Nowy nawyk';

  @override
  String get habitDisplay_emptyImage_text_01 =>
      'Podróż tysiąca mil zaczyna się od jednego kroku';

  @override
  String get habitDisplay_notFoundImage_text_01 => 'No matching habits found';

  @override
  String habitDisplay_notFoundImage_text_02(String keyword) {
    return 'No matching habits for \"$keyword\"';
  }

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_title =>
      'Zarchiwizować wybrane nawyki?';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_confirm => 'potwierdź';

  @override
  String get habitDisplay_archiveHabitsConfirmDialog_cancel => 'anuluj';

  @override
  String habitDisplay_archiveHabitsSuccSnackbarText(int count) {
    return 'Zarchiwizowano $count nawyków';
  }

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_title =>
      'Przywrócić wybrane nawyki?';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_confirm => 'potwierdź';

  @override
  String get habitDisplay_unarchiveHabitsConfirmDialog_cancel => 'anuluj';

  @override
  String habitDisplay_unarchiveHabitsSuccSnackbarText(int count) {
    return 'Przywrócono $count nawyków';
  }

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_title =>
      'Usunąć wybrane nawyki?';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_confirm => 'potwierdź';

  @override
  String get habitDisplay_deleteHabitsConfirmDialog_cancel => 'anuluj';

  @override
  String habitDisplay_deleteHabitsSuccSnackbarText(int count) {
    return 'Usunięto $count nawyków';
  }

  @override
  String habitDisplay_deleteSingleHabitSuccSnackbarText(String name) {
    return 'Usunięto nawyk: \"$name\"';
  }

  @override
  String habitDisplay_exportHabitsSuccSnackbarText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wyeksportowano $count nawyków.',
      one: 'Wyeksportowano nawyk.',
    );
    return '$_temp0';
  }

  @override
  String get habitDisplay_exportAllHabitsSuccSnackbarText =>
      'Wyeksportowano wszystkie nawyki';

  @override
  String get habitDisplay_editPopMenu_selectAll => 'Zaznacz wszystkie';

  @override
  String get habitDisplay_selectButton_label => 'Zaznacz';

  @override
  String get habitDisplay_doneButton_label => 'OK';

  @override
  String habitDisplay_selectedHabits_title(int count) {
    return 'Selected $count';
  }

  @override
  String get habitDisplay_editPopMenu_export => 'Eksportuj';

  @override
  String get habitDisplay_editPopMenu_delete => 'Usuń';

  @override
  String get habitDisplay_editPopMenu_clone => 'Szablon';

  @override
  String get habitDisplay_editButton_tooltip => 'Edytuj';

  @override
  String get habitDisplay_archiveButton_tooltip => 'Archiwizuj';

  @override
  String get habitDisplay_unarchiveButton_tooltip => 'Przywróć';

  @override
  String get habitDisplay_settingButton_tooltip => 'Ustawienia';

  @override
  String get habitDisplay_statsMenu_statSubgroupText => 'Bieżące';

  @override
  String get habitDisplay_statsMenu_completedTileText => 'Ukończone';

  @override
  String get habitDisplay_statsMenu_inProgresTileText => 'W trakcie';

  @override
  String get habitDisplay_statsMenu_archivedTileText => 'Zarchiwizowane';

  @override
  String get habitDisplay_statsMenu_popularitySubgroupText =>
      'Najpopularniejsze nawyki: zmiany w ostatnich 30 dniach';

  @override
  String get habitDisplay_statisticsAction_label => 'Statistics';

  @override
  String get habitDisplay_displayFilterAction_label => 'Display Filter';

  @override
  String get habitDisplay_displayFilter_inProgress => 'W trakcie';

  @override
  String get habitDisplay_displayFilter_archived => 'Zarchiwizowane';

  @override
  String get habitDisplay_displayFilter_completed => 'Ukończone';

  @override
  String get common_appThemeMode_light => 'Jasny Motyw';

  @override
  String get common_appThemeMode_dark => 'Ciemny motyw';

  @override
  String get common_appThemeMode_followSystem => 'Systemowy motyw';

  @override
  String get habitDisplay_mainMenu_lightTheme => 'Jasny Motyw';

  @override
  String get habitDisplay_mainMenu_darkTheme => 'Ciemny motyw';

  @override
  String get habitDisplay_mainMenu_followSystemTheme => 'Systemowy motyw';

  @override
  String get habitDisplay_mainMenu_showArchivedTileText =>
      'Pokaż zarchiwizowane';

  @override
  String get habitDisplay_mainMenu_showCompletedTileText => 'Pokaż ukończone';

  @override
  String get habitDisplay_mainMenu_showActivedTileText => 'Pokaż aktywne';

  @override
  String get habitDisplay_mainMenu_settingTileText => 'Ustawienia';

  @override
  String get habitDisplay_groupType_name => 'Według nazwy';

  @override
  String get habitDisplay_groupType_colorType => 'Według koloru';

  @override
  String get habitDisplay_groupType_createDate => 'By Creation Date';

  @override
  String get habitDisplay_groupType_habitCount => 'By Habit Count';

  @override
  String get habitDisplay_groupTypeDialog_title => 'Group Sort';

  @override
  String get habitDisplay_groupTypeDialog_confirm => 'potwierdź';

  @override
  String get habitDisplay_groupTypeDialog_cancel => 'anuluj';

  @override
  String get habitDisplay_groupTypeDialog_none => 'Flat';

  @override
  String get habitDisplay_editPopMenu_groupModify => 'Modify Group';

  @override
  String get habitDisplay_groupModifyDialog_title => 'Modify Group';

  @override
  String get habitDisplay_groupModifyDialog_removeGroup => 'Remove Group';

  @override
  String get habitDisplay_groupModifyDialog_emptyGroups =>
      'No groups available';

  @override
  String get habitDisplay_groupModifyDialog_alreadyInGroup =>
      'Selected habits are already in this group';

  @override
  String get habitDisplay_groupModifyDialog_createGroup => 'Create Group';

  @override
  String get habitDisplay_groupModifyDialog_saveAndApply => 'Save & Apply';

  @override
  String get habitDisplay_groupModifyConfirm_titleNew => 'Move to Group';

  @override
  String get habitDisplay_groupModifyConfirm_titleMixed =>
      'Confirm Group Change';

  @override
  String habitDisplay_groupModifyConfirm_bodyNewGroup(String groupName) {
    return '$groupName habits will be moved to this group';
  }

  @override
  String get habitDisplay_groupModifyConfirm_bodyRemoveGroup =>
      'Habits will have their group removed';

  @override
  String habitDisplay_groupModifyConfirm_bodyChangeStat(
    int count,
    String fromGroup,
    String toGroup,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count habits will change from \"$fromGroup\" to \"$toGroup\"',
      one: '$count habit will change from \"$fromGroup\" to \"$toGroup\"',
    );
    return '$_temp0';
  }

  @override
  String habitDisplay_groupModifyConfirm_bodyAddStat(
    int count,
    String toGroup,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uncategorized habits will be added to \"$toGroup\"',
      one: '$count uncategorized habit will be added to \"$toGroup\"',
    );
    return '$_temp0';
  }

  @override
  String habitDisplay_groupModifyConfirm_bodyRemoveStat(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count habits will have their groups removed',
      one: '$count habit will have its group removed',
    );
    return '$_temp0';
  }

  @override
  String get habitDisplay_groupModifyConfirm_nameSeparator => ', ';

  @override
  String habitDisplay_groupModify_snackbarText(int count, String groupName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Moved $count habits to \"$groupName\"',
      one: 'Moved habit to \"$groupName\"',
    );
    return '$_temp0';
  }

  @override
  String habitDisplay_groupModify_snackbarTextRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Removed groups from $count habits',
      one: 'Removed group from habit',
    );
    return '$_temp0';
  }

  @override
  String get habitDisplay_groupModify_undoFailed =>
      'Group has been modified elsewhere, cannot undo';

  @override
  String get habitDisplay_sort_reverseText => 'Odwróć';

  @override
  String get habitDisplay_sortDirection_asc => '(Rosnąco)';

  @override
  String get habitDisplay_sortDirection_Desc => '(Malejąco)';

  @override
  String get habitDisplay_sortType_manual => 'Moja kolejność';

  @override
  String get habitDisplay_sortType_name => 'Według nazwy';

  @override
  String get habitDisplay_sortType_colorType => 'Według koloru';

  @override
  String get habitDisplay_sortType_progress => 'Według postępu';

  @override
  String get habitDisplay_sortType_startT => 'Według daty rozpoczęcia';

  @override
  String get habitDisplay_sortType_status => 'Według statusu';

  @override
  String get habitDisplay_sortTypeDialog_title => 'Sortuj';

  @override
  String get habitDisplay_sortTypeDialog_confirm => 'potwierdź';

  @override
  String get habitDisplay_sortTypeDialog_cancel => 'anuluj';

  @override
  String get habitDisplay_debug_debugSubgroup_title => '🛠️Debug';

  @override
  String get habitDisplay_searchBar_hintText => 'Szukaj nawyków';

  @override
  String get habitDisplay_searchFilter_ongoing => 'Ongoing';

  @override
  String get habitDisplay_searchFilter_ongoing_desc =>
      'Shows habits that are currently active and ongoing (not archived or deleted).';

  @override
  String get habitDisplay_searchFilter_completed => 'Ukończone';

  @override
  String get habitDisplay_searchFilter_habitType_groupTitle => 'Typ nawyku';

  @override
  String get habitDisplay_searchFilter_tooltips => 'Show Filters';

  @override
  String get habitDisplay_searchFilter_clearFilter => 'Clear Filters';

  @override
  String get habitDisplay_tab_habits_label => 'Habits';

  @override
  String get habitDisplay_tab_today_label => 'Dzisiaj';

  @override
  String get habitToday_appBar_title => 'Dzisiaj';

  @override
  String get habitToday_image_desc => 'YOU MADE IT';

  @override
  String habitToday_card_subtitle_text(int days) {
    return 'Kept it up for $days days';
  }

  @override
  String get habitToday_card_donePlusButton_label => 'Done+';

  @override
  String get habitToday_card_skipPlusButton_label => 'Skip+';

  @override
  String get habitDetail_editButton_tooltip => 'Edytuj';

  @override
  String get habitDetail_editPopMenu_unarchive => 'Przywróć';

  @override
  String get habitDetail_editPopMenu_archive => 'Archiwizuj';

  @override
  String get habitDetail_editPopMenu_export => 'Eksportuj';

  @override
  String get habitDetail_editPopMenu_delete => 'Usuń';

  @override
  String get habitDetail_editPopMenu_clone => 'Szablon';

  @override
  String get habitDetail_confirmDialog_confirm => 'potwierdź';

  @override
  String get habitDetail_confirmDialog_cancel => 'anuluj';

  @override
  String get habitDetail_archiveConfirmDialog_titleText =>
      'Archiwizować nawyk?';

  @override
  String get habitDetail_unarchiveConfirmDialog_titleText =>
      'Przywrócić nawyk?';

  @override
  String get habitDetail_deleteConfirmDialog_titleText => 'Usunąć nawyk?';

  @override
  String get habitDetail_summary_title => 'Podsumowanie';

  @override
  String habitDetail_summary_body(String score, int days) {
    return 'Bieżąca ocena to $score, a od rozpoczęcia minęło $days dni.';
  }

  @override
  String habitDetail_summary_preBody(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Rozpocznie się za $days dni.',
      one: 'Zaczyna się jutro.',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_leftHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'PONIŻEJ STANDARDU',
      one: 'NIEKOMPLETNY',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_heatmap_rightHelpText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: '',
      two: 'BEZBŁĘDNY',
      one: 'PRZEKROCZONY',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Cel',
      two: 'Próg',
    );
    return '$_temp0';
  }

  @override
  String habitDetail_descDailyGoal_unitText(String unit) {
    return 'Jednostka: $unit';
  }

  @override
  String get habitDetail_descDailyGoal_unitEmptyText => 'brak';

  @override
  String habitDetail_descTargetDays_titleText(int habitType) {
    String _temp0 = intl.Intl.pluralLogic(
      habitType,
      locale: localeName,
      other: 'Dni',
    );
    return '$_temp0';
  }

  @override
  String get habitDetail_descTargetDays_unitText => 'dni';

  @override
  String get habitDetail_descRecordsNum_titleText => 'Rekordy';

  @override
  String get habitDetail_scoreChart_title => 'Wynik';

  @override
  String get habitDetail_scoreChartCombine_dailyText => 'Dzień';

  @override
  String get habitDetail_scoreChartCombine_weeklyText => 'Tydzień';

  @override
  String get habitDetail_scoreChartCombine_monthlyText => 'Miesiąc';

  @override
  String get habitDetail_scoreChartCombine_yearlyText => 'Rok';

  @override
  String get habitDetail_freqChart_freqTitle => 'Częstotliwość';

  @override
  String get habitDetail_freqChart_historyTitle => 'Historia';

  @override
  String get habitDetail_freqChart_combinedTitle => 'Częstotliwość & Historia';

  @override
  String get habitDetail_freqChartCombine_weeklyText => 'Tydzień';

  @override
  String get habitDetail_freqChartCombine_monthlyText => 'Miesiąc';

  @override
  String get habitDetail_freqChartCombine_yearlyText => 'Rok';

  @override
  String get habitDetail_freqChartNaviBar_nowText => 'Teraz';

  @override
  String get habitDetail_freqChart_expanded_hideTooltip =>
      'Ukryj wykres historii';

  @override
  String get habitDetail_freqChart_expanded_showTooltip =>
      'Pokaż wykres historii';

  @override
  String get habitDetail_descSubgroup_title => 'Notatka';

  @override
  String get habitDetail_otherSubgroup_title => 'Inne';

  @override
  String get habitDetail_habitType_title => 'Typ';

  @override
  String get habitDetail_reminderTile_title => 'Przypomnienie';

  @override
  String get habitDetail_freqTile_title => 'Powtarzanie';

  @override
  String get habitDetail_startDateTile_title => 'Data rozpoczęcia';

  @override
  String get habitDetail_createDateTile_title => 'Utworzono';

  @override
  String get habitDetail_modifyDateTile_title => 'Zmodyfikowano';

  @override
  String get habitDetail_editHeatmapCal_dateButtonText => 'Data';

  @override
  String get habitDetail_editHeatmapCal_valueButtonText => 'Wartość';

  @override
  String get habitDetail_editHeatmapCal_backToToday_tooltipText =>
      'Powrót do dziś';

  @override
  String get common_loadError_text => 'Failed to load';

  @override
  String get common_loadError_retryText => 'Spróbuj ponownie';

  @override
  String get habitDetail_notFoundText => 'Nie udało się załadować nawyku';

  @override
  String get habitDetail_notFoundRetryText => 'Spróbuj ponownie';

  @override
  String get habitDetail_changeGoal_title => 'Zmień cel';

  @override
  String habitDetail_changeGoal_currentChipText(String goal) {
    return 'bieżący: $goal';
  }

  @override
  String habitDetail_changeGoal_doneChipText(String goal) {
    return 'zrealizowany: $goal';
  }

  @override
  String get habitDetail_changeGoal_undoneChipText => 'niezrealizowany';

  @override
  String habitDetail_changeGoal_extraChipText(String goal) {
    return '$goal';
  }

  @override
  String habitDetail_changeGoal_helpText(String goal) {
    return 'Cel dzienny, domyślnie: $goal';
  }

  @override
  String get habitDetail_changeGoal_cancelText => 'anuluj';

  @override
  String get habitDetail_changeGoal_saveText => 'zapisz';

  @override
  String get habitDetail_skipReason_title => 'Powód pominięcia';

  @override
  String get habitDetail_skipReason_bodyHelpText => 'Napisz coś tutaj...';

  @override
  String get habitDetail_skipReason_cancelText => 'anuluj';

  @override
  String get habitDetail_skipReason_saveText => 'zapisz';

  @override
  String get appSetting_appbar_titleText => 'Ustawienia';

  @override
  String get appSetting_displaySubgroupText => 'Wyświetlanie';

  @override
  String get appSetting_operationSubgroupText => 'Działanie';

  @override
  String get appSetting_dragCalendarByPageTile_titleText =>
      'Przeciąganie kalendarza po stronach';

  @override
  String get appSetting_dragCalendarByPageTile_subtitleText =>
      'Jeśli włączone, kalendarz w pasku aplikacji na stronie głównej będzie przewijany strona po stronie. Domyślnie wyłączone.';

  @override
  String get appSetting_changeRecordStatusOpTile_titleText =>
      'Zmień status rekordu';

  @override
  String get appSetting_changeRecordStatusOpTile_subtitleText =>
      'Zmienia działanie kliknięcia w celu modyfikacji statusu dziennych rekordów na stronie głównej.';

  @override
  String get appSetting_openRecordStatusDialogOpTile_titleText =>
      'Otwórz szczegóły rekordu';

  @override
  String get appSetting_openRecordStatusDialogOpTile_subtitleText =>
      'Zmienia działanie kliknięcia w celu otwarcia szczegółowego okna dziennych rekordów na stronie głównej.';

  @override
  String get appSetting_expandTimerDelayTile_titleText => 'Group expand delay';

  @override
  String get appSetting_expandTimerDelayTile_subtitleText =>
      'Set how long to hover over a collapsed group header before it auto-expands during drag-and-drop.';

  @override
  String get appSetting_expandTimerDelay_default => 'Default';

  @override
  String get appSetting_expandTimerDelay_fast => 'Fast';

  @override
  String get appSetting_expandTimerDelay_slow => 'Slow';

  @override
  String get appSetting_appThemeColorTile_titleText => 'Theme Color';

  @override
  String get appSetting_appThemeModeTile_titleText => 'Theme Mode';

  @override
  String get appSetting_appThemeColorChosenDiloag_titleText =>
      'Choose Theme Color';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_android =>
      'Use wallpaper\'s main color (Android 12+)';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_linux =>
      'Use GTK+ theme\'s selected background color';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_macos =>
      'Use system theme color';

  @override
  String get appSetting_appThemeColorChosenDialog_subTitleText_windows =>
      'Use system accent or window/glass color';

  @override
  String get appSetting_firstDayOfWeek_titleText => 'Pierwszy dzień tygodnia';

  @override
  String get appSetting_firstDayOfWeekDialog_titleText =>
      'Wybierz pierwszy dzień tygodnia';

  @override
  String get appSetting_firstDayOfWeekDialog_defaultText => ' (Domyślny)';

  @override
  String appSetting_changeLanguage_followSystem_text(String localeName) {
    return 'Podążaj za systemem ($localeName)';
  }

  @override
  String get appSetting_changeLanguage_followSystem_noLocale_text =>
      'Podążaj za systemem';

  @override
  String get appSetting_changeLanguageTile_titleText => 'Język';

  @override
  String get appSetting_changeLanguageDialog_titleText => 'Wybierz język';

  @override
  String get appSetting_languageSubgroupText => 'Language';

  @override
  String get appSetting_openSystemLanguageTile_titleText =>
      'System Language Settings';

  @override
  String get appSetting_openSystemLanguageTile_dialogTitle =>
      'Open System Language Settings';

  @override
  String get appSetting_openSystemLanguageTile_macosDialogContent =>
      'Due to macOS limitations, the app language cannot be changed directly. To switch languages, follow these steps:\n\n1. Open **System Settings > General > Language & Region**\n2. Add this app in the **Applications** list and choose a language';

  @override
  String appSetting_dateDisplayFormat_titleText(String formatTemplate) {
    return 'Format daty ($formatTemplate)';
  }

  @override
  String get appSetting_dateDisplayFormat_titleTemplate_followSystemText =>
      'Podążaj za ustawieniami systemu';

  @override
  String get appSetting_dateDisplayFormat_subTitleText =>
      'Skonfigurowany format daty zostanie zastosowany na stronie szczegółów nawyku.';

  @override
  String get appSetting_compactUISwitcher_titleText =>
      'Włącz kompaktowy interfejs na stronie nawyków';

  @override
  String get appSetting_compactUISwitcher_subtitleText =>
      'Pozwala tabeli kontroli nawyków wyświetlać więcej treści, ale niektóre elementy i tekst mogą być mniejsze.';

  @override
  String get appSetting_collapsed_calendar_bararea_titleText =>
      'Dostosowanie obszaru kalendarza na stronie nawyków';

  @override
  String get appSetting_collapsed_calendar_bararea_subtitleText =>
      'Dostosuj procentową wielkość obszaru tabeli kontroli nawyków.';

  @override
  String get appSetting_collapsed_calendar_bararea_defaultText => 'Domyślny';

  @override
  String get appSetting_reminderSubgroupText => 'Przypomnienia i powiadomienia';

  @override
  String get appSetting_dailyReminder_titleText => 'Codzienne przypomnienie';

  @override
  String get appSetting_backupAndRestoreSubgroupText =>
      'Kopia zapasowa i przywracanie';

  @override
  String get appSetting_export_titleText => 'Eksportuj';

  @override
  String get appSetting_export_subtitleText =>
      'Eksportuje nawyki w formacie JSON. Plik można ponownie zaimportować.';

  @override
  String get appSetting_import_titleText => 'Importuj';

  @override
  String get appSetting_import_subtitleText => 'Importuj nawyki z pliku JSON.';

  @override
  String get appSetting_thirdPartyImport_titleText => 'Import from third-party';

  @override
  String get appSetting_thirdPartyImport_subtitleText =>
      'Import habits from other habit tracker apps';

  @override
  String get appSetting_thirdPartyImport_provider_loopName =>
      'Loop Habit Tracker';

  @override
  String get appSetting_thirdPartyImport_provider_versionHint =>
      'Supports CSV (tested up to <ver/>)';

  @override
  String appSetting_importDialog_confirmTitle(int count) {
    return 'Potwierdź import $count nawyków?';
  }

  @override
  String get appSetting_importDialog_confirmSubtitle =>
      'Uwaga: Import nie usuwa istniejących nawyków.';

  @override
  String get appSetting_importDialog_option_includeHabits => 'Include habits';

  @override
  String get appSetting_importDialog_option_includeGroups => 'Include groups';

  @override
  String appSetting_importDialog_tile_includeHabits(int count) {
    return 'Include $count habits';
  }

  @override
  String appSetting_importDialog_tile_includeGroups(int count) {
    return 'Include $count groups';
  }

  @override
  String appSetting_importConfirmDialog_sourceLabel(String provider) {
    return 'Source: $provider';
  }

  @override
  String get appSetting_thirdPartyImport_error_fileReadError =>
      'Failed to read the selected file.';

  @override
  String get appSetting_thirdPartyImport_error_noHabitsFound =>
      'No habits found in the import file.';

  @override
  String get appSetting_thirdPartyImport_error_parseError =>
      'Failed to parse import file';

  @override
  String get appSetting_thirdPartyImport_error_unknown =>
      'An unexpected error occurred during import.';

  @override
  String get appSetting_importDialog_confirm_confirmText => 'potwierdź';

  @override
  String get appSetting_importDialog_confirm_cancelText => 'anuluj';

  @override
  String appSetting_importDialog_importingTitle(
    int completeCount,
    int totalCount,
  ) {
    return 'Importowano $completeCount/$totalCount';
  }

  @override
  String appSetting_importDialog_completeTitle(int count) {
    return 'Import $count zakończony';
  }

  @override
  String appSetting_importDialog_completeTitleGroups(int count) {
    return 'Completed import $count groups';
  }

  @override
  String get appSetting_importDialog_complete_closeLabel => 'zamknij';

  @override
  String get appSetting_resetConfig_titleText => 'Resetuj ustawienia';

  @override
  String get appSetting_resetConfig_subtitleText =>
      'Przywróć wszystkie ustawienia do domyślnych.';

  @override
  String get appSetting_resetConfigDialog_titleText => 'Resetować ustawienia?';

  @override
  String get appSetting_resetConfigDialog_subtitleText =>
      'Przywrócenie wszystkich ustawień do domyślnych wymaga ponownego uruchomienia aplikacji.';

  @override
  String get appSetting_resetConfigDialog_cancelText => 'anuluj';

  @override
  String get appSetting_resetConfigDialog_confirmText => 'potwierdź';

  @override
  String get appSetting_resetConfigSuccess_snackbarText =>
      'Ustawienia aplikacji zostały zresetowane';

  @override
  String get appSetting_otherSubgroupText => 'Inne';

  @override
  String get appSetting_developMode_titleText => 'Tryb deweloperski';

  @override
  String get appSetting_clearCache_titleText => 'Wyczyść pamięć podręczną';

  @override
  String get appSetting_clearCacheDialog_titleText =>
      'Wyczyść pamięć podręczną';

  @override
  String get appSetting_clearCacheDialog_subtitleText =>
      'Po wyczyszczeniu pamięci podręcznej niektóre wartości zostaną przywrócone do domyślnych.';

  @override
  String get appSetting_clearCacheDialog_cancelText => 'anuluj';

  @override
  String get appSetting_clearCacheDialog_confirmText => 'potwierdź';

  @override
  String get appSetting_clearCache_snackBar_partSuccText =>
      'Częściowe czyszczenie pamięci podręcznej nie powiodło się';

  @override
  String get appSetting_clearCache_snackBar_succText =>
      'Pamięć podręczna wyczyszczona pomyślnie';

  @override
  String get appSetting_clearCache_snackBar_failText =>
      'Czyszczenie pamięci podręcznej nie powiodło się';

  @override
  String get appSetting_debugger_titleText => 'Informacje debugowania';

  @override
  String get appSetting_about_titleText => 'O aplikacji';

  @override
  String get appSetting_experimentalFeatureTile_titleText =>
      'Funkcje eksperymentalne';

  @override
  String get appSetting_synSubgroupText => 'Synchronizacja';

  @override
  String get appSetting_syncOption_titleText => 'Opcje synchronizacji';

  @override
  String get appSetting_notify_titleTile => 'Powiadomienia';

  @override
  String get appSetting_notify_subtitleTile =>
      'Zarządzaj preferencjami powiadomień';

  @override
  String get appSetting_notify_subtitleTile_android =>
      'Stuknij, aby otworzyć ustawienia powiadomień systemowych';

  @override
  String get appSync_nowTile_titleText => 'Synchronizuj teraz';

  @override
  String get appSync_nowTile_titleText_syncing => 'Synchronizacja';

  @override
  String appSync_nowTile_dateFormat(DateTime ymd, DateTime jms) {
    final intl.DateFormat ymdDateFormat = intl.DateFormat.yMd(localeName);
    final String ymdString = ymdDateFormat.format(ymd);
    final intl.DateFormat jmsDateFormat = intl.DateFormat.jms(localeName);
    final String jmsString = jmsDateFormat.format(jms);

    return '$ymdString $jmsString';
  }

  @override
  String get appSync_nowTile_text_noDate =>
      'Ostatnia synchronizacja: brak danych';

  @override
  String appSync_nowTile_text(String dateStr) {
    return 'Ostatnia synchronizacja: $dateStr';
  }

  @override
  String get appSync_nowTile_errorText_noDate =>
      'Ostatnia synchronizacja (Błąd): brak danych';

  @override
  String appSync_nowTile_errorText(String dateStr) {
    return 'Ostatnia synchronizacja (Błąd): $dateStr';
  }

  @override
  String get appSync_nowTile_syncingText => 'Trwa synchronizacja...';

  @override
  String appSync_nowTile_syncingText_withPrt(num prt) {
    final intl.NumberFormat prtNumberFormat =
        intl.NumberFormat.decimalPercentPattern(
          locale: localeName,
          decimalDigits: 2,
        );
    final String prtString = prtNumberFormat.format(prt);

    return 'Trwa synchronizacja: $prtString';
  }

  @override
  String get appSync_nowTile_cancellingText => 'Anulowanie...';

  @override
  String get appSync_nowTile_cancelText_noDate =>
      'Ostatnia synchronizacja (Anulowano): brak danych';

  @override
  String appSync_nowTile_cancelText(String dateStr) {
    return 'Ostatnia synchronizacja (Anulowano): $dateStr';
  }

  @override
  String get appSync_failedTile_titleText => 'Sprawdź logi błędów';

  @override
  String appSync_failedTile_errorText(String info) {
    return '[Błąd]: $info';
  }

  @override
  String appSync_failedTile_webdavMulti_counterText(String reason, int count) {
    return '$reason: $count';
  }

  @override
  String appSync_webdav_resultStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'success': 'Zakończono',
      'cancelled': 'Anulowano',
      'failed': 'Nie powiodło się',
      'multi': 'Wiele statusów',
      'other': 'Nieznany status',
    });
    return '$_temp0';
  }

  @override
  String appSync_webdav_resultStatus_withReason(String status, String reason) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'success': 'Zakończono: $reason',
      'cancelled': 'Anulowano: $reason',
      'failed': 'Nie powiodło się: $reason',
      'multi': 'Wiele statusów: $reason',
      'other': 'Nieznany status',
    });
    return '$_temp0';
  }

  @override
  String appSync_webdav_resultReason(String reason) {
    String _temp0 = intl.Intl.selectLogic(reason, {
      'error': 'Błąd',
      'userAction': 'Wymagana akcja użytkownika',
      'missingHabitUuid': 'Brak UUID nawyku',
      'empty': 'Puste dane',
      'other': 'Nieznany powód',
    });
    return '$_temp0';
  }

  @override
  String get appSync_webdav_newServerConfirmDialog_titleText =>
      'Nowa lokalizacja';

  @override
  String get appSync_webdav_newServerConfirmDialog_subtitleText =>
      'Synchronizacja utworzy potrzebne katalogi i wgra lokalne nawyki na serwer. Kontynuować?';

  @override
  String get appSync_webdav_newServerConfirmDialog_confirmText =>
      'Synchronizuj teraz!';

  @override
  String get appSync_webdav_oldServerConfirmDialog_titleText =>
      'Potwierdź synchronizację';

  @override
  String get appSync_webdav_oldServerConfirmDialog_subtitleText =>
      'Katalog nie jest pusty. Synchronizacja połączy dane serwera i lokalne. Kontynuować?';

  @override
  String get appSync_webdav_oldServerConfirmDialog_confirmText =>
      'Potwierdź scalanie';

  @override
  String get appSync_exportAllLogsTile_titleText =>
      'Eksportuj nieudane logi synchronizacji';

  @override
  String appSync_exportAllLogsTile_subtitleText(String isEmpty) {
    String _temp0 = intl.Intl.selectLogic(isEmpty, {
      'true': 'Brak logów',
      'false': 'Dotknij, aby wyeksportować',
      'other': 'Ładowanie...',
    });
    return '$_temp0';
  }

  @override
  String appSync_syncServerType_text(String name, String isCurrent) {
    String _temp0 = intl.Intl.selectLogic(isCurrent, {
      'true': 'Bieżący: ',
      'other': '',
    });
    String _temp1 = intl.Intl.selectLogic(name, {
      'webdav': 'WebDAV',
      'fake': 'Fałszywy (tylko dla debugera)',
      'other': 'Nieznany ($name)',
    });
    return '$_temp0$_temp1';
  }

  @override
  String appSync_networkType_text(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'mobile': 'Sieć komórkowa',
      'wifi': 'Wifi',
      'other': 'Nieznana',
    });
    return '$_temp0';
  }

  @override
  String appSync_syncInterval_text(String name) {
    String _temp0 = intl.Intl.selectLogic(name, {
      'manual': 'Ręcznie',
      'minute5': '5 Minutes',
      'minute15': '15 minut',
      'minute30': '30 minut',
      'hour1': '1 godzina',
      'other': 'Nieznany',
    });
    return '$_temp0';
  }

  @override
  String get appSync_syncIntervalTile_title => 'Interwał pobierania';

  @override
  String get appSync_summaryTile_title => 'Serwer synchronizacji';

  @override
  String get appSync_summaryTile_subtitle_text_notConfigured =>
      'Nie skonfigurowano';

  @override
  String get appSync_exportAllLogsTile_exportSubjectText =>
      'Wszystkie ostatnie nieudane logi synchronizacji';

  @override
  String get appSync_serverEditor_saveDialog_titleText =>
      'Potwierdź zapis zmian';

  @override
  String get appSync_serverEditor_saveDialog_subtitleText =>
      'Zapisanie nadpisze poprzednią konfigurację serwera.';

  @override
  String get appSync_serverEditor_exitDialog_titleText => 'Niezapisane zmiany';

  @override
  String get appSync_serverEditor_exitDialog_subtitleText =>
      'Wyjście spowoduje utratę wszystkich niezapisanych zmian.';

  @override
  String get appSync_serverEditor_deleteDialog_titleText =>
      'Potwierdź usunięcie';

  @override
  String get appSync_serverEditor_deleteDialog_subtitleText =>
      'Usunięcie spowoduje skasowanie bieżącej konfiguracji serwera.';

  @override
  String get appSync_serverEditor_titleText_add => 'Nowy serwer synchronizacji';

  @override
  String get appSync_serverEditor_titleText_modify =>
      'Edytuj serwer synchronizacji';

  @override
  String get appSync_serverEditor_advance_titleText =>
      'Zaawansowane ustawienia';

  @override
  String get appSync_serverEditor_pathTile_titleText => 'Ścieżka';

  @override
  String get appSync_serverEditor_pathTile_hintText =>
      'Wprowadź tutaj prawidłową ścieżkę WebDAV.';

  @override
  String get appSync_serverEditor_pathTile_errorText_emptyPath =>
      'Ścieżka nie może być pusta!';

  @override
  String get appSync_serverEditor_usernameTile_titleText => 'Nazwa użytkownika';

  @override
  String get appSync_serverEditor_usernameTile_hintText =>
      'Wprowadź nazwę użytkownika, pozostaw puste jeśli nie jest wymagana.';

  @override
  String get appSync_serverEditor_passwordTile_titleText => 'Hasło';

  @override
  String get appSync_serverEditor_ignoreSSLTile_titleText =>
      'Ignoruj certyfikat SSL';

  @override
  String get appSync_serverEditor_timeoutTile_titleText =>
      'Limit czasu synchronizacji (sekundy)';

  @override
  String appSync_serverEditor_timeoutTile_hintText(int seconds, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds$unit',
      zero: 'Nieskończony',
    );
    return 'Domyślnie: $_temp0';
  }

  @override
  String get appSync_serverEditor_timeoutTile_unitText => 's';

  @override
  String get appSync_serverEditor_connTimeoutTile_titleText =>
      'Limit czasu połączenia sieciowego (sekundy)';

  @override
  String appSync_serverEditor_connTimeoutTile_hintText(
    int seconds,
    String unit,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds$unit',
      zero: 'Nieskończony',
    );
    return 'Domyślnie: $_temp0';
  }

  @override
  String get appSync_serverEditor_connTimeoutTile_unitText => 's';

  @override
  String get appSync_serverEditor_connRetryCountTile_titleText =>
      'Liczba prób ponownego połączenia';

  @override
  String appSync_serverEditor_connRetryCountTile_hintText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count',
      zero: 'Ponowne próby wyłączone',
    );
    return 'Domyślnie: $_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_titleText =>
      'Tryb synchronizacji sieci';

  @override
  String appSync_serverEditor_netTypeTile_typeTooltip(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'mobile': 'Synchronizacja przez sieć komórkową',
      'wifi': 'Synchronizacja przez Wifi',
      'other': 'Nieznany',
    });
    return '$_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_lowDataText =>
      'Tryb niskiego transferu';

  @override
  String get appSync_noti_readyToSync_body =>
      'Przygotowanie do synchronizacji...';

  @override
  String appSync_noti_syncing_title(String synced, String type) {
    String _temp0 = intl.Intl.selectLogic(synced, {
      'synced': 'Zsynchronizowano ($type)',
      'failed': 'Błąd synchronizacji ($type)',
      'other': 'Synchronizacja ($type)',
    });
    return '$_temp0';
  }

  @override
  String get appSync_serverEditor_netTypeTile_lowDataTooltip =>
      'Synchronizuj w trybie niskiego transferu';

  @override
  String get experimentalFeatures_warnginBanner_title =>
      'Jedna lub więcej funkcji eksperymentalnych jest włączona. Używaj z ostrożnością.';

  @override
  String get experimentalFeatures_habitSyncTile_titleText =>
      'Chmurowa synchronizacja nawyków';

  @override
  String get experimentalFeatures_habitSyncTile_subtitleText =>
      'Po włączeniu opcja synchronizacji pojawi się w ustawieniach';

  @override
  String experimentalFeatures_warnTile_titleText(String syncName) {
    return 'Funkcja eksperymentalna ($syncName) jest wyłączona, ale nadal działa.';
  }

  @override
  String experimentalFeatures_warnTile_forHabitSyncText(String menuName) {
    return 'Aby całkowicie wyłączyć, przytrzymaj, aby otworzyć \'$menuName\' i wyłącz ją.';
  }

  @override
  String get experimentalFeatures_habitSearchTile_titleText =>
      'Wyszukiwanie nawyków';

  @override
  String get experimentalFeatures_habitSearchTile_subtitleText =>
      'Po włączeniu pasek wyszukiwania pojawi się u góry ekranu Nawyków, umożliwiając wyszukiwanie nawyków.';

  @override
  String get appAbout_appbarTile_titleText => 'Informacje';

  @override
  String appAbout_versionTile_titleText(String appVersion) {
    return 'Wersja: $appVersion';
  }

  @override
  String get appAbout_versionTile_changeLogPath => 'CHANGELOG.md';

  @override
  String get appAbout_sourceCodeTile_titleText => 'Kod źródłowy';

  @override
  String get appAbout_issueTrackerTile_titleText => 'Śledzenie problemów';

  @override
  String get appAbout_contactEmailTile_titleText => 'Skontaktuj się ze mną';

  @override
  String get appAbout_contactEmailTile_emailBody =>
      'Cześć, cieszę się, że się ze mną skontaktowałeś.\nJeśli zgłaszasz błąd, podaj wersję aplikacji i opisz kroki do jego odtworzenia.\n--------------------------------------';

  @override
  String get appAbout_licenseTile_titleText => 'Licencja';

  @override
  String get appAbout_licenseTile_subtitleText => 'Licencja Apache, wersja 2.0';

  @override
  String get appAbout_licenseThirdPartyTile_titleText =>
      'Oświadczenie licencyjne oprogramowania firm trzecich';

  @override
  String get appAbout_licenseThirdPartyTile_subtitleText => 'flutter';

  @override
  String get appAbout_privacyTile_titleText => 'Prywatność';

  @override
  String get appAbout_privacyTile_subTitleText =>
      'Dostęp do polityki prywatności w aplikacji';

  @override
  String get appAbout_donateTile_titleText => 'Wesprzyj';

  @override
  String get appAbout_donateTile_subTitleText =>
      'Jestem indywidualnym deweloperem. Jeśli podoba Ci się aplikacja, kup mi ☕.';

  @override
  String get appAbout_donateTile_ways =>
      '@paypal,@buyMeACoffee,@alipay,@wechatPay,@cryptoCurrencyAll';

  @override
  String get donateWay_paypal => 'Paypal';

  @override
  String get donateWay_buyMeACoffee => 'Buy me a coffee';

  @override
  String get donateWay_alipay => 'Alipay';

  @override
  String get donateWay_wechatPay => 'Wechat Pay';

  @override
  String get donateWay_cryptoCurrency => 'Kryptowaluty';

  @override
  String get donateWay_cryptoCurrency_BTC => 'BTC';

  @override
  String get donateWay_cryptoCurrency_ETH => 'ETH';

  @override
  String get donateWay_cryptoCurrency_BNB => 'BNB';

  @override
  String get donateWay_cryptoCurrency_AVAX => 'AVAX';

  @override
  String get donateWay_cryptoCurrency_FTM => 'FTM';

  @override
  String get donateWay_firstQRGroup => 'Alipay & Wechat Pay';

  @override
  String appAbout_donateDialog_copiedCrypto_msg(String name) {
    return 'Skopiowano adres $name';
  }

  @override
  String get batchCheckin_appbar_title => 'Zbiorcze Zaznaczanie';

  @override
  String get batchCheckin_datePicker_prevButton_tooltip => 'Poprzedni dzień';

  @override
  String get batchCheckin_datePicker_nextButton_tooltip => 'Następny dzień';

  @override
  String get batchCheckin_status_skip_text => 'Pomiń';

  @override
  String get batchCheckin_status_ok_text => 'Ukończone';

  @override
  String get batchCheckin_status_double_text => 'x2 Trafienie!';

  @override
  String get batchCheckin_status_zero_text => 'Nieukończone';

  @override
  String batchCheckin_habits_groupTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nawyki',
      one: 'Nawyk',
    );
    return '$count $_temp0 selected';
  }

  @override
  String get batchCheckin_save_button_text => 'Zapisz';

  @override
  String get batchCheckin_reset_button_text => 'Resetuj';

  @override
  String batchCheckin_completed_snackbar_text(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'status $count nawyków',
      one: 'status nawyku',
    );
    return 'Zmodyfikowano $_temp0';
  }

  @override
  String get batchCheckin_save_confirmDialog_title =>
      'Nadpisz istniejące rekordy';

  @override
  String get batchCheckin_save_confirmDialog_body =>
      'Istniejące rekordy zostaną nadpisane. Po zapisaniu poprzednie rekordy zostaną utracone.';

  @override
  String get batchCheckin_save_confirmDialog_confirmButton_text => 'zapisz';

  @override
  String get batchCheckin_save_confirmDialog_cancelButton_text => 'anuluj';

  @override
  String get batchCheckin_close_confirmDialog_title => 'Potwierdź powrót';

  @override
  String get batchCheckin_close_confirmDialog_body =>
      'Zmiany statusu zaznaczenia nie zostaną zapisane, jeśli nie zapiszesz';

  @override
  String get batchCheckin_close_confirmDialog_confirmButton_text => 'wyjdź';

  @override
  String get batchCheckin_close_confirmDialog_cancelButton_text => 'anuluj';

  @override
  String get appReminder_dailyReminder_title =>
      '🏝 Czy udało Ci się dziś trzymać nawyków?';

  @override
  String get appReminder_dailyReminder_body =>
      'kliknij, aby wejść do aplikacji i odznaczyć nawyki na czas.';

  @override
  String get common_habitColorType_cc1 => 'Głęboki liliowy';

  @override
  String get common_habitColorType_cc2 => 'Czerwony';

  @override
  String get common_habitColorType_cc3 => 'Fioletowy';

  @override
  String get common_habitColorType_cc4 => 'Królewski niebieski';

  @override
  String get common_habitColorType_cc5 => 'Ciemny cyjan';

  @override
  String get common_habitColorType_cc6 => 'Zielony';

  @override
  String get common_habitColorType_cc7 => 'Bursztynowy';

  @override
  String get common_habitColorType_cc8 => 'Pomarańczowy';

  @override
  String get common_habitColorType_cc9 => 'Limonkowy';

  @override
  String get common_habitColorType_cc10 => 'Czarna orchidea';

  @override
  String get common_habitColorType_custom => 'Custom';

  @override
  String common_habitColorType_default(int index) {
    return 'Kolor $index';
  }

  @override
  String get common_appThemeColor_system => 'System';

  @override
  String get common_appThemeColor_primary => 'Primary';

  @override
  String get common_appThemeColor_dynamic => 'Dynamic';

  @override
  String get common_customDateTimeFormatPicker_useSystemFormat_text =>
      'Użyj formatu systemowego';

  @override
  String get common_customDateTimeFormatPicker_fmtTileText => 'Format daty';

  @override
  String get common_customDateTimeFormatPicker_ymd_text => 'Rok Miesiąc Dzień';

  @override
  String get common_customDateTimeFormatPicker_mdy_text => 'Miesiąc Dzień Rok';

  @override
  String get common_customDateTimeFormatPicker_dmy_text => 'Dzień Miesiąc Rok';

  @override
  String get common_customDateTimeFormatPicker_SepTileText => 'Separator';

  @override
  String get common_customDateTimeFormatPicker_sepDash_text => 'Kreska';

  @override
  String get common_customDateTimeFormatPicker_sepSlash_text => 'Ukośnik';

  @override
  String get common_customDateTimeFormatPicker_sepSpace_text => 'Spacja';

  @override
  String get common_customDateTimeFormatPicker_sepDot_text => 'Kropka';

  @override
  String get common_customDateTimeFormatPicker_empty_text => 'Brak separatora';

  @override
  String common_customDateTimeFormatPicker_sep_formatter(
    String splitName,
    String splitChar,
  ) {
    return '$splitName: \"$splitChar\"';
  }

  @override
  String get common_customDateTimeFormatPicker_12Hour_text =>
      'Użyj formatu 12-godzinnego';

  @override
  String get common_customDateTimeFormatPicker_monthName_text =>
      'Użyj pełnej nazwy miesiąca';

  @override
  String get common_customDateTimeFormatPicker_applyFreqChart_text =>
      'Zastosuj w wykresie częstotliwości';

  @override
  String get common_customDateTimeFormatPicker_applyHeapmap_text =>
      'Zastosuj w kalendarzu';

  @override
  String get common_customDateTimeFormatPicker_cancelButton_text => 'anuluj';

  @override
  String get common_customDateTimeFormatPicker_confirmButton_text =>
      'potwierdź';

  @override
  String get common_errorPage_title => 'Ups, awaria!';

  @override
  String get common_errorPage_copied => 'Skopiowano informacje o awarii';

  @override
  String get common_enable_text => 'Włączone';

  @override
  String get common_dontShowAgain => 'Don\'t show again';

  @override
  String get calendarPicker_clip_today => 'Dzisiaj';

  @override
  String get calendarPicker_clip_tomorrow => 'Jutro';

  @override
  String calendarPicker_clip_after7Days(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.E(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Następny $dateString';
  }

  @override
  String get exportConfirmDialog_title_exportAll =>
      'Wyeksportować wszystkie nawyki?';

  @override
  String exportConfirmDialog_title_exportMulti(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$number nawyków',
      one: '1 nawyk',
      zero: 'bieżący nawyk',
    );
    return 'Wyeksportować $_temp0?';
  }

  @override
  String get exportConfirmDialog_option_includeRecords => 'dołącz rekordy';

  @override
  String get exportConfirmDialog_option_includeGroups => 'include groups';

  @override
  String exportConfirmDialog_tile_includeRecords(int count) {
    return 'Include $count records';
  }

  @override
  String exportConfirmDialog_tile_includeGroups(int count) {
    return 'Include $count groups';
  }

  @override
  String get exportConfirmDialog_cancel_buttonText => 'anuluj';

  @override
  String get exportConfirmDialog_confirm_buttonText => 'eksportuj';

  @override
  String get debug_logLevelTile_title => 'Poziom logowania';

  @override
  String get debug_logLevelDialog_title => 'Zmień poziom logowania';

  @override
  String get debug_logLevel_debug => 'Debug';

  @override
  String get debug_logLevel_info => 'Informacja';

  @override
  String get debug_logLevel_warn => 'Ostrzeżenie';

  @override
  String get debug_logLevel_error => 'Błąd';

  @override
  String get debug_logLevel_fatal => 'Krytyczny';

  @override
  String get debug_collectLogTile_title => 'Zbieranie logów';

  @override
  String get debug_collectLogTile_enable_subtitle =>
      'Dotknij, aby zatrzymać zbieranie logów.';

  @override
  String get debug_collectLogTile_disable_subtitle =>
      'Dotknij, aby rozpocząć zbieranie logów.';

  @override
  String get debug_downladDebugLogs_subject => 'Pobieranie logów debugowania';

  @override
  String get dbeug_clearDebugLogs_complete_snackbar =>
      'Logi debugowania wyczyszczone.';

  @override
  String get debug_downladDebugInfo_subject =>
      'Pobieranie informacji debugowania';

  @override
  String debug_downladDebugZip_subject(String fileName) {
    return 'Pobieranie  $fileName';
  }

  @override
  String get debug_missingDebugLogFile_snackbar =>
      'Log debugowania nie istnieje.';

  @override
  String get debug_debuggerLogCard_title => 'Informacje logowania';

  @override
  String get debug_debuggerLogCard_subtitle =>
      'Zawiera lokalne informacje logowania, wymaga włączenia przełącznika zbierania logów.';

  @override
  String get debug_debuggerLogCard_saveButton_text => 'Pobierz';

  @override
  String get debug_debuggerLogCard_clearButton_text => 'Wyczyść';

  @override
  String get debug_debuggerInfoCard_title => 'Informacje debugowania';

  @override
  String get debug_debuggerInfoCard_subtitle =>
      'Zawiera informacje debugowania aplikacji.';

  @override
  String get debug_debuggerInfoCard_openButton_text => 'Otwórz';

  @override
  String get debug_debuggerInfoCard_saveButton_text => 'Zapisz';

  @override
  String get debug_debuggerInfo_notificationTitle =>
      'Zbieranie informacji aplikacji...';

  @override
  String confirmDialog_confirm_text(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'save': 'Zapisz',
      'exit': 'Wyjdź',
      'delete': 'Usuń',
      'other': 'Potwierdź',
    });
    return '$_temp0';
  }

  @override
  String get confirmDialog_cancel_text => 'Anuluj';

  @override
  String get snackbar_undoText => 'COFNIJ';

  @override
  String get snackbar_dismissText => 'ZAMKNIJ';

  @override
  String get contributors_tile_title => 'Współtwórcy';

  @override
  String get userAction_tap => 'Dotknij';

  @override
  String get userAction_doubleTap => 'Podwójne';

  @override
  String get userAction_longTap => 'Przytrzymaj';

  @override
  String get channelName_habitReminder => 'Przypomnienie o nawyku';

  @override
  String get channelName_appReminder => 'Powiadomienie';

  @override
  String get channelName_appDebugger => 'Debuger';

  @override
  String get channelName_appSyncing => 'Proces synchronizacji';

  @override
  String get channelDesc_appSyncing =>
      'Używane do wyświetlania postępu synchronizacji i wyników bez błędów';

  @override
  String get channelName_appSyncFailed => 'Synchronizacja nie powiodła się';

  @override
  String get channelDesc_appSyncFailed =>
      'Używane do powiadamiania o niepowodzeniu synchronizacji';

  @override
  String changelog_banner_title(String version) {
    return 'What\'s New in v$version';
  }

  @override
  String get changelog_banner_action => 'CLOSE';

  @override
  String get changelog_banner_view => 'VIEW';

  @override
  String get changelog_dialog_title => 'Changelog';

  @override
  String get changelog_view_full => 'View Full Changelog';

  @override
  String get habitGroup_uncategorized => 'No Group';

  @override
  String get habitDetail_groupTile_title => 'Group';

  @override
  String get habitEdit_groupTile_title => 'Group';

  @override
  String get habitEdit_groupPicker_hintText => 'Search or create group';

  @override
  String get habitEdit_groupPicker_noGroup => 'No Group';

  @override
  String habitEdit_groupPicker_createGroup(String name) {
    return 'Create \"$name\"';
  }

  @override
  String get habitEdit_groupPicker_loading => 'Loading groups…';

  @override
  String get groupManage_appbar_title => 'Manage Groups';

  @override
  String groupManage_selectionAppbar_title(int count) {
    return '$count selected';
  }

  @override
  String get groupManage_emptyState_text =>
      'No groups yet\nTap + to create your first group';

  @override
  String get groupManage_deleteDialog_title => 'Delete Group';

  @override
  String groupManage_deleteDialog_content(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Habits in these $count groups will become uncategorized.',
      one: 'Habits in this group will become uncategorized.',
    );
    return '$_temp0';
  }

  @override
  String get groupManage_deleteDialog_confirm => 'Usuń';

  @override
  String get groupManage_deleteDialog_cancel => 'Anuluj';

  @override
  String get groupManage_deleted_snackbarText => 'Group deleted';

  @override
  String get groupManage_undo_snackbarAction => 'Undo';

  @override
  String get groupManage_editDialog_title => 'Edit Group';

  @override
  String get groupManage_createDialog_title => 'Create Group';

  @override
  String get groupManage_nameRequired => 'Name is required';

  @override
  String groupManage_nameTooLong(int max) {
    return 'Name must be ≤ $max characters';
  }

  @override
  String get groupManage_name_label => 'Według nazwy';

  @override
  String get groupManage_desc_label => 'Description';

  @override
  String groupManage_descTooLong(int max) {
    return 'Description should be ≤ $max characters';
  }

  @override
  String get groupManage_sortTile_text => 'Sort Groups';

  @override
  String get groupManage_sectionTitle_text => 'Groups';

  @override
  String get groupManage_createDateTile_title => 'Utworzono';

  @override
  String get groupManage_modifyDateTile_title => 'Zmodyfikowano';

  @override
  String get groupManage_icon_label => 'Icon';

  @override
  String get groupManage_icon_none => 'brak';

  @override
  String get groupManage_color_label => 'Według koloru';

  @override
  String get groupManage_color_none => 'brak';

  @override
  String get groupManage_reorder_tooltip => 'Reorder groups';

  @override
  String get groupManage_menu_edit => 'Edytuj';

  @override
  String get groupManage_menu_delete => 'Usuń';

  @override
  String get groupManage_selectAll => 'Zaznacz wszystkie';

  @override
  String get groupHeader_menu_manage => 'Manage';

  @override
  String get groupHeader_menu_collapseAll => 'Collapse all';

  @override
  String get groupHeader_menu_expandAll => 'Expand all';

  @override
  String get appSetting_manageGroups_subtitleText =>
      'Create, edit, and delete habit groups';

  @override
  String get habitDisplay_groupType_manual => 'Moja kolejność';

  @override
  String get wToday => 'Today';

  @override
  String get wHobbies => 'Hobbies';

  @override
  String get wWallet => 'Hobby wallet';

  @override
  String get wWalletTab => 'Wallet';

  @override
  String get wWishlist => 'Wishes';

  @override
  String get wTodayReward => 'Today’s rewards';

  @override
  String get wMonthReward => 'Monthly net rewards';

  @override
  String get wSubtitle => 'Save a little dedication for the things you love.';

  @override
  String get wCurrentWish => 'Your next reward';

  @override
  String get wTodayHobbies => 'Today’s hobbies';

  @override
  String get wAllDone => 'Today’s dedication is safely saved.';

  @override
  String get wEmptyToday => 'No hobbies to record on this day.';

  @override
  String get wEmptyHobbies => 'Start with one thing you love';

  @override
  String get wEmptyHobbiesBody =>
      'Add a hobby and choose a small reward for each check-in.';

  @override
  String get wEmptyWishes => 'Something to look forward to';

  @override
  String get wEmptyWishesBody =>
      'Add something you truly want, then work toward it one day at a time.';

  @override
  String get wEmptyLedger => 'Every small step will leave a record here.';

  @override
  String get wAddHobby => 'Add hobby';

  @override
  String get wEditHobby => 'Edit hobby';

  @override
  String get wAddWish => 'Add wish';

  @override
  String get wEditWish => 'Edit wish';

  @override
  String get wName => 'Name';

  @override
  String get wEmoji => 'Emoji / icon';

  @override
  String get wDescription => 'Description (optional)';

  @override
  String get wDuration => 'Duration (minutes)';

  @override
  String get wReward => 'Amount per occurrence (¥)';

  @override
  String get wFrequency => 'Frequency';

  @override
  String get wWeekdays => 'Days of the week';

  @override
  String get wTimes => 'Times per period';

  @override
  String get wDays => 'Days per period';

  @override
  String get wDaily => 'Daily';

  @override
  String get wWeekly => 'Weekly';

  @override
  String get wMonthly => 'Monthly';

  @override
  String get wCustom => 'Custom period';

  @override
  String get wFrequencyHint =>
      'Check in on selected weekdays, at most once a day. Rest after reaching the period’s target.';

  @override
  String get wComplete => 'Complete';

  @override
  String get wCompleted => 'Completed ✓';

  @override
  String get wUndo => 'Undo';

  @override
  String get wSave => 'Save';

  @override
  String get wCancel => 'Cancel';

  @override
  String get wDelete => 'Delete';

  @override
  String get wArchive => 'Archive';

  @override
  String get wRestoreHobby => 'Unarchive';

  @override
  String get wArchived => 'Archived';

  @override
  String get wShowArchived => 'Show archived hobbies';

  @override
  String get wAdjust => 'Adjust balance';

  @override
  String get wAdjustHelp =>
      'Enter a positive amount to add or a negative amount to subtract. Every adjustment is recorded.';

  @override
  String get wAmount => 'Adjustment (¥)';

  @override
  String get wReason => 'Reason';

  @override
  String get wRecent => 'Recent activity';

  @override
  String get wLedgerLimit =>
      'Showing the latest 200 entries. Full history is included in backups.';

  @override
  String get wEarn => 'Hobby reward';

  @override
  String get wSpend => 'Wish redeemed';

  @override
  String get wAdjustment => 'Adjustment';

  @override
  String get wTargetPrice => 'Target price (¥)';

  @override
  String get wNote => 'Note (optional)';

  @override
  String get wPrimary => 'Make this my primary wish';

  @override
  String get wRedeem => 'Redeem reward';

  @override
  String get wConfirmRedeem => 'Confirm redemption';

  @override
  String get wReady => '🎉 Your reward is within reach';

  @override
  String get wRedeemed => 'Redeemed';

  @override
  String get wSettings => 'Settings';

  @override
  String get wCurrency => 'Default currency';

  @override
  String get wCurrencyValue => 'CNY ¥ · Virtual bookkeeping unit';

  @override
  String get wDisclaimer =>
      'Amounts in your hobby wallet are only for personal motivation and virtual bookkeeping.\nThe app does not provide real money rewards, withdrawals or currency exchange.';

  @override
  String get wAbout => 'About WishLoop';

  @override
  String get wAboutBody =>
      'WishLoop · Hobby Wallet\nBuild lasting hobbies and reward yourself.\nBased on Table Habit, licensed under Apache-2.0.';

  @override
  String get wBackup => 'Export full backup';

  @override
  String get wBackupHelp =>
      'Includes hobbies, check-ins, ledger and wishes. Theme and language stay on this device.';

  @override
  String get wImport => 'Restore full backup';

  @override
  String get wImportConfirm =>
      'Restore replaces all current hobbies, check-ins, ledger and wishes. Export a backup first. Invalid files leave your data unchanged.';

  @override
  String get wImportDone => 'Backup restored';

  @override
  String get wBackupDone => 'Backup saved';

  @override
  String get wLegacyImport => 'Import Table Habit data';

  @override
  String get wLegacyHelp =>
      'Keep existing hobbies and check-ins. Historical records do not earn retroactive rewards.';

  @override
  String get wLegacyConfirm =>
      'Merge hobbies and historical check-ins. Matching records may be updated. Export a full backup first.';

  @override
  String get wLegacyDone =>
      'Import finished. Check your hobbies; historical check-ins do not earn rewards.';

  @override
  String get wNotifications => 'Notifications & reminders';

  @override
  String get wReminder => 'Hobby reminder';

  @override
  String get wReminderHelp =>
      'A gentle reminder at your chosen time. Android battery settings may delay delivery.';

  @override
  String get wReminderDenied =>
      'Could not enable reminders. Allow WishLoop notifications in Android settings.';

  @override
  String get wTestNotification => 'Send test notification';

  @override
  String get wTestSent => 'Test notification sent';

  @override
  String get wRetry => 'Retry';

  @override
  String get wError => 'The action could not be completed. Please try again.';

  @override
  String get wLoadError => 'Could not load your data. Please retry.';

  @override
  String get wInvalid =>
      'Enter valid details and an amount; amounts round to two decimal places.';

  @override
  String get wInsufficient => 'Not enough rewards to redeem this wish.';

  @override
  String get wAlreadyRedeemed => 'This wish has already been redeemed.';

  @override
  String get wSaved => 'Saved';

  @override
  String get wUndoDone => 'Check-in and its reward undone';

  @override
  String get wNegativeBalance =>
      'Undoing or adjusting can make your balance negative. Future rewards will continue to add up.';

  @override
  String get wDeleteConfirm =>
      'Deleting does not erase rewards you have already earned.';

  @override
  String get wNotificationsOff => 'Reminders are off';

  @override
  String get wNotificationBody =>
      'Make a little time for something you love today.';

  @override
  String wMinutes(int value) {
    return 'About $value min';
  }

  @override
  String wRewardLabel(String amount) {
    return 'Reward $amount';
  }

  @override
  String wCompleteFeedback(String name, String amount) {
    return '$name complete. Reward $amount 🎉';
  }

  @override
  String wWishAmounts(String balance, String target) {
    return '$balance / $target';
  }

  @override
  String wShortfall(String amount) {
    return '$amount to go';
  }

  @override
  String wRedeemTitle(String name) {
    return 'Redeem $name?';
  }

  @override
  String wRedeemBody(String price, String balance) {
    return 'Deduct from your hobby wallet:\n$price\n\nBalance after redemption:\n$balance\n\nThis is a virtual ledger entry. Any real purchase is your own decision.';
  }

  @override
  String wRedeemedAt(String date) {
    return 'Redeemed $date';
  }

  @override
  String wReminderBody(String name, String amount) {
    return 'You haven’t completed $name today. Your reward: $amount.';
  }

  @override
  String get wRewardCalendar => 'Reward calendar';

  @override
  String get wCalendarWeek => 'Week';

  @override
  String get wCalendarMonth => 'Month';

  @override
  String get wPreviousPeriod => 'Previous period';

  @override
  String get wNextPeriod => 'Next period';

  @override
  String wPeriodNet(String amount) {
    return 'Net rewards $amount';
  }

  @override
  String get wCalendarLegend =>
      'Red: gain · Green: loss · Intensity scaled to this period';

  @override
  String get wExpandMonth =>
      'Swipe down for month; swipe sideways to change week';

  @override
  String get wCollapseWeek =>
      'Swipe up on the header for week; swipe sideways to change month';

  @override
  String get wFutureDay => 'Future date: recording is unavailable';

  @override
  String wDateHobbies(String date) {
    return 'Hobbies for $date';
  }

  @override
  String wSelectedNet(String amount) {
    return 'Selected day: $amount net';
  }

  @override
  String get wSignedRewardHelp =>
      'Positive amounts reward you; negative amounts deduct for unwanted habits. Amounts round to two decimal places.';

  @override
  String get wPenalty => 'Habit deduction';

  @override
  String wPenaltyLabel(String amount) {
    return 'Occurrence deduction $amount';
  }

  @override
  String get wRecordPenalty => 'Record occurrence';

  @override
  String get wPenaltyRecorded => 'Recorded ✓';

  @override
  String wPenaltyFeedback(String name, String amount) {
    return '$name recorded: $amount deducted';
  }

  @override
  String wPenaltyReminder(String name, String amount) {
    return 'Avoid $name; recording an occurrence deducts $amount.';
  }

  @override
  String get wEstimateReached => 'Goal reached';

  @override
  String wEstimateDays(int days) {
    return 'About $days more days';
  }

  @override
  String get wEstimateUnavailable =>
      'No estimate: net rewards over the last 14 days are not positive';

  @override
  String get wSwitchToMonth => 'Switch to month view';

  @override
  String get wSwitchToWeek => 'Switch to week view';

  @override
  String get wHobbyNameRequired => 'Enter a hobby name.';

  @override
  String get wHomeLayout => 'Home layout';

  @override
  String get wCompactMode => 'Compact mode';

  @override
  String get wHobbiesFirst => 'Hobbies before wish';

  @override
  String get wExpandWish => 'Expand wish';

  @override
  String get wCollapseWish => 'Collapse wish';

  @override
  String get wCategories => 'Categories';

  @override
  String get wCategory => 'Category';

  @override
  String get wAllCategories => 'All';

  @override
  String get wUncategorized => 'Uncategorized';

  @override
  String get wManageCategories => 'Manage categories';

  @override
  String get wAddCategory => 'New category';

  @override
  String get wCategoryName => 'Category name';

  @override
  String get wCategoryRequired => 'Enter a category name';

  @override
  String get wDeleteCategoryBody =>
      'Hobbies will move to Uncategorized. Check-ins and ledger entries are preserved.';

  @override
  String get wNoCategories => 'Create categories to organize your hobbies';

  @override
  String get wReorderHobby => 'Drag to reorder';

  @override
  String get wNoCategoryHobbies => 'No hobbies in this category yet';

  @override
  String get wHomeWidget => 'Android home screen widget';

  @override
  String get wAddHomeWidget => 'Add to home screen';

  @override
  String get wHomeWidgetHelp =>
      'See your balance, wish progress and today’s hobbies. Tap a hobby to check in inside the app.';

  @override
  String get wHomeWidgetManual =>
      'Long-press an empty area on your Android home screen, choose Widgets, then drag WishLoop onto the home screen.';

  @override
  String get wWidgetRefresh => 'Open to refresh today’s hobbies';

  @override
  String get wWidgetEmpty => 'Add your first hobby';

  @override
  String get wWidgetNoWish => 'Choose a primary wish';

  @override
  String get wWidgetOpen => 'Open WishLoop';
}
