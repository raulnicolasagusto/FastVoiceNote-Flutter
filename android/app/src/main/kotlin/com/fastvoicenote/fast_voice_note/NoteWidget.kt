package com.fastvoicenote.fast_voice_note

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Column
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.padding
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.text.FontWeight
import androidx.glance.unit.ColorProvider
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition

class NoteWidget : GlanceAppWidget() {

    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            GlanceContent(context, currentState<HomeWidgetGlanceState>())
        }
    }

    @Composable
    private fun GlanceContent(context: Context, currentState: HomeWidgetGlanceState) {
        val prefs = currentState.preferences
        val title = prefs.getString("widget_title", "Fast Voice Note") ?: "Fast Voice Note"
        val content = prefs.getString("widget_content", "Tap to open") ?: "Tap to open"
        val colorHex = prefs.getString("widget_color", "FFFFFFFF") ?: "FFFFFFFF"
        
        // Parse color
        val backgroundColor = try {
            Color(android.graphics.Color.parseColor("#$colorHex"))
        } catch (e: Exception) {
            Color.White
        }

        Column(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(backgroundColor)
                .padding(16.dp),
            verticalAlignment = Alignment.Top,
            horizontalAlignment = Alignment.Start
        ) {
            // Title
            Text(
                text = title,
                style = TextStyle(
                    color = ColorProvider(Color.Black),
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold
                )
            )
            
            // Content
            Text(
                text = content,
                style = TextStyle(
                    color = ColorProvider(Color.Black.copy(alpha = 0.87f)),
                    fontSize = 14.sp
                ),
                modifier = GlanceModifier.padding(top = 8.dp)
            )
        }
    }
}
