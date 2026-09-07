package io.github.friesi23.mhabit

import org.junit.Assert.*
import org.junit.Test

class WidgetSnapshotOrderTest {
    @Test fun lateUiSnapshotCannotOverwriteCompletedBackgroundSnapshot() {
        val ui = WidgetSnapshotOrder.next()
        val worker = WidgetSnapshotOrder.next()
        assertTrue(WidgetSnapshotOrder.accept(worker))
        assertFalse(WidgetSnapshotOrder.accept(ui))
        assertTrue(WidgetSnapshotOrder.accept(WidgetSnapshotOrder.next()))
    }
    @Test fun concurrentEnginesReceiveDistinctOrderedTokens() {
        val values = java.util.Collections.synchronizedList(mutableListOf<Long>())
        val threads = (1..20).map { Thread { values.add(WidgetSnapshotOrder.next()) }.also { it.start() } }
        threads.forEach { it.join() }
        assertEquals(20, values.toSet().size)
        assertTrue(WidgetSnapshotOrder.accept(values.maxOrNull()!!))
        assertFalse(WidgetSnapshotOrder.accept(values.minOrNull()!!))
    }
}
