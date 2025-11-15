/*
 * FLauncher
 * Copyright (C) 2021  Oscar Rojas
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

package com.geert.flauncher;


import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.*;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.media.MediaMetadata;
import android.media.session.MediaController;
import android.media.session.MediaSession;
import android.media.session.MediaSessionManager;
import android.media.session.PlaybackState;
import android.net.ConnectivityManager;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;
import android.util.Pair;
import android.view.KeyEvent;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

import java.io.ByteArrayOutputStream;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletionService;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorCompletionService;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

public class MainActivity extends FlutterActivity
{
    private final String METHOD_CHANNEL = "com.geert.flauncher/method";
    private final String APPS_EVENT_CHANNEL = "com.geert.flauncher/event_apps";
    private final String NETWORK_EVENT_CHANNEL = "com.geert.flauncher/event_network";
    private final String MEDIA_EVENT_CHANNEL = "com.geert.flauncher/event_media";

    private MediaSessionManager mediaSessionManager;
    private MediaController activeMediaController;
    private EventChannel.EventSink mediaEventSink;
    private MediaSessionManager.OnActiveSessionsChangedListener sessionListener;
    private MediaController.Callback mediaCallback;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine)
    {
        super.configureFlutterEngine(flutterEngine);

        BinaryMessenger messenger = flutterEngine.getDartExecutor().getBinaryMessenger();

        new MethodChannel(messenger, METHOD_CHANNEL).setMethodCallHandler((call, result) -> {
            switch (call.method)
            {
                case "getApplications" -> result.success(getApplications());
                case "getApplicationBanner" -> result.success(getApplicationBanner(call.arguments()));
                case "getApplicationIcon" -> result.success(getApplicationIcon(call.arguments()));
                case "applicationExists" -> result.success(applicationExists(call.arguments()));
                case "launchActivityFromAction" -> result.success(launchActivityFromAction(call.arguments()));
                case "launchApp" -> result.success(launchApp(call.arguments()));
                case "openSettings" -> result.success(openSettings());
                case "openWifiSettings" -> result.success(openWifiSettings());
                case "openAppInfo" -> result.success(openAppInfo(call.arguments()));
                case "uninstallApp" -> result.success(uninstallApp(call.arguments()));
                case "isDefaultLauncher" -> result.success(isDefaultLauncher());
                case "checkForGetContentAvailability" -> result.success(checkForGetContentAvailability());
                case "startAmbientMode" -> result.success(startAmbientMode());
                case "getActiveNetworkInformation" -> result.success(getActiveNetworkInformation());
                case "getCurrentMediaSession" -> result.success(getCurrentMediaSession());
                case "sendMediaAction" -> result.success(sendMediaAction(call.arguments()));
                case "sendPlayPause" -> result.success(sendPlayPause());
                case "sendPlay" -> result.success(sendPlay());
                case "sendPause" -> result.success(sendPause());
                case "sendSkipToNext" -> result.success(sendSkipToNext());
                case "sendSkipToPrevious" -> result.success(sendSkipToPrevious());
                default -> throw new IllegalArgumentException();
            }
        });

        new EventChannel(messenger, APPS_EVENT_CHANNEL).setStreamHandler(
                new LauncherAppsEventStreamHandler(this));

        new EventChannel(messenger, NETWORK_EVENT_CHANNEL).setStreamHandler(
                new NetworkEventStreamHandler(this));

        new EventChannel(messenger, MEDIA_EVENT_CHANNEL).setStreamHandler(
                new MediaSessionEventStreamHandler());

        initializeMediaSessionManager();
    }

    private List<Map<String, Serializable>> getApplications() {
        ExecutorService executor = Executors.newFixedThreadPool(4);
        CompletionService<Pair<Boolean, List<ResolveInfo>>> queryIntentActivitiesCompletionService =
                new ExecutorCompletionService<>(executor);
        queryIntentActivitiesCompletionService.submit(() ->
                Pair.create(false, queryIntentActivities(false)));
        queryIntentActivitiesCompletionService.submit(() ->
                Pair.create(true, queryIntentActivities(true)));
        List<ResolveInfo> tvActivitiesInfo = null;
        List<ResolveInfo> nonTvActivitiesInfo = null;

        int completed = 0;
        while (completed < 2) {
            try {
                var activitiesInfo = queryIntentActivitiesCompletionService.take().get();

                if (!activitiesInfo.first) {
                    tvActivitiesInfo = activitiesInfo.second;
                }
                else {
                    nonTvActivitiesInfo = activitiesInfo.second;
                }
            } catch (InterruptedException | ExecutionException ignored) { }
            finally {
                completed += 1;
            }
        }

        CompletionService<Map<String, Serializable>> completionService = new ExecutorCompletionService<>(executor);

        List<Map<String, Serializable>> applications = new ArrayList<>(
                tvActivitiesInfo.size() + nonTvActivitiesInfo.size());

        boolean settingsPresent = false;
        int appCount = 0;
        for (ResolveInfo tvActivityInfo : tvActivitiesInfo) {
            if (!settingsPresent) {
                settingsPresent = tvActivityInfo.activityInfo.packageName.equals("com.android.tv.settings");
            }

            completionService.submit(() -> buildAppMap(tvActivityInfo.activityInfo, false, null));
            appCount += 1;
        }

        for (ResolveInfo nonTvActivityInfo : nonTvActivitiesInfo) {
            boolean nonDuplicate = true;

            if (!settingsPresent) {
                settingsPresent = nonTvActivityInfo.activityInfo.packageName.equals("com.android.settings");
            }

            for (ResolveInfo tvActivityInfo : tvActivitiesInfo) {
                if (tvActivityInfo.activityInfo.packageName.equals(nonTvActivityInfo.activityInfo.packageName)) {
                    nonDuplicate = false;
                    break;
                }
            }

            if (nonDuplicate) {
                appCount += 1;
                completionService.submit(() -> buildAppMap(nonTvActivityInfo.activityInfo, true, null));
            }
        }

        while (appCount > 0) {
            try {
                Future<Map<String, Serializable>> appMap = completionService.take();
                applications.add(appMap.get());
            } catch (InterruptedException | ExecutionException ignored) {
            } finally {
                appCount -= 1;
            }
        }

        executor.shutdown();

        if (!settingsPresent) {
            PackageManager packageManager = getPackageManager();
            Intent settingsIntent = new Intent(Settings.ACTION_SETTINGS);
            ActivityInfo activityInfo = settingsIntent.resolveActivityInfo(packageManager, 0);

            if (activityInfo != null) {
                applications.add(buildAppMap(activityInfo, false, Settings.ACTION_SETTINGS));
            }
        }

        return applications;
    }

    public Map<String, Serializable> getApplication(String packageName) {
        Map<String, Serializable> map = Map.of();
        PackageManager packageManager = getPackageManager();
        Intent intent = packageManager.getLeanbackLaunchIntentForPackage(packageName);

        if (intent == null) {
            intent = packageManager.getLaunchIntentForPackage(packageName);
        }

        if (intent != null) {
            ActivityInfo activityInfo = intent.resolveActivityInfo(getPackageManager(), 0);

            if (activityInfo != null) {
                map = buildAppMap(activityInfo, false, null);
            }
        }

        return map;
    }

    private byte[] getApplicationBanner(String packageName) {
        byte[] imageBytes = new byte[0];

        PackageManager packageManager = getPackageManager();
        try {
            ApplicationInfo info = packageManager.getApplicationInfo(packageName, 0);
            Drawable drawable = info.loadBanner(packageManager);

            if (drawable != null) {
                imageBytes = drawableToByteArray(drawable);
            }
        } catch (PackageManager.NameNotFoundException ignored) { }

        return imageBytes;
    }

    private byte[] getApplicationIcon(String packageName) {
        byte[] imageBytes = new byte[0];

        PackageManager packageManager = getPackageManager();
        try {
            ApplicationInfo info = packageManager.getApplicationInfo(packageName, 0);
            Drawable drawable = info.loadIcon(packageManager);

            if (drawable != null) {
                imageBytes = drawableToByteArray(drawable);
            }
        } catch (PackageManager.NameNotFoundException ignored) { }

        return imageBytes;
    }

    private boolean applicationExists(String packageName) {
        int flags;

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            flags = PackageManager.MATCH_UNINSTALLED_PACKAGES;
        } else {
            flags = PackageManager.GET_UNINSTALLED_PACKAGES;
        }

        try {
            getPackageManager().getApplicationInfo(packageName, flags);
            return true;
        } catch (PackageManager.NameNotFoundException ignored) {
            return false;
        }
    }

    private List<ResolveInfo> queryIntentActivities(boolean sideloaded) {
        String category;
        if (sideloaded) {
            category = Intent.CATEGORY_LAUNCHER;
        }
        else {
            category = Intent.CATEGORY_LEANBACK_LAUNCHER;
        }

        // NOTE: Would be nice to query the applications that match *either* of the above categories
        // but from the addCategory function documentation, it says that it will "use activities
        // that provide *all* the requested categories"
        Intent intent = new Intent(Intent.ACTION_MAIN)
                .addCategory(category);

        return getPackageManager()
                .queryIntentActivities(intent, 0);
    }

    private Map<String, Serializable> buildAppMap(ActivityInfo activityInfo, boolean sideloaded, String action) {
        PackageManager packageManager = getPackageManager();

        String  applicationName = activityInfo.loadLabel(packageManager).toString(),
                applicationVersionName = "";
        try {
            applicationVersionName = packageManager.getPackageInfo(activityInfo.packageName, 0).versionName;
        }
        catch (PackageManager.NameNotFoundException ignored) { }

        Map<String, Serializable> appMap = new HashMap<>();
        appMap.put("name", applicationName);
        appMap.put("packageName", activityInfo.packageName);
        appMap.put("version", applicationVersionName);
        appMap.put("sideloaded", sideloaded);

        if (action != null) {
            appMap.put("action", action);
        }
        return appMap;
    }

    private boolean launchActivityFromAction(String action) {
        return tryStartActivity(new Intent(action));
    }

    private boolean launchApp(String packageName) {
        PackageManager packageManager = getPackageManager();
        Intent intent = packageManager.getLeanbackLaunchIntentForPackage(packageName);

        if (intent == null) {
            intent = packageManager.getLaunchIntentForPackage(packageName);
        }

        return tryStartActivity(intent);
    }

    private boolean openSettings() {
        return launchActivityFromAction(Settings.ACTION_SETTINGS);
    }

    private boolean openWifiSettings() {
        return launchActivityFromAction(Settings.ACTION_WIFI_SETTINGS);
    }

    private boolean openAppInfo(String packageName) {
        Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                .setData(Uri.fromParts("package", packageName, null));

        return tryStartActivity(intent);
    }

    private boolean uninstallApp(String packageName) {
        Intent intent = new Intent(Intent.ACTION_DELETE)
                .setData(Uri.fromParts("package", packageName, null));

        return tryStartActivity(intent);
    }

    private boolean checkForGetContentAvailability() {
        List<ResolveInfo> intentActivities = getPackageManager().queryIntentActivities(
                new Intent(Intent.ACTION_GET_CONTENT, null).setTypeAndNormalize("image/*"),
                0);

        return !intentActivities.isEmpty();
    }

    private boolean isDefaultLauncher() {
        Intent intent = new Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME);
        ResolveInfo defaultLauncher = getPackageManager().resolveActivity(intent, 0);

        if (defaultLauncher != null && defaultLauncher.activityInfo != null) {
            return defaultLauncher.activityInfo.packageName.equals(getPackageName());
        }

        return false;
    }

    private boolean startAmbientMode()
    {
        Intent intent = new Intent(Intent.ACTION_MAIN)
                .setClassName("com.android.systemui", "com.android.systemui.Somnambulator");

        return tryStartActivity(intent);
    }

    private Map<String, Object> getActiveNetworkInformation()
    {
        ConnectivityManager connectivityManager = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return NetworkUtils.getNetworkInformation(this, connectivityManager.getActiveNetwork());
        }
        else {
            //noinspection deprecation
            return NetworkUtils.getNetworkInformation(this, connectivityManager.getActiveNetworkInfo());
        }
    }

    private boolean tryStartActivity(Intent intent)
    {
        boolean success = true;

        try {
            startActivity(intent);
        }
        catch (Exception ignored) {
            success = false;
        }

        return success;
    }

    private byte[] drawableToByteArray(Drawable drawable) {
        if (drawable.getIntrinsicWidth() <= 0 || drawable.getIntrinsicHeight() <= 0) {
            return new byte[0];
        }

        Bitmap bitmap;
        if (drawable instanceof BitmapDrawable bitmapDrawable) {
            bitmap = bitmapDrawable.getBitmap();
        }
        else {
            bitmap = drawableToBitmap(drawable);
        }
        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
        return stream.toByteArray();
    }

    Bitmap drawableToBitmap(Drawable drawable) {
        Bitmap bitmap = Bitmap.createBitmap(
                drawable.getIntrinsicWidth(),
                drawable.getIntrinsicHeight(),
                Bitmap.Config.ARGB_8888);

        Canvas canvas = new Canvas(bitmap);
        drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
        drawable.draw(canvas);
        return bitmap;
    }

    // Media Session Integration Methods
    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    private void initializeMediaSessionManager() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            mediaSessionManager = (MediaSessionManager) getSystemService(Context.MEDIA_SESSION_SERVICE);

            sessionListener = controllers -> {
                updateActiveMediaController();
            };

            mediaCallback = new MediaController.Callback() {
                @Override
                public void onPlaybackStateChanged(PlaybackState state) {
                    notifyMediaSessionChanged();
                }

                @Override
                public void onMetadataChanged(MediaMetadata metadata) {
                    notifyMediaSessionChanged();
                }
            };

            updateActiveMediaController();
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    private void updateActiveMediaController() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            // Unregister previous controller callback if exists
            if (activeMediaController != null) {
                activeMediaController.unregisterCallback(mediaCallback);
            }

            // Get active sessions
            List<MediaController> controllers = null;

            // Try to get sessions through NotificationListenerService first
            if (MediaNotificationListenerService.isServiceEnabled()) {
                controllers = MediaNotificationListenerService.getInstance().getActiveMediaSessions();
            }

            // Fallback to direct access if service not available
            if (controllers == null) {
                try {
                    ComponentName notificationListener = new ComponentName(this, MediaNotificationListenerService.class);
                    controllers = mediaSessionManager.getActiveSessions(notificationListener);
                } catch (SecurityException e) {
                    // Permission not granted, try with null component
                    try {
                        controllers = mediaSessionManager.getActiveSessions(null);
                    } catch (SecurityException ex) {
                        controllers = new ArrayList<>();
                    }
                }
            }

            if (controllers != null && !controllers.isEmpty()) {
                // Use the first active controller
                activeMediaController = controllers.get(0);
                activeMediaController.registerCallback(mediaCallback);
            } else {
                activeMediaController = null;
            }

            notifyMediaSessionChanged();
        }
    }

    private Map<String, Object> getCurrentMediaSession() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && activeMediaController != null) {
            Map<String, Object> sessionInfo = new HashMap<>();

            // Get package name
            sessionInfo.put("packageName", activeMediaController.getPackageName());

            // Get app name
            PackageManager pm = getPackageManager();
            try {
                ApplicationInfo appInfo = pm.getApplicationInfo(activeMediaController.getPackageName(), 0);
                sessionInfo.put("appName", pm.getApplicationLabel(appInfo).toString());
            } catch (PackageManager.NameNotFoundException e) {
                sessionInfo.put("appName", activeMediaController.getPackageName());
            }

            // Get metadata
            MediaMetadata metadata = activeMediaController.getMetadata();
            if (metadata != null) {
                sessionInfo.put("title", metadata.getString(MediaMetadata.METADATA_KEY_TITLE));
                sessionInfo.put("artist", metadata.getString(MediaMetadata.METADATA_KEY_ARTIST));
                sessionInfo.put("album", metadata.getString(MediaMetadata.METADATA_KEY_ALBUM));
                sessionInfo.put("duration", metadata.getLong(MediaMetadata.METADATA_KEY_DURATION));
            }

            // Get playback state
            PlaybackState playbackState = activeMediaController.getPlaybackState();
            if (playbackState != null) {
                sessionInfo.put("isPlaying", playbackState.getState() == PlaybackState.STATE_PLAYING);
                sessionInfo.put("position", playbackState.getPosition());

                // Get available actions
                List<String> actions = new ArrayList<>();
                long availableActions = playbackState.getActions();

                if ((availableActions & PlaybackState.ACTION_PLAY) != 0) actions.add("play");
                if ((availableActions & PlaybackState.ACTION_PAUSE) != 0) actions.add("pause");
                if ((availableActions & PlaybackState.ACTION_SKIP_TO_NEXT) != 0) actions.add("skipToNext");
                if ((availableActions & PlaybackState.ACTION_SKIP_TO_PREVIOUS) != 0) actions.add("skipToPrevious");
                if ((availableActions & PlaybackState.ACTION_SEEK_TO) != 0) actions.add("seekTo");

                sessionInfo.put("availableActions", actions);
            }

            sessionInfo.put("hasActiveSession", true);
            return sessionInfo;
        }

        // Return empty session info if no active controller
        Map<String, Object> emptySession = new HashMap<>();
        emptySession.put("hasActiveSession", false);
        return emptySession;
    }

    private boolean sendMediaAction(String action) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && activeMediaController != null) {
            MediaController.TransportControls controls = activeMediaController.getTransportControls();

            switch (action) {
                case "play" -> controls.play();
                case "pause" -> controls.pause();
                case "skipToNext" -> controls.skipToNext();
                case "skipToPrevious" -> controls.skipToPrevious();
                case "stop" -> controls.stop();
                default -> {
                    return false;
                }
            }
            return true;
        }
        return false;
    }

    private boolean sendPlayPause() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && activeMediaController != null) {
            PlaybackState state = activeMediaController.getPlaybackState();
            if (state != null) {
                MediaController.TransportControls controls = activeMediaController.getTransportControls();
                if (state.getState() == PlaybackState.STATE_PLAYING) {
                    controls.pause();
                } else {
                    controls.play();
                }
                return true;
            }
        }
        return false;
    }

    private boolean sendPlay() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && activeMediaController != null) {
            activeMediaController.getTransportControls().play();
            return true;
        }
        return false;
    }

    private boolean sendPause() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && activeMediaController != null) {
            activeMediaController.getTransportControls().pause();
            return true;
        }
        return false;
    }

    private boolean sendSkipToNext() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && activeMediaController != null) {
            activeMediaController.getTransportControls().skipToNext();
            return true;
        }
        return false;
    }

    private boolean sendSkipToPrevious() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && activeMediaController != null) {
            activeMediaController.getTransportControls().skipToPrevious();
            return true;
        }
        return false;
    }

    private void notifyMediaSessionChanged() {
        if (mediaEventSink != null) {
            mediaEventSink.success(getCurrentMediaSession());
        }
    }

    // Media Session Event Stream Handler
    private class MediaSessionEventStreamHandler implements EventChannel.StreamHandler {
        @Override
        public void onListen(Object arguments, EventChannel.EventSink events) {
            mediaEventSink = events;

            // Register session listener if not already registered
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && mediaSessionManager != null) {
                try {
                    ComponentName notificationListener = new ComponentName(MainActivity.this, MediaNotificationListenerService.class);
                    mediaSessionManager.addOnActiveSessionsChangedListener(sessionListener, notificationListener);
                } catch (SecurityException e) {
                    // Need notification listener permission - try with null
                    try {
                        mediaSessionManager.addOnActiveSessionsChangedListener(sessionListener, null);
                    } catch (SecurityException ex) {
                        // Cannot register listener without proper permissions
                    }
                }
            }

            // Send initial state
            notifyMediaSessionChanged();
        }

        @Override
        public void onCancel(Object arguments) {
            mediaEventSink = null;

            // Unregister listeners
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                if (mediaSessionManager != null && sessionListener != null) {
                    mediaSessionManager.removeOnActiveSessionsChangedListener(sessionListener);
                }

                if (activeMediaController != null && mediaCallback != null) {
                    activeMediaController.unregisterCallback(mediaCallback);
                }
            }
        }
    }
}
