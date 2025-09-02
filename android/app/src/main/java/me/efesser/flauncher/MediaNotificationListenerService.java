/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
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

import android.annotation.TargetApi;
import android.media.session.MediaController;
import android.media.session.MediaSession;
import android.media.session.MediaSessionManager;
import android.os.Build;
import android.service.notification.NotificationListenerService;
import android.service.notification.StatusBarNotification;

import java.util.List;

@TargetApi(Build.VERSION_CODES.LOLLIPOP)
public class MediaNotificationListenerService extends NotificationListenerService {

    private static MediaNotificationListenerService instance;
    private MediaSessionManager mediaSessionManager;

    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            mediaSessionManager = (MediaSessionManager) getSystemService(MEDIA_SESSION_SERVICE);
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        instance = null;
    }

    @Override
    public void onNotificationPosted(StatusBarNotification sbn) {
        // We can handle notification posted events if needed
    }

    @Override
    public void onNotificationRemoved(StatusBarNotification sbn) {
        // We can handle notification removed events if needed
    }

    /**
     * Get the active media sessions
     * This requires the NotificationListenerService to be enabled
     */
    public List<MediaController> getActiveMediaSessions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && mediaSessionManager != null) {
            try {
                return mediaSessionManager.getActiveSessions(null);
            } catch (SecurityException e) {
                // Permission not granted
                return null;
            }
        }
        return null;
    }

    /**
     * Static method to get the instance of this service
     */
    public static MediaNotificationListenerService getInstance() {
        return instance;
    }

    /**
     * Check if the service is running and connected
     */
    public static boolean isServiceEnabled() {
        return instance != null;
    }
}
