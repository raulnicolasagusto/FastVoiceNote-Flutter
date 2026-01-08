package com.fastvoicenote.fast_voice_note

import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver

class NoteWidgetReceiver : HomeWidgetGlanceWidgetReceiver<NoteWidget>() {
    override val glanceAppWidget = NoteWidget()
}
