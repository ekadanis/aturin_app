package com.AturinJaya.pdbl

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.content.Intent
import android.app.PendingIntent
import android.util.Log
import es.antonborri.home_widget.HomeWidgetPlugin
import java.text.SimpleDateFormat
import java.util.*

/**
 * Aturin Calendar Home Widget - Modern & Simple
 * Clean design with calendar-style layout
 */
class AturinAppHomeWidget : AppWidgetProvider() {
    
    private val TAG = "AturinWidget"

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        Log.d(TAG, "onUpdate: Updating ${appWidgetIds.size} widgets")
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        Log.d(TAG, "Widget enabled for first time")
    }

    override fun onDisabled(context: Context) {
        Log.d(TAG, "Last widget removed")
    }

    companion object {
        fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            Log.d("AturinWidget", "Updating widget $appWidgetId")
            
            try {
                // Use our new calendar layout
                val views = RemoteViews(context.packageName, R.layout.aturin_widget_calendar)
                
                // Get current date
                val dateFormat = SimpleDateFormat("EEEE, d MMM", Locale("id", "ID"))
                val currentDate = dateFormat.format(Date())
                
                // Get data from Flutter (with safe defaults)
                var widgetData: android.content.SharedPreferences? = null
                try {
                    widgetData = HomeWidgetPlugin.getData(context)
                } catch (e: Exception) {
                    Log.e("AturinWidget", "Error getting data: ${e.message}")
                }

                val totalActivities = widgetData?.getInt("totalActivities", 0) ?: 0
                val totalTasks = widgetData?.getInt("totalTasks", 0) ?: 0
                val totalItems = totalActivities + totalTasks
                
                // Update date
                views.setTextViewText(R.id.widget_date, currentDate)
                
                if (totalItems == 0) {
                    // Show empty state
                    views.setViewVisibility(R.id.empty_container, android.view.View.VISIBLE)
                    views.setViewVisibility(R.id.schedule_container, android.view.View.GONE)
                    views.setTextViewText(R.id.widget_summary, "Tidak ada jadwal hari ini")
                    Log.d("AturinWidget", "Showing empty state")
                } else {
                    // Show schedule with REAL data from Flutter
                    views.setViewVisibility(R.id.empty_container, android.view.View.GONE)
                    views.setViewVisibility(R.id.schedule_container, android.view.View.VISIBLE)
                    
                    // Show REAL schedule items from Flutter
                    showRealSchedule(context, views)
                    
                    // Update summary
                    val summaryText = if (totalActivities > 0 && totalTasks > 0) {
                        "$totalActivities aktivitas • $totalTasks tugas"
                    } else if (totalActivities > 0) {
                        "$totalActivities aktivitas"
                    } else {
                        "$totalTasks tugas"
                    }
                    views.setTextViewText(R.id.widget_summary, summaryText)
                    Log.d("AturinWidget", "Showing schedule: $summaryText")
                }

                // Set click intent to open app
                setClickIntent(context, views)

                // Update widget
                appWidgetManager.updateAppWidget(appWidgetId, views)
                Log.d("AturinWidget", "Widget updated successfully")
                
            } catch (e: Exception) {
                Log.e("AturinWidget", "Error updating widget: ${e.message}")
                e.printStackTrace()
                
                // Simple fallback
                try {
                    val fallbackViews = RemoteViews(context.packageName, android.R.layout.simple_list_item_1)
                    fallbackViews.setTextViewText(android.R.id.text1, "Aturin Calendar\nTap to open app")
                    appWidgetManager.updateAppWidget(appWidgetId, fallbackViews)
                } catch (e2: Exception) {
                    Log.e("AturinWidget", "Fallback also failed: ${e2.message}")
                }
            }
        }
        
        private fun showRealSchedule(context: Context, views: RemoteViews) {
            Log.d("AturinWidget", "Loading REAL schedule data from Flutter")
            
            try {
                val widgetData = HomeWidgetPlugin.getData(context)
                Log.d("AturinWidget", "SharedPreferences data available: ${widgetData != null}")
                
                if (widgetData != null) {
                    // Debug: log all available data
                    Log.d("AturinWidget", "totalActivities: ${widgetData.getInt("totalActivities", -1)}")
                    Log.d("AturinWidget", "totalTasks: ${widgetData.getInt("totalTasks", -1)}")
                    Log.d("AturinWidget", "totalItems: ${widgetData.getInt("totalItems", -1)}")
                    
                    for (i in 1..3) {
                        val time = widgetData.getString("item_${i}_time", "")
                        val title = widgetData.getString("item_${i}_title", "")
                        val type = widgetData.getString("item_${i}_type", "")
                        Log.d("AturinWidget", "Raw data item_$i: time='$time', title='$title', type='$type'")
                    }
                }
                
                // Hide all items first
                for (i in 1..3) {
                    views.setViewVisibility(getItemId(i), android.view.View.GONE)
                }
                
                // Show real items from Flutter data
                var itemsShown = 0
                for (i in 1..3) {
                    val time = widgetData?.getString("item_${i}_time", "") ?: ""
                    val title = widgetData?.getString("item_${i}_title", "") ?: ""
                    val icon = widgetData?.getString("item_${i}_icon", "") ?: ""
                    val type = widgetData?.getString("item_${i}_type", "") ?: ""
                    
                    if (time.isNotEmpty() && title.isNotEmpty()) {
                        Log.d("AturinWidget", "Showing item $i: $time - $title ($type)")
                        
                        views.setViewVisibility(getItemId(i), android.view.View.VISIBLE)
                        views.setTextViewText(getItemTimeId(i), time)
                        views.setTextViewText(getItemTitleId(i), title)
                        views.setTextViewText(getItemIconId(i), icon.ifEmpty { 
                            if (type == "activity") "Aktivitas" else "Tugas" 
                        })
                        itemsShown++
                    }
                }
                
                Log.d("AturinWidget", "Total items shown: $itemsShown")
                
                // If no real data found, show placeholder message
                if (itemsShown == 0) {
                    Log.d("AturinWidget", "No real data found - showing placeholder")
                    views.setViewVisibility(getItemId(1), android.view.View.VISIBLE)
                    views.setTextViewText(getItemTimeId(1), "--:--")
                    views.setTextViewText(getItemTitleId(1), "No schedule data")
                    views.setTextViewText(getItemIconId(1), "📅")
                }
                
            } catch (e: Exception) {
                Log.e("AturinWidget", "Error loading real schedule data: ${e.message}")
                e.printStackTrace()
                // Show error message
                views.setViewVisibility(getItemId(1), android.view.View.VISIBLE)
                views.setTextViewText(getItemTimeId(1), "--:--")
                views.setTextViewText(getItemTitleId(1), "Error: ${e.message}")
                views.setTextViewText(getItemIconId(1), "⚠️")
            }
        }
        
        private fun setClickIntent(context: Context, views: RemoteViews) {
            try {
                val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                if (intent != null) {
                    // Set action untuk identifikasi dari widget
                    intent.action = "WIDGET_CLICKED"
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    
                    val pendingIntent = PendingIntent.getActivity(
                        context, 0, intent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    
                    // Set click pada seluruh widget
                    views.setOnClickPendingIntent(R.id.widget_date, pendingIntent)
                    views.setOnClickPendingIntent(R.id.widget_summary, pendingIntent)
                    
                    // Set click pada setiap item schedule jika ada
                    views.setOnClickPendingIntent(R.id.item_1, pendingIntent)
                    views.setOnClickPendingIntent(R.id.item_2, pendingIntent)
                    views.setOnClickPendingIntent(R.id.item_3, pendingIntent)
                    
                    Log.d("AturinWidget", "Click intent set successfully")
                }
            } catch (e: Exception) {
                Log.e("AturinWidget", "Error setting click intent: ${e.message}")
            }
        }
        
        private fun getItemId(itemNumber: Int): Int = when(itemNumber) {
            1 -> R.id.item_1
            2 -> R.id.item_2
            3 -> R.id.item_3
            else -> R.id.item_1
        }
        
        private fun getItemTimeId(itemNumber: Int): Int = when(itemNumber) {
            1 -> R.id.item_1_time
            2 -> R.id.item_2_time
            3 -> R.id.item_3_time
            else -> R.id.item_1_time
        }
        
        private fun getItemTitleId(itemNumber: Int): Int = when(itemNumber) {
            1 -> R.id.item_1_title
            2 -> R.id.item_2_title
            3 -> R.id.item_3_title
            else -> R.id.item_1_title
        }
        
        private fun getItemIconId(itemNumber: Int): Int = when(itemNumber) {
            1 -> R.id.item_1_icon
            2 -> R.id.item_2_icon
            3 -> R.id.item_3_icon
            else -> R.id.item_1_icon
        }
    }
    
    data class ScheduleItem(
        val time: String,
        val title: String,
        val icon: String,
        val type: String
    )
}
