import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flauncher/flauncher_channel.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/media_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flauncher/models/category.dart';
import 'package:flauncher/gradients.dart';

@GenerateMocks([
  FLauncherChannel,
  WallpaperService,
  AppsService,
  MediaService,
  SettingsService,
  ImagePicker,
], customMocks: [
  MockSpec<FLauncherDatabase>(unsupportedMembers: {#alias}),
  MockSpec<ImageProvider>(unsupportedMembers: {#alias}),
])
void main() {}

class MockAppsService extends Mock implements AppsService {
  @override
  List<CategoryWithApps> get categoriesWithApps => super.noSuchMethod(
    Invocation.getter(#categoriesWithApps),
    returnValue: <CategoryWithApps>[],
  );
  
  @override
  List<Category> get categories => super.noSuchMethod(
    Invocation.getter(#categories),
    returnValue: <Category>[],
  );
  
  @override
  List<LauncherSection> get launcherSections => super.noSuchMethod(
    Invocation.getter(#launcherSections),
    returnValue: <LauncherSection>[],
  );
  
  @override
  bool get initialized => super.noSuchMethod(
    Invocation.getter(#initialized),
    returnValue: true,
  );
  
  @override
  Future<void> moveCategory(int oldIndex, int newIndex) => super.noSuchMethod(
    Invocation.method(#moveCategory, [oldIndex, newIndex]),
    returnValue: Future.value(),
    returnValueForMissingStub: Future.value(),
  );
  
  @override
  Future<void> setCategorySort(Category category, CategorySort sort, {bool shouldNotifyListeners = true}) => super.noSuchMethod(
    Invocation.method(#setCategorySort, [category, sort], {#shouldNotifyListeners: shouldNotifyListeners}),
    returnValue: Future.value(),
    returnValueForMissingStub: Future.value(),
  );
  
  @override
  Future<void> setCategoryType(Category category, CategoryType type, {bool shouldNotifyListeners = true}) => super.noSuchMethod(
    Invocation.method(#setCategoryType, [category, type], {#shouldNotifyListeners: shouldNotifyListeners}),
    returnValue: Future.value(),
    returnValueForMissingStub: Future.value(),
  );
  
  @override
  Future<void> setCategoryColumnsCount(Category category, int columnsCount) => super.noSuchMethod(
    Invocation.method(#setCategoryColumnsCount, [category, columnsCount]),
    returnValue: Future.value(),
    returnValueForMissingStub: Future.value(),
  );
  
  @override
  Future<void> setCategoryRowHeight(Category category, int rowHeight) => super.noSuchMethod(
    Invocation.method(#setCategoryRowHeight, [category, rowHeight]),
    returnValue: Future.value(),
    returnValueForMissingStub: Future.value(),
  );
  
  @override
  Future<void> deleteSection(int index) => super.noSuchMethod(
    Invocation.method(#deleteSection, [index]),
    returnValue: Future.value(),
    returnValueForMissingStub: Future.value(),
  );
  
  @override
  Future<void> saveApplicationOrderInCategory(Category category) => super.noSuchMethod(
    Invocation.method(#saveApplicationOrderInCategory, [category]),
    returnValue: Future.value(),
    returnValueForMissingStub: Future.value(),
  );
}

class MockSettingsService extends Mock implements SettingsService {
  @override
  bool get enableAnimations => super.noSuchMethod(
    Invocation.getter(#enableAnimations),
    returnValue: false,
  );

  @override
  set enableAnimations(bool value) => super.noSuchMethod(
    Invocation.setter(#enableAnimations, value),
    returnValueForMissingStub: null,
  );
  
  @override
  bool get appHighlightAnimationEnabled => super.noSuchMethod(
    Invocation.getter(#appHighlightAnimationEnabled),
    returnValue: true,
  );
  
  @override
  bool get appKeyClickEnabled => super.noSuchMethod(
    Invocation.getter(#appKeyClickEnabled),
    returnValue: true,
  );
  
  @override
  bool get autoHideAppBarEnabled => super.noSuchMethod(
    Invocation.getter(#autoHideAppBarEnabled),
    returnValue: false,
  );
  
  @override
  bool get showCategoryTitles => super.noSuchMethod(
    Invocation.getter(#showCategoryTitles),
    returnValue: true,
  );
  
  @override
  bool get showDateInStatusBar => super.noSuchMethod(
    Invocation.getter(#showDateInStatusBar),
    returnValue: true,
  );
  
  @override
  bool get showTimeInStatusBar => super.noSuchMethod(
    Invocation.getter(#showTimeInStatusBar),
    returnValue: true,
  );
  
  @override
  String get gradientUuid => super.noSuchMethod(
    Invocation.getter(#gradientUuid),
    returnValue: null,
  );
  
  @override
  String get backButtonAction => super.noSuchMethod(
    Invocation.getter(#backButtonAction),
    returnValue: "NOTHING",
  );
  
  @override
  String get dateFormat => super.noSuchMethod(Invocation.getter(#dateFormat),
      returnValue: "yyyy-MM-dd");
  
  @override
  String get timeFormat => super.noSuchMethod(Invocation.getter(#timeFormat),
      returnValue: "HH:mm");
  
  @override
  String? get unsplashQuery => super.noSuchMethod(
    Invocation.getter(#unsplashQuery),
    returnValue: null,
  );
}

class MockWallpaperService extends Mock implements WallpaperService {
  @override
  WallpaperOption get selectedOption => super.noSuchMethod(Invocation.getter(#selectedOption),
      returnValue: WallpaperOption.gradient);
  
  @override
  FLauncherGradient get gradient => super.noSuchMethod(Invocation.getter(#gradient),
      returnValue: FLauncherGradients.greatWhale);
}

class MockMediaService extends Mock implements MediaService {
  @override
  bool get hasActiveMedia => super.noSuchMethod(Invocation.getter(#hasActiveMedia),
      returnValue: false,
      returnValueForMissingStub: false);
}