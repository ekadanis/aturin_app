package com.AturinJaya.pdbl

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.content.Intent
import android.app.PendingIntent
import android.util.Log
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Aturin App Home Widget Provider - Simplified Version
 * Menampilkan jadwal aktivitas dan tugas hari ini
 */
class AturinAppHomeWidget : AppWidgetProvider() {
    
    private val TAG = "AturinAppHomeWidget"

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d(TAG, "onUpdate: Updating ${appWidgetIds.size} widgets")
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Widget pertama kali ditambahkan
        Log.d(TAG, "onEnabled: Widget added for the first time")
    }

    override fun onDisabled(context: Context) {
        // Widget terakhir dihapus
        Log.d(TAG, "onDisabled: Last widget instance removed")
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "onReceive: Received intent action: ${intent.action}")
        super.onReceive(context, intent)
    }

    companion object {
        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            Log.d("AturinAppHomeWidget", "updateAppWidget: Updating widget ID $appWidgetId")
            try {
                val widgetData = HomeWidgetPlugin.getData(context)
                Log.d("AturinAppHomeWidget", "updateAppWidget: Got shared preferences data")
                
                // Use simple and reliable layout
                val views = RemoteViews(context.packageName, android.R.layout.simple_list_item_1)
                Log.d("AturinAppHomeWidget", "updateAppWidget: Created RemoteViews with simple layout for package ${context.packageName}")

                // Get data from shared preferences
                val date = widgetData.getString("date", "Hari ini") ?: "Hari ini"
                val totalItems = widgetData.getInt("totalItems", 0)
                val totalActivities = widgetData.getInt("totalActivities", 0)
                val totalTasks = widgetData.getInt("totalTasks", 0)
                val isEmpty = widgetData.getBoolean("isEmpty", true)
                val lastUpdated = widgetData.getLong("lastUpdated", 0)
                
                Log.d("AturinAppHomeWidget", "Widget data: date=$date, items=$totalItems, activities=$totalActivities, tasks=$totalTasks, isEmpty=$isEmpty, lastUpdated=$lastUpdated")

                // Create combined display text for better visibility
                val displayText = if (isEmpty || totalItems == 0) {
                    "Aturin - $date\n\nTidak ada jadwal hari ini"
                } else {
                    "Aturin - $date\n\n$totalActivities aktivitas, $totalTasks tugas"
                }
                
                Log.d("AturinAppHomeWidget", "Display text: $displayText")

                // Update text view with all info
                views.setTextViewText(android.R.id.text1, displayText)
                
                // Force text colors and style to be very visible
                try {
                    views.setTextColor(android.R.id.text1, android.graphics.Color.BLACK)
                    views.setTextViewTextSize(android.R.id.text1, android.util.TypedValue.COMPLEX_UNIT_SP, 16f)
                    views.setInt(android.R.id.text1, "setBackgroundColor", android.graphics.Color.WHITE)
                    Log.d("AturinAppHomeWidget", "Text styling applied to ensure visibility")
                } catch (e: Exception) {
                    Log.e("AturinAppHomeWidget", "Error applying text styling: ${e.message}")
                }

                // Set a simple app launch intent - guaranteed to work
                try {
                    // Simple intent to launch the main app
                    val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                    
                    Log.d("AturinAppHomeWidget", "Creating simple app launch intent")
                    val pendingIntent = PendingIntent.getActivity(
                        context, 
                        0, 
                        launchIntent, 
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    
                    // Set click listener - just one text view to click
                    views.setOnClickPendingIntent(android.R.id.text1, pendingIntent)
                    
                    Log.d("AturinAppHomeWidget", "Widget click handler set up with app launch intent")
                } catch (e: Exception) {
                    Log.e("AturinAppHomeWidget", "Error setting click intent: ${e.message}")
                    e.printStackTrace()
                    // We don't need a fallback here since we're already using the simplest approach
                }

                Log.d("AturinAppHomeWidget", "Updating widget ID $appWidgetId with new content")
                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (e: Exception) {
                // Fallback to basic text widget if error occurs
                Log.e("AturinAppHomeWidget", "Error updating widget: ${e.message}")
                e.printStackTrace()
                
                val views = RemoteViews(context.packageName, android.R.layout.simple_list_item_1)
                views.setTextViewText(android.R.id.text1, "Aturin App\nWidget error - ${e.message}")
                
                try {
                    appWidgetManager.updateAppWidget(appWidgetId, views)
                } catch (e2: Exception) {
                    Log.e("AturinAppHomeWidget", "Failed even with fallback: ${e2.message}")
                }
            }
        }
    }
}
